package com.brockw.stickwar.engine.multiplayer
{
   import com.brockw.simulationSync.EndOfGameMove;
   import com.brockw.simulationSync.EndOfTurnMove;
   import com.brockw.simulationSync.Move;
   import com.brockw.stickwar.BaseMain;
   import com.brockw.stickwar.campaign.CampaignGameScreen;
   import com.brockw.stickwar.campaign.Level;
   import com.brockw.stickwar.campaign.controllers.CampaignTutorial;
   import com.brockw.stickwar.engine.multiplayer.moves.MoveFactory;
   import com.brockw.stickwar.engine.multiplayer.moves.PauseMove;
   import com.brockw.stickwar.engine.multiplayer.moves.ScreenPositionUpdateMove;
   import com.brockw.stickwar.engine.multiplayer.PostGameScreen;
   import com.brockw.stickwar.engine.units.Unit;
   import com.brockw.stickwar.stickwar2;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.setInterval;
   import flash.utils.clearInterval;

   public class CoopGameScreen extends CampaignGameScreen
   {
      public static var lanSocket:LanSocket;
      public static var gameSeed:int;
      public static var isHost:Boolean;

      private var _coopGameOver:Boolean;
      private var _coopSavedOnMessage:Function;
      private var _coopSavedOnClose:Function;
      private var _coopSavedOnError:Function;
      private var _coopMoveCounter:int;
      private var _localPaused:Boolean;
      private var _peerPaused:Boolean;
      private var _lastSelectionHash:String;
      private var _selectionSendCooldown:int;
      private var _coopPingInterval:int;

      public function CoopGameScreen(main:BaseMain)
      {
         super(main);
         this._coopGameOver = false;
         this._coopMoveCounter = 0;
         this._localPaused = false;
         this._peerPaused = false;
         this._lastSelectionHash = "";
          this._selectionSendCooldown = 0;
          this._coopPingInterval = 0;
       }

      override public function get isPaused() : Boolean
      {
         return this._localPaused && this._peerPaused;
      }

      override public function enter() : void
      {
         main.seed = gameSeed;
         var currentLevel:Level = main.campaign.getCurrentLevel();
         if(currentLevel.controller == CampaignTutorial)
         {
            currentLevel.controller = null;
         }
         super.enter();
         if(game != null && game.teamA != null)
         {
            game.teamA.spawnUnitGroup([Unit.U_MINER, Unit.U_MINER, Unit.U_MINER, Unit.U_MINER, Unit.U_SWORDWRATH, Unit.U_SWORDWRATH, Unit.U_SWORDWRATH, Unit.U_SWORDWRATH]);
            game.teamA.gold = 500;
         }
          if(lanSocket != null && lanSocket.connected)
          {
             this._coopSavedOnMessage = lanSocket.onMessage;
             this._coopSavedOnClose = lanSocket.onClose;
             this._coopSavedOnError = lanSocket.onError;
             lanSocket.onMessage = this.coopOnMessage;
             lanSocket.onClose = this.coopOnClose;
             this._coopPingInterval = setInterval(function():void
             {
                if(lanSocket != null && lanSocket.connected)
                {
                   lanSocket.send("PING");
                }
             }, 10000);
          }
       }

      override public function leave() : void
      {
         this.cleanUp();
      }

      override public function update(evt:Event, timeDiff:Number) : void
      {
         super.update(evt,timeDiff);
         this.updateTeammateSelection();
      }

      override public function endTurn() : void
      {
         simulation.endOfTurnMove = new EndOfTurnMove();
         simulation.endOfTurnMove.expectedNumberOfMoves = this.simulation.movesInTurn;
         simulation.endOfTurnMove.frameRate = simulation.frameRate;
         simulation.endOfTurnMove.turnSize = 5;
         simulation.endOfTurnMove.turn = simulation.turn;
         simulation.processMove(simulation.endOfTurnMove);
         simulation.movesInTurn = 0;
      }

      override public function doMove(move:Move, id:int) : void
      {
         if(move is PauseMove)
         {
            this._localPaused = !this._localPaused;
            if(lanSocket != null && lanSocket.connected)
            {
               lanSocket.send("DATA|COOP_PAUSE|" + (this._localPaused ? "1" : "0"));
            }
            return;
         }
         move.init(id,simulation.frame,simulation.turn);
         move.position = this._coopMoveCounter++ * 2 + (isHost ? 0 : 1);
         simulation.processMove(move);
         ++simulation.movesInTurn;
          if(lanSocket != null && lanSocket.connected && id == this.team.id && !(move is ScreenPositionUpdateMove))
          {
             lanSocket.send("DATA|MOVE|" + move.toString());
          }
      }

      override public function endGame() : void
      {
         if(this._coopGameOver)
         {
            return;
         }
         this._coopGameOver = true;
         if(lanSocket != null && lanSocket.connected)
         {
            lanSocket.send("DATA|COOP_GAME_OVER");
         }
         var playedLevel:* = main.campaign.getCurrentLevel();
         var wasReplay:Boolean = main.campaign.isReplay;
         gameTimer.removeEventListener(TimerEvent.TIMER,updateGameLoop);
         gameTimer.stop();
         var e:EndOfGameMove = new EndOfGameMove();
         e.winner = game.winner.id;
         e.turn = simulation.turn;
         simulation.processMove(e);
         if(main is stickwar2 && main.tracker != null)
         {
            if(e.winner == team.id)
            {
               main.tracker.trackEvent(main.campaign.getLevelDescription(),"finish","win",game.economyRecords.length);
            }
            else
            {
               main.tracker.trackEvent(main.campaign.getLevelDescription(),"finish","lose",game.economyRecords.length);
            }
         }
         main.postGameScreen.setWinner(e.winner,team.type,playedLevel.player.raceName,playedLevel.oponent.raceName,team.id);
         main.postGameScreen.setRecords(game.economyRecords,game.militaryRecords);
         if(isHost && e.winner == team.id && !wasReplay)
         {
            main.campaign.campaignPoints += this.getCampaignPointReward(playedLevel);
            if(playedLevel.controller == com.brockw.stickwar.campaign.controllers.CampaignCutScene2 || main.campaign.currentLevel >= main.campaign.levels.length - 1)
            {
               main.campaign.currentLevel = main.campaign.levels.length;
            }
            else
            {
               ++main.campaign.currentLevel;
            }
         }
         if(isHost && !wasReplay && !main.campaign.isGameFinished() && e.winner == team.id)
         {
            for each(var u:int in main.campaign.getCurrentLevel().unlocks)
            {
               main.postGameScreen.appendUnitUnlocked(u,game);
            }
         }
         if(e.winner == team.id && !wasReplay)
         {
            main.postGameScreen.showNextUnitUnlocked();
         }
         main.postGameScreen.setMode(PostGameScreen.M_CAMPAIGN,wasReplay);
         if(e.winner == team.id)
         {
            main.postGameScreen.setTipText("");
         }
         else
         {
            main.postGameScreen.setTipText(playedLevel.tip);
         }
         main.showScreen("postGame",false,true);
      }

      override public function cleanUp() : void
      {
         super.cleanUp();
         if(this._coopPingInterval != 0)
         {
            clearInterval(this._coopPingInterval);
            this._coopPingInterval = 0;
         }
         if(lanSocket != null)
         {
            if(this._coopSavedOnMessage != null)
            {
               lanSocket.onMessage = this._coopSavedOnMessage;
               lanSocket.onClose = this._coopSavedOnClose;
               lanSocket.onError = this._coopSavedOnError;
            }
            this._coopSavedOnMessage = null;
            this._coopSavedOnClose = null;
            this._coopSavedOnError = null;
         }
      }

      private function updateTeammateSelection() : void
      {
         if(this._selectionSendCooldown > 0)
         {
            --this._selectionSendCooldown;
            return;
         }
         if(userInterface == null || userInterface.selectedUnits == null)
         {
            return;
         }
         var selected:Array = userInterface.selectedUnits.selected;
         if(selected.length == 0)
         {
            if(this._lastSelectionHash != "")
            {
               this._lastSelectionHash = "";
               if(lanSocket != null && lanSocket.connected)
               {
                  lanSocket.send("DATA|COOP_SELECT|");
               }
            }
            return;
         }
         var ids:Array = [];
         for each(var unit:Unit in selected)
         {
            ids.push(unit.id);
         }
         var hash:String = ids.join("|");
         if(hash != this._lastSelectionHash)
         {
            this._lastSelectionHash = hash;
            if(lanSocket != null && lanSocket.connected)
            {
               lanSocket.send("DATA|COOP_SELECT|" + hash);
            }
            this._selectionSendCooldown = 3;
         }
      }

      public function coopOnMessage(msg:String) : void
      {
         if(msg.indexOf("MOVE|") == 0)
         {
            var moveString:String = msg.substr(5);
            var parts:Array = moveString.split(" ");
            var type:int = int(parts[3]);
            var move:Move = MoveFactory.createMoveFromString(type,parts);
             if(move != null)
             {
                try
                {
                   this.simulation.processMove(move);
                   if(move.turn == this.simulation.turn)
                   {
                      ++this.simulation.movesInTurn;
                   }
                }
                catch(e:Error)
                {
                }
             }
         }
         else if(msg == "COOP_GAME_OVER")
         {
            if(!this._coopGameOver)
            {
               this.endGame();
            }
         }
         else if(msg.indexOf("COOP_PAUSE|") == 0)
         {
            var pauseParts:Array = msg.split("|");
            this._peerPaused = pauseParts[1] == "1";
         }
         else if(msg.indexOf("COOP_SELECT|") == 0)
         {
            if(game == null || game.teamA == null || game.teamA.units == null)
            {
               return;
            }
            var selectStr:String = msg.substr(12);
            for each(var unit:Unit in game.teamA.units)
            {
               unit.teammateSelected = false;
            }
            if(selectStr.length > 0)
            {
               var unitIds:Array = selectStr.split("|");
               for each(var idStr:String in unitIds)
               {
                  var unitId:int = int(idStr);
                  if(game.teamA.units[unitId] != null)
                  {
                     game.teamA.units[unitId].teammateSelected = true;
                  }
               }
            }
         }
         else if(msg == "HOST_DISCONNECTED" || msg == "CLIENT_DISCONNECTED")
         {
            if(!this._coopGameOver)
            {
               this.coopOnClose();
            }
         }
      }

      public function coopOnClose():void
      {
         this._coopSavedOnMessage = null;
         this._coopSavedOnClose = null;
         this._coopSavedOnError = null;
         main.showScreen("coopScreen", false, true);
      }
   }
}
