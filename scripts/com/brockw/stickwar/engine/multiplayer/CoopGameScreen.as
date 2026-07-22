package com.brockw.stickwar.engine.multiplayer
{
    import com.brockw.simulationSync.EndOfGameMove;
    import com.brockw.simulationSync.EndOfTurnMove;
    import com.brockw.simulationSync.Move;
    import com.brockw.stickwar.BaseMain;
    import com.brockw.stickwar.campaign.CampaignGameScreen;
    import com.brockw.stickwar.campaign.Level;
    import com.brockw.stickwar.campaign.controllers.CampaignTutorial;
    import com.brockw.stickwar.engine.Team.Team;
    import com.brockw.stickwar.engine.multiplayer.moves.MoveFactory;
    import com.brockw.stickwar.engine.multiplayer.moves.ScreenPositionUpdateMove;
    import com.brockw.stickwar.engine.multiplayer.PostGameScreen;
    import com.brockw.stickwar.engine.units.Unit;
    import com.brockw.stickwar.stickwar2;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.text.TextField;
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

        private var _isInTutorialPhase:Boolean;
        private var _localTutorialDone:Boolean;
        private var _peerTutorialDone:Boolean;
        private var _isWaitingForPeer:Boolean;
        private var _tutorialComplete:Boolean;
        private var _waitingOverlay:Sprite;
        private var _syncedStartFrames:int;
        private var _syncedStartOverlay:Sprite;
         private var _cleanedUp:Boolean;

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

            this._isInTutorialPhase = false;
            this._localTutorialDone = false;
            this._peerTutorialDone = false;
            this._isWaitingForPeer = false;
            this._tutorialComplete = false;
            this._waitingOverlay = null;
            this._syncedStartFrames = 0;
            this._syncedStartOverlay = null;
             this._cleanedUp = false;
        }

       override public function get isPaused() : Boolean
       {
          return this._localPaused && this._peerPaused;
       }

       override public function set isPaused(value:Boolean) : void
       {
          if(this._localPaused == value) return;
          this._localPaused = value;
          if(lanSocket != null && lanSocket.connected)
          {
             lanSocket.send("DATA|COOP_PAUSE|" + (value ? "1" : "0"));
          }
           if(game != null) game.setPaused(value);
        }

        override public function set isFastForward(value:Boolean) : void
        {
           if(super.isFastForward == value) return;
           super.isFastForward = value;
           if(lanSocket != null && lanSocket.connected)
           {
              lanSocket.send("DATA|COOP_FF|" + (value ? "1" : "0"));
           }
        }

        override public function enter() : void
       {
          _cleanedUp = false;
          var currentLevel:Level = main.campaign.getCurrentLevel();
          if(!_tutorialComplete && currentLevel.controller == CampaignTutorial)
          {
             _isInTutorialPhase = true;
          }
          else
          {
             _isInTutorialPhase = false;
             if(currentLevel.controller == CampaignTutorial)
             {
                currentLevel.controller = null;
             }
          }
          if(_tutorialComplete)
          {
             main.seed = gameSeed;
          }
          super.enter();
          if(game != null && game.teamA != null)
          {
             if(!_tutorialComplete)
             {
                game.teamA.spawnUnitGroup([Unit.U_MINER, Unit.U_MINER, Unit.U_MINER, Unit.U_MINER, Unit.U_SWORDWRATH, Unit.U_SWORDWRATH, Unit.U_SWORDWRATH, Unit.U_SWORDWRATH]);
                game.teamA.gold = 500;
             }
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
           if(!_isInTutorialPhase) this.updateTeammateSelection();
           if(_isInTutorialPhase && !_isWaitingForPeer)
           {
              if(!_localTutorialDone && controller != null && controller is CampaignTutorial)
              {
                 if(CampaignTutorial(controller).isTutorialComplete())
                 {
                    _localTutorialDone = true;
                    if(lanSocket != null && lanSocket.connected)
                    {
                       lanSocket.send("DATA|COOP_TUTORIAL_DONE");
                    }
                    showWaitingOverlay();
                  }
              }
              if(!_isWaitingForPeer && _localTutorialDone && _peerTutorialDone)
              {
                 _isWaitingForPeer = true;
              }
           }
            if(_isWaitingForPeer && _localTutorialDone && _peerTutorialDone)
            {
               _isWaitingForPeer = false;
               _localTutorialDone = false;
               _peerTutorialDone = false;
               _tutorialComplete = true;
               startSyncedGame();
            }
            if(_syncedStartFrames > 0)
            {
               _syncedStartFrames--;
               if(_syncedStartFrames == 0 && _isInTutorialPhase)
               {
                  removeSyncedStartText();
                  _isInTutorialPhase = false;
               }
            }
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
          move.init(id,simulation.frame,simulation.turn);
         move.position = this._coopMoveCounter++ * 2 + (isHost ? 0 : 1);
         simulation.processMove(move);
         ++simulation.movesInTurn;
           if(!_isInTutorialPhase && lanSocket != null && lanSocket.connected && id == this.team.id && !(move is ScreenPositionUpdateMove))
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
           if(_cleanedUp) return;
           _cleanedUp = true;
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
            removeWaitingOverlay();
            removeSyncedStartText();
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
             if(_isInTutorialPhase) return;
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
                    move.execute(this.game);
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
          else if(msg.indexOf("COOP_FF|") == 0)
          {
             var ffParts:Array = msg.split("|");
             super.isFastForward = ffParts[1] == "1";
          }
           else if(msg.indexOf("COOP_SELECT|") == 0)
          {
             if(_isInTutorialPhase) return;
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
                    var targetUnit:Unit = game.units[unitId] as Unit;
                   if(targetUnit != null && targetUnit.team == game.teamA)
                   {
                      targetUnit.teammateSelected = true;
                   }
                }
            }
         }
            else if(msg == "COOP_TUTORIAL_DONE")
            {
               _peerTutorialDone = true;
            }
           else if(msg == "COOP_QUIT")
          {
             if(lanSocket != null)
             {
                lanSocket.close();
             }
             lanSocket = null;
             main.showScreen("coopScreen", false, true);
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
          lanSocket = null;
          main.showScreen("coopScreen", false, true);
       }

        private function showWaitingOverlay():void
        {
           if(_waitingOverlay == null)
           {
              _waitingOverlay = new Sprite();
              _waitingOverlay.graphics.beginFill(0, 1);
              _waitingOverlay.graphics.drawRect(0, 0, 2000, 2000);
              var tf:TextField = new TextField();
              tf.textColor = 0xFFFFFF;
              tf.text = "Waiting for other player...";
               tf.x = 325;
               tf.y = 350;
               tf.width = 200;
              _waitingOverlay.addChild(tf);
           }
           if(!contains(_waitingOverlay))
           {
              addChild(_waitingOverlay);
           }
        }

        private function removeWaitingOverlay():void
        {
           if(_waitingOverlay != null && contains(_waitingOverlay))
           {
              removeChild(_waitingOverlay);
           }
           _waitingOverlay = null;
        }

        private function cleanUpGameState():void
        {
           if(game == null) return;
           if(controller != null && controller is CampaignTutorial)
           {
              controller = null;
           }
           game.teamA.cleanUpUnits();
           game.teamB.cleanUpUnits();
           game.teamA.gold = 0;
           game.teamA.mana = 0;
           game.teamB.gold = 0;
           game.teamB.mana = 0;
           this.doAiUpdates = false;
        }

        private function startSyncedGame():void
        {
           removeWaitingOverlay();
           var currentLevel:Level = main.campaign.getCurrentLevel();
           currentLevel.controller = null;
           cleanUpGameState();
           main.seed = gameSeed;
           if(game != null)
           {
              game.teamA.spawnUnitGroup(currentLevel.player.startingUnits);
              game.teamA.gold = currentLevel.player.gold;
              game.teamA.mana = currentLevel.player.mana;
              game.teamB.spawnUnitGroup(currentLevel.oponent.startingUnits);
              game.teamB.gold = currentLevel.oponent.gold;
              game.teamB.mana = currentLevel.oponent.mana;
              game.teamB.currentAttackState = Team.G_ATTACK;
           }
           this.doAiUpdates = true;
           this._coopMoveCounter = 0;
           showSyncedStartText();
           _syncedStartFrames = 150;
        }

        private function showSyncedStartText():void
        {
           if(_syncedStartOverlay == null)
           {
              _syncedStartOverlay = new Sprite();
              _syncedStartOverlay.graphics.beginFill(0, 0.7);
              _syncedStartOverlay.graphics.drawRect(0, 0, 2000, 2000);
              var tf:TextField = new TextField();
              tf.textColor = 0xFFFFFF;
              tf.text = "Your objective is to destroy the enemy statue\nbefore they destroy yours. Good luck.";
               tf.x = 225;
               tf.y = 300;
              tf.width = 400;
              tf.height = 100;
              _syncedStartOverlay.addChild(tf);
           }
           if(!contains(_syncedStartOverlay))
           {
              addChild(_syncedStartOverlay);
           }
        }

        private function removeSyncedStartText():void
        {
           if(_syncedStartOverlay != null && contains(_syncedStartOverlay))
           {
              removeChild(_syncedStartOverlay);
           }
           _syncedStartOverlay = null;
        }
    }
}
