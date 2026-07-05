package com.brockw.stickwar.campaign.controllers
{
   import com.brockw.stickwar.GameScreen;
   import com.brockw.stickwar.campaign.Campaign;
   import com.brockw.stickwar.campaign.CampaignGameScreen;
   import com.brockw.stickwar.campaign.InGameMessage;
   import com.brockw.stickwar.engine.Ai.command.AttackMoveCommand;
   import com.brockw.stickwar.engine.Ai.command.HoldCommand;
   import com.brockw.stickwar.engine.Ai.command.UnitCommand;
   import com.brockw.stickwar.engine.Gold;
   import com.brockw.stickwar.engine.Hill;
   import com.brockw.stickwar.engine.Team.Team;
   import com.brockw.stickwar.engine.Team.Tech;
   import com.brockw.stickwar.engine.units.Archer;
   import com.brockw.stickwar.engine.units.Magikill;
   import com.brockw.stickwar.engine.units.Monk;
   import com.brockw.stickwar.engine.units.Ninja;
   import com.brockw.stickwar.engine.units.Skelator;
   import com.brockw.stickwar.engine.units.Spearton;
   import com.brockw.stickwar.engine.units.Swordwrath;
   import com.brockw.stickwar.engine.units.Undead;
   import com.brockw.stickwar.engine.units.Unit;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   
   public class CampaignAmbush extends CampaignController
   {
      
      private static const LEVEL_NATIVE_TRIBES:String = "Ambush: Native Tribes";
      
      private static const LEVEL_SHADOWRATH_STALKERS:String = "Ambush: Shadowrath Stalkers";
      
      private static const LEVEL_REBELS_BREAK:String = "Ambush: Rebels Last Stand";
      
      private static const LEVEL_DEAD_HORDE:String = "Ambush: Undead Horde";
      
      private static const HORDE_WAVE_TIMES:Array = [90,1200,2100,3000,3900];
      
      private static const HORDE_WAVE_UNDEAD_NORMAL:Array = [4,6,8,10,12];
      
      private static const HORDE_WAVE_UNDEAD_HARD:Array = [6,8,10,12,16];
      
      private static const HORDE_WAVE_UNDEAD_INSANE:Array = [8,10,14,18,22];
      
      private static const CUTSCENE_PAN_FRAMES:int = 60;
      
      private static const CUTSCENE_FIST_WAIT_FRAMES:int = 15;
      
      private static const CUTSCENE_END_WAIT_FRAMES:int = 120;
      
      private static const CUTSCENE_UNDEAD_COUNT:int = 20;
      
      private static const CUTSCENE_UNDEAD_SPACING:Number = 40;
      
      private static const CUTSCENE_GREEN_TINT:uint = 6750054;
      
      private static const HORDE_CS_BEFORE:int = -1;
      
      private static const HORDE_CS_FIST_WAIT:int = 0;
      
      private static const HORDE_CS_WAIT_END:int = 1;
      
      private static const HORDE_CS_DONE:int = 2;
      
      private static const SURVIVE_FRAMES:int = 30 * 150;
      
      private static const SHADOWRATH_NIGHT_TINT_COLOR:uint = 464175;
      
      private static const SHADOWRATH_NIGHT_TINT_ALPHA:Number = 0.32;
      
      private static const SHADOWRATH_BARRIER_DISTANCE_FROM_BASE:Number = 1350;
      
      private static const STALK_CLOAK_UNLOCK_FRAME:int = 2700;
      
      private static const STALK_CLOAK_TRIGGER_PADDING:Number = 160;
      
      private static const START_MESSAGE_DELAY_FRAMES:int = 45;
      
      private static const START_MESSAGE_VISIBLE_FRAMES:int = 30 * 8;
      
      private static const COMPLETE_DELAY_FRAMES:int = 30 * 3;
      
      private static const REINFORCEMENT_SWORDWRATHS:int = 6;
      
      private static const REINFORCEMENT_SPEARTONS:int = 3;
      
      private static const BARRIER_PADDING:Number = 120;
      
      private static const NATIVE_SPEARTON_WEAPON:String = "Native Spaer";
      
      private static const NATIVE_SPEARTON_ARMOR:String = "Native Spearton";
      
      private static const NATIVE_SPEARTON_MISC:String = "Native Shield";
      
      private static const NATIVE_SWORDWRATH_WEAPON:String = "Club";
      
      private static const NATIVE_HEALTH_MULTIPLIER:Number = 0.5;
      
      private static const NATIVE_BASE_SPAWN_OFFSET:Number = 260;
      
      private static const REINFORCEMENT_BASE_SPAWN_OFFSET:Number = 120;
      
      private static const NATIVE_FORMATION_MAX_ROWS:int = 6;
      
      private static const NATIVE_FORMATION_ROW_SPACING:Number = 34;
      
      private static const NATIVE_FORMATION_COLUMN_SPACING:Number = 55;
      
      private static const NATIVE_FORMATION_GOAL_PADDING:Number = 70;
      
      private static const ATTACK_REFRESH_DELAY_FRAMES:int = 60;
      
      private static const NATIVE_WAVE_TIMES:Array = [90,1200,2000,2700,3600];
      
      private static const NATIVE_WAVE_SPEARTONS_NORMAL:Array = [0,1,1,0,2];
      
      private static const NATIVE_WAVE_SWORDWRATHS_NORMAL:Array = [2,2,2,3,4];
      
      private static const NATIVE_WAVE_SPEARTONS_HARD:Array = [1,2,1,0,3];
      
      private static const NATIVE_WAVE_SWORDWRATHS_HARD:Array = [2,2,2,4,4];
      
      private static const NATIVE_WAVE_SPEARTONS_INSANE:Array = [1,2,2,1,5];
      
      private static const NATIVE_WAVE_SWORDWRATHS_INSANE:Array = [3,3,3,4,6];
      
      private static const STALK_WAVE_TIMES:Array = [90,1200,2000,2700,3600];
      
      private static const STALK_WAVE_SHADOWRATHS_NORMAL:Array = [0,2,0,1,4];
      
      private static const STALK_WAVE_SHADOWRATHS_HARD:Array = [0,3,0,2,5];
      
      private static const STALK_WAVE_SHADOWRATHS_INSANE:Array = [0,4,0,2,7];
      
      private static const REBEL_OPENING_DELAY_FRAMES:int = 30 * 4;
      
      private static const REBEL_CAMERA_DELAY_FRAMES:int = 15;
      
      private static const REBEL_OPENING_HOLD_FRAMES:int = 30 * 5;
      
      private static const REBEL_WAVE_FRAME:int = 4000;
      
      private static const REBEL_ENDING_HOLD_FRAMES:int = 30 * 8;
      
      private static const REBEL_END_MESSAGE_FRAMES:int = 30 * 4;
      
      private static const REBEL_WAVE_ENDING_TIMEOUT_FRAMES:int = 30 * 90;
      
      private static const REBEL_WAVE_NORMAL:Array = [Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_NINJA,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_MAGIKILL,Unit.U_MONK];
      
      private static const REBEL_WAVE_HARD:Array = [Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_NINJA,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_MAGIKILL,Unit.U_MONK];
      
      private static const REBEL_WAVE_INSANE:Array = [Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_NINJA,Unit.U_NINJA,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_MAGIKILL,Unit.U_MONK];
      
      private var initialized:Boolean;
      
      private var startFrame:int;
      
      private var barrierX:Number;
      
      private var lastEnemyArmyVersion:int;
      
      private var nativeWaveIndex:int;
      
      private var stalkWaveIndex:int;
      
      private var hordeWaveIndex:int;
      
      private var hordeMarrowkaiSpawned:Boolean;
      
      private var hordeCutsceneState:int;
      
      private var hordeCutsceneTimer:int;
      
      private var hordeCutsceneMarrowkai:Skelator;
      
      private var hordeCutsceneUndeads:Array;
      
      private var hordeCutsceneActive:Boolean;
      
      private var marrowkaiSummonTimer:int;
      
      private var ambushCompleteDelayStartFrame:int;
      
      private var hasShownStartMessage:Boolean;
      
      private var hasSpawnedReinforcements:Boolean;
      
      private var message:InGameMessage;
      
      private var messageStartFrame:int;
      
      private var infectionMessage:InGameMessage;
      
      private var infectionMessageFrames:int;
      
      private var activeNativeWaveUnits:Array;
      
      private var activeStalkWaveUnits:Array;
      
      private var activeHordeWaveUnits:Array;
      
      private var activeRebelWaveUnits:Array;
      
      private var rebelDisplayUnits:Array;
      
      private var rebelWaveSpawned:Boolean;
      
      private var rebelCameraQueued:Boolean;
      
      private var rebelOpeningStarted:Boolean;
      
      private var rebelOpeningFinished:Boolean;
      
      private var rebelEndingStarted:Boolean;
      
      private var rebelEndingStartFrame:int;
      
      private var rebelRevealFog:Boolean;
      
      private var hordeRevealFog:Boolean;
      
      private var nightOverlay:Sprite;
      
      private var hasUnlockedStalkCloak:Boolean;
      
      private var pendingAttackRefreshes:Array;
      
      public function CampaignAmbush(gameScreen:GameScreen)
      {
         super(gameScreen);
         this.initialized = false;
         this.startFrame = 0;
         this.barrierX = 0;
         this.lastEnemyArmyVersion = -1;
         this.nativeWaveIndex = 0;
         this.stalkWaveIndex = 0;
         this.hordeWaveIndex = 0;
         this.hordeMarrowkaiSpawned = false;
         this.hordeCutsceneState = HORDE_CS_DONE;
         this.hordeCutsceneTimer = 0;
         this.hordeCutsceneMarrowkai = null;
         this.hordeCutsceneUndeads = [];
         this.hordeCutsceneActive = false;
         this.marrowkaiSummonTimer = 0;
         this.ambushCompleteDelayStartFrame = -1;
         this.hasShownStartMessage = false;
         this.hasSpawnedReinforcements = false;
         this.message = null;
         this.messageStartFrame = -1;
         this.infectionMessage = null;
         this.infectionMessageFrames = 0;
         this.activeNativeWaveUnits = [];
         this.activeStalkWaveUnits = [];
         this.activeHordeWaveUnits = [];
         this.activeRebelWaveUnits = [];
         this.rebelDisplayUnits = [];
         this.rebelWaveSpawned = false;
         this.rebelCameraQueued = false;
         this.rebelOpeningStarted = false;
         this.rebelOpeningFinished = false;
         this.rebelEndingStarted = false;
         this.rebelEndingStartFrame = -1;
         this.rebelRevealFog = false;
         this.hordeRevealFog = false;
         this.nightOverlay = null;
         this.hasUnlockedStalkCloak = false;
         this.pendingAttackRefreshes = [];
      }
      
      override public function update(gameScreen:GameScreen) : void
      {
         if(!this.initialized)
         {
            this.initializeAmbush(gameScreen);
         }
         gameScreen.isFastForward = false;
         this.updateMessage(gameScreen);
         this.updateInfectionMessage(gameScreen);
         this.updateAmbushFog(gameScreen);
         this.keepEnemyBaseHidden(gameScreen);
         this.updateNativeTribesWaves(gameScreen);
         this.updateShadowrathStalkersWaves(gameScreen);
         this.updateShadowrathStalkersCloak(gameScreen);
         this.updateRebelBreakAmbush(gameScreen);
         this.updateDeadHordeWaves(gameScreen);
         if(this.isDeadHordeLevel(gameScreen) && this.hordeCutsceneActive)
         {
            this.updateDeadHordeCutscene(gameScreen);
         }
         this.updatePendingAttackRefreshes(gameScreen);
         this.updateAmbusherOrders(gameScreen);
         this.stopSpawnedPlayerUnits(gameScreen);
         this.clampPlayerUnits(gameScreen);
         if(this.isRebelBreakLevel(gameScreen) || this.isDeadHordeLevel(gameScreen))
         {
            return;
         }
         if(gameScreen.game.frame - this.startFrame >= SURVIVE_FRAMES && !this.hasSpawnedReinforcements)
         {
            this.spawnReinforcements(gameScreen);
            this.hasSpawnedReinforcements = true;
         }
         if(gameScreen.game.frame - this.startFrame >= SURVIVE_FRAMES && this.hasSpawnedAllAmbushWaves(gameScreen) && !this.hasLivingEnemyCombatUnits(gameScreen))
         {
            if(this.ambushCompleteDelayStartFrame < 0)
            {
               this.ambushCompleteDelayStartFrame = gameScreen.game.frame;
            }
            if(gameScreen.game.frame - this.ambushCompleteDelayStartFrame >= COMPLETE_DELAY_FRAMES)
            {
               this.completeAmbush(gameScreen);
            }
         }
         else
         {
            this.ambushCompleteDelayStartFrame = -1;
         }
      }
      
      private function initializeAmbush(gameScreen:GameScreen) : void
      {
         this.initialized = true;
         this.startFrame = gameScreen.game.frame;
         this.barrierX = this.getAmbushBarrierX(gameScreen);
         gameScreen.doAiUpdates = false;
         gameScreen.isFastForward = false;
         if(!this.isRebelBreakLevel(gameScreen))
         {
            gameScreen.team.tech.isResearchedMap[Tech.CASTLE_ARCHER_1] = true;
         }
         gameScreen.team.tech.isResearchedMap[Tech.MINER_SPEED] = true;
         gameScreen.team.createTimeMultiplier = 0.5;
         gameScreen.team.tech.researchTimeMultiplier = 0.5;
         this.initializeShadowrathStalkers(gameScreen);
         this.initializeRebelBreak(gameScreen);
         this.initializeDeadHordeCutscene(gameScreen);
         this.removeMiddleHills(gameScreen);
         this.hideEnemyGoldVisuals(gameScreen);
         this.disableEnemyCastleDefence(gameScreen);
         this.applyShadowrathNightOverlay(gameScreen);
         this.updateAmbushFog(gameScreen);
         this.keepEnemyBaseHidden(gameScreen);
         this.updateAmbusherOrders(gameScreen);
      }
      
      private function getAmbushBarrierX(gameScreen:GameScreen) : Number
      {
         if(this.isShadowrathStalkersLevel(gameScreen))
         {
            return Math.min(gameScreen.game.map.width / 2 - BARRIER_PADDING,gameScreen.team.homeX + gameScreen.team.direction * SHADOWRATH_BARRIER_DISTANCE_FROM_BASE);
         }
         return gameScreen.game.map.width / 2 - BARRIER_PADDING;
      }
      
      private function initializeRebelBreak(gameScreen:GameScreen) : void
      {
         if(!this.isRebelBreakLevel(gameScreen))
         {
            return;
         }
         gameScreen.team.tech.isResearchedMap[Tech.MINER_SPEED] = true;
         gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.MINER_WALL] = false;
         gameScreen.team.enemyTeam.unitsAvailable[Unit.U_MINER] = 0;
         this.applyRebelBreakDifficultyResearch(gameScreen);
         this.clearEnemyStartingCombatUnits(gameScreen);
         gameScreen.team.enemyTeam.bypassMana = true;
         this.spawnRebelOpeningDisplay(gameScreen);
      }
      
      private function applyRebelBreakDifficultyResearch(gameScreen:GameScreen) : void
      {
         if(gameScreen.main == null || gameScreen.main.campaign == null)
         {
            return;
         }
         if(gameScreen.main.campaign.difficultyLevel == Campaign.D_NORMAL)
         {
            gameScreen.team.tech.isResearchedMap[Tech.CASTLE_ARCHER_1] = true;
            gameScreen.team.tech.isResearchedMap[Tech.BANK_PASSIVE_1] = true;
            gameScreen.team.tech.isResearchedMap[Tech.MAGIKILL_WALL] = true;
            gameScreen.team.tech.isResearchedMap[Tech.MAGIKILL_POISON] = true;
         }
         else if(gameScreen.main.campaign.difficultyLevel == Campaign.D_HARD)
         {
            gameScreen.team.tech.isResearchedMap[Tech.BANK_PASSIVE_1] = true;
            gameScreen.team.tech.isResearchedMap[Tech.MAGIKILL_POISON] = true;
         }
         gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.MAGIKILL_POISON] = true;
         gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.MAGIKILL_WALL] = true;
         gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CLOAK] = true;
      }
      
      private function initializeShadowrathStalkers(gameScreen:GameScreen) : void
      {
         if(!this.isShadowrathStalkersLevel(gameScreen))
         {
            return;
         }
         gameScreen.team.tech.isResearchedMap[Tech.MINER_SPEED] = true;
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CLOAK];
         this.clearEnemyStartingCombatUnits(gameScreen);
      }
      
      private function applyShadowrathNightOverlay(gameScreen:GameScreen) : void
      {
         if(!this.isShadowrathStalkersLevel(gameScreen) || gameScreen.game == null || gameScreen.game.stage == null)
         {
            return;
         }
         if(this.nightOverlay != null)
         {
            return;
         }
         this.nightOverlay = new Sprite();
         this.nightOverlay.mouseEnabled = false;
         this.nightOverlay.mouseChildren = false;
         this.nightOverlay.graphics.beginFill(SHADOWRATH_NIGHT_TINT_COLOR,SHADOWRATH_NIGHT_TINT_ALPHA);
         this.nightOverlay.graphics.drawRect(0,0,gameScreen.game.stage.stageWidth,gameScreen.game.stage.stageHeight);
         this.nightOverlay.graphics.endFill();
         gameScreen.game.addChild(this.nightOverlay);
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
         if(this.isDeadHordeLevel(gameScreen))
         {
            this.message.setMessage("Dead Horde approaches! Survive the undead onslaught!","");
         }
         else
         {
            this.message.setMessage("Defend until Reinforcements arrive","");
         }
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
         if(!this.infectionMessage && this.isDeadHordeLevel(gameScreen))
         {
            for each(var uInfected in gameScreen.team.units)
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
      
      private function updateAmbushFog(gameScreen:GameScreen) : void
      {
         if(gameScreen.game.fogOfWar == null)
         {
            return;
         }
         if(gameScreen is CampaignGameScreen && gameScreen.isDebugFullVisionEnabled)
         {
            gameScreen.game.fogOfWar.isFogOn = false;
            return;
         }
         if(this.rebelRevealFog || this.hordeRevealFog)
         {
            gameScreen.game.fogOfWar.isFogOn = false;
            return;
         }
         if(this.isNativeTribesLevel(gameScreen) || this.isShadowrathStalkersLevel(gameScreen) || this.isRebelBreakLevel(gameScreen) || this.isDeadHordeLevel(gameScreen))
         {
            gameScreen.game.fogOfWar.isFogOn = true;
            gameScreen.game.fogOfWar.lockForwardPosition(this.barrierX);
         }
      }
      
      private function keepEnemyBaseHidden(gameScreen:GameScreen) : void
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
            gameScreen.team.enemyTeam.statue.health = Math.max(gameScreen.team.enemyTeam.statue.health,1);
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
         i = int(gameScreen.game.map.gold.length / 2);
         while(i < gameScreen.game.map.gold.length)
         {
            gold = gameScreen.game.map.gold[i] as Gold;
            if(gold != null)
            {
               gold.ore.visible = false;
               gold.frontOre.visible = false;
               gold.ore.mouseEnabled = false;
               gold.frontOre.mouseEnabled = false;
            }
            i++;
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
      
      private function disableEnemyCastleDefence(gameScreen:GameScreen) : void
      {
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CASTLE_ARCHER_1];
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CASTLE_ARCHER_2];
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CASTLE_ARCHER_3];
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CASTLE_ARCHER_4];
         delete gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CASTLE_ARCHER_5];
      }
      
      private function clampPlayerUnits(gameScreen:GameScreen) : void
      {
         var unit:Unit = null;
         if(this.isRebelBreakLevel(gameScreen) && this.rebelOpeningFinished)
         {
            return;
         }
         for each(unit in gameScreen.team.units)
         {
            if(unit != null && unit.isAlive() && this.rebelDisplayUnits.indexOf(unit) == -1 && unit.px > this.barrierX)
            {
               unit.px = this.barrierX;
               unit.x = unit.px;
               this.holdUnit(gameScreen,unit);
            }
         }
      }
      
      private function updateAmbusherOrders(gameScreen:GameScreen) : void
      {
         var unit:Unit = null;
         if(this.isNativeTribesLevel(gameScreen) || this.isShadowrathStalkersLevel(gameScreen) || this.isRebelBreakLevel(gameScreen) || this.isDeadHordeLevel(gameScreen))
         {
            return;
         }
         if(this.lastEnemyArmyVersion == gameScreen.team.enemyTeam.armyChangeVersion)
         {
            return;
         }
         this.lastEnemyArmyVersion = gameScreen.team.enemyTeam.armyChangeVersion;
         for each(unit in gameScreen.team.enemyTeam.units)
         {
            if(unit != null && unit.isAlive() && unit.type != Unit.U_MINER && unit.type != Unit.U_CHAOS_MINER && unit.type != Unit.U_CHAOS_TOWER)
            {
               this.issueAmbushAttackCommand(gameScreen,unit);
            }
         }
      }
      
      private function issueAmbushAttackCommand(gameScreen:GameScreen, unit:Unit, goalY:Number = -1) : void
      {
         var attackMoveCommand:AttackMoveCommand = null;
         if(unit.ai == null)
         {
            return;
         }
         attackMoveCommand = new AttackMoveCommand(gameScreen.game);
         attackMoveCommand.type = UnitCommand.ATTACK_MOVE;
         attackMoveCommand.goalX = gameScreen.team.statue.px;
         attackMoveCommand.goalY = goalY < 0 ? gameScreen.game.map.height / 2 : goalY;
         attackMoveCommand.realX = attackMoveCommand.goalX;
         attackMoveCommand.realY = attackMoveCommand.goalY;
         unit.ai.setCommand(gameScreen.game,attackMoveCommand);
      }
      
      private function updateNativeTribesWaves(gameScreen:GameScreen) : void
      {
         var elapsed:int = gameScreen.game.frame - this.startFrame;
         if(!this.isNativeTribesLevel(gameScreen))
         {
            return;
         }
         if(this.hasLivingActiveNativeWaveUnits())
         {
            return;
         }
         if(this.nativeWaveIndex < NATIVE_WAVE_TIMES.length && elapsed >= int(NATIVE_WAVE_TIMES[this.nativeWaveIndex]))
         {
            this.spawnNativeWave(gameScreen,int(this.getNativeWaveSpeartons(gameScreen)[this.nativeWaveIndex]),int(this.getNativeWaveSwordwraths(gameScreen)[this.nativeWaveIndex]));
            ++this.nativeWaveIndex;
         }
      }
      
      private function updateShadowrathStalkersWaves(gameScreen:GameScreen) : void
      {
         var elapsed:int = gameScreen.game.frame - this.startFrame;
         if(!this.isShadowrathStalkersLevel(gameScreen))
         {
            return;
         }
         this.updateShadowrathCloakUnlock(gameScreen,elapsed);
         if(this.hasLivingActiveStalkWaveUnits())
         {
            return;
         }
         if(this.stalkWaveIndex < STALK_WAVE_TIMES.length && elapsed >= int(STALK_WAVE_TIMES[this.stalkWaveIndex]))
         {
            this.spawnStalkWave(gameScreen,int(this.getStalkWaveShadowraths(gameScreen)[this.stalkWaveIndex]));
            ++this.stalkWaveIndex;
         }
      }
      
      private function updateShadowrathCloakUnlock(gameScreen:GameScreen, elapsed:int) : void
      {
         if(this.hasUnlockedStalkCloak || elapsed < STALK_CLOAK_UNLOCK_FRAME)
         {
            return;
         }
         this.hasUnlockedStalkCloak = true;
         gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.CLOAK] = true;
      }
      
      private function getStalkWaveShadowraths(gameScreen:GameScreen) : Array
      {
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_INSANE)
         {
            return STALK_WAVE_SHADOWRATHS_INSANE;
         }
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_HARD)
         {
            return STALK_WAVE_SHADOWRATHS_HARD;
         }
         return STALK_WAVE_SHADOWRATHS_NORMAL;
      }
      
      private function getNativeWaveSpeartons(gameScreen:GameScreen) : Array
      {
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_INSANE)
         {
            return NATIVE_WAVE_SPEARTONS_INSANE;
         }
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_HARD)
         {
            return NATIVE_WAVE_SPEARTONS_HARD;
         }
         return NATIVE_WAVE_SPEARTONS_NORMAL;
      }
      
      private function getNativeWaveSwordwraths(gameScreen:GameScreen) : Array
      {
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_INSANE)
         {
            return NATIVE_WAVE_SWORDWRATHS_INSANE;
         }
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_HARD)
         {
            return NATIVE_WAVE_SWORDWRATHS_HARD;
         }
         return NATIVE_WAVE_SWORDWRATHS_NORMAL;
      }
      
      private function spawnNativeWave(gameScreen:GameScreen, speartonCount:int, swordwrathCount:int) : void
      {
         var i:int = 0;
         var spearton:Spearton = null;
         var swordwrath:Swordwrath = null;
         var spawnedUnits:Array = [];
         var refreshEntries:Array = [];
         var goalY:Number = 0;
         var totalCount:int = speartonCount + swordwrathCount;
         i = 0;
         while(i < speartonCount)
         {
            spearton = gameScreen.game.unitFactory.getUnit(Unit.U_SPEARTON);
            gameScreen.team.enemyTeam.spawn(spearton,gameScreen.game);
            goalY = this.getNativeFormationGoalY(gameScreen,i,totalCount);
            spearton.px = this.getNativeFormationSpawnX(gameScreen,i);
            spearton.x = spearton.px;
            spearton.py = goalY;
            spearton.y = spearton.py;
            spearton.scaleX *= gameScreen.team.enemyTeam.direction * -1;
            spearton.forceSkin(NATIVE_SPEARTON_WEAPON,NATIVE_SPEARTON_ARMOR,NATIVE_SPEARTON_MISC);
            spearton.maxHealth *= NATIVE_HEALTH_MULTIPLIER;
            spearton.health = spearton.maxHealth;
            spearton.healthBar.totalHealth = spearton.maxHealth;
            spearton.healthBar.health = spearton.health;
            spearton.healthBar.reset();
            this.issueAmbushAttackCommand(gameScreen,spearton,goalY);
            spawnedUnits.push(spearton);
            refreshEntries.push([spearton,goalY]);
            i++;
         }
         i = 0;
         while(i < swordwrathCount)
         {
            swordwrath = gameScreen.game.unitFactory.getUnit(Unit.U_SWORDWRATH);
            gameScreen.team.enemyTeam.spawn(swordwrath,gameScreen.game);
            goalY = this.getNativeFormationGoalY(gameScreen,speartonCount + i,totalCount);
            swordwrath.px = this.getNativeFormationSpawnX(gameScreen,speartonCount + i);
            swordwrath.x = swordwrath.px;
            swordwrath.py = goalY;
            swordwrath.y = swordwrath.py;
            swordwrath.scaleX *= gameScreen.team.enemyTeam.direction * -1;
            swordwrath.forceSkin(NATIVE_SWORDWRATH_WEAPON);
            swordwrath.maxHealth *= NATIVE_HEALTH_MULTIPLIER;
            swordwrath.health = swordwrath.maxHealth;
            swordwrath.healthBar.totalHealth = swordwrath.maxHealth;
            swordwrath.healthBar.health = swordwrath.health;
            swordwrath.healthBar.reset();
            this.issueAmbushAttackCommand(gameScreen,swordwrath,goalY);
            spawnedUnits.push(swordwrath);
            refreshEntries.push([swordwrath,goalY]);
            i++;
         }
         this.activeNativeWaveUnits = spawnedUnits;
         this.pendingAttackRefreshes.push([gameScreen.game.frame + ATTACK_REFRESH_DELAY_FRAMES,refreshEntries]);
      }
      
      private function spawnStalkWave(gameScreen:GameScreen, shadowrathCount:int) : void
      {
         var i:int = 0;
         var ninja:Ninja = null;
         var spawnedUnits:Array = [];
         var refreshEntries:Array = [];
         var goalY:Number = 0;
         if(shadowrathCount <= 0)
         {
            this.activeStalkWaveUnits = [];
            return;
         }
         i = 0;
         while(i < shadowrathCount)
         {
            ninja = gameScreen.game.unitFactory.getUnit(Unit.U_NINJA);
            gameScreen.team.enemyTeam.spawn(ninja,gameScreen.game);
            goalY = this.getNativeFormationGoalY(gameScreen,i,shadowrathCount);
            ninja.px = this.getNativeFormationSpawnX(gameScreen,i);
            ninja.x = ninja.px;
            ninja.py = goalY;
            ninja.y = ninja.py;
            ninja.scaleX *= gameScreen.team.enemyTeam.direction * -1;
            this.issueAmbushAttackCommand(gameScreen,ninja,goalY);
            spawnedUnits.push(ninja);
            refreshEntries.push([ninja,goalY]);
            i++;
         }
         this.activeStalkWaveUnits = spawnedUnits;
         this.pendingAttackRefreshes.push([gameScreen.game.frame + ATTACK_REFRESH_DELAY_FRAMES,refreshEntries]);
      }
      
      private function updateShadowrathStalkersCloak(gameScreen:GameScreen) : void
      {
         var unit:Unit = null;
         var ninja:Ninja = null;
         var triggerX:Number = Number(NaN);
         if(!this.hasUnlockedStalkCloak || !this.isShadowrathStalkersLevel(gameScreen))
         {
            return;
         }
         triggerX = this.barrierX + gameScreen.team.direction * STALK_CLOAK_TRIGGER_PADDING;
         for each(unit in this.activeStalkWaveUnits)
         {
            ninja = unit as Ninja;
            if(ninja != null && ninja.isAlive() && !ninja.isStealthed && (ninja.px - triggerX) * gameScreen.team.direction <= 0)
            {
               ninja.stealth();
            }
         }
      }
      
      private function updateRebelBreakAmbush(gameScreen:GameScreen) : void
      {
         var elapsed:int = gameScreen.game.frame - this.startFrame;
         if(!this.isRebelBreakLevel(gameScreen))
         {
            return;
         }
         if(!this.rebelOpeningStarted && elapsed >= REBEL_OPENING_DELAY_FRAMES)
         {
            this.startRebelOpening(gameScreen);
         }
         if(this.rebelCameraQueued && !this.rebelOpeningFinished && elapsed >= REBEL_OPENING_DELAY_FRAMES + REBEL_CAMERA_DELAY_FRAMES)
         {
            this.setCameraTarget(gameScreen,this.getEnemyCameraX(gameScreen) - 100);
            this.rebelCameraQueued = false;
         }
         if(this.rebelOpeningStarted && !this.rebelOpeningFinished && elapsed >= REBEL_OPENING_DELAY_FRAMES + REBEL_OPENING_HOLD_FRAMES)
         {
            this.finishRebelOpening(gameScreen);
         }
         if(!this.rebelWaveSpawned && elapsed >= REBEL_WAVE_FRAME)
         {
            this.spawnRebelWave(gameScreen);
            this.rebelWaveSpawned = true;
         }
         if(this.rebelWaveSpawned && !this.rebelEndingStarted && !this.hasLivingActiveRebelWaveUnits())
         {
            if(this.ambushCompleteDelayStartFrame < 0)
            {
               this.showAmbushMessage(gameScreen,"Something has intercepted the rebels");
               this.ambushCompleteDelayStartFrame = gameScreen.game.frame;
            }
            if(gameScreen.game.frame - this.ambushCompleteDelayStartFrame >= REBEL_END_MESSAGE_FRAMES)
            {
               this.startRebelEnding(gameScreen);
            }
         }
         if(this.rebelWaveSpawned && !this.rebelEndingStarted && elapsed >= REBEL_WAVE_FRAME + REBEL_WAVE_ENDING_TIMEOUT_FRAMES)
         {
            this.startRebelEnding(gameScreen);
         }
         if(this.rebelEndingStarted && gameScreen.game.frame - this.rebelEndingStartFrame >= REBEL_ENDING_HOLD_FRAMES)
         {
            this.rebelRevealFog = false;
            this.hordeRevealFog = false;
            this.completeAmbush(gameScreen);
         }
      }
      
      private function startRebelOpening(gameScreen:GameScreen) : void
      {
         this.rebelOpeningStarted = true;
         this.rebelRevealFog = true;
         this.showAmbushMessage(gameScreen,"Rebels are sending everything they have at you! Prepare a defense");
         this.rebelCameraQueued = true;
      }
      
      private function finishRebelOpening(gameScreen:GameScreen) : void
      {
         this.rebelOpeningFinished = true;
         this.rebelRevealFog = false;
         this.cleanupRebelDisplayUnits(gameScreen);
         this.killAllEnemyUnits(gameScreen);
         this.setCameraTarget(gameScreen,gameScreen.team.homeX + gameScreen.team.direction * 300);
      }
      
      private function startRebelEnding(gameScreen:GameScreen) : void
      {
         this.rebelEndingStarted = true;
         this.rebelEndingStartFrame = gameScreen.game.frame;
         this.rebelRevealFog = true;
         gameScreen.doAiUpdates = true;
         this.pendingAttackRefreshes = [];
         if(this.message != null && gameScreen.contains(this.message))
         {
            gameScreen.removeChild(this.message);
            this.message = null;
         }
         this.spawnRebelEndingBattle(gameScreen);
         this.setCameraTarget(gameScreen,gameScreen.team.enemyTeam.homeX + gameScreen.team.enemyTeam.direction * 1100);
      }
      
      private function spawnRebelOpeningDisplay(gameScreen:GameScreen) : void
      {
         var displayTypes:Array = [Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SPEARTON,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_SWORDWRATH,Unit.U_NINJA,Unit.U_NINJA,Unit.U_NINJA,Unit.U_NINJA,Unit.U_NINJA,Unit.U_NINJA,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER,Unit.U_ARCHER];
         var bossTypes:Array = [Unit.U_SPEARTON,Unit.U_ARCHER,Unit.U_NINJA,Unit.U_MAGIKILL,Unit.U_MONK];
         var i:int = 0;
         var column:int = 0;
         var row:int = 0;
         var rowsInColumn:int = 0;
         var lastCol:int = int(Math.ceil(displayTypes.length / 6));
         i = 0;
         while(i < bossTypes.length)
         {
            column = 0;
            row = i;
            rowsInColumn = int(bossTypes.length);
            var bossUnit:Unit = this.spawnDisplayUnit(gameScreen,gameScreen.team.enemyTeam,int(bossTypes[i]),this.getEnemyDisplayX_New(gameScreen,column,row),this.getDisplayY_New(gameScreen,row,rowsInColumn,column),true,false);
            if(bossUnit != null)
            {
               bossUnit.bossAbilitySpawnLockFrames = 999999;
            }
            i++;
         }
         i = 0;
         while(i < displayTypes.length)
         {
            column = lastCol - int(i / 6);
            row = i % 6;
            rowsInColumn = Math.min(6,displayTypes.length - i);
            this.spawnDisplayUnit(gameScreen,gameScreen.team.enemyTeam,int(displayTypes[i]),this.getEnemyDisplayX_New(gameScreen,column,row),this.getDisplayY_New(gameScreen,row,rowsInColumn,column),false,false);
            i++;
         }
      }
      
      private function spawnRebelWave(gameScreen:GameScreen) : void
      {
         var wave:Array = this.getRebelWaveTypes(gameScreen);
         var refreshEntries:Array = [];
         var unit:Unit = null;
         var goalY:Number = 0;
         var i:int = 0;
         var spawnX:Number = 0;
         this.activeRebelWaveUnits = [];
         i = 0;
         while(i < wave.length)
         {
            unit = gameScreen.game.unitFactory.getUnit(int(wave[i]));
            gameScreen.team.enemyTeam.spawn(unit,gameScreen.game);
            goalY = this.getNativeFormationGoalY(gameScreen,i,wave.length);
            spawnX = gameScreen.game.map.width / 2 + 200;
            unit.px = spawnX;
            unit.x = unit.px;
            unit.py = goalY;
            unit.y = unit.py;
            unit.scaleX *= gameScreen.team.enemyTeam.direction * -1;
            this.issueAmbushAttackCommand(gameScreen,unit,goalY);
            this.activeRebelWaveUnits.push(unit);
            if(int(wave[i]) == Unit.U_MAGIKILL)
            {
               unit.allowAiAutoCast = true;
            }
            else
            {
               refreshEntries.push([unit,goalY]);
            }
            i++;
         }
         this.pendingAttackRefreshes.push([gameScreen.game.frame + ATTACK_REFRESH_DELAY_FRAMES,refreshEntries]);
      }
      
      private function spawnRebelEndingBattle(gameScreen:GameScreen) : void
      {
         var pairs:Array = [[Unit.U_SPEARTON,Unit.U_KNIGHT],[Unit.U_SPEARTON,Unit.U_GIANT],[Unit.U_ARCHER,Unit.U_KNIGHT],[Unit.U_ARCHER,Unit.U_CAT],[Unit.U_SPEARTON,Unit.U_GIANT],[Unit.U_NINJA,Unit.U_BOMBER],[Unit.U_SWORDWRATH,Unit.U_DEAD],[Unit.U_SPEARTON,Unit.U_GIANT],[Unit.U_ARCHER,Unit.U_KNIGHT],[Unit.U_MAGIKILL,Unit.U_KNIGHT],[Unit.U_MONK,Unit.U_DEAD],[Unit.U_SPEARTON,Unit.U_GIANT]];
         var bossTypes:Array = [Unit.U_NINJA,Unit.U_MAGIKILL,Unit.U_SPEARTON];
         var i:int = 0;
         var rebel:Unit = null;
         var chaos:Unit = null;
         var GAP:Number = 160;
         if(gameScreen.team.unitGroups[Unit.U_KNIGHT] == null)
         {
            gameScreen.team.unitGroups[Unit.U_KNIGHT] = [];
         }
         if(gameScreen.team.unitGroups[Unit.U_DEAD] == null)
         {
            gameScreen.team.unitGroups[Unit.U_DEAD] = [];
         }
         if(gameScreen.team.unitGroups[Unit.U_BOMBER] == null)
         {
            gameScreen.team.unitGroups[Unit.U_BOMBER] = [];
         }
         if(gameScreen.team.unitGroups[Unit.U_CAT] == null)
         {
            gameScreen.team.unitGroups[Unit.U_CAT] = [];
         }
         if(gameScreen.team.unitGroups[Unit.U_WINGIDON] == null)
         {
            gameScreen.team.unitGroups[Unit.U_WINGIDON] = [];
         }
         if(gameScreen.team.unitGroups[Unit.U_GIANT] == null)
         {
            gameScreen.team.unitGroups[Unit.U_GIANT] = [];
         }
         i = 0;
         while(i < pairs.length)
         {
            var column:int = int(i / 5);
            var row:int = i % 5;
            var centerX:Number = gameScreen.team.enemyTeam.homeX + gameScreen.team.enemyTeam.direction * (550 + column * 350);
            var pairY:Number = gameScreen.game.map.height / 2 + (row - 2) * 90;
            pairY = Math.max(80,Math.min(gameScreen.game.map.height - 80,pairY));
            var rebelX:Number = centerX - GAP / 2;
            var chaosX:Number = centerX + GAP / 2;
            if(gameScreen.game.random.nextNumber() > 0.5)
            {
               rebelX = centerX + GAP / 2;
               chaosX = centerX - GAP / 2;
            }
            rebel = this.spawnDisplayUnit(gameScreen,gameScreen.team.enemyTeam,int(pairs[i][0]),rebelX,pairY,false,true);
            if(rebel != null)
            {
               rebel.health = Math.max(1,rebel.maxHealth * (i % 3 == 0 ? 0.25 : 0.5));
               rebel.healthBar.health = rebel.health;
               rebel.healthBar.reset();
            }
            chaos = this.spawnDisplayUnitRaw(gameScreen,gameScreen.team,int(pairs[i][1]),chaosX,pairY,false,true);
            if(chaos != null)
            {
               chaos.id = gameScreen.game.getNextUnitId();
               gameScreen.game.units[chaos.id] = chaos;
               gameScreen.team.units.push(chaos);
               if(gameScreen.team.unitGroups[chaos.type] != null)
               {
                  gameScreen.team.unitGroups[chaos.type].push(chaos);
               }
               chaos.ai.init();
               var dummyCmd:AttackMoveCommand = new AttackMoveCommand(gameScreen.game);
               dummyCmd.goalX = gameScreen.team.enemyTeam.homeX;
               dummyCmd.goalY = gameScreen.game.map.height / 2;
               chaos.ai.currentCommand = dummyCmd;
               var chaosCmd:AttackMoveCommand = new AttackMoveCommand(gameScreen.game);
               chaosCmd.goalX = gameScreen.team.enemyTeam.homeX;
               chaosCmd.goalY = gameScreen.game.map.height / 2;
               chaos.ai.setCommand(gameScreen.game,chaosCmd);
               chaos.cure();
               this.tintUnitRed(chaos);
            }
            i++;
         }
         i = 0;
         while(i < bossTypes.length)
         {
            rebel = this.spawnDisplayUnit(gameScreen,gameScreen.team.enemyTeam,int(bossTypes[i]),gameScreen.team.enemyTeam.homeX + gameScreen.team.enemyTeam.direction * (220 + i * 80),gameScreen.game.map.height / 2 + (i - 1) * 70,true,true);
            if(rebel != null)
            {
               if(rebel is Ninja)
               {
                  rebel.bossAbilitySpawnLockFrames = 999999;
               }
            }
            i++;
         }
      }
      
      private function getRebelWaveTypes(gameScreen:GameScreen) : Array
      {
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_INSANE)
         {
            return REBEL_WAVE_INSANE;
         }
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_HARD)
         {
            return REBEL_WAVE_HARD;
         }
         return REBEL_WAVE_NORMAL;
      }
      
      private function spawnReinforcements(gameScreen:GameScreen) : void
      {
         var i:int = 0;
         var swordwrath:Swordwrath = null;
         var spearton:Spearton = null;
         var totalCount:int = REINFORCEMENT_SWORDWRATHS + REINFORCEMENT_SPEARTONS;
         var goalY:Number = 0;
         i = 0;
         while(i < REINFORCEMENT_SWORDWRATHS)
         {
            swordwrath = gameScreen.game.unitFactory.getUnit(Unit.U_SWORDWRATH);
            gameScreen.team.spawn(swordwrath,gameScreen.game);
            goalY = this.getReinforcementFormationY(gameScreen,i,totalCount);
            swordwrath.px = this.getReinforcementFormationX(gameScreen,i);
            swordwrath.x = swordwrath.px;
            swordwrath.py = goalY;
            swordwrath.y = swordwrath.py;
            i++;
         }
         i = 0;
         while(i < REINFORCEMENT_SPEARTONS)
         {
            spearton = gameScreen.game.unitFactory.getUnit(Unit.U_SPEARTON);
            gameScreen.team.spawn(spearton,gameScreen.game);
            goalY = this.getReinforcementFormationY(gameScreen,REINFORCEMENT_SWORDWRATHS + i,totalCount);
            spearton.px = this.getReinforcementFormationX(gameScreen,REINFORCEMENT_SWORDWRATHS + i);
            spearton.x = spearton.px;
            spearton.py = goalY;
            spearton.y = spearton.py;
            i++;
         }
      }
      
      private function getReinforcementFormationX(gameScreen:GameScreen, formationIndex:int) : Number
      {
         var column:int = int(formationIndex / NATIVE_FORMATION_MAX_ROWS);
         return gameScreen.team.homeX + gameScreen.team.direction * (REINFORCEMENT_BASE_SPAWN_OFFSET + column * NATIVE_FORMATION_COLUMN_SPACING);
      }
      
      private function getReinforcementFormationY(gameScreen:GameScreen, formationIndex:int, totalCount:int) : Number
      {
         var column:int = int(formationIndex / NATIVE_FORMATION_MAX_ROWS);
         var row:int = formationIndex % NATIVE_FORMATION_MAX_ROWS;
         var rowsInColumn:int = Math.min(NATIVE_FORMATION_MAX_ROWS,totalCount - column * NATIVE_FORMATION_MAX_ROWS);
         var goalY:Number = gameScreen.game.map.height / 2 + (row - (rowsInColumn - 1) / 2) * NATIVE_FORMATION_ROW_SPACING;
         return Math.max(NATIVE_FORMATION_GOAL_PADDING,Math.min(gameScreen.game.map.height - NATIVE_FORMATION_GOAL_PADDING,goalY));
      }
      
      private function getNativeFormationGoalY(gameScreen:GameScreen, formationIndex:int, totalCount:int) : Number
      {
         var column:int = int(formationIndex / NATIVE_FORMATION_MAX_ROWS);
         var row:int = formationIndex % NATIVE_FORMATION_MAX_ROWS;
         var rowsInColumn:int = Math.min(NATIVE_FORMATION_MAX_ROWS,totalCount - column * NATIVE_FORMATION_MAX_ROWS);
         var goalY:Number = gameScreen.game.map.height / 2 + (row - (rowsInColumn - 1) / 2) * NATIVE_FORMATION_ROW_SPACING;
         return Math.max(NATIVE_FORMATION_GOAL_PADDING,Math.min(gameScreen.game.map.height - NATIVE_FORMATION_GOAL_PADDING,goalY));
      }
      
      private function getNativeFormationSpawnX(gameScreen:GameScreen, formationIndex:int) : Number
      {
         var column:int = int(formationIndex / NATIVE_FORMATION_MAX_ROWS);
         var row:int = formationIndex % NATIVE_FORMATION_MAX_ROWS;
         return gameScreen.team.enemyTeam.homeX + gameScreen.team.enemyTeam.direction * (NATIVE_BASE_SPAWN_OFFSET + column * NATIVE_FORMATION_COLUMN_SPACING + row * 6);
      }
      
      private function getEnemyDisplayX_New(gameScreen:GameScreen, column:int, row:int) : Number
      {
         return gameScreen.team.enemyTeam.homeX + gameScreen.team.enemyTeam.direction * (220 + column * 80);
      }
      
      private function getDisplayY_New(gameScreen:GameScreen, row:int, rowsInColumn:int, column:int) : Number
      {
         var goalY:Number = gameScreen.game.map.height / 2 + (row - (rowsInColumn - 1) / 2) * 200;
         return Math.max(80,Math.min(gameScreen.game.map.height - 80,goalY));
      }
      
      private function getEndingBattleX(gameScreen:GameScreen, formationIndex:int, rebelSide:Boolean) : Number
      {
         var spread:Number = formationIndex % 5 * 110 + int(formationIndex / 5) * 60;
         var baseOffset:Number = rebelSide ? 450 : 850;
         return gameScreen.team.enemyTeam.homeX + gameScreen.team.enemyTeam.direction * (baseOffset + spread);
      }
      
      private function getEndingBattleY(gameScreen:GameScreen, formationIndex:int) : Number
      {
         var offsets:Array = [-145,-75,30,115,-15,160,-110,75,0,140,-165,95];
         return Math.max(80,Math.min(gameScreen.game.map.height - 80,gameScreen.game.map.height / 2 + Number(offsets[formationIndex % offsets.length])));
      }
      
      private function spawnDisplayUnit(gameScreen:GameScreen, spawnTeam:Team, unitType:int, xPos:Number, yPos:Number, makeBoss:Boolean = false, allowAi:Boolean = false) : Unit
      {
         var unit:Unit = null;
         if(spawnTeam == null)
         {
            return null;
         }
         unit = gameScreen.game.unitFactory.getUnit(unitType);
         if(unit == null)
         {
            return null;
         }
         if(unit.mc == null)
         {
            return null;
         }
         spawnTeam.spawn(unit,gameScreen.game);
         unit.px = unit.x = xPos;
         unit.py = unit.y = yPos;
         unit.scaleX *= spawnTeam.direction * -1;
         unit.isBossMovementLocked = !allowAi;
         if(makeBoss)
         {
            this.makeDisplayBoss(unit);
         }
         if(!allowAi)
         {
            this.holdUnit(gameScreen,unit);
         }
         this.rebelDisplayUnits.push(unit);
         return unit;
      }
      
      private function spawnDisplayUnitRaw(gameScreen:GameScreen, spawnTeam:Team, unitType:int, xPos:Number, yPos:Number, makeBoss:Boolean = false, allowAi:Boolean = false) : Unit
      {
         var unit:Unit = null;
         if(spawnTeam == null)
         {
            return null;
         }
         unit = gameScreen.game.unitFactory.getUnit(unitType);
         if(unit == null)
         {
            return null;
         }
         if(unit.mc == null)
         {
            return null;
         }
         unit.team = spawnTeam;
         unit.setBuilding();
         unit.px = unit.x = xPos;
         unit.py = unit.y = yPos;
         unit.scaleX *= spawnTeam.direction * -1;
         unit.isBossMovementLocked = !allowAi;
         unit.isDead = false;
         unit.isDieing = false;
         unit.init(gameScreen.game);
         gameScreen.game.battlefield.addChildAt(unit,0);
         if(makeBoss)
         {
            this.makeDisplayBoss(unit);
         }
         if(!allowAi)
         {
            this.holdUnit(gameScreen,unit);
         }
         this.rebelDisplayUnits.push(unit);
         return unit;
      }
      
      private function getDisplayTeam(gameScreen:GameScreen, teamType:int, homeX:int, direction:int, isEnemy:Boolean) : Team
      {
         var displayTeam:Team = Team.getTeamFromId(teamType,gameScreen.game,9999,gameScreen.team.techAllowed);
         displayTeam.homeX = homeX;
         displayTeam.direction = direction;
         displayTeam.isEnemy = isEnemy;
         displayTeam.enemyTeam = gameScreen.team.enemyTeam;
         return displayTeam;
      }
      
      private function makeDisplayBoss(unit:Unit) : void
      {
         if(unit is Spearton)
         {
            unit.makeBoss();
         }
         else if(unit is Archer)
         {
            unit.makeBoss();
         }
         else if(unit is Ninja)
         {
            unit.makeBoss();
         }
         else if(unit is Magikill)
         {
            unit.makeBoss();
         }
         else if(unit is Monk)
         {
            unit.makeBoss();
         }
      }
      
      private function tintUnitRed(unit:Unit) : void
      {
         var color:ColorTransform = null;
         if(unit == null || unit.mc == null)
         {
            return;
         }
         color = unit.mc.transform.colorTransform;
         color.redOffset = 75;
         color.greenOffset = 0;
         color.blueOffset = 0;
         unit.mc.transform.colorTransform = color;
      }
      
      private function hasLivingActiveNativeWaveUnits() : Boolean
      {
         var i:int = 0;
         var unit:Unit = null;
         while(i < this.activeNativeWaveUnits.length)
         {
            unit = this.activeNativeWaveUnits[i] as Unit;
            if(!(unit == null || !unit.isAlive()))
            {
               return true;
            }
            this.activeNativeWaveUnits.splice(i,1);
         }
         return false;
      }
      
      private function hasLivingActiveStalkWaveUnits() : Boolean
      {
         var i:int = 0;
         var unit:Unit = null;
         while(i < this.activeStalkWaveUnits.length)
         {
            unit = this.activeStalkWaveUnits[i] as Unit;
            if(!(unit == null || !unit.isAlive()))
            {
               return true;
            }
            this.activeStalkWaveUnits.splice(i,1);
         }
         return false;
      }
      
      private function hasLivingActiveRebelWaveUnits() : Boolean
      {
         var i:int = 0;
         var unit:Unit = null;
         while(i < this.activeRebelWaveUnits.length)
         {
            unit = this.activeRebelWaveUnits[i] as Unit;
            if(!(unit == null || !unit.isAlive()))
            {
               return true;
            }
            this.activeRebelWaveUnits.splice(i,1);
         }
         return false;
      }
      
      private function hasSpawnedAllAmbushWaves(gameScreen:GameScreen) : Boolean
      {
         if(this.isNativeTribesLevel(gameScreen))
         {
            return this.nativeWaveIndex >= NATIVE_WAVE_TIMES.length;
         }
         if(this.isShadowrathStalkersLevel(gameScreen))
         {
            return this.stalkWaveIndex >= STALK_WAVE_TIMES.length;
         }
         if(this.isRebelBreakLevel(gameScreen))
         {
            return this.rebelWaveSpawned;
         }
         if(this.isDeadHordeLevel(gameScreen))
         {
            return this.hordeMarrowkaiSpawned;
         }
         return true;
      }
      
      private function updateDeadHordeWaves(gameScreen:GameScreen) : void
      {
         var elapsed:int = gameScreen.game.frame - this.startFrame;
         if(!this.isDeadHordeLevel(gameScreen))
         {
            return;
         }
         if(this.hordeCutsceneActive)
         {
            return;
         }
         if(this.hordeMarrowkaiSpawned)
         {
            if(!this.hasLivingActiveHordeWaveUnits())
            {
               if(this.ambushCompleteDelayStartFrame < 0)
               {
                  this.ambushCompleteDelayStartFrame = gameScreen.game.frame;
               }
               if(gameScreen.game.frame - this.ambushCompleteDelayStartFrame >= COMPLETE_DELAY_FRAMES)
               {
                  this.completeAmbush(gameScreen);
               }
            }
            else
            {
               this.ambushCompleteDelayStartFrame = -1;
            }
            if(gameScreen.game.frame - this.marrowkaiSummonTimer >= 360 && this.activeHordeWaveUnits.length > 0)
            {
               var marrowkai:Skelator = this.activeHordeWaveUnits[0];
               if(marrowkai != null && marrowkai.isAlive() && marrowkai.notInSpell())
               {
                  marrowkai.bossSummonFist(gameScreen.team.statue.px,gameScreen.game.map.height / 2);
               }
               this.marrowkaiSummonTimer = gameScreen.game.frame;
            }
            return;
         }
         if(this.hasLivingActiveHordeWaveUnits())
         {
            return;
         }
         if(this.hordeWaveIndex < HORDE_WAVE_TIMES.length && elapsed >= int(HORDE_WAVE_TIMES[this.hordeWaveIndex]))
         {
            this.spawnDeadHordeWave(gameScreen,int(this.getHordeWaveUndeadCount(gameScreen)[this.hordeWaveIndex]));
            ++this.hordeWaveIndex;
         }
         else if(this.hordeWaveIndex >= HORDE_WAVE_TIMES.length)
         {
            this.spawnDeadHordeMarrowkai(gameScreen);
            this.hordeMarrowkaiSpawned = true;
         }
      }
      
      private function getHordeWaveUndeadCount(gameScreen:GameScreen) : Array
      {
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_INSANE)
         {
            return HORDE_WAVE_UNDEAD_INSANE;
         }
         if(gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.difficultyLevel == Campaign.D_HARD)
         {
            return HORDE_WAVE_UNDEAD_HARD;
         }
         return HORDE_WAVE_UNDEAD_NORMAL;
      }
      
      private function spawnDeadHordeWave(gameScreen:GameScreen, count:int) : void
      {
         var i:int = 0;
         var undead:Undead = null;
         var spawnedUnits:Array = [];
         var refreshEntries:Array = [];
         var goalY:Number = 0;
         i = 0;
         while(i < count)
         {
            undead = gameScreen.game.unitFactory.getUnit(Unit.U_UNDEAD);
            gameScreen.team.enemyTeam.spawn(undead,gameScreen.game);
            goalY = this.getNativeFormationGoalY(gameScreen,i,count);
            undead.px = this.getNativeFormationSpawnX(gameScreen,i);
            undead.x = undead.px;
            undead.py = goalY;
            undead.y = undead.py;
            undead.scaleX *= gameScreen.team.enemyTeam.direction * -1;
            this.issueAmbushAttackCommand(gameScreen,undead,goalY);
            spawnedUnits.push(undead);
            refreshEntries.push([undead,goalY]);
            i++;
         }
         this.activeHordeWaveUnits = spawnedUnits;
         this.pendingAttackRefreshes.push([gameScreen.game.frame + ATTACK_REFRESH_DELAY_FRAMES,refreshEntries]);
      }
      
      private function initializeDeadHordeCutscene(gameScreen:GameScreen) : void
      {
         var s:Skelator = null;
         if(!this.isDeadHordeLevel(gameScreen))
         {
            return;
         }
         s = gameScreen.game.unitFactory.getUnit(Unit.U_SKELATOR);
         gameScreen.team.enemyTeam.spawn(s,gameScreen.game);
         s.px = gameScreen.team.enemyTeam.homeX + gameScreen.team.enemyTeam.direction * 400;
         s.x = s.px;
         s.py = gameScreen.game.map.height / 2;
         s.y = s.py;
         s.scaleX *= gameScreen.team.enemyTeam.direction * -1;
         s.makeBoss();
         s.isBossMovementLocked = true;
         s.forceFaceDirection(gameScreen.team.direction);
         var hold:HoldCommand = new HoldCommand(gameScreen.game);
         s.ai.setCommand(gameScreen.game,hold);
         gameScreen.team.enemyTeam.tech.isResearchedMap[Tech.SKELETON_FIST_ATTACK] = true;
         if(!Boolean(gameScreen.team.enemyTeam.unitGroups[Unit.U_UNDEAD]))
         {
            gameScreen.team.enemyTeam.unitGroups[Unit.U_UNDEAD] = [];
         }
         this.hordeRevealFog = true;
         this.hordeCutsceneMarrowkai = s;
         this.hordeCutsceneUndeads = [];
         this.hordeCutsceneState = HORDE_CS_BEFORE;
         this.hordeCutsceneTimer = gameScreen.game.frame;
         this.hordeCutsceneActive = true;
      }
      
      private function updateDeadHordeCutscene(gameScreen:GameScreen) : void
      {
         var elapsed:int = 0;
         var i:int = 0;
         var undead:Undead = null;
         var spawnX:Number = Number(NaN);
         var spawnY:Number = Number(NaN);
         var goalY:Number = Number(NaN);
         if(!this.isDeadHordeLevel(gameScreen) || !this.hordeCutsceneActive)
         {
            return;
         }
         elapsed = gameScreen.game.frame - this.hordeCutsceneTimer;
         switch(this.hordeCutsceneState)
         {
            case HORDE_CS_BEFORE:
               if(elapsed >= CUTSCENE_PAN_FRAMES)
               {
                  this.setCameraTarget(gameScreen,this.hordeCutsceneMarrowkai.px - 700);
                  this.hordeCutsceneState = HORDE_CS_FIST_WAIT;
                  this.hordeCutsceneTimer = gameScreen.game.frame;
               }
               break;
            case HORDE_CS_FIST_WAIT:
               if(elapsed >= CUTSCENE_FIST_WAIT_FRAMES)
               {
                  this.hordeCutsceneMarrowkai.playCutsceneFist(this.hordeCutsceneMarrowkai.px - 150,gameScreen.game.map.height / 2,CUTSCENE_UNDEAD_COUNT);
                  this.hordeCutsceneState = HORDE_CS_WAIT_END;
                  this.hordeCutsceneTimer = gameScreen.game.frame;
               }
               break;
            case HORDE_CS_WAIT_END:
               if(elapsed >= CUTSCENE_END_WAIT_FRAMES)
               {
                  this.cleanupDeadHordeCutscene(gameScreen);
                  this.hordeCutsceneState = HORDE_CS_DONE;
               }
         }
      }
      
      private function cleanupDeadHordeCutscene(gameScreen:GameScreen) : void
      {
         if(this.hordeCutsceneMarrowkai != null)
         {
            gameScreen.team.enemyTeam.removeUnitCompletely(this.hordeCutsceneMarrowkai,gameScreen.game);
            this.hordeCutsceneMarrowkai = null;
         }
         var undeadGroup:Array = gameScreen.team.enemyTeam.unitGroups[Unit.U_UNDEAD];
         if(undeadGroup != null)
         {
            while(undeadGroup.length > 0)
            {
               gameScreen.team.enemyTeam.removeUnitCompletely(undeadGroup[0],gameScreen.game);
            }
         }
         this.hordeCutsceneUndeads = [];
         this.hordeRevealFog = false;
         this.setCameraTarget(gameScreen,this.getPlayerCameraX(gameScreen));
         this.startFrame = gameScreen.game.frame;
         this.hordeCutsceneActive = false;
      }
      
      private function spawnDeadHordeMarrowkai(gameScreen:GameScreen) : void
      {
         var s:Skelator = gameScreen.game.unitFactory.getUnit(Unit.U_SKELATOR);
         gameScreen.team.enemyTeam.spawn(s,gameScreen.game);
         var goalY:Number = gameScreen.game.map.height / 2;
         s.px = gameScreen.game.map.width / 2 + 200;
         s.x = s.px;
         s.py = goalY;
         s.y = s.py;
         s.scaleX *= gameScreen.team.enemyTeam.direction * -1;
         s.makeBoss();
         s.isBossMovementLocked = true;
         this.marrowkaiSummonTimer = gameScreen.game.frame;
         s.maxHealth = 400;
         s.health = s.maxHealth;
         s.healthBar.totalHealth = s.maxHealth;
         s.healthBar.health = s.health;
         s.healthBar.reset();
         this.activeHordeWaveUnits = [s];
      }
      
      private function hasLivingActiveHordeWaveUnits() : Boolean
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
      
      private function updatePendingAttackRefreshes(gameScreen:GameScreen) : void
      {
         var i:int = 0;
         var j:int = 0;
         var refresh:Array = null;
         var refreshEntries:Array = null;
         var entry:Array = null;
         while(i < this.pendingAttackRefreshes.length)
         {
            refresh = this.pendingAttackRefreshes[i];
            if(gameScreen.game.frame < int(refresh[0]))
            {
               i++;
            }
            else
            {
               refreshEntries = refresh[1];
               j = 0;
               while(j < refreshEntries.length)
               {
                  entry = refreshEntries[j];
                  if(entry != null && entry[0] != null && entry[0].isAlive())
                  {
                     this.issueAmbushAttackCommand(gameScreen,entry[0],Number(entry[1]));
                  }
                  j++;
               }
               this.pendingAttackRefreshes.splice(i,1);
            }
         }
      }
      
      private function isNativeTribesLevel(gameScreen:GameScreen) : Boolean
      {
         return gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.getCurrentLevel() != null && gameScreen.main.campaign.getCurrentLevel().title == LEVEL_NATIVE_TRIBES;
      }
      
      private function isShadowrathStalkersLevel(gameScreen:GameScreen) : Boolean
      {
         return gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.getCurrentLevel() != null && gameScreen.main.campaign.getCurrentLevel().title == LEVEL_SHADOWRATH_STALKERS;
      }
      
      private function isRebelBreakLevel(gameScreen:GameScreen) : Boolean
      {
         return gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.getCurrentLevel() != null && gameScreen.main.campaign.getCurrentLevel().title == LEVEL_REBELS_BREAK;
      }
      
      private function isDeadHordeLevel(gameScreen:GameScreen) : Boolean
      {
         return gameScreen.main != null && gameScreen.main.campaign != null && gameScreen.main.campaign.getCurrentLevel() != null && gameScreen.main.campaign.getCurrentLevel().title == LEVEL_DEAD_HORDE;
      }
      
      private function shouldShowStartMessage(gameScreen:GameScreen) : Boolean
      {
         return this.isNativeTribesLevel(gameScreen) || this.isShadowrathStalkersLevel(gameScreen) || this.isDeadHordeLevel(gameScreen);
      }
      
      private function showAmbushMessage(gameScreen:GameScreen, text:String) : void
      {
         if(this.message != null && gameScreen.contains(this.message))
         {
            gameScreen.removeChild(this.message);
         }
         this.message = new InGameMessage("",gameScreen.game);
         this.message.x = gameScreen.game.stage.stageWidth / 2;
         this.message.y = gameScreen.game.stage.stageHeight / 4 - 75;
         this.message.scaleX *= 1.3;
         this.message.scaleY *= 1.3;
         this.message.setMessage(text,"");
         gameScreen.addChild(this.message);
         this.messageStartFrame = gameScreen.game.frame;
      }
      
      private function cleanupRebelDisplayUnits(gameScreen:GameScreen) : void
      {
         var unit:Unit = null;
         while(this.rebelDisplayUnits.length > 0)
         {
            unit = this.rebelDisplayUnits.pop() as Unit;
            if(unit != null && unit.isAlive())
            {
               unit.isBossMovementLocked = false;
               unit.isBossUnit = false;
               unit.team.removeUnitCompletely(unit,gameScreen.game);
            }
         }
      }
      
      private function killAllEnemyUnits(gameScreen:GameScreen) : void
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
            if(unit != null && unit.isAlive() && unit.type != Unit.U_STATUE)
            {
               if(unit is Magikill && unit.isBoss)
               {
                  unit.damage(0,unit.maxHealth * 2,null);
               }
               else
               {
                  gameScreen.team.enemyTeam.removeUnitCompletely(unit,gameScreen.game);
               }
            }
         }
      }
      
      private function setCameraTarget(gameScreen:GameScreen, targetX:Number) : void
      {
         if(gameScreen.game.background != null)
         {
            targetX = Math.max(gameScreen.game.background.minScreenX(),Math.min(gameScreen.game.background.maxScreenX(),targetX));
         }
         gameScreen.game.targetScreenX = targetX;
      }
      
      private function getEnemyCameraX(gameScreen:GameScreen) : Number
      {
         return gameScreen.team.enemyTeam.homeX + gameScreen.team.enemyTeam.direction * gameScreen.game.map.screenWidth;
      }
      
      private function getPlayerCameraX(gameScreen:GameScreen) : Number
      {
         return gameScreen.team.homeX - gameScreen.team.direction * gameScreen.game.map.screenWidth;
      }
      
      private function stopSpawnedPlayerUnits(gameScreen:GameScreen) : void
      {
         var unit:Unit = null;
         if(this.rebelEndingStarted || this.rebelOpeningFinished)
         {
            return;
         }
         for each(unit in gameScreen.team.units)
         {
            if(unit != null && unit.isAlive() && unit.type != Unit.U_MINER && this.rebelDisplayUnits.indexOf(unit) == -1 && unit.ai.currentCommand.type == UnitCommand.ATTACK_MOVE && unit.px > this.getAmbushBarrierX(gameScreen))
            {
               this.holdUnit(gameScreen,unit);
            }
         }
      }
      
      private function holdUnit(gameScreen:GameScreen, unit:Unit) : void
      {
         var holdCommand:HoldCommand = null;
         if(unit.ai == null)
         {
            return;
         }
         holdCommand = new HoldCommand(gameScreen.game);
         unit.ai.setCommand(gameScreen.game,holdCommand);
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
               gameScreen.team.enemyTeam.population = Math.max(0,gameScreen.team.enemyTeam.population - unit.population);
               gameScreen.team.enemyTeam.removeUnitCompletely(unit,gameScreen.game);
            }
         }
      }
      
      private function hasLivingEnemyCombatUnits(gameScreen:GameScreen) : Boolean
      {
         var unit:Unit = null;
         for each(unit in gameScreen.team.enemyTeam.units)
         {
            if(unit != null && unit.isAlive() && unit.type != Unit.U_MINER && unit.type != Unit.U_CHAOS_MINER && unit.type != Unit.U_CHAOS_TOWER)
            {
               return true;
            }
         }
         return false;
      }
      
      private function completeAmbush(gameScreen:GameScreen) : void
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

