package com.brockw.stickwar.campaign.controllers
{
import com.brockw.stickwar.campaign.Campaign;
import com.brockw.stickwar.campaign.InGameMessage;
import com.brockw.stickwar.GameScreen;
import com.brockw.stickwar.engine.Ai.command.AttackMoveCommand;
import com.brockw.stickwar.engine.Ai.command.HoldCommand;
import com.brockw.stickwar.engine.Ai.command.MoveCommand;
import com.brockw.stickwar.engine.Ai.command.StandCommand;
import com.brockw.stickwar.engine.Ai.command.UnitCommand;
import com.brockw.stickwar.engine.Team.Team;
import com.brockw.stickwar.engine.Team.Order.CastleArchers;
import com.brockw.stickwar.engine.Team.Tech;
import com.brockw.stickwar.engine.Team.Building;
import com.brockw.stickwar.engine.Team.CastleDefence;
import com.brockw.stickwar.engine.units.Unit;
import com.brockw.stickwar.engine.units.Skelator;
import com.brockw.stickwar.engine.units.Undead;
import com.brockw.stickwar.engine.Gold;
import com.brockw.stickwar.engine.Hill;
import com.brockw.stickwar.engine.Entity;
import com.brockw.stickwar.engine.Ore;
import com.brockw.stickwar.engine.StickWar;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.utils.Dictionary;
import flash.events.MouseEvent;
import flash.text.TextField;
import com.brockw.stickwar.engine.multiplayer.moves.UnitMove;
import com.brockw.stickwar.engine.Ai.MinerAi;
import com.brockw.stickwar.engine.Ai.UnitAi;
    
    public class CampaignHordeCenter extends CampaignController
    {
       private static const HORDE_WAVE_TIMES:Array = [90, 1200, 2100, 3000, 3900];
      
      private static const HORDE_WAVE_UNDEAD_NORMAL:Array = [12, 16, 20, 24, 30];
      
      private static const HORDE_WAVE_UNDEAD_HARD:Array = [16, 20, 26, 32, 40];
      
      private static const HORDE_WAVE_UNDEAD_INSANE:Array = [22, 28, 36, 44, 54];
      
      private static const COMPLETE_DELAY_FRAMES:int = 30 * 3;
      
      private static const SURVIVE_FRAMES:int = 30 * 150;

      private static const LEFT_GATE_ARCHER_X_OFFSET:Number = 800;
      private static const RIGHT_GATE_ARCHER_X_OFFSET:Number = 550;


      private static const LEFT_GOLD_CLUSTER_OFFSET:Number = 1200;
      private static const RIGHT_GOLD_CLUSTER_OFFSET:Number = 1100;

      private static const LEFT_LANE_X_OFFSET:Number = -800;
      private static const CENTER_LANE_X_OFFSET:Number = 0;
      private static const RIGHT_LANE_X_OFFSET:Number = 800;
      
      private var initialized:Boolean;
      
      private var startFrame:int;
      
      private var hordeWaveIndex:int;
      
      private var hordeCutsceneActive:Boolean;
      
      private var hordeCutsceneMarrowkai:Skelator;
      
      private var hordeCutsceneState:int;
      
      private var hordeCutsceneTimer:int;
      private var cutsceneStarted:int;
      private var cutsceneDelayFrame:int;
      
      private var ambushCompleteDelayStartFrame:int;
      
      private var lastStance:int;
       
      private var lastDefendCommandFrame:int = 0;
      private var lastAttackCommandFrame:int = 0;
      private var lastGarrisonCommandFrame:int = 0;
       
      private var hasShownStartMessage:Boolean;
      
      private var message:InGameMessage;
      
      private var messageStartFrame:int;
      
      private var infectionMessage:InGameMessage;
      
      private var infectionMessageFrames:int;
      
      private var activeHordeWaveUnits:Array;

        private var centerX:Number;
      
      private var leftGateX:Number;
        
      private var hordeRevealFog:Boolean;

      private var leftBarrierX:Number;

      private var rightBarrierX:Number;

      private var leftFogMc:_fog;

      private var rightFogMc:_fog;

      private var leftFogLowMc:_fogLowQuality;

      private var rightFogLowMc:_fogLowQuality;

      private var fogInitialized:Boolean;

      private var hordeFogOverlay:Sprite;

      private var hordeFogMapWidth:Number;

      private var hordeFogMapHeight:Number;

      private var fogNaturalWidth:Number;

      private var fogLowNaturalWidth:Number;

      private var leftFogFill:Shape;

      private var rightFogFill:Shape;
         
      private var _gameScreen:GameScreen;
        
      private var neutralPatrolStates:Dictionary;

      private var tutorialActive:Boolean;
      private var tutorialState:int;
      private var tutorialLastState:int;
      private var tutorialMessage:InGameMessage;
      private var tutorialArrowMc:flash.display.Sprite;
      private var tutorialNextButton:flash.display.Sprite;
      private var tutorialTrainingPopBefore:int;
      private var tutorialNeutralUnit:Unit;
      private var tutorialGoldGranted:Boolean;
      private var tutorialQueuedState:int;
      private var tutorialNextLabel:TextField;
      private var skipTutorialButton:skipTutorial;
        
      private static const HORDE_CS_BEFORE:int = -1;
      
      private static const HORDE_CS_FIST_WAIT:int = 0;
      
      private static const HORDE_CS_WAIT_END:int = 1;
       
       private static const HORDE_CS_DONE:int = 2;
      
      private static const START_MESSAGE_DELAY_FRAMES:int = 45;
      
      private static const START_MESSAGE_VISIBLE_FRAMES:int = 30 * 8;
      
      private static const CUTSCENE_PAN_FRAMES:int = 60;
      
      private static const CUTSCENE_FIST_WAIT_FRAMES:int = 15;
      
      private static const CUTSCENE_END_WAIT_FRAMES:int = 120;
      
        private static const CUTSCENE_UNDEAD_COUNT:int = 20;
      
      private static const PATROL_RADIUS_X:Number = 300;
      
      private static const PATROL_RADIUS_Y:Number = 60;
      
      private static const PATROL_IDLE_MIN_FRAMES:int = 120;
       
      private static const PATROL_IDLE_MAX_FRAMES:int = 210;

      private static var TUTORIAL_INTRO:int = 0;
      private static var TUTORIAL_PAN_CENTER:int = 1;
      private static var TUTORIAL_TRAIN_SWORD:int = 2;
      private static var TUTORIAL_NEUTRAL_INFO:int = 3;
      private static var TUTORIAL_PAN_LEFT:int = 4;
      private static var TUTORIAL_TRAIN_SPEAR:int = 5;
      private static var TUTORIAL_SIDE_ASSIGN:int = 6;
      private static var TUTORIAL_REASSIGN_INFO:int = 7;
      private static var TUTORIAL_REASSIGN_ACTION:int = 8;
      private static var TUTORIAL_STANCE_INFO:int = 9;
      private static var TUTORIAL_STANCE_LEFT:int = 10;
      private static var TUTORIAL_STANCE_RIGHT:int = 11;
      private static var TUTORIAL_STANCE_BOTH:int = 12;
      private static var TUTORIAL_PLAY_AROUND:int = 13;
      private static var TUTORIAL_DONE:int = 14;
       
      public function CampaignHordeCenter(gameScreen:GameScreen)
      {
         super(gameScreen);
         this.initialized = false;
         this.startFrame = 0;
         this.hordeWaveIndex = 0;
         this.hordeCutsceneActive = false;
         this.hordeCutsceneMarrowkai = null;
         this.hordeCutsceneState = HORDE_CS_DONE;
               this.hordeCutsceneTimer = 0;
               this.cutsceneStarted = 0;
               this.cutsceneDelayFrame = 0;
          this.ambushCompleteDelayStartFrame = -1;
         this.lastStance = -1;
         this.hasShownStartMessage = false;
         this.message = null;
         this.messageStartFrame = -1;
         this.infectionMessage = null;
          this.infectionMessageFrames = 0;
            this.activeHordeWaveUnits = [];
             this.centerX = 0;
           this.leftGateX = 0;
            this.hordeRevealFog = false;
              this._gameScreen = null;
              this.neutralPatrolStates = new Dictionary();
              this.tutorialActive = false;
              this.tutorialState = TUTORIAL_INTRO;
              this.tutorialLastState = -999;
              this.tutorialMessage = null;
              this.tutorialArrowMc = null;
              this.tutorialNextButton = null;
              this.tutorialTrainingPopBefore = 0;
              this.tutorialNeutralUnit = null;
               this.tutorialGoldGranted = false;
               this.tutorialQueuedState = -1;
         }
      
      override public function update(gameScreen:GameScreen) : void
       {
          if(!this.initialized)
          {
             this.initialize(gameScreen);
          }
           gameScreen.isFastForward = false;
           if(this.tutorialActive)
           {
              this.updateTutorial(gameScreen);
              return;
           }
            if(this.cutsceneStarted == 0)
            {
               this.cutsceneStarted = 1;
               this.cutsceneDelayFrame = gameScreen.game.frame;
               this.startFrame = gameScreen.game.frame;
            }
           if(this.cutsceneStarted == 1 && gameScreen.game.frame - this.cutsceneDelayFrame >= 45)
           {
              this.initCutscene(gameScreen);
              this.cutsceneStarted = 2;
           }
           if(this.hordeCutsceneActive)
           {
              this.updateCutscene(gameScreen);
              return;
           }
           this.updateMessage(gameScreen);
           this.updateInfectionMessage(gameScreen);
           this.updateHordeCenterLevel(gameScreen);
       }
      
       private function initialize(gameScreen:GameScreen) : void
       {
          this.initialized = true;
          this._gameScreen = gameScreen;
          this.startFrame = gameScreen.game.frame;
          this.centerX = gameScreen.game.map.width / 2;
          this.leftGateX = this.centerX - 1400;
         gameScreen.doAiUpdates = false;
         gameScreen.isFastForward = false;
          gameScreen.team.tech.isResearchedMap[Tech.CASTLE_ARCHER_1] = true;
         gameScreen.team.tech.isResearchedMap[Tech.MINER_SPEED] = true;
         gameScreen.team.tech.isResearchedMap[Tech.MINER_WALL] = true;
         gameScreen.team.tech.isResearchedMap[Tech.BANK_PASSIVE_1] = true;
         gameScreen.team.tech.isResearchedMap[Tech.BANK_PASSIVE_2] = true;
         gameScreen.team.createTimeMultiplier = 0.5;
         gameScreen.team.tech.researchTimeMultiplier = 0.5;
         var team:Team = gameScreen.team;
         var enemyTeam:Team = gameScreen.team.enemyTeam;
         team.autoMarchOnSpawn = false;
         team.isCenterBase = true;
          team.homeX = this.centerX - 25;
           var centerX:Number = this.centerX;
           var nextCenterSpawnSide:int = 0;
           team.onSpawnUnitPosition = function(unit:Unit, spawnZone:int):Object
           {
              if(unit.team != null && unit.team.game.battlefield.contains(unit))
                 unit.team.game.battlefield.setChildIndex(unit, unit.team.game.battlefield.numChildren - 1);
                  if(!unit.isMiner())
                {
                   var yMid:Number = unit.team.game.map.height / 2;
                   var move:MoveCommand = new MoveCommand(unit.team.game);
                   move.targetId = -1;
                      if(spawnZone == -1)
                      {
                         unit.assignedSide = 0;
                         move.goalX = unit.team.homeX;
                         move.goalY = yMid;
                      }
                    else
                    {
                       var laneX:Number = spawnZone == 0 ? centerX + LEFT_LANE_X_OFFSET : centerX + RIGHT_LANE_X_OFFSET;
                       unit.assignedSide = spawnZone == 0 ? -1 : 1;
                       move.goalX = laneX;
                       move.goalY = yMid;
                    }
                    unit.ai.setCommand(unit.team.game, move);
                 }
                 else
                  {
                      if(spawnZone == -1)
                         unit.assignedSide = 0;
                     else
                        unit.assignedSide = spawnZone == 0 ? -1 : 1;
                  }
              return null;
           };
         team.statue.px = this.centerX;
         team.statue.x = team.statue.px;
         team.statue.py = gameScreen.game.map.height / 2;
         team.statue.y = team.statue.py;
         var castleFront:* = team.castleFront;
         var castleBack:* = team.castleBack;
         castleFront.x = this.centerX + 400;
         castleFront.px = this.centerX;
         castleBack.x = this.centerX + 400;
         castleBack.px = this.centerX;
         team.base.x = this.centerX - 500;
         team.base.px = team.base.x;
         var centerScreenX:Number = this.centerX - gameScreen.game.map.screenWidth / 2;
         gameScreen.game.screenX = centerScreenX;
         gameScreen.game.targetScreenX = centerScreenX;
         var leftArchers:CastleArchers = new CastleArchers(gameScreen.game, team, -team.direction);
         leftArchers.update(gameScreen.game);
          team.secondCastleDefence = leftArchers;
          var leftCastleFront:Entity = new Entity();
          leftCastleFront.addChild(new _castleFrontMc_LeftSide());
          leftCastleFront.x = this.leftGateX + 350;
          leftCastleFront.px = this.centerX;
          leftCastleFront.y = -gameScreen.game.battlefield.y;
          leftCastleFront.py = gameScreen.game.map.height / 2 + 40;
          gameScreen.game.battlefield.addChild(leftCastleFront);
          var leftCastleBack:Entity = new Entity();
          leftCastleBack.addChild(new _castleBackMc_LeftSide());
          leftCastleBack.x = this.leftGateX + 370;
          leftCastleBack.px = this.centerX;
          leftCastleBack.y = -gameScreen.game.battlefield.y;
          leftCastleBack.py = -gameScreen.game.battlefield.y;
          gameScreen.game.battlefield.addChild(leftCastleBack);
          if(gameScreen.game.battlefield.contains(team.statue))
          {
             gameScreen.game.battlefield.setChildIndex(team.statue, gameScreen.game.battlefield.numChildren - 1);
          }
          var bank:Building = team.buildings["BankBuilding"];
          if(bank != null)
          {
             bank.visible = false;
             bank.mouseEnabled = false;
          }
           this.hideEnemyBase(gameScreen);
          this.disableEnemyCastleDefence(gameScreen);
          this.clearEnemyStartingCombatUnits(gameScreen);
          if(gameScreen.team.enemyTeam.unitsAvailable != null)
          {
             delete gameScreen.team.enemyTeam.unitsAvailable[Unit.U_CHAOS_MINER];
          }
          this.removeMiddleHills(gameScreen);
          if(gameScreen.game.fogOfWar != null)
          {
            gameScreen.game.fogOfWar.isFogOn = false;
            gameScreen.game.ignoreHomeXTargeting = true;
           }
            this.leftBarrierX = gameScreen.game.map.width * 0.15;
            this.rightBarrierX = gameScreen.game.map.width * 0.85;
           this.initHordeFog(gameScreen);
            this.splitGoldDeposits(gameScreen);
             this.drawHomeXMarker(gameScreen);
                 this.setupStartingUnits(gameScreen);
                 this.initTutorial(gameScreen);
           }
      
      private function initCutscene(gameScreen:GameScreen) : void
      {
         var s:Skelator = null;
         s = Skelator(gameScreen.game.unitFactory.getUnit(Unit.U_SKELATOR));
         gameScreen.team.enemyTeam.spawn(s, gameScreen.game);
         s.px = gameScreen.team.enemyTeam.homeX + gameScreen.team.enemyTeam.direction * 400;
         s.x = s.px;
         s.py = gameScreen.game.map.height / 2;
         s.y = s.py;
         s.scaleX *= gameScreen.team.enemyTeam.direction * -1;
         s.makeBoss();
         s.isBossMovementLocked = true;
         s.forceFaceDirection(gameScreen.team.direction);
         var hold:HoldCommand = new HoldCommand(gameScreen.game);
         s.ai.setCommand(gameScreen.game, hold);
         gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.SKELETON_FIST_ATTACK] = true;
         if(!Boolean(gameScreen.team.enemyTeam.unitGroups[Unit.U_UNDEAD]))
         {
            gameScreen.team.enemyTeam.unitGroups[Unit.U_UNDEAD] = [];
         }
           this.hordeRevealFog = true;
           if(this.leftFogMc != null) this.leftFogMc.visible = false;
           if(this.rightFogMc != null) this.rightFogMc.visible = false;
           if(this.leftFogLowMc != null) this.leftFogLowMc.visible = false;
           if(this.rightFogLowMc != null) this.rightFogLowMc.visible = false;
           if(this.hordeFogOverlay != null) this.hordeFogOverlay.graphics.clear();
           this.hordeCutsceneMarrowkai = s;
          this.hordeCutsceneState = HORDE_CS_BEFORE;
         this.hordeCutsceneTimer = gameScreen.game.frame;
         this.hordeCutsceneActive = true;
         gameScreen.team.enemyTeam.currentAttackState = Team.G_GARRISON;
      }
      
         private function updateHordeCenterLevel(gameScreen:GameScreen) : void
         {
            this.updateFog(gameScreen);
            this.updateHordeFog(gameScreen);
            this.updateStanceFilter(gameScreen);
             this.fixAllCastleArchers(gameScreen);
               this.updateNeutralPatrol(gameScreen);
                 this.updateWaves(gameScreen);
           }
       
       private function updateCutscene(gameScreen:GameScreen) : void
      {
         if(this.hordeCutsceneState == HORDE_CS_BEFORE)
         {
            this.setCameraTarget(gameScreen, gameScreen.team.enemyTeam.homeX + gameScreen.team.enemyTeam.direction * 1100);
            if(gameScreen.game.frame - this.hordeCutsceneTimer >= CUTSCENE_PAN_FRAMES)
            {
               this.hordeCutsceneState = HORDE_CS_FIST_WAIT;
               this.hordeCutsceneTimer = gameScreen.game.frame;
            }
         }
         else if(this.hordeCutsceneState == HORDE_CS_FIST_WAIT)
         {
            if(gameScreen.game.frame - this.hordeCutsceneTimer >= CUTSCENE_FIST_WAIT_FRAMES)
            {
               if(this.hordeCutsceneMarrowkai != null && this.hordeCutsceneMarrowkai.isAlive())
               {
                  this.hordeCutsceneMarrowkai.playCutsceneFist(this.hordeCutsceneMarrowkai.px + 200, gameScreen.game.map.height / 2, CUTSCENE_UNDEAD_COUNT);
               }
               this.hordeCutsceneState = HORDE_CS_WAIT_END;
               this.hordeCutsceneTimer = gameScreen.game.frame;
            }
         }
          else if(this.hordeCutsceneState == HORDE_CS_WAIT_END)
          {
             if(gameScreen.game.frame - this.hordeCutsceneTimer >= CUTSCENE_END_WAIT_FRAMES)
             {
                this.cleanupCutscene(gameScreen);
             }
          }
       }
      
      private function cleanupCutscene(gameScreen:GameScreen) : void
      {
         if(this.message != null && gameScreen.contains(this.message))
         {
            gameScreen.removeChild(this.message);
            this.message = null;
         }
         var unit:Unit = null;
         var cleanupList:Array = [];
         for each(unit in gameScreen.team.enemyTeam.units)
         {
            if(unit != null && unit is Undead)
            {
               cleanupList.push(unit);
            }
         }
         for each(unit in cleanupList)
         {
            gameScreen.team.enemyTeam.removeUnitCompletely(unit, gameScreen.game);
         }
         if(this.hordeCutsceneMarrowkai != null)
         {
            gameScreen.team.enemyTeam.removeUnitCompletely(this.hordeCutsceneMarrowkai, gameScreen.game);
            this.hordeCutsceneMarrowkai = null;
         }
         this.hordeCutsceneActive = false;
         var centerScreenX:Number = this.centerX - gameScreen.game.map.screenWidth / 2;
         this.setCameraTarget(gameScreen, centerScreenX);
         this.hordeRevealFog = false;
          this.hordeCutsceneState = HORDE_CS_DONE;
          this.startFrame = gameScreen.game.frame;
          gameScreen.team.enemyTeam.currentAttackState = Team.G_DEFEND;
       }
      
      private function updateFog(gameScreen:GameScreen) : void
      {
         if(gameScreen.game.fogOfWar == null)
         {
            return;
         }
         gameScreen.game.fogOfWar.isFogOn = false;
      }

      private function initHordeFog(gameScreen:GameScreen) : void
      {
         if(this.fogInitialized)
         {
            return;
         }
          this.fogInitialized = true;
          this.leftFogMc = new _fog();
          this.leftFogMc.y = 0;
          this.leftFogMc.alpha = 0.7;
          this.applyFogTint(this.leftFogMc);
          this.leftFogMc.cacheAsBitmap = true;
          this.rightFogMc = new _fog();
          this.rightFogMc.y = 0;
          this.rightFogMc.alpha = 0.7;
          this.applyFogTint(this.rightFogMc);
           this.rightFogMc.cacheAsBitmap = true;
           this.fogNaturalWidth = this.leftFogMc.width;
           this.leftFogLowMc = new _fogLowQuality();
          this.leftFogLowMc.y = 0;
          this.leftFogLowMc.alpha = 1;
          this.leftFogLowMc.cacheAsBitmap = true;
          this.rightFogLowMc = new _fogLowQuality();
          this.rightFogLowMc.y = 0;
          this.rightFogLowMc.alpha = 1;
           this.rightFogLowMc.cacheAsBitmap = true;
           this.fogLowNaturalWidth = this.leftFogLowMc.width;
            this.leftFogFill = new Shape();
            this.rightFogFill = new Shape();
           gameScreen.game.addChild(this.leftFogFill);
           gameScreen.game.addChild(this.rightFogFill);
           gameScreen.game.addChild(this.leftFogMc);
          gameScreen.game.addChild(this.rightFogMc);
          gameScreen.game.addChild(this.leftFogLowMc);
          gameScreen.game.addChild(this.rightFogLowMc);
          var mapMc:* = gameScreen.userInterface.hud.hud.map;
          this.hordeFogOverlay = new Sprite();
          this.hordeFogOverlay.mouseEnabled = false;
          this.hordeFogOverlay.mouseChildren = false;
           this.hordeFogMapWidth = mapMc.width;
           this.hordeFogMapHeight = mapMc.height;
           mapMc.addChild(this.hordeFogOverlay);
       }

       private function updateHordeFog(gameScreen:GameScreen) : void
      {
         if(!this.fogInitialized || this.hordeRevealFog)
         {
            this.leftFogMc.visible = false;
            this.rightFogMc.visible = false;
            this.leftFogLowMc.visible = false;
            this.rightFogLowMc.visible = false;
            this.hordeFogOverlay.graphics.clear();
            return;
         }
           var alphaOn:Boolean = gameScreen.game.gameScreen.hasAlphaOnFogOfWar;
           var screenX:Number = gameScreen.game.screenX;
           var screenWidth:Number = gameScreen.game.map.screenWidth;
           this.leftFogMc.visible = alphaOn;
           this.rightFogMc.visible = alphaOn;
           this.leftFogLowMc.visible = !alphaOn;
           this.rightFogLowMc.visible = !alphaOn;
           this.leftFogMc.scaleX = -1;
           this.leftFogMc.x = this.leftBarrierX - screenX;
           this.leftFogLowMc.scaleX = -1;
           this.leftFogLowMc.x = this.leftBarrierX - screenX;
           this.rightFogMc.scaleX = 1;
           this.rightFogMc.x = this.rightBarrierX - screenX;
           this.rightFogLowMc.scaleX = 1;
           this.rightFogLowMc.x = this.rightBarrierX - screenX;
           var mapHeight:Number = gameScreen.game.map.height;
           var leftGap:Number = this.leftBarrierX - screenX;
           var rightGap:Number = (screenX + screenWidth) - this.rightBarrierX;
           this.leftFogFill.graphics.clear();
           this.rightFogFill.graphics.clear();
           if(leftGap > 0)
           {
              this.leftFogFill.graphics.beginFill(0, 0.7);
              this.leftFogFill.graphics.drawRect(0, 0, leftGap, mapHeight);
              this.leftFogFill.graphics.endFill();
              this.leftFogFill.visible = true;
           }
           else
           {
              this.leftFogFill.visible = false;
           }
           if(rightGap > 0)
           {
              this.rightFogFill.x = this.rightBarrierX - screenX;
              this.rightFogFill.graphics.beginFill(0, 0.7);
              this.rightFogFill.graphics.drawRect(0, 0, rightGap, mapHeight);
              this.rightFogFill.graphics.endFill();
              this.rightFogFill.visible = true;
           }
           else
           {
              this.rightFogFill.visible = false;
           }
           if(this.leftBarrierX >= this.rightBarrierX)
           {
              this.rightBarrierX = this.leftBarrierX + 1;
           }
           var mapTotalWidth:Number = gameScreen.game.map.width;
           if(mapTotalWidth <= 0)
           {
              mapTotalWidth = 1;
           }
           var mapWidth:Number = this.hordeFogMapWidth;
          var mapHeight:Number = this.hordeFogMapHeight;
          this.hordeFogOverlay.graphics.clear();
         this.hordeFogOverlay.graphics.beginFill(0,1.0);
         this.hordeFogOverlay.graphics.drawRect(0,0,mapWidth * this.leftBarrierX / mapTotalWidth,mapHeight);
         this.hordeFogOverlay.graphics.drawRect(mapWidth * this.rightBarrierX / mapTotalWidth,0,mapWidth - mapWidth * this.rightBarrierX / mapTotalWidth,mapHeight);
         this.hordeFogOverlay.graphics.endFill();
      }

      private function applyFogTint(mc:_fog) : void
      {
         var ct:ColorTransform = new ColorTransform();
         ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 0.1;
         ct.redOffset = ct.greenOffset = ct.blueOffset = 0;
         mc.transform.colorTransform = ct;
      }

      private function setCameraTarget(gameScreen:GameScreen, targetX:Number) : void
      {
         if(targetX < 0)
         {
            targetX = 0;
         }
         if(targetX > gameScreen.game.background.maxScreenX())
         {
            targetX = gameScreen.game.background.maxScreenX();
         }
         gameScreen.game.targetScreenX = targetX;
      }
      
      private function updateWaves(gameScreen:GameScreen) : void
      {
         var elapsed:int = gameScreen.game.frame - this.startFrame;
         if(this.hasLivingWaveUnits())
         {
            return;
         }
         if(this.hordeWaveIndex < HORDE_WAVE_TIMES.length && elapsed >= int(HORDE_WAVE_TIMES[this.hordeWaveIndex]))
         {
            this.spawnWave(gameScreen, this.getWaveCount(gameScreen));
            ++this.hordeWaveIndex;
         }
         else if(this.hordeWaveIndex >= HORDE_WAVE_TIMES.length)
         {
            if(this.ambushCompleteDelayStartFrame < 0)
            {
               this.ambushCompleteDelayStartFrame = gameScreen.game.frame;
            }
            if(gameScreen.game.frame - this.ambushCompleteDelayStartFrame >= COMPLETE_DELAY_FRAMES)
            {
               this.completeHorde(gameScreen);
            }
         }
      }
      
      private function spawnWave(gameScreen:GameScreen, count:int) : void
      {
         var i:int = 0;
         var undead:Undead = null;
         var halfCount:int = Math.ceil(count / 2);
         var spawnedUnits:Array = [];
          for(i = 0; i < halfCount; i++)
          {
             undead = Undead(gameScreen.game.unitFactory.getUnit(Unit.U_UNDEAD));
             if(undead == null) continue;
             gameScreen.team.enemyTeam.spawn(undead, gameScreen.game);
              undead.px = this.rightBarrierX - 100 - i * 40;
             undead.x = undead.px;
              undead.py = gameScreen.game.map.height / 2 + (i - (halfCount - 1) / 2) * 20;
              undead.y = undead.py;
              undead.scaleX *= gameScreen.team.enemyTeam.direction * -1;
              this.issueAttackCommand(gameScreen, undead);
              if(gameScreen.game.battlefield.contains(undead))
                 gameScreen.game.battlefield.setChildIndex(undead, gameScreen.game.battlefield.numChildren - 1);
              spawnedUnits.push(undead);
          }
           for(i = 0; i < count - halfCount; i++)
           {
              undead = Undead(gameScreen.game.unitFactory.getUnit(Unit.U_UNDEAD));
              if(undead == null) continue;
              gameScreen.team.enemyTeam.spawn(undead, gameScreen.game);
              undead.px = this.leftBarrierX + i * 40;
            undead.x = undead.px;
             undead.py = gameScreen.game.map.height / 2 + (i - (count - halfCount - 1) / 2) * 20;
            undead.y = undead.py;
            undead.scaleX = Math.abs(undead.scaleX);
             this.issueAttackCommand(gameScreen, undead);
             if(gameScreen.game.battlefield.contains(undead))
                gameScreen.game.battlefield.setChildIndex(undead, gameScreen.game.battlefield.numChildren - 1);
             spawnedUnits.push(undead);
         }
         this.activeHordeWaveUnits = spawnedUnits;
      }
      
      private function issueAttackCommand(gameScreen:GameScreen, unit:Unit) : void
      {
         var attackMoveCommand:AttackMoveCommand = null;
         if(unit.ai == null)
         {
            return;
         }
         attackMoveCommand = new AttackMoveCommand(gameScreen.game);
         attackMoveCommand.type = UnitCommand.ATTACK_MOVE;
         attackMoveCommand.goalX = gameScreen.team.statue.px;
         attackMoveCommand.goalY = gameScreen.game.map.height / 2;
         attackMoveCommand.realX = attackMoveCommand.goalX;
         attackMoveCommand.realY = attackMoveCommand.goalY;
         unit.ai.setCommand(gameScreen.game, attackMoveCommand);
      }
      
      private function getWaveCount(gameScreen:GameScreen) : int
      {
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_INSANE)
         {
            return int(HORDE_WAVE_UNDEAD_INSANE[this.hordeWaveIndex]);
         }
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_HARD)
         {
            return int(HORDE_WAVE_UNDEAD_HARD[this.hordeWaveIndex]);
         }
         return int(HORDE_WAVE_UNDEAD_NORMAL[this.hordeWaveIndex]);
      }
      
      private function hasLivingWaveUnits() : Boolean
      {
         var unit:Unit = null;
         for each(unit in this.activeHordeWaveUnits)
         {
            if(unit != null && unit.isAlive())
            {
               return true;
            }
         }
       return false;
        }

          private function updateStanceFilter(gameScreen:GameScreen) : void
        {
           var team:Team = gameScreen.team;
           var viewLeft:Number = gameScreen.game.screenX;
           var viewRight:Number = viewLeft + gameScreen.game.stage.stageWidth;
           var statueVisible:Boolean = this.centerX >= viewLeft && this.centerX <= viewRight;
           var cameraIsLeft:Boolean = (viewLeft + viewRight) / 2 < this.centerX;
           var homeX:Number = gameScreen.team.homeX;
           var unit:Unit;

            if(team.currentAttackState == Team.G_DEFEND)
            {
                if(team.defendCommandFrame != this.lastDefendCommandFrame)
                {
                   this.lastDefendCommandFrame = team.defendCommandFrame;
                   var defendLeft:Boolean = statueVisible || cameraIsLeft;
                   var defendRight:Boolean = statueVisible || !cameraIsLeft;
                    var leftAtkMove:UnitMove = new UnitMove();
                    leftAtkMove.fromStance = true;
                    leftAtkMove.moveType = UnitCommand.ATTACK_MOVE;
                    var leftMove:UnitMove = new UnitMove();
                    leftMove.fromStance = true;
                    leftMove.moveType = UnitCommand.MOVE;
                    var rightAtkMove:UnitMove = new UnitMove();
                    rightAtkMove.fromStance = true;
                    rightAtkMove.moveType = UnitCommand.ATTACK_MOVE;
                    var rightMove:UnitMove = new UnitMove();
                    rightMove.fromStance = true;
                    rightMove.moveType = UnitCommand.MOVE;
                    var leftMinerMove:UnitMove = new UnitMove();
                    leftMinerMove.fromStance = true;
                    leftMinerMove.moveType = UnitCommand.MOVE;
                    var rightMinerMove:UnitMove = new UnitMove();
                    rightMinerMove.fromStance = true;
                    rightMinerMove.moveType = UnitCommand.MOVE;
                   var leftLaneX:Number = this.centerX + LEFT_LANE_X_OFFSET;
                   var rightLaneX:Number = this.centerX + RIGHT_LANE_X_OFFSET;
                   var leftGoldX:Number = this.centerX - LEFT_GOLD_CLUSTER_OFFSET;
                   var rightGoldX:Number = this.centerX + RIGHT_GOLD_CLUSTER_OFFSET;
                   var yMid:Number = gameScreen.game.map.height / 2;
                       for each(unit in team.units)
                        {
                           if(!unit.isAlive()) continue;
                           if(unit.assignedSide == 0) continue;
                          var unitLeft:Boolean = unit.assignedSide != 0 ? unit.assignedSide == -1 : unit.px < homeX + 600;
                          var unitRight:Boolean = unit.assignedSide != 0 ? unit.assignedSide == 1 : unit.px > homeX - 600;
                         if(!unit.isMiner())
                         {
                            if(unitLeft && defendLeft)
                            {
                               if(unit.isGarrisoned) unit.ungarrison();
                              if(unit.px < leftLaneX)
                                 leftMove.units.push(unit.id);
                              else
                                 leftAtkMove.units.push(unit.id);
                           }
                           else if(unitRight && defendRight)
                           {
                              if(unit.isGarrisoned) unit.ungarrison();
                              if(unit.px > rightLaneX)
                                 rightMove.units.push(unit.id);
                              else
                                 rightAtkMove.units.push(unit.id);
                           }
                        }
                             else if(unitLeft && defendLeft)
                             {
                              if(unit.isGarrisoned)
                                 unit.ungarrison();
                              var savedOre:Ore = MinerAi(unit.ai).garrisonTargetOre;
                             if(savedOre != null)
                             {
                              var directMove:UnitMove = new UnitMove();
                                 directMove.fromStance = true;
                                 directMove.moveType = UnitCommand.MOVE;
                                 directMove.owner = team.id;
                                 directMove.units.push(unit.id);
                                 directMove.arg0 = savedOre.x;
                                 directMove.arg1 = savedOre.y;
                                 directMove.arg4 = savedOre.id;
                                 directMove.execute(gameScreen.game);
                                 MinerAi(unit.ai).targetOre = savedOre;
                              }
                              else if(MinerAi(unit.ai).targetOre != null)
                              {
                              }
                              else
                              {
                                 leftMinerMove.units.push(unit.id);
                              }
                           }
                           else if(unitRight && defendRight)
                           {
                              if(unit.isGarrisoned)
                                 unit.ungarrison();
                              var savedOre:Ore = MinerAi(unit.ai).garrisonTargetOre;
                              if(savedOre != null)
                              {
                                 var directMove:UnitMove = new UnitMove();
                                 directMove.fromStance = true;
                                 directMove.moveType = UnitCommand.MOVE;
                                directMove.owner = team.id;
                                directMove.units.push(unit.id);
                                directMove.arg0 = savedOre.x;
                                directMove.arg1 = savedOre.y;
                                directMove.arg4 = savedOre.id;
                                directMove.execute(gameScreen.game);
                                MinerAi(unit.ai).targetOre = savedOre;
                             }
                             else if(MinerAi(unit.ai).targetOre != null)
                             {
                             }
                             else
                             {
                                rightMinerMove.units.push(unit.id);
                             }
                            }
                     }
                    leftMove.owner = team.id;
                    leftMove.arg0 = leftLaneX;
                    leftMove.arg1 = yMid;
                    leftAtkMove.owner = team.id;
                    leftAtkMove.arg0 = leftLaneX;
                    leftAtkMove.arg1 = yMid;
                    rightMove.owner = team.id;
                    rightMove.arg0 = rightLaneX;
                    rightMove.arg1 = yMid;
                    rightAtkMove.owner = team.id;
                    rightAtkMove.arg0 = rightLaneX;
                    rightAtkMove.arg1 = yMid;
                    leftMinerMove.owner = team.id;
                    leftMinerMove.arg0 = leftGoldX;
                    leftMinerMove.arg1 = yMid;
                    rightMinerMove.owner = team.id;
                    rightMinerMove.arg0 = rightGoldX;
                    rightMinerMove.arg1 = yMid;
                     if(leftMove.units.length > 0) leftMove.execute(gameScreen.game);
                     if(leftAtkMove.units.length > 0) leftAtkMove.execute(gameScreen.game);
                     if(rightMove.units.length > 0) rightMove.execute(gameScreen.game);
                     if(rightAtkMove.units.length > 0) rightAtkMove.execute(gameScreen.game);
                     if(leftMinerMove.units.length > 0) leftMinerMove.execute(gameScreen.game);
                      if(rightMinerMove.units.length > 0) rightMinerMove.execute(gameScreen.game);
                  }
                 return;
             }
 
             if(team.currentAttackState == Team.G_ATTACK)
             {
                 if(team.attackCommandFrame != this.lastAttackCommandFrame)
                 {
                    this.lastAttackCommandFrame = team.attackCommandFrame;
                    var attackLeft:Boolean = statueVisible || cameraIsLeft;
                    var attackRight:Boolean = statueVisible || !cameraIsLeft;
                    var leftAttackMove:UnitMove = new UnitMove();
                     leftAttackMove.fromStance = true;
                     leftAttackMove.moveType = UnitCommand.ATTACK_MOVE;
                     var rightAttackMove:UnitMove = new UnitMove();
                     rightAttackMove.fromStance = true;
                     rightAttackMove.moveType = UnitCommand.ATTACK_MOVE;
                     var leftMinerMove:UnitMove = new UnitMove();
                     leftMinerMove.fromStance = true;
                     leftMinerMove.moveType = UnitCommand.MOVE;
                     var rightMinerMove:UnitMove = new UnitMove();
                     rightMinerMove.fromStance = true;
                     rightMinerMove.moveType = UnitCommand.MOVE;
                    var leftGoalX:Number = 0 - 100;
                    var rightGoalX:Number = team.enemyTeam.statue.px;
                    var leftGoldX:Number = this.centerX - LEFT_GOLD_CLUSTER_OFFSET;
                    var rightGoldX:Number = this.centerX + RIGHT_GOLD_CLUSTER_OFFSET;
                      var yMidAttack:Number = gameScreen.game.map.height / 2;
                         for each(unit in team.units)
                         {
                            if(!unit.isAlive()) continue;
                            if(unit.assignedSide == 0) continue;
                            var unitLeft:Boolean = unit.assignedSide != 0 ? unit.assignedSide == -1 : unit.px < homeX + 600;
                           var unitRight:Boolean = unit.assignedSide != 0 ? unit.assignedSide == 1 : unit.px > homeX - 600;
                          if(!unit.isMiner())
                          {
                             if(unitLeft && attackLeft)
                             {
                               if(unit.isGarrisoned) unit.ungarrison();
                               leftAttackMove.units.push(unit.id);
                            }
                            else if(unitRight && attackRight)
                            {
                               if(unit.isGarrisoned) unit.ungarrison();
                               rightAttackMove.units.push(unit.id);
                            }
                         }
                             else if(unitLeft && attackLeft)
                             {
                             if(unit.isGarrisoned)
                                unit.ungarrison();
                             var savedOre:Ore = MinerAi(unit.ai).garrisonTargetOre;
                            if(savedOre != null)
                            {
                             var directMove:UnitMove = new UnitMove();
                                directMove.fromStance = true;
                                directMove.moveType = UnitCommand.MOVE;
                                directMove.owner = team.id;
                                directMove.units.push(unit.id);
                                directMove.arg0 = savedOre.x;
                                directMove.arg1 = savedOre.y;
                                directMove.arg4 = savedOre.id;
                                directMove.execute(gameScreen.game);
                                MinerAi(unit.ai).targetOre = savedOre;
                             }
                             else if(MinerAi(unit.ai).targetOre != null)
                             {
                             }
                             else
                             {
                                leftMinerMove.units.push(unit.id);
                             }
                          }
                          else if(unitRight && attackRight)
                          {
                             if(unit.isGarrisoned)
                                unit.ungarrison();
                             var savedOre:Ore = MinerAi(unit.ai).garrisonTargetOre;
                             if(savedOre != null)
                             {
                                var directMove:UnitMove = new UnitMove();
                                directMove.fromStance = true;
                                directMove.moveType = UnitCommand.MOVE;
                               directMove.owner = team.id;
                               directMove.units.push(unit.id);
                               directMove.arg0 = savedOre.x;
                               directMove.arg1 = savedOre.y;
                               directMove.arg4 = savedOre.id;
                               directMove.execute(gameScreen.game);
                               MinerAi(unit.ai).targetOre = savedOre;
                            }
                            else if(MinerAi(unit.ai).targetOre != null)
                            {
                            }
                            else
                            {
                               rightMinerMove.units.push(unit.id);
                            }
                            }
                     }
                    leftAttackMove.owner = team.id;
                    leftAttackMove.arg0 = leftGoalX;
                    leftAttackMove.arg1 = yMidAttack;
                    rightAttackMove.owner = team.id;
                    rightAttackMove.arg0 = rightGoalX;
                    rightAttackMove.arg1 = yMidAttack;
                    leftMinerMove.owner = team.id;
                    leftMinerMove.arg0 = leftGoldX;
                    leftMinerMove.arg1 = yMidAttack;
                    rightMinerMove.owner = team.id;
                    rightMinerMove.arg0 = rightGoldX;
                    rightMinerMove.arg1 = yMidAttack;
                      if(leftAttackMove.units.length > 0) leftAttackMove.execute(gameScreen.game);
                      if(rightAttackMove.units.length > 0) rightAttackMove.execute(gameScreen.game);
                      if(leftMinerMove.units.length > 0) leftMinerMove.execute(gameScreen.game);
                       if(rightMinerMove.units.length > 0) rightMinerMove.execute(gameScreen.game);
                    }
                   return;
                }
 
             if(team.currentAttackState == Team.G_GARRISON)
            {
                if(team.garrisonCommandFrame != this.lastGarrisonCommandFrame)
                {
                   this.lastGarrisonCommandFrame = team.garrisonCommandFrame;
                   var garrisonLeft:Boolean = statueVisible || cameraIsLeft;
                   var garrisonRight:Boolean = statueVisible || !cameraIsLeft;
                    var leftGarrMove:UnitMove = new UnitMove();
                    leftGarrMove.fromStance = true;
                    leftGarrMove.moveType = UnitCommand.MOVE;
                    var rightGarrMove:UnitMove = new UnitMove();
                    rightGarrMove.fromStance = true;
                    rightGarrMove.moveType = UnitCommand.MOVE;
                    var leftGarrQueued:UnitMove = new UnitMove();
                    leftGarrQueued.fromStance = true;
                    leftGarrQueued.moveType = UnitCommand.GARRISON;
                    leftGarrQueued.queued = true;
                    var rightGarrQueued:UnitMove = new UnitMove();
                    rightGarrQueued.fromStance = true;
                    rightGarrQueued.moveType = UnitCommand.GARRISON;
                    rightGarrQueued.queued = true;
                    var leftGarrisonPoint:Number = team.homeX;
                     var rightGarrisonPoint:Number = team.homeX;
                      var yMidGarrison:Number = gameScreen.game.map.height / 2;
                         for each(unit in team.units)
                         {
                            if(!unit.isAlive()) continue;
                            if(unit.assignedSide == 0) continue;
                            var unitLeft:Boolean = unit.assignedSide != 0 ? unit.assignedSide == -1 : unit.px < homeX + 600;
                           var unitRight:Boolean = unit.assignedSide != 0 ? unit.assignedSide == 1 : unit.px > homeX - 600;
                           if(unitLeft && garrisonLeft)
                           {
                              if(unit.isGarrisoned) unit.ungarrison();
                              if(unit.isMiner()) MinerAi(unit.ai).garrisonTargetOre = MinerAi(unit.ai).targetOre;
                              leftGarrMove.units.push(unit.id);
                             leftGarrQueued.units.push(unit.id);
                          }
                          else if(unitRight && garrisonRight)
                          {
                             if(unit.isGarrisoned) unit.ungarrison();
                             if(unit.isMiner()) MinerAi(unit.ai).garrisonTargetOre = MinerAi(unit.ai).targetOre;
                             rightGarrMove.units.push(unit.id);
                             rightGarrQueued.units.push(unit.id);
                          }
                       }
                      leftGarrMove.owner = team.id;
                    leftGarrMove.arg0 = leftGarrisonPoint;
                    leftGarrMove.arg1 = yMidGarrison;
                    leftGarrMove.arg2 = int(gameScreen.game.map.height / 3);
                    leftGarrQueued.owner = team.id;
                    rightGarrMove.owner = team.id;
                    rightGarrMove.arg0 = rightGarrisonPoint;
                    rightGarrMove.arg1 = yMidGarrison;
                    rightGarrMove.arg2 = int(gameScreen.game.map.height / 3);
                    rightGarrQueued.owner = team.id;
                   if(leftGarrMove.units.length > 0)
                   {
                      leftGarrMove.execute(gameScreen.game);
                      leftGarrQueued.execute(gameScreen.game);
                   }
                      if(rightGarrMove.units.length > 0)
                      {
                         rightGarrMove.execute(gameScreen.game);
                          rightGarrQueued.execute(gameScreen.game);
                       }
                   }
                  return;
              }
         }
       
        private function updateSecondArchers(gameScreen:GameScreen) : void
        {
           if(gameScreen.team.secondCastleDefence != null)
           {
              gameScreen.team.secondCastleDefence.update(gameScreen.game);
           }
        }
        
        private function updateNeutralPatrol(gameScreen:GameScreen) : void
        {
           var unit:Unit = null;
           var state:Object = null;
           var patrolX:Number = NaN;
           var patrolY:Number = NaN;
           var m:UnitMove = null;
           var homeX:Number = gameScreen.team.homeX;
           var yMid:Number = gameScreen.game.map.height / 2;
           for each(unit in gameScreen.team.units)
           {
              if(!unit.isAlive() || unit.isMiner() || unit.assignedSide != 0)
                 continue;
              state = this.neutralPatrolStates[unit.id];
              if(state == null)
              {
                 state = {state:"idle", idleStartFrame:gameScreen.game.frame};
                 this.neutralPatrolStates[unit.id] = state;
              }
              if(state.state == "idle")
              {
                 if(gameScreen.game.frame - state.idleStartFrame >= PATROL_IDLE_MIN_FRAMES + int(gameScreen.game.random.nextNumber() * (PATROL_IDLE_MAX_FRAMES - PATROL_IDLE_MIN_FRAMES)))
                 {
                    patrolX = homeX + (gameScreen.game.random.nextNumber() * 2 - 1) * PATROL_RADIUS_X;
                    patrolY = yMid + (gameScreen.game.random.nextNumber() * 2 - 1) * PATROL_RADIUS_Y;
                    m = new UnitMove();
                    m.moveType = UnitCommand.MOVE;
                    m.units.push(unit.id);
                    m.owner = gameScreen.team.id;
                    m.arg0 = patrolX;
                    m.arg1 = patrolY;
                    m.execute(gameScreen.game);
                    state.state = "moving";
                    state.patrolX = patrolX;
                    state.patrolY = patrolY;
                 }
              }
              else if(state.state == "moving")
              {
                 if(Math.abs(unit.px - state.patrolX) < 50 && Math.abs(unit.py - state.patrolY) < 50)
                 {
                    state.state = "idle";
                    state.idleStartFrame = gameScreen.game.frame;
                 }
              }
           }
        }
        
      private function initTutorial(gameScreen:GameScreen) : void
      {
         this.tutorialActive = true;
         this.tutorialState = TUTORIAL_INTRO;
         this.tutorialLastState = -999;
         this.tutorialTrainingPopBefore = 0;
         this.tutorialNeutralUnit = null;
          this.tutorialGoldGranted = false;
          this.tutorialQueuedState = -1;
         var game:StickWar = gameScreen.game;
         this.tutorialMessage = new InGameMessage("", game);
         this.tutorialMessage.x = game.stage.stageWidth / 2;
         this.tutorialMessage.y = game.stage.stageHeight / 4 - 75;
         this.tutorialMessage.scaleX *= 1.3;
         this.tutorialMessage.scaleY *= 1.3;
         gameScreen.addChild(this.tutorialMessage);
         this.tutorialArrowMc = new tutorialArrow();
         gameScreen.addChild(this.tutorialArrowMc);
         this.startFrame = game.frame;
         delete game.team.unitsAvailable[Unit.U_MINER];
         delete game.team.unitsAvailable[Unit.U_SWORDWRATH];
         delete game.team.unitsAvailable[Unit.U_ARCHER];
         delete game.team.unitsAvailable[Unit.U_SPEARTON];
         delete game.team.unitsAvailable[Unit.U_NINJA];
         delete game.team.unitsAvailable[Unit.U_MONK];
         delete game.team.unitsAvailable[Unit.U_MAGIKILL];
           delete game.team.unitsAvailable[Unit.U_ENSLAVED_GIANT];
            gameScreen.userInterface.tutorialActionsLocked = true;
            game.soundManager.playSoundInBackground("fieldOfAmbush");
         }

        private function hasEnteredTutorialState() : Boolean
       {
          if(this.tutorialLastState == this.tutorialState)
             return false;
          this.tutorialLastState = this.tutorialState;
          return true;
       }

        private function showTutorialNextButton(gameScreen:GameScreen, text:String = "Next >>") : void
       {
          if(this.tutorialNextButton == null)
          {
             this.tutorialNextButton = new Sprite();
             this.tutorialNextButton.graphics.beginFill(0x333333, 0.9);
             this.tutorialNextButton.graphics.drawRoundRect(0, 0, 100, 28, 6);
             this.tutorialNextButton.graphics.endFill();
             this.tutorialNextButton.graphics.lineStyle(1, 0x888888);
             this.tutorialNextButton.graphics.drawRoundRect(0, 0, 100, 28, 6);
             this.tutorialNextLabel = new TextField();
             this.tutorialNextLabel.textColor = 0xFFFFFF;
             this.tutorialNextLabel.x = 8;
             this.tutorialNextLabel.y = 3;
             this.tutorialNextLabel.width = 90;
             this.tutorialNextLabel.height = 22;
             this.tutorialNextLabel.selectable = false;
             this.tutorialNextButton.addChild(this.tutorialNextLabel);
             this.tutorialNextButton.buttonMode = true;
             this.tutorialNextButton.useHandCursor = true;
             var self:CampaignHordeCenter = this;
             this.tutorialNextButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                self.onTutorialNextClick();
             });
          }
          this.tutorialNextLabel.text = text;
          if(!gameScreen.contains(this.tutorialNextButton))
          {
             this.tutorialNextButton.x = gameScreen.game.stage.stageWidth / 2 + 180;
             this.tutorialNextButton.y = gameScreen.game.stage.stageHeight / 4 - 75 + 120;
             gameScreen.addChild(this.tutorialNextButton);
          }
       }

       private function hideTutorialNextButton(gameScreen:GameScreen) : void
       {
          if(this.tutorialNextButton != null)
          {
             if(gameScreen.contains(this.tutorialNextButton))
             {
                gameScreen.removeChild(this.tutorialNextButton);
             }
          }
       }

      private function onTutorialNextClick() : void
      {
         this.tutorialQueuedState = this.tutorialState + 1;
      }

      private function tutorialArrowFollowUnit(target:Unit) : void
       {
          if(this.tutorialArrowMc != null && target != null && target.isAlive())
          {
             this.tutorialArrowMc.visible = true;
             this.tutorialArrowMc.x = target.x + target.team.game.battlefield.x;
             this.tutorialArrowMc.y = target.y - target.pheight * 0.8 + target.team.game.battlefield.y;
             this.tutorialArrowMc.rotation = 0;
          }
       }

       private function tutorialArrowAt(gameScreen:GameScreen, ax:Number, ay:Number, rotation:Number = 0) : void
      {
         if(this.tutorialArrowMc != null)
         {
            this.tutorialArrowMc.visible = true;
            this.tutorialArrowMc.x = ax;
            this.tutorialArrowMc.y = ay;
            this.tutorialArrowMc.rotation = rotation;
         }
      }

      private function tutorialArrowHide() : void
      {
         if(this.tutorialArrowMc != null)
         {
            this.tutorialArrowMc.visible = false;
         }
      }

      private function trainUnitIsComplete(gameScreen:GameScreen, type:int) : Boolean
      {
         var queueCount:int = int(gameScreen.team.buttonInfoMap[type][3]);
         if(queueCount > 0 && this.tutorialTrainingPopBefore == 0)
         {
            this.tutorialTrainingPopBefore = gameScreen.team.units.length;
         }
         if(this.tutorialTrainingPopBefore > 0 && queueCount == 0 && gameScreen.team.units.length > this.tutorialTrainingPopBefore)
         {
            this.tutorialTrainingPopBefore = 0;
            return true;
         }
         return false;
      }

      private function cameraIsAtCenter(gameScreen:GameScreen) : Boolean
      {
         var camCenter:Number = gameScreen.game.screenX + gameScreen.game.stage.stageWidth / 2;
         return Math.abs(camCenter - this.centerX) < 100;
      }

      private function cameraIsLeftOfCenter(gameScreen:GameScreen) : Boolean
      {
         var camCenter:Number = gameScreen.game.screenX + gameScreen.game.stage.stageWidth / 2;
         return camCenter < this.centerX - 500;
      }

      private function updateTutorial(gameScreen:GameScreen) : void
       {
          var game:StickWar = null;
          var enteredState:Boolean = false;
          var unit:Unit = null;
          var queueCount:int = 0;
          var neutralUnit:Unit = null;
          var i:int = 0;
           this.updateFog(gameScreen);
           this.updateHordeFog(gameScreen);
           this.updateStanceFilter(gameScreen);
           this.fixAllCastleArchers(gameScreen);
          this.updateNeutralPatrol(gameScreen);
         if(this.tutorialState == TUTORIAL_DONE)
         {
             this.tutorialArrowHide();
             if(gameScreen.contains(this.tutorialMessage))
                gameScreen.removeChild(this.tutorialMessage);
             this.tutorialMessage = null;
             this.hideTutorialNextButton(gameScreen);
             this.tutorialNextButton = null;
             if(this.tutorialArrowMc != null && gameScreen.contains(this.tutorialArrowMc))
                gameScreen.removeChild(this.tutorialArrowMc);
             this.tutorialArrowMc = null;
              if(this.skipTutorialButton != null)
              {
                 this.skipTutorialButton.removeEventListener(MouseEvent.CLICK, this.onSkipTutorialClick);
                 if(gameScreen.contains(this.skipTutorialButton))
                    gameScreen.removeChild(this.skipTutorialButton);
                 this.skipTutorialButton = null;
              }
               this.tutorialActive = false;
               gameScreen.userInterface.tutorialActionsLocked = false;
               gameScreen.userInterface.isGlobalsEnabled = true;
               gameScreen.team.unitsAvailable[Unit.U_SWORDWRATH] = 1;
               gameScreen.team.unitsAvailable[Unit.U_ARCHER] = 1;
               gameScreen.team.unitsAvailable[Unit.U_SPEARTON] = 1;
               gameScreen.team.unitsAvailable[Unit.U_NINJA] = 1;
               gameScreen.team.unitsAvailable[Unit.U_MONK] = 1;
               gameScreen.team.unitsAvailable[Unit.U_MAGIKILL] = 1;
               gameScreen.team.unitsAvailable[Unit.U_ENSLAVED_GIANT] = 1;
               gameScreen.team.unitsAvailable[Unit.U_MINER] = 1;
              gameScreen.game.soundManager.playSoundInBackground("fieldOfMemories");
             gameScreen.doAiUpdates = true;
            gameScreen.userInterface.hud.hud.fastForward.visible = true;
            gameScreen.userInterface.isSlowCamera = false;
            gameScreen.team.gold = 500;
            gameScreen.team.mana = 200;
            return;
         }
         if(this.tutorialQueuedState >= 0)
         {
            this.tutorialState = this.tutorialQueuedState;
            this.tutorialQueuedState = -1;
         }
         if(this.tutorialMessage != null)
         {
            this.tutorialMessage.update();
         }
         if(this.tutorialArrowMc != null)
         {
            if(this.tutorialArrowMc.currentFrame == this.tutorialArrowMc.totalFrames)
               this.tutorialArrowMc.gotoAndPlay(1);
            else
               this.tutorialArrowMc.nextFrame();
         }
         enteredState = this.hasEnteredTutorialState();
         if(this.tutorialState == TUTORIAL_INTRO)
         {
            if(enteredState)
            {
                gameScreen.userInterface.isGlobalsEnabled = false;
                gameScreen.doAiUpdates = false;
                this.tutorialMessage.setMessage("This level has two fronts! Controls change based on camera placement.", "Tutorial");
                this.showTutorialNextButton(gameScreen);
                game = gameScreen.game;
                if(this.skipTutorialButton == null)
                {
                   this.skipTutorialButton = new skipTutorial();
                   this.skipTutorialButton.addEventListener(MouseEvent.CLICK, this.onSkipTutorialClick, false, 0, true);
                }
                this.skipTutorialButton.x = game.stage.stageWidth / 2 + 17;
                this.skipTutorialButton.y = this.tutorialMessage.y + this.tutorialMessage.height - 140;
                if(!gameScreen.contains(this.skipTutorialButton) && (game.main.campaign.difficultyLevel == Campaign.D_HARD || game.main.campaign.difficultyLevel == Campaign.D_INSANE))
                {
                   gameScreen.addChild(this.skipTutorialButton);
                 }
             }
          }
           else if(this.tutorialState == TUTORIAL_PAN_CENTER)
          {
             if(enteredState)
             {
                gameScreen.userInterface.cameraLocked = true;
                gameScreen.game.targetScreenX = this.centerX - gameScreen.game.stage.stageWidth / 2;
                 this.hideTutorialNextButton(gameScreen);
                if(this.skipTutorialButton != null && gameScreen.contains(this.skipTutorialButton))
                   gameScreen.removeChild(this.skipTutorialButton);
                if(!this.tutorialGoldGranted)
                {
                   game.team.gold = 150;
                   this.tutorialGoldGranted = true;
                }
                this.tutorialMessage.setMessage("Navigate to where the Statue is visible.", "Tutorial");
                this.tutorialArrowAt(gameScreen, game.stage.stageWidth / 2 - 90, game.stage.stageHeight - 115);
             }
            if(this.cameraIsAtCenter(gameScreen))
            {
               this.tutorialState = TUTORIAL_TRAIN_SWORD;
            }
         }
         else if(this.tutorialState == TUTORIAL_TRAIN_SWORD)
         {
            if(enteredState)
             {
                game.team.unitsAvailable[Unit.U_SWORDWRATH] = 1;
                this.tutorialTrainingPopBefore = 0;
                 this.tutorialArrowAt(gameScreen, 95, game.stage.stageHeight - 100);
              }
              queueCount = int(game.team.buttonInfoMap[Unit.U_SWORDWRATH][3]);
              if(queueCount > 0)
              {
                 this.tutorialArrowHide();
                 this.tutorialMessage.setMessage("Swordwrath is training...", "Tutorial");
              }
              else if(this.tutorialTrainingPopBefore == 0)
              {
                 this.tutorialArrowAt(gameScreen, 95, game.stage.stageHeight - 100);
               this.tutorialMessage.setMessage("Click the icon below to train a Swordwrath.", "Tutorial");
            }
            if(this.trainUnitIsComplete(gameScreen, Unit.U_SWORDWRATH))
            {
               this.tutorialTrainingPopBefore = 0;
               this.tutorialState = TUTORIAL_NEUTRAL_INFO;
            }
         }
         else if(this.tutorialState == TUTORIAL_NEUTRAL_INFO)
         {
            if(enteredState)
            {
               this.tutorialArrowHide();
               delete game.team.unitsAvailable[Unit.U_SWORDWRATH];
               this.tutorialMessage.setMessage("Units trained while the Statue is seen from camera POV become Neutral — they patrol and guard the center.", "");
               this.showTutorialNextButton(gameScreen);
            }
         }
          else if(this.tutorialState == TUTORIAL_PAN_LEFT)
          {
             if(enteredState)
             {
                gameScreen.userInterface.cameraLocked = false;
                this.hideTutorialNextButton(gameScreen);
                this.tutorialMessage.setMessage("Move the camera to the left side.", "Tutorial");
                this.tutorialArrowAt(gameScreen, 50, game.stage.stageHeight / 4, 90);
             }
            if(this.cameraIsLeftOfCenter(gameScreen))
            {
               this.tutorialState = TUTORIAL_TRAIN_SPEAR;
            }
         }
          else if(this.tutorialState == TUTORIAL_TRAIN_SPEAR)
          {
              if(enteredState)
               {
                  gameScreen.userInterface.cameraLocked = true;
                  gameScreen.game.targetScreenX = this.centerX + LEFT_LANE_X_OFFSET - gameScreen.game.stage.stageWidth / 2;
                  game.team.unitsAvailable[Unit.U_SPEARTON] = 1;
                  game.team.gold = 450;
                  game.team.mana = 50;
                  this.tutorialTrainingPopBefore = 0;
                   this.tutorialArrowAt(gameScreen, 195, game.stage.stageHeight - 100);
                }
              queueCount = int(game.team.buttonInfoMap[Unit.U_SPEARTON][3]);
              if(queueCount > 0)
              {
                 this.tutorialArrowHide();
                 this.tutorialMessage.setMessage("Spearton is training...", "Tutorial");
              }
              else if(this.tutorialTrainingPopBefore == 0)
              {
                 this.tutorialArrowAt(gameScreen, 50, game.stage.stageHeight - 100);
               this.tutorialMessage.setMessage("Click the icon below to train a Spearton.", "Tutorial");
            }
            if(this.trainUnitIsComplete(gameScreen, Unit.U_SPEARTON))
            {
               this.tutorialTrainingPopBefore = 0;
               this.tutorialState = TUTORIAL_SIDE_ASSIGN;
            }
         }
         else if(this.tutorialState == TUTORIAL_SIDE_ASSIGN)
         {
            if(enteredState)
            {
               this.tutorialArrowHide();
               delete game.team.unitsAvailable[Unit.U_SPEARTON];
               this.tutorialMessage.setMessage("Camera on the left side assigns new units to the Left side. Same for the right. Center assigns to Neutral.", "");
               this.showTutorialNextButton(gameScreen);
            }
         }
         else if(this.tutorialState == TUTORIAL_REASSIGN_INFO)
          {
             if(enteredState)
             {
                gameScreen.userInterface.isSlowCamera = true;
                gameScreen.game.targetScreenX = this.centerX - gameScreen.game.stage.stageWidth / 2;
                this.tutorialMessage.setMessage("You can reassign existing units by moving them to any side.", "");
                this.showTutorialNextButton(gameScreen);
             }
          }
          else if(this.tutorialState == TUTORIAL_REASSIGN_ACTION)
          {
             if(enteredState)
             {
                gameScreen.userInterface.cameraLocked = false;
                gameScreen.userInterface.isGlobalsEnabled = true;
                game.team.gold = 500;
                game.team.mana = 200;
                game.team.unitsAvailable[Unit.U_SWORDWRATH] = 1;
                game.team.unitsAvailable[Unit.U_ARCHER] = 1;
                game.team.unitsAvailable[Unit.U_SPEARTON] = 1;
                game.team.unitsAvailable[Unit.U_NINJA] = 1;
                game.team.unitsAvailable[Unit.U_MONK] = 1;
                game.team.unitsAvailable[Unit.U_MAGIKILL] = 1;
                game.team.unitsAvailable[Unit.U_ENSLAVED_GIANT] = 1;
                game.team.unitsAvailable[Unit.U_MINER] = 1;
                this.hideTutorialNextButton(gameScreen);
                this.tutorialNeutralUnit = null;
                for each(unit in game.team.units)
                {
                   if(unit.isAlive() && !unit.isMiner() && unit.assignedSide == 0)
                   {
                      this.tutorialNeutralUnit = unit;
                      break;
                   }
                }
                this.tutorialMessage.setMessage("Select the patrolling Swordwrath, then right-click on the left side past the front gates to send him there.", "");
             }
             if(this.tutorialNeutralUnit != null)
             {
                if(this.tutorialNeutralUnit.isAlive())
                {
                    this.tutorialArrowFollowUnit(this.tutorialNeutralUnit);
                }
                else
                {
                   this.tutorialArrowHide();
                }
                if(this.tutorialNeutralUnit.assignedSide == -1)
                {
                   this.tutorialState = TUTORIAL_STANCE_INFO;
                }
             }
             else
             {
                for each(unit in game.team.units)
                {
                   if(unit.isAlive() && !unit.isMiner() && unit.assignedSide == 0)
                   {
                      this.tutorialNeutralUnit = unit;
                      break;
                   }
                }
                if(this.tutorialNeutralUnit == null)
                {
                   this.tutorialState = TUTORIAL_STANCE_INFO;
                }
             }
          }
          else if(this.tutorialState == TUTORIAL_STANCE_INFO)
         {
            if(enteredState)
            {
               this.tutorialMessage.setMessage("Group command buttons change with camera placement too.", "");
               this.tutorialArrowAt(gameScreen, game.stage.stageWidth / 2, game.stage.stageHeight - 75);
               this.showTutorialNextButton(gameScreen);
            }
         }
         else if(this.tutorialState == TUTORIAL_STANCE_LEFT)
         {
            if(enteredState)
            {
               this.tutorialArrowHide();
               this.tutorialMessage.setMessage("Camera on left: Attack and Garrison buttons are swapped.", "");
               this.showTutorialNextButton(gameScreen);
            }
         }
         else if(this.tutorialState == TUTORIAL_STANCE_RIGHT)
         {
            if(enteredState)
            {
               this.tutorialMessage.setMessage("Camera on center or right: buttons return to the normal layout (Defend/Attack/Garrison).", "");
               this.showTutorialNextButton(gameScreen);
            }
         }
         else if(this.tutorialState == TUTORIAL_STANCE_BOTH)
         {
            if(enteredState)
            {
               this.tutorialMessage.setMessage("Camera on left -> only Left units respond. Camera on right -> only Right units respond. Camera on center -> both sides respond.", "");
               this.showTutorialNextButton(gameScreen);
            }
         }
         else if(this.tutorialState == TUTORIAL_PLAY_AROUND)
         {
             if(enteredState)
             {
                this.tutorialArrowHide();
                this.tutorialMessage.setMessage("Play around with the buttons. Press `Done` when you\'re ready. Good luck!", "");
                this.showTutorialNextButton(gameScreen, "Done");
             }
          }
          if(Boolean(this.tutorialMessage))
          {
             if(!this.tutorialMessage.isMessageShowing())
             {
                if(Boolean(this.tutorialArrowMc))
                   this.tutorialArrowMc.visible = false;
             }
          }
       }

          private function updateMessage(gameScreen:GameScreen) : void
      {
         if(this.message != null)
         {
            if(gameScreen.contains(this.message))
            {
               this.message.update();
               if(this.messageStartFrame >= 0 && gameScreen.game.frame - this.messageStartFrame >= START_MESSAGE_VISIBLE_FRAMES)
               {
                  gameScreen.removeChild(this.message);
                  this.message = null;
               }
            }
            return;
         }
         if(!this.shouldShowStartMessage(gameScreen) || this.hasShownStartMessage || gameScreen.game.frame - this.startFrame < START_MESSAGE_DELAY_FRAMES)
         {
            return;
         }
         this.hasShownStartMessage = true;
         this.message = new InGameMessage("",gameScreen.game);
         this.message.x = gameScreen.game.stage.stageWidth / 2;
         this.message.y = gameScreen.game.stage.stageHeight / 4 - 75;
         this.message.scaleX *= 1.3;
         this.message.scaleY *= 1.3;
         this.message.setMessage("Undead swarm from both sides! Defend the center!","");
         gameScreen.addChild(this.message);
         this.messageStartFrame = gameScreen.game.frame;
      }
      
      private function updateInfectionMessage(gameScreen:GameScreen) : void
      {
         if(Boolean(this.infectionMessage) && gameScreen.contains(this.infectionMessage))
         {
            this.infectionMessage.update();
            if(this.infectionMessageFrames++ > 30 * 5)
            {
               gameScreen.removeChild(this.infectionMessage);
            }
            return;
         }
         if(!this.infectionMessage)
         {
            for each(var uInfected:Unit in gameScreen.team.units)
            {
               if(uInfected.isInfected)
               {
                  this.infectionMessage = new InGameMessage("",gameScreen.game);
                  this.infectionMessage.x = gameScreen.game.stage.stageWidth / 2;
                  this.infectionMessage.y = gameScreen.game.stage.stageHeight / 4 - 75;
                  this.infectionMessage.scaleX *= 1.3;
                  this.infectionMessage.scaleY *= 1.3;
                  gameScreen.addChild(this.infectionMessage);
                  this.infectionMessage.setMessage("A unit has been infected. Only garrison can cure the infection.","");
                  this.infectionMessageFrames = 0;
                  break;
               }
            }
         }
      }
      
      private function shouldShowStartMessage(gameScreen:GameScreen) : Boolean
      {
         return !this.hordeCutsceneActive;
      }
      
      private function hideEnemyBase(gameScreen:GameScreen) : void
      {
         if(gameScreen.team.enemyTeam.castleBack != null)
         {
            gameScreen.team.enemyTeam.castleBack.visible = false;
         }
         if(gameScreen.team.enemyTeam.castleFront != null)
         {
            gameScreen.team.enemyTeam.castleFront.visible = false;
         }
         if(gameScreen.team.enemyTeam.base != null)
         {
            gameScreen.team.enemyTeam.base.visible = false;
         }
         if(gameScreen.team.enemyTeam.statue != null)
         {
            gameScreen.team.enemyTeam.statue.visible = false;
            gameScreen.team.enemyTeam.statue.health = Math.max(gameScreen.team.enemyTeam.statue.health, 1);
            gameScreen.team.enemyTeam.statue.px = gameScreen.game.map.width + 500;
            gameScreen.team.enemyTeam.statue.x = gameScreen.team.enemyTeam.statue.px;
         }
      }
      
      private function hideEnemyGoldVisuals(gameScreen:GameScreen) : void
      {
         var i:int = 0;
         var gold:Gold = null;
         if(gameScreen.game.map == null || gameScreen.game.map.gold == null)
         {
            return;
         }
         for(i = int(gameScreen.game.map.gold.length / 2); i < gameScreen.game.map.gold.length; i++)
         {
            gold = gameScreen.game.map.gold[i] as Gold;
            if(gold != null)
            {
               gold.ore.visible = false;
               gold.frontOre.visible = false;
               gold.ore.mouseEnabled = false;
               gold.frontOre.mouseEnabled = false;
            }
         }
      }
      
      private function disableEnemyCastleDefence(gameScreen:GameScreen) : void
      {
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CASTLE_ARCHER_1];
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CASTLE_ARCHER_2];
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CASTLE_ARCHER_3];
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CASTLE_ARCHER_4];
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CASTLE_ARCHER_5];
      }
      
      private function clearEnemyStartingCombatUnits(gameScreen:GameScreen) : void
      {
         var unit:Unit = null;
         var snapshot:Array = null;
         if(gameScreen.team == null || gameScreen.team.enemyTeam == null)
         {
            return;
         }
         snapshot = gameScreen.team.enemyTeam.units.concat();
         for each(unit in snapshot)
         {
            if(unit != null && unit.type != Unit.U_STATUE && unit.type != Unit.U_CHAOS_TOWER)
            {
               gameScreen.team.enemyTeam.population = Math.max(0, gameScreen.team.enemyTeam.population - unit.population);
               gameScreen.team.enemyTeam.removeUnitCompletely(unit, gameScreen.game);
            }
         }
      }
      
      private function removeMiddleHills(gameScreen:GameScreen) : void
      {
         var hill:Hill = null;
         while(gameScreen.game.map.hills.length > 0)
         {
            hill = gameScreen.game.map.hills.pop();
            if(hill != null && hill.parent != null)
            {
               hill.parent.removeChild(hill);
            }
         }
      }
      
        private function splitGoldDeposits(gameScreen:GameScreen) : void
       {
          var golds:Vector.<Ore> = gameScreen.game.map.gold;
          var half:int = int(golds.length / 2);
          var i:int;
          var gold:Gold;
          var leftCenterX:Number = 0;
          var rightCenterX:Number = 0;
          for(i = 0; i < half; i++)
             leftCenterX += Gold(golds[i]).px;
          for(i = half; i < golds.length; i++)
             rightCenterX += Gold(golds[i]).px;
          leftCenterX /= half;
          rightCenterX /= golds.length - half;
          var desiredLeftX:Number = this.centerX - LEFT_GOLD_CLUSTER_OFFSET;
          var desiredRightX:Number = this.centerX + RIGHT_GOLD_CLUSTER_OFFSET;
          for(i = 0; i < half; i++)
          {
             gold = Gold(golds[i]);
             gold.px = gold.px - leftCenterX + desiredLeftX;
             gold.x = gold.px;
             gold.ore.x = gold.px;
             gold.ore.px = gold.px;
             gold.frontOre.x = gold.px;
             gold.frontOre.px = gold.px;
          }
          for(i = half; i < golds.length; i++)
          {
             gold = Gold(golds[i]);
              gold.px = desiredRightX + rightCenterX - gold.px;
             gold.x = gold.px;
             gold.ore.x = gold.px;
             gold.ore.px = gold.px;
             gold.frontOre.x = gold.px;
             gold.frontOre.px = gold.px;
          }
       }
      
       private function setupStartingUnits(gameScreen:GameScreen) : void
       {
          var team:Team = gameScreen.team;
          var unit:Unit = null;
          var moveCommand:MoveCommand = null;
          var typeGroups:Object = {};
          var typeStr:String = null;
          var j:int = 0;
          for each(unit in team.units)
          {
             if(unit.isAlive() && unit.type != Unit.U_STATUE && unit.type != Unit.U_CHAOS_TOWER)
             {
                typeStr = String(unit.type);
                if(typeGroups[typeStr] == null)
                   typeGroups[typeStr] = [];
                typeGroups[typeStr].push(unit);
             }
          }
          var leftUnits:Array = [];
          var rightUnits:Array = [];
          var leftLaneX:Number = this.centerX + LEFT_LANE_X_OFFSET;
          var rightLaneX:Number = this.centerX + RIGHT_LANE_X_OFFSET;
          var yBase:Number = gameScreen.game.map.height / 2;
          var total:int;
          var half:int;
          var leftCount:int;
          for each(var group:Array in typeGroups)
          {
             total = group.length;
             half = int(total / 2);
             leftCount = half;
             if(total % 2 != 0)
                leftCount = half + (gameScreen.game.random.nextNumber() > 0.5 ? 1 : 0);
             for(j = 0; j < leftCount; j++)
                leftUnits.push(group[j]);
             for(; j < total; j++)
                rightUnits.push(group[j]);
          }
          var spawnX:Number = this.centerX + CENTER_LANE_X_OFFSET;
           for(j = 0; j < leftUnits.length; j++)
           {
              unit = leftUnits[j];
              unit.assignedSide = -1;
              unit.px = spawnX;
              unit.x = unit.px;
              unit.py = yBase;
              unit.y = unit.py;
               moveCommand = new MoveCommand(gameScreen.game);
               moveCommand.targetId = -1;
               moveCommand.goalX = leftLaneX + (-30 + j * 20);
              moveCommand.goalY = yBase;
              unit.ai.setCommand(gameScreen.game, moveCommand);
           }
           for(j = 0; j < rightUnits.length; j++)
           {
              unit = rightUnits[j];
              unit.assignedSide = 1;
              unit.px = spawnX;
              unit.x = unit.px;
              unit.py = yBase;
              unit.y = unit.py;
               moveCommand = new MoveCommand(gameScreen.game);
               moveCommand.targetId = -1;
               moveCommand.goalX = rightLaneX + (-30 + j * 20);
              moveCommand.goalY = yBase;
              unit.ai.setCommand(gameScreen.game, moveCommand);
           }
       }

         private function drawHomeXMarker(gameScreen:GameScreen) : void
        {
           var zone:flash.display.Shape = new flash.display.Shape();
           var hX:Number = gameScreen.team.homeX;
           var radius:Number = 650;
           zone.graphics.beginFill(0x00FF00, 0.15);
           zone.graphics.drawRect(hX - radius, gameScreen.game.map.height / 2 - 200, radius * 2, 400);
           zone.graphics.endFill();
           zone.graphics.lineStyle(2, 0x00FF00, 0.4);
           zone.graphics.drawRect(hX - radius, gameScreen.game.map.height / 2 - 200, radius * 2, 400);
            gameScreen.game.battlefield.addChildAt(zone, 0);
                   }

          private function fixAllCastleArchers(gameScreen:GameScreen) : void
          {
         var archer:Unit = null;
         var yLevel:Number = gameScreen.game.map.height / 2 - 100;
         var leftDefence:CastleDefence = gameScreen.team.secondCastleDefence;
         if(leftDefence != null && leftDefence.units.length > 0)
         {
            archer = leftDefence.units[0];
            if(archer != null && archer.isAlive())
            {
               archer.px = this.leftGateX + LEFT_GATE_ARCHER_X_OFFSET;
               archer.x = archer.px;
               archer.py = yLevel;
                archer.y = archer.py + archer.pz;
                archer.forceFaceDirection(gameScreen.team.direction);
            }
         }
         var rightDefence:CastleDefence = gameScreen.team.castleDefence;
         if(rightDefence != null && rightDefence.units.length > 0)
         {
            archer = rightDefence.units[0];
            if(archer != null && archer.isAlive())
            {
               archer.px = this.centerX + RIGHT_GATE_ARCHER_X_OFFSET;
               archer.x = archer.px;
               archer.py = yLevel;
                archer.y = archer.py + archer.pz;
               archer.forceFaceDirection(gameScreen.team.direction);
            }
         }
      }
      
        private function onSkipTutorialClick(e:flash.events.Event) : void
       {
          this.tutorialState = TUTORIAL_DONE;
          if(this.skipTutorialButton != null)
          {
             this.skipTutorialButton.removeEventListener(MouseEvent.CLICK, this.onSkipTutorialClick);
             if(this._gameScreen.contains(this.skipTutorialButton))
                this._gameScreen.removeChild(this.skipTutorialButton);
             this.skipTutorialButton = null;
          }
       }

        private function completeHorde(gameScreen:GameScreen) : void
      {
         if(gameScreen.game.gameOver)
         {
            return;
         }
         gameScreen.game.winner = gameScreen.team;
         gameScreen.game.gameOver = true;
      }
   }
}
