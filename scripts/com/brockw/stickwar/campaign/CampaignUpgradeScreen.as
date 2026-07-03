package com.brockw.stickwar.campaign
{
   import com.brockw.game.Screen;
   import com.brockw.stickwar.BaseMain;
   import com.brockw.stickwar.engine.Team.Tech;
    import com.brockw.stickwar.engine.Team.TechItem;
    import com.brockw.stickwar.campaign.Level;
     import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.MovieClip;
    import flash.geom.ColorTransform;
   import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
   
   public class CampaignUpgradeScreen extends Screen
   {
      
      private var main:BaseMain;
      
      private var mc:campaignUpgradeScreenMc;
      
      private var buttonMap:Dictionary;
      
      private var clicked:Boolean;

      private var _showBossUpgrades:Boolean;

      private var _bossButtonNames:Array;

      private var _showBossToggleTip:Boolean;

      private var _bossToggleTipTimer:int;

      private var _tutorialArrow:tutorialArrow;

      private var _tipMessageBox:inGameMessageBoxMc;

      private var upgradeTips:Dictionary;
      
      private var timeOfLastUpdate:int;
      
      public function CampaignUpgradeScreen(main:BaseMain)
      {
         super();
         this.main = main;
         this.mc = new campaignUpgradeScreenMc();
         addChild(this.mc);
          this.timeOfLastUpdate = getTimer();
          this.initButtonMap();
          this.initUpgradeTips();
          this._bossButtonNames = ["Spearos","Archis","Arrow Storm","Shade","Vitalis","Explosive Arrow","Shinobi III","Magis","Lightning Stun","Meteor II","Summon II"];
      }
      
      private function setUpButton(txt:String, button:MovieClip) : void
       {
          if(!button) return;
          this.buttonMap[txt] = button;
          button.buttonMode = true;
          button.mouseChildren = false;
          button.gotoAndStop(1);
       }
      
      private function initButtonMap() : void
      {
         this.buttonMap = new Dictionary();
         this.setUpButton("Castle Archer I",this.mc.button1);
         this.setUpButton("Rage",this.mc.button2);
         this.setUpButton("Passive Income I",this.mc.button3);
         this.setUpButton("Block",this.mc.button4);
         this.setUpButton("Miner Speed",this.mc.button5);
         this.setUpButton("Castle Archer II",this.mc.button6);
         this.setUpButton("Shield Bash",this.mc.button7);
         this.setUpButton("Cure",this.mc.button8);
         this.setUpButton("Passive Income II",this.mc.button9);
         this.setUpButton("Castle Archer III",this.mc.button10);
         this.setUpButton("Fire Arrow",this.mc.button11);
         this.setUpButton("Cloak",this.mc.button12);
         this.setUpButton("Electric Wall",this.mc.button13);
         this.setUpButton("Miner Wall",this.mc.button14);
         this.setUpButton("Statue Health",this.mc.button15);
         this.setUpButton("Giant Growth I",this.mc.button16);
         this.setUpButton("Poison Spray",this.mc.button17);
         this.setUpButton("Giant Growth II",this.mc.button20);
         this.setUpButton("Tower Spawn II",this.mc.button18);
      this.setUpButton("Tower Spawn I",this.mc.button19);
       
       this.setUpButton("Spearos",this.mc.button21);
       this.setUpButton("Archis",this.mc.button22);
       this.setUpButton("Arrow Storm",this.mc.button23);
       this.setUpButton("Shade",this.mc.button24);
       this.setUpButton("Vitalis",this.mc.button25);
       this.setUpButton("Explosive Arrow",this.mc.button26);
       this.setUpButton("Shinobi III",this.mc.button27);
       this.setUpButton("Magis",this.mc.button28);
       this.setUpButton("Lightning Stun",this.mc.button29);
       this.setUpButton("Meteor II",this.mc.button30);
       this.setUpButton("Summon II",this.mc.button31);
       }

      private function addUpgradeTip(upgradeType:int, upgrade:XMLList, button:Bitmap) : void
      {
         this.upgradeTips[upgradeType] = new TechItem(upgrade,button);
      }

      private function initUpgradeTips() : void
       {
          this.upgradeTips = new Dictionary();
          
          var arrowStormFireBmd:BitmapData = new ArchidonFire();
          var arrowStormCt:ColorTransform = new ColorTransform();
          arrowStormCt.color = 0x4444FF;
          arrowStormFireBmd.draw(arrowStormFireBmd, null, arrowStormCt, BlendMode.MULTIPLY);
          
          var explosionFireBmd:BitmapData = new ArchidonFire();
          var explosionCt:ColorTransform = new ColorTransform();
          explosionCt.color = 0xFF0000;
          explosionFireBmd.draw(explosionFireBmd, null, explosionCt, BlendMode.MULTIPLY);
          
          var cloak3Bmd:BitmapData = new NinjaCloak();
          var cloak3Ct:ColorTransform = new ColorTransform();
          cloak3Ct.color = 0xAA00FF;
          cloak3Bmd.draw(cloak3Bmd, null, cloak3Ct, BlendMode.MULTIPLY);
          
          var nuke2Bmd:BitmapData = new MagikillFireballs();
          var nuke2Ct:ColorTransform = new ColorTransform();
          nuke2Ct.color = 0xFFD700;
          nuke2Bmd.draw(nuke2Bmd, null, nuke2Ct, BlendMode.MULTIPLY);
          
          var stunBmd:BitmapData = new MagikillWall();
          var stunCt:ColorTransform = new ColorTransform();
          stunCt.color = 0xFFD700;
          stunBmd.draw(stunBmd, null, stunCt, BlendMode.MULTIPLY);
         this.addUpgradeTip(Tech.SWORDWRATH_RAGE,this.main.xml.xml.Order.Tech.rage,new Bitmap(new SwordwrathSacrifice()));
         this.addUpgradeTip(Tech.BLOCK,this.main.xml.xml.Order.Tech.block,new Bitmap(new SpeartanShieldWall()));
         this.addUpgradeTip(Tech.CLOAK,this.main.xml.xml.Order.Tech.cloak,new Bitmap(new NinjaCloak1()));
         this.addUpgradeTip(Tech.CLOAK_II,this.main.xml.xml.Order.Tech.cloak2,new Bitmap(new NinjaCloak2()));
         this.addUpgradeTip(Tech.ARCHIDON_FIRE,this.main.xml.xml.Order.Tech.archidonFire,new Bitmap(new ArchidonFire()));
         this.addUpgradeTip(Tech.MAGIKILL_NUKE,this.main.xml.xml.Order.Tech.magikillNuke,new Bitmap(new MagikillFireballs()));
         this.addUpgradeTip(Tech.MAGIKILL_WALL,this.main.xml.xml.Order.Tech.magikillWall,new Bitmap(new MagikillWall()));
         this.addUpgradeTip(Tech.MAGIKILL_POISON,this.main.xml.xml.Order.Tech.magikillPoison,new Bitmap(new poisonSprayBitmap()));
         this.addUpgradeTip(Tech.MONK_CURE,this.main.xml.xml.Order.Tech.cure,new Bitmap(new CureBitmap()));
         this.addUpgradeTip(Tech.CASTLE_ARCHER_1,this.main.xml.xml.Order.Tech.castleArchers1,new Bitmap(new castleArcherLevel1Bitmap()));
         this.addUpgradeTip(Tech.CASTLE_ARCHER_2,this.main.xml.xml.Order.Tech.castleArchers2,new Bitmap(new castleArcherLevel2Bitmap()));
         this.addUpgradeTip(Tech.CASTLE_ARCHER_3,this.main.xml.xml.Order.Tech.castleArchers3,new Bitmap(new castleArcherLevel3Bitmap()));
         this.addUpgradeTip(Tech.SHIELD_BASH,this.main.xml.xml.Order.Tech.speartonShieldBash,new Bitmap(new shieldHitBitmap()));
         this.addUpgradeTip(Tech.STATUE_HEALTH,this.main.xml.xml.Order.Tech.statueHealth,new Bitmap(new statueHealthBitmap()));
         this.addUpgradeTip(Tech.MINER_SPEED,this.main.xml.xml.Order.Tech.minerSpeed,new Bitmap(new minerBagBitmap()));
         this.addUpgradeTip(Tech.BANK_PASSIVE_1,this.main.xml.xml.Order.Tech.passiveIncomeGold1,new Bitmap(new passiveIncomeBitmap()));
         this.addUpgradeTip(Tech.BANK_PASSIVE_2,this.main.xml.xml.Order.Tech.passiveIncomeGold2,new Bitmap(new passiveIncomeBitmap()));
         this.addUpgradeTip(Tech.BANK_PASSIVE_3,this.main.xml.xml.Order.Tech.passiveIncomeGold3,new Bitmap(new passiveIncomeBitmap()));
         this.addUpgradeTip(Tech.GIANT_GROWTH_I,this.main.xml.xml.Order.Tech.giantSize1,new Bitmap(new GiantGrowth1Bitmap()));
         this.addUpgradeTip(Tech.GIANT_GROWTH_II,this.main.xml.xml.Order.Tech.giantSize2,new Bitmap(new GiantGrowth2Bitmap()));
         this.addUpgradeTip(Tech.MINER_WALL,this.main.xml.xml.Order.Tech.minerWall,new Bitmap(new OrderTowerBitmap()));
         this.addUpgradeTip(Tech.CROSSBOW_FIRE,this.main.xml.xml.Order.Tech.crossbowFire,new Bitmap(new allbowtrossFireArrowUpgrade()));
         this.addUpgradeTip(Tech.TOWER_SPAWN_I,this.main.xml.xml.Chaos.Tech.towerSpawnI,new Bitmap(new towerUpgradeI()));
           this.addUpgradeTip(Tech.TOWER_SPAWN_II,this.main.xml.xml.Chaos.Tech.towerSpawnII,new Bitmap(new towerUpgradeII()));

             this.addUpgradeTip(Tech.BOSS_SPEARTON_UNLOCK,new XMLList(<tech><tip>Legendary Spearton General and master of the Way of the Spear. Commands nearby Speartons to form Shield Walls and execute devastating Shield Bashes. Spearton units train faster while he is on the battlefield.</tip><cost>0</cost><mana>0</mana><time>0</time><hotKey>0</hotKey><name>Spearos</name></tech>),new Bitmap(new SpeartanShieldWall()));
             this.addUpgradeTip(Tech.BOSS_ARCHER_UNLOCK,new XMLList(<tech><tip>Founder of the Archidons and unmatched master archer. Fires explosive arrows, commands deadly Arrow Storms, and executes weakened foes with poisonous precision.</tip><cost>0</cost><mana>0</mana><time>0</time><hotKey>0</hotKey><name>Archis</name></tech>),new Bitmap(new ArchidonFire()));
             this.addUpgradeTip(Tech.BOSS_NINJA_UNLOCK,new XMLList(<tech><tip>Princess of the Shadows and founder of the Shadowrath. Strikes unseen from the darkness, chaining cloak attacks while commanding illusionary clones to overwhelm her prey.</tip><cost>0</cost><mana>0</mana><time>0</time><hotKey>0</hotKey><name>Shade</name></tech>),new Bitmap(new NinjaCloak1()));
             this.addUpgradeTip(Tech.BOSS_MONK_UNLOCK,new XMLList(<tech><tip>Founder of the Way of Restoration. A legendary healer capable of curing multiple allies at once and returning fallen warriors to the battlefield through powerful revival magic.</tip><cost>0</cost><mana>0</mana><time>0</time><hotKey>0</hotKey><name>Vitalis</name></tech>),new Bitmap(new CureBitmap()));
             this.addUpgradeTip(Tech.BOSS_MAGIKILL_UNLOCK,new XMLList(<tech><tip>Founder of the Magikill and master of arcane warfare. Summons loyal minions, calls down meteor barrages, and cripples enemies with powerful lightning magic.</tip><cost>0</cost><mana>0</mana><time>0</time><hotKey>0</hotKey><name>Magis</name></tech>),new Bitmap(new MagikillFireballs()));
           this.addUpgradeTip(Tech.ARCHER_BOSS_ARROW_STORM,this.main.xml.xml.Order.Tech.arrowStorm,new Bitmap(arrowStormFireBmd));
           this.addUpgradeTip(Tech.ARCHER_BOSS_EXPLOSION_ARROW,this.main.xml.xml.Order.Tech.explosionArrow,new Bitmap(explosionFireBmd));
           this.addUpgradeTip(Tech.NINJA_CLOAK3,this.main.xml.xml.Order.Tech.cloak3,new Bitmap(cloak3Bmd));
           this.addUpgradeTip(Tech.MAGIKILL_LIGHTNING_STUN,this.main.xml.xml.Order.Tech.magikillLightningStun,new Bitmap(stunBmd));
           this.addUpgradeTip(Tech.MAGIKILL_NUKE_2,this.main.xml.xml.Order.Tech.magikillNuke2,new Bitmap(nuke2Bmd));
           this.addUpgradeTip(Tech.MAGIKILL_SUMMON_UPGRADE,this.main.xml.xml.Order.Tech.magikillSummonUpgrade,new Bitmap(new MagikillSummon()));

        }
      
      private function update(evt:Event) : void
      {
         var key:String = null;
         var c:CampaignUpgrade = null;
         var t:TechItem = null;
         var canUpgrade:Boolean = false;
         var p:String = null;
         if(this.mc.confirmTech.visible)
         {
            return;
         }
         this.mc.campaignPoints.text = "" + this.main.campaign.campaignPoints;
         if(this.main.campaign.campaignPoints == 0)
         {
            this.mc.campaignPoints.text = "0";
         }
          for(key in this.buttonMap)
          {
              var btn:MovieClip = this.buttonMap[key];
              if(!btn || !btn.visible) continue;
             c = CampaignUpgrade(this.main.campaign.upgradeMap[key]);
             t = this.upgradeTips[this.main.campaign.upgradeMap[key].tech];
             if(Boolean(t) && Boolean(btn.hitTestPoint(stage.mouseX,stage.mouseY,false)))
             {
                this.mc.infoBox.text.text = t.tip;
             }
             canUpgrade = true;
             if(Boolean(this.main.campaign.upgradeMap[key].upgraded))
             {
                canUpgrade = false;
                btn.gotoAndStop(3);
             }
             for each(p in this.main.campaign.upgradeMap[key].parents)
             {
                if(!this.main.campaign.upgradeMap[p].upgraded)
                {
                   canUpgrade = false;
                }
             }
             if(canUpgrade)
             {
                btn.gotoAndStop(2);
                btn.alpha = 1;
             }
             else if(!this.main.campaign.upgradeMap[key].upgraded)
             {
                btn.alpha = 0.5;
             }
             if(this.main.campaign.campaignPoints == 0)
             {
                canUpgrade = false;
             }
             if(canUpgrade && btn.hitTestPoint(stage.mouseX,stage.mouseY,false) && this.clicked)
             {
                this.main.campaign.upgradeMap[key].upgraded = true;
                c = CampaignUpgrade(this.main.campaign.upgradeMap[key]);
                this.main.campaign.techAllowed[c.tech] = 1;
                --this.main.campaign.campaignPoints;
                this.main.soundManager.playSoundFullVolume("ArmoryEquipSound");
             }
          }
          if(this._showBossToggleTip)
          {
             --this._bossToggleTipTimer;
             if(this._bossToggleTipTimer <= 0)
             {
                this.createBossToggleTip();
                this._showBossToggleTip = false;
             }
          }
           else if(this._tutorialArrow != null)
           {
              if(this._tutorialArrow.currentFrame == this._tutorialArrow.totalFrames)
              {
                 this._tutorialArrow.gotoAndPlay(1);
              }
              else
              {
                 this._tutorialArrow.nextFrame();
              }
           }
           if(this._tipMessageBox != null)
           {
              var targetX:Number = stage.stageWidth / 2;
              this._tipMessageBox.x += (targetX - this._tipMessageBox.x) * 0.4;
           }
           this.clicked = false;
       }
      
      override public function maySwitchOnDisconnect() : Boolean
      {
         return false;
      }
      
      private function mapButton(evt:Event) : void
      {
         if(this.main.campaign.campaignPoints != 0)
         {
            this.mc.confirmTech.visible = true;
         }
         else
         {
            this.main.showScreen("campaignMap",false,true);
         }
         this.main.soundManager.playSoundFullVolume("clickButton");
      }
      
      private function click(evt:Event) : void
      {
         this.clicked = true;
      }
      
      private function yesButton(evt:Event) : void
      {
         this.mc.confirmTech.visible = false;
         this.main.showScreen("campaignMap",false,true);
      }
      
      private function noButton(evt:Event) : void
       {
          this.mc.confirmTech.visible = false;
       }
       
           private function toggleUpgradeSelection(evt:Event) : void
           {
              this.cleanupBossToggleTip();
              this._showBossUpgrades = !this._showBossUpgrades;
             var key:String;
             for(key in this.buttonMap)
             {
                var btn:MovieClip = this.buttonMap[key];
                if(!btn) continue;
                var isBoss:Boolean = this._bossButtonNames.indexOf(key) != -1;
                btn.visible = this._showBossUpgrades ? isBoss : !isBoss;
             }
             this.main.soundManager.playSoundFullVolume("clickButton");
          }
         
         override public function enter() : void
         {
            this.main.soundManager.playSoundInBackground("loginMusic");
            stage.frameRate = 30;
            this._showBossUpgrades = false;
            addEventListener(Event.ENTER_FRAME,this.update);
            addEventListener(MouseEvent.CLICK,this.click);
            this.mc.start.addEventListener(MouseEvent.CLICK,this.mapButton);
            this.mc.confirmTech.visible = false;
            this.mc.confirmTech.yesButton.addEventListener(MouseEvent.CLICK,this.yesButton);
            this.mc.confirmTech.noButton.addEventListener(MouseEvent.CLICK,this.noButton);
             var mbCompleted:Boolean = false;
             for each(var mbLevel:Level in this.main.campaign.levels)
             {
                if(mbLevel.title == "Massive Battle" && mbLevel.bestTime >= 0)
                {
                   mbCompleted = true;
                   break;
                }
             }
             if(mbCompleted)
             {
                this.mc.UpgradeSelection.visible = true;
                this.mc.UpgradeSelection.addEventListener(MouseEvent.CLICK,this.toggleUpgradeSelection);
             }
              else
              {
                 this.mc.UpgradeSelection.visible = false;
              }
             if(this.mc.UpgradeSelection.visible && !main.campaign.bossToggleTipSeen)
             {
                this._showBossToggleTip = true;
                this._bossToggleTipTimer = 30;
                main.campaign.bossToggleTipSeen = true;
             }
             var key:String;
            for(key in this.buttonMap)
            {
               var btn:MovieClip = this.buttonMap[key];
               if(!btn) continue;
               var isBoss:Boolean = this._bossButtonNames.indexOf(key) != -1;
               btn.visible = !isBoss;
            }
         }
        
           private function createBossToggleTip() : void
           {
              this._tutorialArrow = new tutorialArrow();
              this._tutorialArrow.x = this.mc.UpgradeSelection.x + this.mc.x + this.mc.UpgradeSelection.width / 2 - 100;
              this._tutorialArrow.y = this.mc.UpgradeSelection.y + this.mc.y - 30;
              addChild(this._tutorialArrow);

              this._tipMessageBox = new inGameMessageBoxMc();
              this._tipMessageBox.text.text = "Click here to switch to another set of upgrades";
              this._tipMessageBox.step.text = "";
              this._tipMessageBox.tick.visible = false;
              this._tipMessageBox.scaleX = 1.3;
              this._tipMessageBox.scaleY = 1.3;
              this._tipMessageBox.x = stage.stageWidth + this._tipMessageBox.width;
              this._tipMessageBox.y = stage.stageHeight / 4 - 75;
              addChild(this._tipMessageBox);
           }

           private function cleanupBossToggleTip() : void
           {
              this._showBossToggleTip = false;
              if(this._tutorialArrow != null)
              {
                 if(contains(this._tutorialArrow))
                 {
                    removeChild(this._tutorialArrow);
                 }
                 this._tutorialArrow = null;
              }
              if(this._tipMessageBox != null)
              {
                 if(contains(this._tipMessageBox))
                 {
                    removeChild(this._tipMessageBox);
                 }
                 this._tipMessageBox = null;
              }
           }

          override public function leave() : void
         {
            this.cleanupBossToggleTip();
            removeEventListener(Event.ENTER_FRAME,this.update);
            removeEventListener(MouseEvent.CLICK,this.click);
            this.mc.start.removeEventListener(MouseEvent.CLICK,this.mapButton);
            this.mc.confirmTech.yesButton.removeEventListener(MouseEvent.CLICK,this.yesButton);
            this.mc.confirmTech.noButton.removeEventListener(MouseEvent.CLICK,this.noButton);
            this.mc.UpgradeSelection.removeEventListener(MouseEvent.CLICK,this.toggleUpgradeSelection);
         }
   }
}

