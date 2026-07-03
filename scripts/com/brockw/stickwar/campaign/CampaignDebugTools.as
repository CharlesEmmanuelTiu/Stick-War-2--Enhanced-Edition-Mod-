package com.brockw.stickwar.campaign
{
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import com.brockw.stickwar.engine.units.Unit;
   
   public class CampaignDebugTools
   {
      
      private static const DEBUG_SET_ORDER:int = 0;
      
      private static const DEBUG_SET_CHAOS:int = 1;
      
      private var screen:CampaignGameScreen;
      
      private var debugModeEnabled:Boolean;
      
      private var debugSpawnSet:int;
      
      private var debugOverlay:TextField;
      
      private var debugAbilityToast:TextField;
      
      private var debugAbilityToastText:String;
      
       private var debugAbilityToastUntilFrame:int;
       
       private var debugSideInfo:TextField;

       
       public function CampaignDebugTools(screen:CampaignGameScreen)
       {
          super();
          this.screen = screen;
          this.debugModeEnabled = false;
          this.debugSpawnSet = DEBUG_SET_ORDER;
          this.debugOverlay = null;
          this.debugAbilityToast = null;
          this.debugAbilityToastText = "";
          this.debugAbilityToastUntilFrame = 0;
          this.debugSideInfo = null;

       }
      
      public function handleHotkeys() : void
      {
         if(this.screen == null || this.screen.userInterface == null || this.screen.userInterface.keyBoardState == null || !this.screen.userInterface.keyBoardState.isShift)
         {
            return;
         }
         if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F9))
         {
            this.debugModeEnabled = !this.debugModeEnabled;
            this.screen.setDebugModeEnabled(this.debugModeEnabled);
            if(!this.debugModeEnabled)
            {
               this.removeOverlay();
            }
            else
            {
               this.showEnabledLabel();
            }
            return;
         }
         if(this.debugModeEnabled)
         {
            if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F8))
            {
               this.screen.toggleDebugFullVision();
               return;
            }
            if(this.screen.userInterface.keyBoardState.isPressed(189))
            {
               this.screen.toggleDebugEnemyAiFreezeAttackMode();
               return;
            }
            if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F6))
            {
               this.debugSpawnSet = DEBUG_SET_ORDER;
               this.screen.setDebugSpawnSet(this.debugSpawnSet);
               this.showToast("DEBUG SET: ORDER");
               return;
            }
            if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F7))
            {
               this.debugSpawnSet = DEBUG_SET_CHAOS;
               this.screen.setDebugSpawnSet(this.debugSpawnSet);
               this.showToast("DEBUG SET: CHAOS");
               return;
            }
             if(this.screen.userInterface.keyBoardState.isPressed(48))
             {
                this.screen.killEnemyUnitsAndLockTraining();
                return;
             }
             if(this.screen.userInterface.keyBoardState.isPressed(187))
             {
                this.screen.team.gold += 5000;
                this.screen.team.mana += 5000;
                this.showToast("+5000 Gold, +5000 Mana");
                return;
             }
             this.trySpawnBosses();
         }
      }

      private function trySpawnBosses() : void
      {
         if(this.screen == null)
         {
            return;
         }
         if(this.debugSpawnSet == DEBUG_SET_ORDER)
         {
            this.trySpawnOrderSet();
         }
         else
         {
            this.trySpawnChaosSet();
         }
      }

      private function trySpawnOrderSet() : void
      {
         if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F1))
         {
            this.screen.spawnDebugBoss(Unit.U_SPEARTON);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F2))
         {
            this.screen.spawnDebugBoss(Unit.U_ARCHER);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F3))
         {
            this.screen.spawnDebugBoss(Unit.U_NINJA);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F4))
         {
            this.screen.spawnDebugBoss(Unit.U_MAGIKILL);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F5))
         {
            this.screen.spawnDebugBoss(Unit.U_MONK);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(49))
         {
            this.screen.spawnDebugAlliedUnit(Unit.U_SPEARTON,1);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(50))
         {
            this.screen.spawnDebugAlliedUnit(Unit.U_ARCHER,2);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(51))
         {
            this.screen.spawnDebugAlliedGroupAtBase([Unit.U_MAGIKILL,Unit.U_MONK]);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(52))
         {
            this.screen.spawnDebugAlliedUnit(Unit.U_ENSLAVED_GIANT,1);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(53))
         {
            this.screen.spawnDebugAlliedUnit(Unit.U_NINJA,1);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(54))
         {
            this.screen.spawnDebugEnemyAtBase(Unit.U_SPEARTON,1);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(55))
         {
            this.screen.spawnDebugEnemyAtBase(Unit.U_ARCHER,2);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(56))
         {
            this.screen.spawnDebugShadowrathAtEnemyBase();
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(57))
         {
            this.screen.spawnDebugEnemyGroupAtBase([Unit.U_MAGIKILL,Unit.U_MONK]);
         }
      }

      private function trySpawnChaosSet() : void
      {
         if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F1))
         {
            this.screen.spawnDebugKnightBoss();
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F2))
         {
            this.screen.spawnDebugBoss(Unit.U_WINGIDON);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F3))
         {
            this.screen.spawnDebugBoss(Unit.U_SKELATOR);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(Keyboard.F4))
         {
            this.screen.spawnDebugThumbnailBossLineup();
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(49))
         {
            this.screen.spawnDebugEnemyAtBase(Unit.U_KNIGHT,1);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(50))
         {
            this.screen.spawnDebugEnemyAtBase(Unit.U_DEAD,1);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(51))
         {
            this.screen.spawnDebugEnemyAtBase(Unit.U_WINGIDON,1);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(52))
         {
            this.screen.spawnDebugEnemyAtBase(Unit.U_SKELATOR,1);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(53))
         {
            this.screen.spawnDebugEnemyAtBase(Unit.U_MEDUSA,1);
         }
         else if(this.screen.userInterface.keyBoardState.isPressed(54))
         {
            this.screen.damageDebugEnemyStatue(250);
         }
      }
      
       public function update() : void
       {
          this.updateToast();
          if(this.debugModeEnabled && this.screen != null && this.screen.userInterface != null && this.screen.userInterface.mouseState != null && this.screen.userInterface.mouseState.clicked)
          {
             var u:Unit = this.screen.game.mouseOverUnit;
             if(u != null && u.team == this.screen.team)
             {
                this.ensureSideInfoField();
                var sideName:String = u.assignedSide == 0 ? "Neutral" : (u.assignedSide == -1 ? "Left" : "Right");
                this.debugSideInfo.text = this.getUnitTypeName(u.type) + ": " + sideName;
             }
             else if(this.debugSideInfo != null)
             {
                this.debugSideInfo.text = "";
             }
          }
       }
      
      public function showToast(message:String) : void
      {
         if(this.screen == null || this.screen.game == null)
         {
            return;
         }
         this.debugAbilityToastText = message;
         this.debugAbilityToastUntilFrame = this.screen.game.frame + 30 * 3;
         this.updateToast();
      }
      
      public function cleanUp() : void
       {
          this.removeOverlay();
          this.screen = null;
          this.debugModeEnabled = false;
          this.debugSpawnSet = DEBUG_SET_ORDER;
          this.debugAbilityToastText = "";
          this.debugAbilityToastUntilFrame = 0;
          this.debugSideInfo = null;

       }
      
      private function showEnabledLabel() : void
      {
         var format:TextFormat = null;
         if(this.screen == null)
         {
            return;
         }
         if(this.debugOverlay != null)
         {
            if(!this.screen.contains(this.debugOverlay))
            {
               this.screen.addChild(this.debugOverlay);
            }
            return;
         }
         this.debugOverlay = new TextField();
         format = new TextFormat("_typewriter",12,16776960,true);
         this.debugOverlay.defaultTextFormat = format;
         this.debugOverlay.selectable = false;
         this.debugOverlay.mouseEnabled = false;
         this.debugOverlay.multiline = false;
         this.debugOverlay.wordWrap = false;
         this.debugOverlay.background = true;
         this.debugOverlay.backgroundColor = 0;
         this.debugOverlay.border = true;
         this.debugOverlay.borderColor = 16776960;
         this.debugOverlay.width = 120;
         this.debugOverlay.height = 20;
         this.debugOverlay.x = 8;
         this.debugOverlay.y = 8;
         this.debugOverlay.text = "DEBUG ENABLED";
         this.screen.addChild(this.debugOverlay);
      }
      
      private function updateToast() : void
      {
         if(this.screen == null || this.screen.game == null || this.debugAbilityToastText == "" || this.screen.game.frame > this.debugAbilityToastUntilFrame)
         {
            if(this.screen != null && this.debugAbilityToast != null && this.screen.contains(this.debugAbilityToast))
            {
               this.screen.removeChild(this.debugAbilityToast);
            }
            return;
         }
         this.ensureToast();
         this.debugAbilityToast.text = this.debugAbilityToastText;
      }
      
      private function ensureToast() : void
      {
         var format:TextFormat = null;
         if(this.screen == null)
         {
            return;
         }
         if(this.debugAbilityToast != null)
         {
            if(!this.screen.contains(this.debugAbilityToast))
            {
               this.screen.addChild(this.debugAbilityToast);
            }
            return;
         }
         this.debugAbilityToast = new TextField();
         format = new TextFormat("_typewriter",14,16776960,true);
         this.debugAbilityToast.defaultTextFormat = format;
         this.debugAbilityToast.selectable = false;
         this.debugAbilityToast.mouseEnabled = false;
         this.debugAbilityToast.multiline = false;
         this.debugAbilityToast.wordWrap = false;
         this.debugAbilityToast.background = true;
         this.debugAbilityToast.backgroundColor = 0;
         this.debugAbilityToast.border = true;
         this.debugAbilityToast.borderColor = 16776960;
         this.debugAbilityToast.width = 260;
         this.debugAbilityToast.height = 24;
         this.debugAbilityToast.x = 286;
         this.debugAbilityToast.y = 8;
         this.screen.addChild(this.debugAbilityToast);
      }
      
       private function removeOverlay() : void
       {
          if(this.screen != null && this.debugOverlay != null && this.screen.contains(this.debugOverlay))
          {
             this.screen.removeChild(this.debugOverlay);
          }
          if(this.screen != null && this.debugAbilityToast != null && this.screen.contains(this.debugAbilityToast))
          {
             this.screen.removeChild(this.debugAbilityToast);
          }
          if(this.screen != null && this.debugSideInfo != null && this.screen.contains(this.debugSideInfo))
          {
             this.screen.removeChild(this.debugSideInfo);
          }
       }
       
       private function ensureSideInfoField() : void
       {
          var format:TextFormat = null;
          if(this.screen == null)
          {
             return;
          }
          if(this.debugSideInfo != null)
          {
             if(!this.screen.contains(this.debugSideInfo))
             {
                this.screen.addChild(this.debugSideInfo);
             }
             return;
          }
          this.debugSideInfo = new TextField();
          format = new TextFormat("_typewriter",12,16776960,true);
          this.debugSideInfo.defaultTextFormat = format;
          this.debugSideInfo.selectable = false;
          this.debugSideInfo.mouseEnabled = false;
          this.debugSideInfo.multiline = false;
          this.debugSideInfo.wordWrap = false;
          this.debugSideInfo.background = true;
          this.debugSideInfo.backgroundColor = 0;
          this.debugSideInfo.border = true;
          this.debugSideInfo.borderColor = 16776960;
          this.debugSideInfo.width = 150;
          this.debugSideInfo.height = 20;
          this.debugSideInfo.x = 8;
          this.debugSideInfo.y = 31;
          this.debugSideInfo.text = "";
          this.screen.addChild(this.debugSideInfo);
       }
       
       private function getUnitTypeName(type:int) : String
       {
          switch(type)
          {
             case Unit.U_MINER: return "Miner";
             case Unit.U_MAGIKILL: return "Magikill";
             case Unit.U_MONK: return "Monk";
             case Unit.U_ARCHER: return "Archer";
             case Unit.U_FLYING_CROSSBOWMAN: return "FlyingCrossbow";
             case Unit.U_NINJA: return "Ninja";
             case Unit.U_SWORDWRATH: return "Swordwrath";
             case Unit.U_SPEARTON: return "Spearton";
             case Unit.U_ENSLAVED_GIANT: return "EnslavedGiant";
             case Unit.U_DEAD: return "Dead";
             case Unit.U_WINGIDON: return "Wingidon";
             case Unit.U_DASHNITE: return "Dashnite";
             case Unit.U_CHAOS_MINER: return "ChaosMiner";
             case Unit.U_BOMBER: return "Bomber";
             case Unit.U_SKELATOR: return "Skelator";
             case Unit.U_CAT: return "Cat";
             case Unit.U_KNIGHT: return "Knight";
             case Unit.U_MEDUSA: return "Medusa";
             case Unit.U_GIANT: return "ChaosGiant";
             default: return "Type" + type;
          }
       }
    }
}






