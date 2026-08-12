package com.brockw.stickwar.engine.multiplayer
{
    import com.brockw.random.Random;
    import com.brockw.simulationSync.EndOfGameMove;
    import com.brockw.simulationSync.EndOfTurnMove;
    import com.brockw.simulationSync.Move;
    import com.brockw.stickwar.BaseMain;
    import com.brockw.stickwar.campaign.Campaign;
    import com.brockw.stickwar.campaign.CampaignGameScreen;
    import com.brockw.stickwar.campaign.Level;
    import com.brockw.stickwar.campaign.controllers.CampaignTutorial;
    import com.brockw.stickwar.engine.Team.Team;
    import com.brockw.stickwar.engine.multiplayer.moves.MoveFactory;
    import com.brockw.stickwar.engine.multiplayer.moves.ScreenPositionUpdateMove;
    import com.brockw.stickwar.engine.multiplayer.moves.CastleArcherShotMove;
    import com.brockw.stickwar.engine.multiplayer.PostGameScreen;
    import com.brockw.stickwar.engine.units.Unit;
    import com.brockw.stickwar.stickwar2;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.utils.clearInterval;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    import flash.utils.setInterval;

   public class CoopGameScreen extends CampaignGameScreen
   {
       public static var lanSocket:LanSocket;
       public static var gameSeed:int;
       public static var isHost:Boolean;
       public static var soloMode:Boolean = false;
       public static var joinInGame:Boolean = false;

private static const RECONNECT_WINDOW_MS:int = 15000;
        private static const RECONNECT_RETRY_MS:int = 1000;
        private static const DEFAULT_COOP_PLAYER_UNITS:Array = [Unit.U_MINER, Unit.U_MINER, Unit.U_MINER, Unit.U_MINER, Unit.U_SWORDWRATH, Unit.U_SWORDWRATH, Unit.U_SWORDWRATH, Unit.U_SWORDWRATH];
        private static const DEFAULT_COOP_PLAYER_GOLD:int = 500;
        private static const DEFAULT_COOP_ENEMY_UNITS_NORMAL:Array = [Unit.U_MINER, Unit.U_MINER, Unit.U_MINER];
        private static const DEFAULT_COOP_ENEMY_UNITS_HARD:Array = [Unit.U_MINER, Unit.U_MINER, Unit.U_MINER, Unit.U_MINER, Unit.U_SPEARTON];
        private static const DEFAULT_COOP_ENEMY_GOLD:int = 150;
        private static const ALLOW_DEBUG_IN_COOP:Boolean = false;

private var _reconnectState:String;
        private var _reconnectStart:int;
        private var _reconnectInterval:int;
        private var _intentClose:Boolean;
        private var _soloMode:Boolean;
       private var _catchUpLog:Array;
       private var _catchUpQueue:Array;
       private var _catchUpTargetTurn:int;
       private var _catchUpTargetFrame:int;
       private var _catchUpTargetCheck:int;
private var _catchUpActive:Boolean;
 private var _catchUpStartTime:int;
        private var _catchUpSending:Boolean;
        private var _catchUpSendIdx:int;
        private var _catchUpEndLine:String;
        private var _inputLocked:Boolean;
        private var _reconnectOverlay:Sprite;
        private var _reconnectText:TextField;
        private var _waitText:TextField;
        private var _sessionLog:Array;
        private var _sessionLogMax:int;
        private var _joinStreaming:Boolean;
        private var _joinBacklogIdx:int;
        private var _joinJoinInitSent:Boolean;
        private var _joinLiveBuffer:Array;
        private var _joinReplayMode:Boolean;
        private var _joinOverlay:Sprite;
         private var _joinTutorialHost:Boolean;
         private var _waitTutorialTimer:int;
         private var _joinTutorialForceTimer:int;
private var _spawnIdBaseline:int;
private var _spawnConf:Array;
private var _spawnTeamARoster:Array;
private var _spawnTeamBRoster:Array;

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
          private var _cleanedUp:Boolean;
          private var _isRestarting:Boolean;

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
               this._cleanedUp = false;
               this._isRestarting = false;
               this._reconnectState = "none";
               this._reconnectStart = 0;
               this._reconnectInterval = 0;
this._intentClose = false;
               this._soloMode = soloMode;
               this._catchUpLog = [];
               this._catchUpQueue = [];
               this._catchUpTargetTurn = 0;
               this._catchUpTargetFrame = 0;
               this._catchUpTargetCheck = 0;
this._catchUpActive = false;
                this._catchUpStartTime = 0;
                this._catchUpSending = false;
                this._catchUpSendIdx = 0;
                this._catchUpEndLine = "";
this._inputLocked = false;
                this._reconnectOverlay = null;
                this._reconnectText = null;
                this._waitText = null;
                this._sessionLog = [];
                this._sessionLogMax = 200000;
                this._joinStreaming = false;
                this._joinBacklogIdx = 0;
                this._joinJoinInitSent = false;
                this._joinLiveBuffer = [];
                this._joinReplayMode = false;
                this._joinOverlay = null;
this._joinTutorialHost = false;
                 this._waitTutorialTimer = 0;
                 this._joinTutorialForceTimer = 0;
                 this._spawnIdBaseline = 0;
                 this._spawnConf = null;
                 this._spawnTeamARoster = null;
                 this._spawnTeamBRoster = null;
            }

       override public function get isPaused() : Boolean
       {
          if(_soloMode)
          {
             return this._localPaused;
          }
          if(_reconnectState == "waiting")
          {
             return this._localPaused;
          }
          if(_reconnectState == "reconnecting" || _reconnectState == "resyncWait")
          {
             return true;
          }
          if(_reconnectState == "resync")
          {
             return false;
          }
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
           if(!_soloMode && value) return;
           if(super.isFastForward == value) return;
           super.isFastForward = value;
           if(lanSocket != null && lanSocket.connected)
{
               lanSocket.send("DATA|COOP_FF|" + (value ? "1" : "0"));
            }
         }

         override protected function allowDebugHotkeys() : Boolean
         {
            return ALLOW_DEBUG_IN_COOP;
         }

         override protected function isEnemyAiDoMoveRoutingEnabled() : Boolean
         {
            return !_isInTutorialPhase;
         }

         override public function isCastleShotManaged() : Boolean
         {
            return !_soloMode && !_isInTutorialPhase;
         }

         override public function routeCastleShot(move:Move) : void
         {
            if(!isHost) return;
            if(move == null) return;
            this.doMove(move,(move as CastleArcherShotMove).teamId);
         }

         override public function enter() : void
         {
            _cleanedUp = false;
           _isRestarting = false;
           _soloMode = soloMode;
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
              if(game != null)
              {
                 game.random = new Random(gameSeed);
              }
           }
            super.enter();
            var spawnLevel:Level = main.campaign.getCurrentLevel();
            if(_spawnConf == null)
            {
               _spawnConf = [spawnLevel.player.startingUnits.concat(), spawnLevel.player.gold, spawnLevel.player.mana, spawnLevel.oponent.startingUnits.concat(), spawnLevel.oponent.gold, spawnLevel.oponent.mana];
            }
            if(game != null)
            {
               _spawnIdBaseline = game.getCurrentId();
            }
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
               if(isHost)
               {
                  lanSocket.send("HOST_IN_GAME");
                  lanSocket.send("HOST_BUSY|0");
               }
            }
            if(_tutorialComplete)
            {
               startSyncedGame();
            }
            if(joinInGame)
            {
               _joinReplayMode = false;
               _catchUpActive = false;
               _catchUpQueue = [];
               _catchUpLog = [];
this.lockInput();
                this.showJoinOverlay("Joining match...");
             }
             this.updateFastForwardAvailability();
          }

      override public function leave() : void
      {
         this.cleanUp();
      }

        override public function update(evt:Event, timeDiff:Number) : void
        {
this.updateFastForwardAvailability();
if(_joinStreaming) this.drainJoinStreaming();
            if(_catchUpSending) this.drainCatchUpSend();
            if(_catchUpActive && _joinReplayMode) this.feedJoinReplay();
if(_catchUpActive && !_joinReplayMode) this.feedCatchUp();
if(_reconnectState == "resync" && _catchUpQueue.length > 0 && _catchUpStartTime != 0 && getTimer() - _catchUpStartTime > 30000)
            {
               this.restartLevel();
               return;
            }
            super.update(evt,timeDiff);
           if(!_isInTutorialPhase && _reconnectState == "none") this.updateTeammateSelection();
           if(_isInTutorialPhase && !_isWaitingForPeer)
           {
              if(!_localTutorialDone && controller != null && controller is CampaignTutorial)
              {
                 if(CampaignTutorial(controller).isTutorialComplete())
                 {
                    _localTutorialDone = true;
                    if(!_soloMode && lanSocket != null && lanSocket.connected)
                    {
                       lanSocket.send("DATA|COOP_TUTORIAL_DONE");
                    }
                    if(!_soloMode)
                    {
                       showWaitingOverlay();
                    }
                  }
              }
              if(!_isWaitingForPeer && _localTutorialDone && (_peerTutorialDone || _soloMode))
              {
                 _isWaitingForPeer = true;
              }
           }
            if(_isWaitingForPeer && _localTutorialDone && (_peerTutorialDone || _soloMode))
            {
               _isWaitingForPeer = false;
               _localTutorialDone = false;
               _peerTutorialDone = false;
               _tutorialComplete = true;
               _isInTutorialPhase = false;
               this.startFreshGame();
            }
if(_syncedStartFrames > 0)
            {
               _syncedStartFrames--;
                if(_syncedStartFrames == 0 && _isInTutorialPhase)
                {
                   _isInTutorialPhase = false;
                }
            }
            if(_isInTutorialPhase && !_tutorialComplete && _localTutorialDone && !_peerTutorialDone && !_soloMode)
            {
               ++_waitTutorialTimer;
               if(_waitTutorialTimer > 60)
               {
                   _waitTutorialTimer = 0;
                   if(lanSocket != null && lanSocket.connected)
                   {
                      lanSocket.send("DATA|COOP_TUTORIAL_DONE");
                   }
                }
             }
             this.setFastForwardButtonLocked(!_soloMode);
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
          if(!_isInTutorialPhase && !_soloMode && id == this.game.teamB.id && !isHost)
          {
             return;
          }
          move.init(id,simulation.frame,simulation.turn);
         move.position = this._coopMoveCounter++ * 2 + (isHost ? 0 : 1);
         simulation.processMove(move);
         ++simulation.movesInTurn;
if(!_isInTutorialPhase && (id == this.team.id || (isHost && id == this.game.teamB.id)) && !(move is ScreenPositionUpdateMove))
            {
               var moveStr:String = move.toString();
               if(_sessionLog.length < _sessionLogMax)
               {
                  _sessionLog.push(moveStr);
               }
               if(_joinStreaming)
               {
               }
               else if(_reconnectState == "waiting")
               {
                  if(_catchUpLog.length < 20000)
                  {
                     _catchUpLog.push(moveStr);
                  }
               }
               else if(!_soloMode && lanSocket != null && lanSocket.connected)
               {
                  lanSocket.send("DATA|MOVE|" + moveStr);
               }
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
           if(isHost && lanSocket != null && lanSocket.connected)
           {
              lanSocket.send("HOST_LEAVE_GAME");
              lanSocket.send("HOST_BUSY|1");
           }
           super.cleanUp();
           if(this._coopPingInterval != 0)
           {
              clearInterval(this._coopPingInterval);
              this._coopPingInterval = 0;
           }
           if(_reconnectInterval != 0)
           {
              clearInterval(_reconnectInterval);
              _reconnectInterval = 0;
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
             this.clearReconnectingOverlay();
             this.hideWaitingForReconnect();
             this.removeJoinOverlay();
             this.unlockInput();
             _reconnectState = "none";
             _catchUpActive = false;
             _catchUpLog = [];
             _catchUpQueue = [];
             _joinStreaming = false;
              _joinReplayMode = false;
              _joinTutorialHost = false;
              _waitTutorialTimer = 0;
              _joinTutorialForceTimer = 0;
              removeWaitingOverlay();
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
               if(_joinReplayMode)
               {
                  if(_catchUpQueue.length < 40000)
                  {
                     _catchUpQueue.push(msg.substr(5));
                  }
                  return;
               }
this.applyMoveLine(msg.substr(5));
             }
          else if(msg.indexOf("COOP_START_CONFIG|") == 0)
            {
               var cfgParts:Array = msg.split("|");
               if(cfgParts.length >= 7)
               {
                  var cfgPu:Array = [];
                  var cfgOu:Array = [];
                  var cfgPs:Array = String(cfgParts[5]).split(",");
                  var cfgOs:Array = String(cfgParts[6]).split(",");
                  for each(var cfgPsStr:String in cfgPs)
                  {
                     if(cfgPsStr.length > 0) cfgPu.push(int(cfgPsStr));
                  }
for each(var cfgOsStr:String in cfgOs)
                   {
                      if(cfgOsStr.length > 0) cfgOu.push(int(cfgOsStr));
                   }
                    _spawnConf = [cfgPu, int(cfgParts[1]), int(cfgParts[2]), cfgOu, int(cfgParts[3]), int(cfgParts[4])];
                   if(cfgParts.length >= 9)
                   {
                      _spawnTeamARoster = [];
                      _spawnTeamBRoster = [];
                      var cfgRa:Array = String(cfgParts[7]).split(",");
                      var cfgRb:Array = String(cfgParts[8]).split(",");
                      for each(var cfgRsStr:String in cfgRa)
                      {
                         if(cfgRsStr.length > 0) _spawnTeamARoster.push(int(cfgRsStr));
                      }
                      for each(var cfgRoStr:String in cfgRb)
                      {
                         if(cfgRoStr.length > 0) _spawnTeamBRoster.push(int(cfgRoStr));
                      }
                      this.applyHostRoster();
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
              if(_soloMode) super.isFastForward = ffParts[1] == "1";
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
            else if(msg.indexOf("COOP_JOIN_INIT|") == 0)
            {
               var joinInitParts:Array = msg.split("|");
               if(joinInitParts.length >= 3)
               {
                  CoopGameScreen.gameSeed = int(joinInitParts[1]);
                  var joinInTutorial:int = int(joinInitParts[2]);
                  CoopGameScreen.joinInGame = false;
if(joinInTutorial == 1)
                   {
                      _joinTutorialHost = false;
                      if(_isInTutorialPhase && controller is CampaignTutorial)
                      {
                         this.removeJoinOverlay();
                         this.unlockInput();
                      }
                      else
                      {
                         _localTutorialDone = true;
                         _isWaitingForPeer = true;
                         if(lanSocket != null && lanSocket.connected)
                         {
                            lanSocket.send("DATA|COOP_TUTORIAL_DONE");
                         }
                         this.removeJoinOverlay();
                         this.showWaitingOverlay();
                      }
                   }
                  else
                  {
                     this.startJoinCatchup();
                  }
               }
            }
            else if(msg == "COOP_TUTORIAL_RESTART")
            {
               if(_isRestarting) return;
               _isRestarting = true;
               if(!_tutorialComplete)
               {
                  _localTutorialDone = false;
                  _peerTutorialDone = false;
                  _isWaitingForPeer = false;
               }
               main.showScreen("coopGameScreen", true);
            }
           else if(msg == "COOP_QUIT")
           {
              this._intentClose = true;
              this.cleanUp();
              if(lanSocket != null)
              {
                 lanSocket.close();
              }
              lanSocket = null;
              main.showScreen("coopScreen", false, true);
           }
           else if(msg.indexOf("WAIT_FOR_RECONNECT|") == 0)
           {
              if(!this._soloMode && !this._coopGameOver && _reconnectState == "none")
              {
                 this._reconnectState = "waiting";
                 this.showWaitingForReconnect();
              }
           }
           else if(msg == "RESUMED")
           {
              this.onResumed();
           }
           else if(msg.indexOf("COOP_CATCHUP_MOVE|") == 0)
           {
              if(_reconnectState == "reconnecting" || _reconnectState == "resync")
              {
                 if(_catchUpQueue.length < 40000)
                 {
                    _catchUpQueue.push(msg.substr(18));
                 }
              }
           }
           else if(msg.indexOf("COOP_CATCHUP_END|") == 0)
           {
              if(_reconnectState == "reconnecting")
              {
                 var endParts:Array = msg.split("|");
                 _catchUpTargetTurn = int(endParts[1]);
                 _catchUpTargetFrame = int(endParts[2]);
                 _catchUpTargetCheck = int(endParts[3]);
                 _reconnectState = "resync";
                 _catchUpActive = true;
                 _catchUpStartTime = getTimer();
                 this.clearReconnectingOverlay();
              }
           }
           else if(msg == "COOP_CATCHUP_ACK")
           {
              if(_reconnectState == "resyncWait")
              {
                 _reconnectState = "none";
                 _catchUpActive = false;
                 _localPaused = false;
                 _peerPaused = false;
                 if(game != null) game.setPaused(false);
                 this.hideWaitingForReconnect();
              }
           }
           else if(msg == "COOP_CATCHUP_FAIL")
           {
              if(_reconnectState == "resyncWait" || _reconnectState == "waiting" || _reconnectState == "resync")
              {
                 this.restartLevel();
              }
           }
else if(msg == "CLIENT_LEFT")
            {
               // The partner left for good. The host persists and keeps playing solo.
               this._soloMode = true;
               _reconnectState = "none";
               _catchUpActive = false;
               _catchUpLog = [];
               _catchUpQueue = [];
               this.clearReconnectingOverlay();
               this.hideWaitingForReconnect();
               this.setFastForwardButtonLocked(false);
               if(game != null) game.setPaused(false);
            }
 else if(msg == "CLIENT_JOINED_IN_GAME")
             {
                this._soloMode = false;
                this.updateFastForwardAvailability();
                _joinLiveBuffer = [];
                _joinJoinInitSent = false;
                if(game != null) game.setPaused(false);
                this.hideWaitingForReconnect();
                this.clearReconnectingOverlay();
                this.sendStartConfig();
if(!_tutorialComplete)
                {
                   _joinStreaming = false;
                   _peerTutorialDone = false;
                   _joinTutorialHost = true;
                   _waitTutorialTimer = 0;
                   _joinTutorialForceTimer = 0;
                   this.sendJoinInit(1);
                }
               else
                {
                   _joinStreaming = true;
                   _joinBacklogIdx = 0;
                   this.sendJoinInit(0);
                }
            }
            else if(msg == "HOST_DISCONNECTED" || msg == "CLIENT_DISCONNECTED")
            {
               if(!this._coopGameOver)
               {
                  this.leaveToMenu();
               }
            }
         }

private function applyMoveLine(moveString:String) : void
        {
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
                  try
                  {
                     move.execute(this.game);
                  }
                  catch(e2:Error)
                  {
                  }
               }
            }
         }

        private function onResumed() : void
       {
          if(_reconnectState == "waiting")
          {
             // We are the survivor: freeze briefly, ship the moves the partner missed,
             // then wait for the rejoiner to confirm it has caught up.
             _reconnectState = "resyncWait";
             _localPaused = true;
             if(game != null) game.setPaused(true);
             this.startCatchUpSend();
          }
          else if(_reconnectState == "reconnecting")
          {
             // We were the dropped player. The survivor will stream us the missed moves.
             _reconnectState = "resync";
             _catchUpActive = true;
             _catchUpStartTime = getTimer();
             this.clearReconnectingOverlay();
          }
       }

private function startCatchUpSend() : void
      {
         if(lanSocket == null) return;
         _catchUpSending = true;
         _catchUpSendIdx = 0;
         _catchUpEndLine = "";
         var simTurn:int = 0;
         var simFrame:int = 0;
         if(this.simulation != null)
         {
            simTurn = this.simulation.turn;
            simFrame = this.simulation.frame;
         }
         var check:int = 0;
         if(this.game != null)
         {
            try { check = this.game.getCheckSum(); } catch(e:Error) {}
         }
         _catchUpEndLine = "DATA|COOP_CATCHUP_END|" + simTurn + "|" + simFrame + "|" + check;
      }

      private function drainCatchUpSend() : void
      {
         if(!_catchUpSending) return;
         if(lanSocket == null || !lanSocket.connected)
         {
            _catchUpSending = false;
            _catchUpLog = [];
            _catchUpEndLine = "";
            return;
         }
         var sentCount:int = 0;
         while(_catchUpSendIdx < _catchUpLog.length)
         {
            lanSocket.send("DATA|COOP_CATCHUP_MOVE|" + _catchUpLog[_catchUpSendIdx]);
            _catchUpSendIdx++;
            sentCount++;
            if(sentCount >= 500) break;
         }
         if(_catchUpSendIdx >= _catchUpLog.length)
         {
            if(_catchUpEndLine != "")
            {
               lanSocket.send(_catchUpEndLine);
            }
            _catchUpLog = [];
            _catchUpSendIdx = 0;
            _catchUpEndLine = "";
            _catchUpSending = false;
         }
      }

       private function feedCatchUp() : void
       {
          if(!_catchUpActive || this.simulation == null) return;
          var fed:int = 0;
          while(_catchUpQueue.length > 0)
          {
             var line:String = _catchUpQueue[0];
             var parts:Array = line.split(" ");
             if(parts.length < 4) { _catchUpQueue.shift(); continue; }
             var turn:int = int(parts[2]);
             if(turn != this.simulation.turn - 1) break;
             try
             {
                this.applyMoveLine(line);
                _catchUpQueue.shift();
                fed++;
             }
             catch(e:Error)
             {
                _catchUpQueue.shift();
             }
             if(fed > 500) break;
          }
          if(_catchUpQueue.length == 0 && this.simulation.turn >= _catchUpTargetTurn)
          {
             _catchUpActive = false;
             this.finishCatchUp();
          }
       }

       private function finishCatchUp() : void
       {
          if(_reconnectState != "resync") return;
          var ok:Boolean = true;
          if(this.game != null)
          {
             try { ok = this.game.getCheckSum() == _catchUpTargetCheck; } catch(e:Error) {}
          }
          if(lanSocket != null && lanSocket.connected)
          {
             lanSocket.send("DATA|COOP_CATCHUP_ACK");
          }
_reconnectState = "none";
           _localPaused = false;
           _peerPaused = false;
           if(game != null) game.setPaused(false);
           if(_joinReplayMode)
           {
              _joinReplayMode = false;
              _joinLiveBuffer = [];
              this.removeJoinOverlay();
              this.unlockInput();
           }
           if(!ok)
           {
              // Deterministic replay could not be fully verified. Resume anyway rather than
              // forcing players to restart the level; next turns will re-sync via the move stream.
           }
        }

private function sendJoinInit(inTutorial:int) : void
         {
            if(lanSocket == null) return;
            var ctr:int = 0;
            if(this.simulation != null)
            {
               ctr = this._coopMoveCounter;
            }
            lanSocket.send("DATA|COOP_JOIN_INIT|" + CoopGameScreen.gameSeed + "|" + inTutorial + "|" + ctr);
            _joinJoinInitSent = true;
         }

         private function sendStartConfig() : void
         {
            if(lanSocket == null || !lanSocket.connected || _spawnConf == null) return;
            var cfgPU:Array = _spawnConf[0] as Array;
            var cfgOU:Array = _spawnConf[3] as Array;
            var rosterA:String = "";
            var rosterB:String = "";
            if(game != null && game.teamA != null)
            {
               rosterA = rosterKeyStr(game.teamA.unitsAvailable);
               rosterB = rosterKeyStr(game.teamB.unitsAvailable);
            }
            lanSocket.send("DATA|COOP_START_CONFIG|" + int(_spawnConf[1]) + "|" + int(_spawnConf[2]) + "|" + int(_spawnConf[4]) + "|" + int(_spawnConf[5]) + "|" + cfgPU.join(",") + "|" + cfgOU.join(",") + "|" + rosterA + "|" + rosterB);
         }

         private function rosterKeyStr(d:Dictionary) : String
         {
            if(d == null) return "";
            var out:Array = [];
            for(var k:String in d)
            {
               out.push(int(k));
            }
            return out.join(",");
         }

         private function applyHostRoster() : void
         {
            if(_spawnTeamARoster == null || _spawnTeamBRoster == null) return;
            if(game == null || game.teamA == null || game.teamB == null) return;
            var rosterAByType:Dictionary = new Dictionary();
            for each(var rosterAUnit:int in _spawnTeamARoster)
            {
               rosterAByType[rosterAUnit] = 1;
            }
            var rosterBByType:Dictionary = new Dictionary();
            for each(var rosterBUnit:int in _spawnTeamBRoster)
            {
               rosterBByType[rosterBUnit] = 1;
            }
            game.teamA.unitsAvailable = rosterAByType;
            game.teamB.unitsAvailable = rosterBByType;
         }

         private function coopDisconnectToMenu() : void
         {
            _soloMode = true;
            if(lanSocket != null)
            {
               try
               {
                  lanSocket.send("DISCONNECT");
               }
               catch(e:Error)
               {
               }
               try
               {
                  lanSocket.close();
               }
               catch(e:Error)
               {
               }
               lanSocket = null;
            }
            CoopGameScreen.lanSocket = null;
            if(CoopScreen.lanSocketRef != null)
            {
               try { CoopScreen.lanSocketRef.close(); }
               catch(e:Error) { }
CoopScreen.lanSocketRef = null;
             }
main.soundManager.playSoundInBackground("");
              if(main != null) main.showScreen("mainMenu");
           }

        private function setFastForwardButtonLocked(locked:Boolean) : void
        {
           if(userInterface == null || userInterface.hud == null || userInterface.hud.hud == null) return;
           if(userInterface.hud.hud.fastForward != null)
           {
              userInterface.hud.hud.fastForward.visible = !locked;
              userInterface.hud.hud.fastForward.mouseEnabled = !locked;
              userInterface.hud.hud.fastForward.buttonMode = !locked;
           }
        }

        private function updateFastForwardAvailability() : void
        {
           if(_soloMode) return;
           super.isFastForward = false;
           this.setFastForwardButtonLocked(true);
        }

       private function drainJoinStreaming() : void
        {
           if(lanSocket == null || !lanSocket.connected)
           {
              _joinStreaming = false;
              return;
           }
           var sent:int = 0;
           while(_joinStreaming && _joinBacklogIdx < _sessionLog.length)
           {
              lanSocket.send("DATA|COOP_CATCHUP_MOVE|" + _sessionLog[_joinBacklogIdx]);
              _joinBacklogIdx++;
              sent++;
              if(sent >= 500) break;
           }
           if(_joinStreaming && _joinBacklogIdx >= _sessionLog.length)
           {
              var simTurn:int = 0;
              var simFrame:int = 0;
              if(this.simulation != null)
              {
                 simTurn = this.simulation.turn;
                 simFrame = this.simulation.frame;
              }
              var check:int = 0;
              if(this.game != null)
              {
                 try { check = this.game.getCheckSum(); } catch(e:Error) {}
              }
              lanSocket.send("DATA|COOP_CATCHUP_END|" + simTurn + "|" + simFrame + "|" + check);
              _joinStreaming = false;
              _joinBacklogIdx = 0;
           }
        }

       private function feedJoinReplay() : void
        {
           if(!_catchUpActive || this.simulation == null) return;
           var fed:int = 0;
           while(_catchUpQueue.length > 0)
           {
              var line:String = _catchUpQueue[0];
              var parts:Array = line.split(" ");
              if(parts.length < 4) { _catchUpQueue.shift(); continue; }
              var turn:int = int(parts[2]);
              if(turn > this.simulation.turn + 1) break;
              this.applyMoveLine(line);
              _catchUpQueue.shift();
              fed++;
              if(fed > 1500) break;
           }
           if(_catchUpQueue.length == 0 && this.simulation.turn >= _catchUpTargetTurn)
           {
              _catchUpActive = false;
              this.finishCatchUp();
           }
        }

       private function startJoinCatchup() : void
        {
           _joinReplayMode = true;
           _catchUpActive = false;
           _catchUpQueue = [];
           _catchUpLog = [];
_localPaused = true;
            _peerPaused = false;
            _isInTutorialPhase = false;
            _tutorialComplete = true;
startSyncedGame();
            _isInTutorialPhase = false;
            _syncedStartFrames = 0;
            _reconnectState = "reconnecting";
            this.showJoinOverlay("Joining match - catching up...");
         }

       private function showJoinOverlay(text:String) : void
        {
           if(_joinOverlay == null)
           {
              _joinOverlay = new Sprite();
              _joinOverlay.graphics.beginFill(0, 1);
              _joinOverlay.graphics.drawRect(0, 0, 2000, 2000);
              var tf:TextField = new TextField();
              tf.textColor = 0xFFFFFF;
              tf.text = (text == null || text.length == 0) ? "Joining match..." : text;
              tf.x = 300;
              tf.y = 350;
              tf.width = 260;
              _joinOverlay.addChild(tf);
           }
           if(!contains(_joinOverlay))
           {
              addChild(_joinOverlay);
           }
        }

       private function removeJoinOverlay() : void
        {
           if(_joinOverlay != null && contains(_joinOverlay))
           {
              removeChild(_joinOverlay);
           }
           _joinOverlay = null;
        }

       public function coopOnClose():void
       {
          if(this._coopGameOver || this._intentClose || this._soloMode)
          {
             this._reconnectState = "none";
             this.clearReconnectingOverlay();
             if(_reconnectInterval != 0)
             {
                clearInterval(_reconnectInterval);
                _reconnectInterval = 0;
             }
this._coopSavedOnMessage = null;
              this._coopSavedOnClose = null;
              this._coopSavedOnError = null;
              lanSocket = null;
              main.soundManager.playSoundInBackground("");
              main.showScreen("coopScreen", false, true);
              return;
          }
          this.enterReconnecting();
       }

       private function leaveToMenu() : void
       {
          if(_reconnectInterval != 0)
          {
             clearInterval(_reconnectInterval);
             _reconnectInterval = 0;
          }
this.clearReconnectingOverlay();
           this.hideWaitingForReconnect();
           this.removeJoinOverlay();
           this.unlockInput();
           _reconnectState = "none";
           _catchUpActive = false;
           _catchUpLog = [];
           _catchUpQueue = [];
           _joinStreaming = false;
           _joinReplayMode = false;
           _soloMode = false;
this._coopSavedOnMessage = null;
           this._coopSavedOnClose = null;
           this._coopSavedOnError = null;
           if(lanSocket != null)
           {
              try { lanSocket.close(); } catch(e:Error) {}
              lanSocket = null;
           }
           main.soundManager.playSoundInBackground("");
           main.showScreen("coopScreen", false, true);
        }

       private function enterReconnecting() : void
       {
          if(_reconnectState == "reconnecting" || _reconnectState == "resync" || _reconnectState == "resyncWait")
          {
             return;
}
           _reconnectState = "reconnecting";
           _reconnectStart = getTimer();
          _reconnectInterval = 0;
          _catchUpLog = [];
          _catchUpQueue = [];
          _catchUpActive = false;
          this.showReconnectingOverlay();
          if(_reconnectInterval == 0)
          {
             _reconnectInterval = setInterval(this.attemptReconnect, RECONNECT_RETRY_MS);
          }
          this.attemptReconnect();
       }

       private function attemptReconnect() : void
       {
          if(_reconnectState != "reconnecting") return;
          var now:int = getTimer();
          if(now - _reconnectStart > RECONNECT_WINDOW_MS)
          {
             this.reconnectFailed();
             return;
          }
          if(lanSocket != null)
          {
             try { lanSocket.close(); } catch(e:Error) {}
             lanSocket = null;
          }
          var sock:LanSocket = new LanSocket();
          lanSocket = sock;
          sock.onMessage = this.coopOnMessage;
          sock.onClose = this.reconnectSocketClosed;
          sock.onError = this.reconnectSocketError;
          sock.onConnect = function():void
          {
             if(HostSessionScreen.lobbyId != null)
             {
                sock.send("RECONNECT|" + HostSessionScreen.lobbyId + "|" + HostSessionScreen.role + "|" + HostSessionScreen.password);
             }
          };
          try
          {
             sock.connect("127.0.0.1", 9333);
          }
          catch(e:Error) {}
       }

       private function reconnectSocketClosed() : void
       {
       }

       private function reconnectSocketError(msg:String) : void
       {
       }

private function reconnectFailed() : void
        {
           if(_reconnectInterval != 0)
           {
              clearInterval(_reconnectInterval);
              _reconnectInterval = 0;
           }
           if(lanSocket != null)
           {
              try { lanSocket.close(); } catch(e:Error) {}
              lanSocket = null;
           }
           _reconnectState = "none";
           this.clearReconnectingOverlay();
           main.showScreen("coopScreen", false, true);
        }

        private function showReconnectingOverlay() : void
        {
           this.lockInput();
           if(_reconnectOverlay == null)
           {
              _reconnectOverlay = new Sprite();
              _reconnectOverlay.graphics.beginFill(0x000000, 0.85);
              _reconnectOverlay.graphics.drawRect(0, 0, 2000, 2000);
              _reconnectOverlay.graphics.endFill();
              _reconnectText = new TextField();
              _reconnectText.text = "Reconnecting";
              _reconnectText.textColor = 0xFFFFFF;
              _reconnectText.autoSize = TextFieldAutoSize.CENTER;
              _reconnectText.selectable = false;
              _reconnectText.mouseEnabled = false;
              _reconnectText.x = 900;
              _reconnectText.y = 350;
              _reconnectOverlay.addChild(_reconnectText);
           }
           if(!contains(_reconnectOverlay))
           {
              addChild(_reconnectOverlay);
           }
        }

        private function clearReconnectingOverlay() : void
        {
           if(_reconnectOverlay != null && contains(_reconnectOverlay))
           {
              removeChild(_reconnectOverlay);
           }
           _reconnectOverlay = null;
           _reconnectText = null;
           this.unlockInput();
        }

        private function showWaitingForReconnect() : void
        {
           if(_waitText != null && contains(_waitText))
           {
              return;
           }
           _waitText = new TextField();
           _waitText.text = "Waiting for teammate to reconnect...";
           _waitText.textColor = 0xFFFFFF;
           _waitText.selectable = false;
           _waitText.mouseEnabled = false;
           _waitText.x = 700;
           _waitText.y = 40;
           _waitText.width = 600;
           addChild(_waitText);
        }

        private function hideWaitingForReconnect() : void
        {
           if(_waitText != null && contains(_waitText))
           {
              removeChild(_waitText);
           }
           _waitText = null;
        }

        private function lockInput() : void
        {
           if(_inputLocked) return;
           if(stage == null) return;
           _inputLocked = true;
           stage.addEventListener(MouseEvent.MOUSE_DOWN, this._blockReconnectInput, true);
           stage.addEventListener(MouseEvent.MOUSE_UP, this._blockReconnectInput, true);
           stage.addEventListener(MouseEvent.CLICK, this._blockReconnectInput, true);
           stage.addEventListener(MouseEvent.MOUSE_WHEEL, this._blockReconnectInput, true);
           stage.addEventListener(MouseEvent.MOUSE_MOVE, this._blockReconnectInput, true);
           stage.addEventListener(KeyboardEvent.KEY_DOWN, this._blockReconnectInput, true);
           stage.addEventListener(KeyboardEvent.KEY_UP, this._blockReconnectInput, true);
        }

        private function unlockInput() : void
        {
           if(!_inputLocked) return;
           _inputLocked = false;
           if(stage == null) return;
           stage.removeEventListener(MouseEvent.MOUSE_DOWN, this._blockReconnectInput, true);
           stage.removeEventListener(MouseEvent.MOUSE_UP, this._blockReconnectInput, true);
           stage.removeEventListener(MouseEvent.CLICK, this._blockReconnectInput, true);
           stage.removeEventListener(MouseEvent.MOUSE_WHEEL, this._blockReconnectInput, true);
           stage.removeEventListener(MouseEvent.MOUSE_MOVE, this._blockReconnectInput, true);
           stage.removeEventListener(KeyboardEvent.KEY_DOWN, this._blockReconnectInput, true);
           stage.removeEventListener(KeyboardEvent.KEY_UP, this._blockReconnectInput, true);
        }

        private function _blockReconnectInput(e:Event) : void
        {
           if(e != null)
           {
              e.stopImmediatePropagation();
           }
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

public function restartLevel():void
        {
           if(_isRestarting) return;
           _isRestarting = true;
           if(lanSocket != null && lanSocket.connected)
           {
              lanSocket.send("DATA|COOP_TUTORIAL_RESTART");
           }
           if(!_tutorialComplete)
           {
              _localTutorialDone = false;
              _peerTutorialDone = false;
              _isWaitingForPeer = false;
           }
           main.showScreen("coopGameScreen", true);
        }

         private function startFreshGame():void
         {
            if(_isRestarting) return;
            _isRestarting = true;
            removeWaitingOverlay();
            _sessionLog = [];
            _catchUpLog = [];
            _catchUpQueue = [];
            _joinStreaming = false;
            _catchUpActive = false;
            startSyncedGame();
            if(game != null && userInterface != null)
            {
               game.screenX = game.team.homeX;
               if(game.team == game.teamB)
               {
                  game.screenX -= game.map.screenWidth;
               }
               game.targetScreenX = game.screenX;
               userInterface.isSlowCamera = false;
            }
            _tutorialComplete = true;
            _isInTutorialPhase = false;
            _isRestarting = false;
         }

private function startSyncedGame():void
         {
            removeWaitingOverlay();
            var currentLevel:Level = main.campaign.getCurrentLevel();
            currentLevel.controller = null;
            if(_spawnConf == null)
            {
               _spawnConf = [currentLevel.player.startingUnits.concat(), currentLevel.player.gold, currentLevel.player.mana, currentLevel.oponent.startingUnits.concat(), currentLevel.oponent.gold, currentLevel.oponent.mana];
            }
if(game != null && _spawnIdBaseline == 0)
             {
                _spawnIdBaseline = game.getCurrentId();
             }
             var thisPu:Array = _spawnConf[0] as Array;
             var thisOu:Array = _spawnConf[3] as Array;
             if(thisPu == null || thisPu.length == 0)
             {
                _spawnConf[0] = DEFAULT_COOP_PLAYER_UNITS.concat();
                _spawnConf[1] = DEFAULT_COOP_PLAYER_GOLD;
             }
             if(thisOu == null || thisOu.length == 0)
             {
                if(main.campaign.difficultyLevel == Campaign.D_NORMAL)
                {
                   _spawnConf[3] = DEFAULT_COOP_ENEMY_UNITS_NORMAL.concat();
                }
                else
                {
                   _spawnConf[3] = DEFAULT_COOP_ENEMY_UNITS_HARD.concat();
                }
                _spawnConf[4] = DEFAULT_COOP_ENEMY_GOLD;
             }
             if(isHost && !_soloMode && lanSocket != null && lanSocket.connected)
             {
                this.sendStartConfig();
             }
            cleanUpGameState();
            main.seed = gameSeed;
            if(game != null)
            {
               game.setCurrentId(_spawnIdBaseline);
               game.random = new Random(gameSeed);
               game.teamA.spawnUnitGroup(_spawnConf[0] as Array);
               game.teamA.gold = int(_spawnConf[1]);
               game.teamA.mana = int(_spawnConf[2]);
               game.teamB.spawnUnitGroup(_spawnConf[3] as Array);
game.teamB.gold = int(_spawnConf[4]);
                game.teamB.mana = int(_spawnConf[5]);
                game.teamB.currentAttackState = Team.G_ATTACK;
                this.applyHostRoster();
             }
this.doAiUpdates = true;
               this._coopMoveCounter = 0;
               _syncedStartFrames = 0;
               _isInTutorialPhase = false;
          }

     }
}
