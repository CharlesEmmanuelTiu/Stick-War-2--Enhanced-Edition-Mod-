package com.brockw.stickwar.engine.units
{
   import com.brockw.game.Util;
   import com.brockw.stickwar.campaign.CampaignGameScreen;
   import com.brockw.stickwar.engine.ActionInterface;
   import com.brockw.stickwar.engine.Ai.*;
   import com.brockw.stickwar.engine.Ai.command.*;
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.Team.Tech;
   import com.brockw.stickwar.market.*;
   import flash.display.MovieClip;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   
   public class Ninja extends Unit
   {
      
      private static var WEAPON_REACH:int;
      
      private static const BOSS_RETREAT_HEALTH_RATIO:Number = 0.5;
      
      private static const BOSS_LOST_HEALTH_RATIO:Number = 0.05;
      
      private static const BOSS_ARMOR_SKIN:String = "Tribal Ninja";
      
      private static const BOSS_WEAPON_SKIN:String = "Red Ninja";
      
      private static const BOSS_MISC_SKIN:String = "Katana";
      
      private static const BOSS_DAMAGE_TAKEN_MULTIPLIER:Number = 1 / 1.75;
      
      private static const BOSS_ESCAPE_INVISIBLE_FRAMES:int = 30 * 3;
      
      private static const BOSS_SPECIAL_CLOAK_DURATION_FRAMES:int = 30 * 12;
      
      private static const PLAYER_BOSS_CLOAK3_DURATION_FRAMES:int = 30 * 8;
      
      private static const BOSS_CHAIN_CLOAK_DURATION_FRAMES:int = 45;
      
      private static const BOSS_CHAIN_CLOAK_DELAY_FRAMES:int = 15;
      
      private static const CLONE_IDLE_TIMEOUT_FRAMES:int = 30 * 10;
      
      private static const CLONE_FOLLOW_RANGE_X:int = 100;
      
      private static const CLONE_FOLLOW_RANGE_Y:int = 60;
      
      private var _stealthSpellTimer:SpellCooldown;
      
      private var stealthSpellGlow:DropShadowFilter;
      
      private var isDash:Boolean;
      
      private var ninjaCopyDistance:Number;
      
      private var dontStealth:Boolean;
      
      private var ninjaStealthVelocity:Number;
      
      private var normalVelocity:Number;
      
      private var currentStacks:int;
      
      private var maxStacks:int;
      
      private var currentTarget:Unit;
      
      private var stackDamage:int;
      
      private var furyEffect:int;
      
      private var lastHitFrame:int;
      
      private var _isAutoCloakToggled:Boolean;
      
      private var _autoPendingShadowCloneOnHit:Boolean;
      
      private var _isBoss:Boolean;
      
      private var bossPendingChainCloak:Boolean;
      
      private var bossPendingChainCloakFrames:int;
      
      private var _bossEmergencySortie:Boolean;
      
      private var bossRetreatCooldownFrames:int;
      
      private var bossEscapeInvisibleFrames:int;
      
      private var bossWhiffPenaltyFrames:int;
      
      private var bossSpecialCloakActive:Boolean;
      
      private var bossSpecialCloakHit:Boolean;
      
      private var bossCloakWasActive:Boolean;
      
      private var bossImmediateSpecialReady:Boolean;
      
      private var bossNeedsSpecialReset:Boolean;
      
      private var _isPlayerBoss:Boolean;
      
      private var _shadowClone1:Ninja;
      
      private var _shadowClone2:Ninja;
      
      private var _clonesInCombat:Boolean;
      
      private var _shadowCloneCooldownFrames:int;
      
      private var bossWhiffPenaltyCooldownMax:int;
      
      private var shadowCloneCooldownMax:int;
      
      private var _cloneIdleTimerFrames:int;
      
      private var spawnProtectionFrames:int;
      
      private var _lastAnimLabel:String;
      
      private var _lastCloneRetargetId:int;
      
      public function Ninja(game:StickWar)
      {
         super(game);
         _mc = new _ninja();
         this.init(game);
         addChild(_mc);
         ai = new NinjaAi(this);
         initSync();
         firstInit();
         this.dontStealth = true;
         this.ninjaCopyDistance = 1;
         this._isAutoCloakToggled = false;
         this._autoPendingShadowCloneOnHit = false;
         this._isBoss = false;
         this.bossPendingChainCloak = false;
         this.bossPendingChainCloakFrames = 0;
         this._bossEmergencySortie = false;
         this.bossRetreatCooldownFrames = 0;
         this.bossEscapeInvisibleFrames = 0;
         this.bossWhiffPenaltyFrames = 0;
         this.bossSpecialCloakActive = false;
         this.bossSpecialCloakHit = false;
         this.bossCloakWasActive = false;
         this.bossImmediateSpecialReady = false;
         this.bossNeedsSpecialReset = false;
         this._isPlayerBoss = false;
         this._shadowClone1 = null;
         this._shadowClone2 = null;
         this._clonesInCombat = false;
         this._shadowCloneCooldownFrames = 0;
         this._cloneIdleTimerFrames = 0;
         this.spawnProtectionFrames = 0;
         this._lastAnimLabel = "";
         this._lastCloneRetargetId = -1;
      }
      
      public static function setItemForMc(mc:MovieClip, weapon:String, armor:String, misc:String) : void
      {
         if(Boolean(mc.ninjahead))
         {
            mc.ninjahead.gotoAndStop(armor == "" ? 1 : armor);
         }
         if(Boolean(mc.ninjastaff))
         {
            mc.ninjastaff.gotoAndStop(weapon == "" ? 1 : weapon);
         }
         if(Boolean(mc.ninjasword))
         {
            mc.ninjasword.gotoAndStop(misc == "" ? 1 : misc);
         }
         if(Boolean(mc.weaponGroup))
         {
            if(Boolean(mc.weaponGroup.ninjastaff))
            {
               mc.weaponGroup.ninjastaff.gotoAndStop(weapon == "" ? 1 : weapon);
            }
            if(Boolean(mc.weaponGroup.ninjasword))
            {
               mc.weaponGroup.ninjasword.gotoAndStop(misc == "" ? 1 : misc);
            }
         }
      }
      
      public static function setItem(mc:MovieClip, weapon:String, armor:String, misc:String) : void
      {
         var m:_ninja = mc;
         setItemForMc(m.mc,weapon,armor,misc);
         if(Boolean(m.shadow1))
         {
            setItemForMc(m.shadow1,weapon,armor,misc);
         }
         if(Boolean(m.shadow2))
         {
            setItemForMc(m.shadow2,weapon,armor,misc);
         }
      }
      
      override public function weaponReach() : Number
      {
         return WEAPON_REACH;
      }
      
      override public function init(game:StickWar) : void
      {
         initBase();
         this._isBoss = false;
         this._isAutoCloakToggled = false;
         this._autoPendingShadowCloneOnHit = false;
         this._stealthSpellTimer = new SpellCooldown(game.xml.xml.Order.Units.ninja.stealth.effect,game.xml.xml.Order.Units.ninja.stealth.cooldown,game.xml.xml.Order.Units.ninja.stealthMana);
         WEAPON_REACH = game.xml.xml.Order.Units.ninja.weaponReach;
         population = game.xml.xml.Order.Units.ninja.population;
         _mass = game.xml.xml.Order.Units.ninja.mass;
         _maxForce = game.xml.xml.Order.Units.ninja.maxForce;
         _dragForce = game.xml.xml.Order.Units.ninja.dragForce;
         _scale = game.xml.xml.Order.Units.ninja.scale;
         _maxVelocity = this.normalVelocity = game.xml.xml.Order.Units.ninja.maxVelocity;
         this.createTime = game.xml.xml.Order.Units.ninja.cooldown;
         this.ninjaCopyDistance = game.xml.xml.Order.Units.ninja.ninjaCopyDistance;
         loadDamage(game.xml.xml.Order.Units.ninja);
         maxHealth = health = game.xml.xml.Order.Units.ninja.health;
         this.maxStacks = game.xml.xml.Order.Units.ninja.fury.stacks;
         this.stackDamage = game.xml.xml.Order.Units.ninja.fury.bonus;
         this.furyEffect = game.xml.xml.Order.Units.ninja.fury.furyEffect;
         this.currentStacks = 0;
         this.currentTarget = null;
         this.lastHitFrame = 0;
         this.ninjaStealthVelocity = game.xml.xml.Order.Units.ninja.stealth.maxVelocity;
         this.stealthSpellGlow = new DropShadowFilter();
         this.stealthSpellGlow.knockout = true;
         this.stealthSpellGlow.angle = 0;
         this.stealthSpellGlow.distance = 0;
         this.stealthSpellGlow.color = 0;
         type = Unit.U_NINJA;
         _mc.stop();
         _mc.width *= _scale;
         _mc.height *= _scale;
         _state = S_RUN;
         _mc.mc.gotoAndPlay(1); //unpopped
         _mc.gotoAndStop(1); //unpopped
         drawShadow();
         this.isDash = true;
         this._isPlayerBoss = false;
         this.bossWhiffPenaltyCooldownMax = game.xml.xml.Order.Units.ninja.cloak3.cooldown;
         this.shadowCloneCooldownMax = game.xml.xml.Order.Units.ninja.shadowClone.cooldown;
      }
      
      override public function setBuilding() : void
      {
         building = team.buildings["BarracksBuilding"];
      }
      
      override public function getDamageToDeal() : Number
      {
         return damageToDeal;
      }
      
      public function stealthCooldown() : Number
      {
         return this._stealthSpellTimer.cooldown();
      }
      
      private function activateStealth(isBossSpecial:Boolean, ignoreCooldown:Boolean = false, bossEffectFrames:int = -1) : Boolean
      {
         if(this.isBoss && !isBossSpecial && this.team != null && this.team.isAi)
         {
            return false;
         }
         if(team.tech.isResearched(Tech.CLOAK))
         {
            if(ignoreCooldown)
            {
               if(bossEffectFrames >= 0)
               {
                  this._stealthSpellTimer.forceActivateWithEffect(bossEffectFrames);
               }
               else
               {
                  this._stealthSpellTimer.forceActivate();
               }
            }
            else if(bossEffectFrames >= 0 ? !this._stealthSpellTimer.spellActivateWithEffect(team,bossEffectFrames) : !this._stealthSpellTimer.spellActivate(team))
            {
               return false;
            }
            this.dontStealth = false;
            if(this.isBoss && isBossSpecial)
            {
               this.bossSpecialCloakActive = true;
               this.bossSpecialCloakHit = false;
            }
            team.game.soundManager.playSound("ninjaCloakSound",px,py);
            return true;
         }
         return false;
      }
      
      public function stealth() : Boolean
      {
         return this.activateStealth(false);
      }
      
      public function bossSpecialStealth(ignoreCooldown:Boolean = false, isChainCloak:Boolean = false) : Boolean
      {
         var usedImmediateReady:Boolean = this.bossImmediateSpecialReady;
         if(!isChainCloak && team.game.gameScreen is CampaignGameScreen && !team.game.gameScreen.canUseRebelsUnitedBossAbility(this,"shadowrathCloak"))
         {
            return false;
         }
         var cloakDuration:int = isChainCloak ? BOSS_CHAIN_CLOAK_DURATION_FRAMES : (this._isPlayerBoss ? PLAYER_BOSS_CLOAK3_DURATION_FRAMES : BOSS_SPECIAL_CLOAK_DURATION_FRAMES);
         if(this._isPlayerBoss && team.tech.isResearched(Tech.NINJA_CLOAK3))
         {
            var manaCost:int = int(isChainCloak ? 10 : team.game.xml.xml.Order.Units.ninja.cloak3.mana);
            if(team.mana < manaCost)
            {
               return false;
            }
            team.mana -= manaCost;
            ignoreCooldown = true;
         }
         var didActivate:Boolean = this.activateStealth(true,ignoreCooldown || usedImmediateReady,cloakDuration);
         if(didActivate && usedImmediateReady)
         {
            this.bossImmediateSpecialReady = false;
         }
         return didActivate;
      }
      
      override protected function checkForHit() : Boolean
      {
         var poisonDamage:Number = Number(NaN);
         var target:Unit = ai.getClosestTarget();
         if(target == null)
         {
            return false;
         }
         var dir:int = Util.sgn(target.px - px);
         if(_mc.mc.tip == null)
         {
            return false;
         }
         var p2:Point = _mc.mc.tip.localToGlobal(new Point(0,0));
         if(target.checkForHitPoint(p2,target))
         {
            if(this.currentTarget != target || team.game.frame - this.lastHitFrame > this.furyEffect)
            {
               this.currentStacks = 0;
            }
            if(this.currentStacks > this.maxStacks)
            {
               this.currentStacks = this.maxStacks;
            }
            if(target is Statue)
            {
               target.damage(0,this.stackDamage * this.currentStacks + _damageToArmour,null);
            }
            else if(target.isArmoured)
            {
               target.damage(0,this.stackDamage * this.currentStacks + this.damageToArmour,null);
            }
            else
            {
               target.damage(0,this.stackDamage * this.currentStacks + this.damageToNotArmour,null);
            }
            poisonDamage = 0;
            if(team.tech.isResearched(Tech.CLOAK_II))
            {
               poisonDamage = Number(team.game.xml.xml.Order.Units.ninja.stealth.poison2);
            }
            else if(team.tech.isResearched(Tech.CLOAK))
            {
               poisonDamage = Number(team.game.xml.xml.Order.Units.ninja.stealth.poison);
            }
            if(!this.dontStealth)
            {
               target.poison(poisonDamage);
            }
            ++this.currentStacks;
            this.lastHitFrame = team.game.frame;
            this.currentTarget = target;
            if(this.isBoss && (this._shadowClone1 != null || this._shadowClone2 != null))
            {
               if(target.id == this._lastCloneRetargetId)
               {
                  return true;
               }
               this._lastCloneRetargetId = target.id;
               this._clonesInCombat = true;
               if(target.isAlive() && target.team != null && target.team != this.team && !target.isFlying())
               {
                  var frontCmd2:MoveCommand = new MoveCommand(this.team.game);
                  frontCmd2.type = UnitCommand.MOVE;
                  frontCmd2.goalX = target.px;
                  frontCmd2.goalY = target.py;
                  frontCmd2.realX = frontCmd2.goalX;
                  frontCmd2.realY = frontCmd2.goalY;
                  if(this._shadowClone1 != null)
                  {
                     this._shadowClone1._state = 0;
                     this._shadowClone1.isBossMovementLocked = false;
                     this._shadowClone1.ai.setCommand(this.team.game,frontCmd2);
                  }
                  if(this._shadowClone2 != null)
                  {
                     this._shadowClone2._state = 0;
                     this._shadowClone2.isBossMovementLocked = false;
                     if(target.type != Unit.U_WALL && target.type != Unit.U_STATUE && target.team != null)
                     {
                        var flankCmd2:MoveCommand = new MoveCommand(this.team.game);
                        flankCmd2.type = UnitCommand.MOVE;
                        flankCmd2.goalX = target.px + target.team.direction * 140;
                        flankCmd2.goalY = target.py;
                        flankCmd2.realX = flankCmd2.goalX;
                        flankCmd2.realY = flankCmd2.goalY;
                        this._shadowClone2.ai.setCommand(this.team.game,flankCmd2);
                     }
                     else
                     {
                        this._shadowClone2.ai.setCommand(this.team.game,frontCmd2);
                     }
                  }
               }
            }
            return true;
         }
         return false;
      }
      
      override public function update(game:StickWar) : void
      {
         if(this.bossRetreatCooldownFrames > 0)
         {
            --this.bossRetreatCooldownFrames;
         }
         if(this.bossEscapeInvisibleFrames > 0)
         {
            --this.bossEscapeInvisibleFrames;
         }
         if(this.bossWhiffPenaltyFrames > 0)
         {
            --this.bossWhiffPenaltyFrames;
         }
         if(this.bossPendingChainCloakFrames > 0)
         {
            --this.bossPendingChainCloakFrames;
         }
         if(this.spawnProtectionFrames > 0)
         {
            --this.spawnProtectionFrames;
         }
         this._stealthSpellTimer.update();
         if(this.isBoss)
         {
            this.updateShadowClones();
         }
         updateCommon(game);
         if(!isDieing)
         {
            if(_isDualing)
            {
               _mc.gotoAndStop(_currentDual.attackLabel);
               moveDualPartner(_dualPartner,_currentDual.xDiff);
               if(_mc.mc.currentFrame == _mc.mc.totalFrames)
               {
                  _mc.gotoAndStop("run");
                  _isDualing = false;
                  _state = S_RUN;
                  px += Util.sgn(mc.scaleX) * _currentDual.finalXOffset * this.scaleX * this._scale * _worldScaleX * this.perspectiveScale;
                  dx = 0;
                  dy = 0;
               }
            }
            else if(this.isDash && _state == S_RUN)
            {
               if(Math.abs(_dx) + Math.abs(_dy) > 1)
               {
                  if(!this.dontStealth)
                  {
                     _mc.gotoAndStop("stealth");
                     this._maxVelocity = this.ninjaStealthVelocity;
                  }
                  else
                  {
                     _mc.gotoAndStop("run");
                     if(Boolean(_mc.shadow1) && Boolean(_mc.shadow2))
                     {
                        _mc.shadow1.x = _mc.mc.x - Math.abs(dx) * 10 * this.ninjaCopyDistance;
                        _mc.shadow2.x = _mc.mc.x - Math.abs(dx) * 20 * this.ninjaCopyDistance;
                        _mc.shadow1.y = _mc.mc.y - dy * 5 * this.ninjaCopyDistance;
                        _mc.shadow2.y = _mc.mc.y - dy * 10 * this.ninjaCopyDistance;
                     }
                     this._maxVelocity = this.normalVelocity;
                  }
               }
               else
               {
                  _mc.gotoAndStop("stand");
               }
            }
            else if(_state == S_RUN)
            {
               if(Math.abs(_dx) + Math.abs(_dy) > 0.1)
               {
                  if(this._stealthSpellTimer.inEffect() || this.bossEscapeInvisibleFrames > 0)
                  {
                     _mc.gotoAndStop("stealth");
                     this._maxVelocity = this.ninjaStealthVelocity;
                  }
                  else
                  {
                     _mc.gotoAndStop("run");
                     this._maxVelocity = this.normalVelocity;
                  }
               }
               else
               {
                  _mc.gotoAndStop("stand");
               }
            }
            else if(_state == S_ATTACK)
            {
               if(mc.mc.swing != null)
               {
                  team.game.soundManager.playSoundRandom("ninjaSwipe",4,px,py);
               }
               if(!hasHit)
               {
                  hasHit = this.checkForHit();
                  if(hasHit)
                  {
                     if(this.isBoss && !this.dontStealth)
                     {
                        var wasSpecial:Boolean = this.bossSpecialCloakActive;
                        this.markBossSpecialCloakHit();
                        if(wasSpecial && !(this.currentTarget is Statue))
                        {
                           this.bossPendingChainCloak = true;
                           this.bossPendingChainCloakFrames = BOSS_CHAIN_CLOAK_DELAY_FRAMES;
                        }
                     }
                     if(this._autoPendingShadowCloneOnHit && hasHit && this.isBoss && !(this.currentTarget is Statue))
                     {
                        this._autoPendingShadowCloneOnHit = false;
                        if(this.team != null && this.team.tech.isResearched(Tech.NINJA_SHADOW_CLONE))
                        {
                           this.activateShadowClone();
                        }
                     }
                     this.dontStealth = true;
                     game.soundManager.playSound("sword1",px,py);
                  }
               }
               if(_mc.mc.totalFrames == _mc.mc.currentFrame)
               {
                  _state = S_RUN;
                  this.dontStealth = true;
               }
            }
            updateMotion(game);
         }
         else if(isDead == false)
         {
            if(_isDualing)
            {
               _mc.gotoAndStop(_currentDual.defendLabel);
               if(_mc.mc.currentFrame == _mc.mc.totalFrames)
               {
                  isDualing = false;
                  mc.filters = [];
                  this.team.removeUnit(this,game);
                  isDead = true;
               }
            }
            else
            {
               _mc.gotoAndStop(getDeathLabel(game));
               this.team.removeUnit(this,game);
               isDead = true;
            }
         }
         if(!(isDead && _mc.mc.currentFrame == _mc.mc.totalFrames))
         {
            Util.animateMovieClip(_mc);
         }
         if(!this._stealthSpellTimer.inEffect() && this.bossEscapeInvisibleFrames == 0)
         {
            this.dontStealth = true;
         }
         if(this.isBoss)
         {
            this.updateBossCloakPenaltyState();
         }
         if(!this.dontStealth || this.bossEscapeInvisibleFrames > 0)
         {
            mc.filters = [this.stealthSpellGlow];
            mc.mc.alpha = 1;
         }
         else
         {
            mc.filters = [];
            mc.mc.alpha = 1;
         }
         if(this._lastAnimLabel != _mc.currentLabel)
         {
            this._lastAnimLabel = _mc.currentLabel;
            if(this.isBoss || this.isBossSummoned)
            {
               Ninja.setItem(mc,BOSS_WEAPON_SKIN,BOSS_ARMOR_SKIN,BOSS_MISC_SKIN);
            }
            else if(!hasDefaultLoadout)
            {
               Ninja.setItem(mc,team.loadout.getItem(this.type,MarketItem.T_WEAPON),team.loadout.getItem(this.type,MarketItem.T_ARMOR),team.loadout.getItem(this.type,MarketItem.T_MISC));
            }
         }
      }
      
      override public function isTargetable() : Boolean
      {
         return !isDead && !isDieing && !this._isDualing && this.dontStealth && this.bossEscapeInvisibleFrames == 0;
      }
      
      override public function setActionInterface(a:ActionInterface) : void
      {
         super.setActionInterface(a);
         a.setAction(2,0,UnitCommand.NINJA_STACK);
         if(team.tech.isResearched(Tech.CLOAK) || team.tech.isResearched(Tech.NINJA_SHADOW_CLONE))
         {
            if(team.tech.isResearched(Tech.CLOAK))
            {
               if(this.isBoss && team.tech.isResearched(Tech.NINJA_CLOAK3))
               {
                  a.setAction(0,0,UnitCommand.NINJA_CLOAK3);
               }
               else
               {
                  a.setAction(0,0,UnitCommand.STEALTH);
               }
            }
            a.setAction(1,0,UnitCommand.CURE);
         }
         if(this.isBoss && this._isPlayerBoss && team.tech.isResearched(Tech.NINJA_SHADOW_CLONE) && (team.techAllowed == null || Tech.BOSS_NINJA_UNLOCK in team.techAllowed))
         {
            a.setAction(0,1,UnitCommand.NINJA_SHADOW_CLONE);
         }
      }
      
      override public function get damageToArmour() : Number
      {
         var assasinateDamage:Number = Number(NaN);
         if(!this.dontStealth)
         {
            assasinateDamage = 0;
            if(team.tech.isResearched(Tech.CLOAK_II))
            {
               assasinateDamage = Number(team.game.xml.xml.Order.Units.ninja.stealth.damageToArmour2);
            }
            else if(team.tech.isResearched(Tech.CLOAK))
            {
               assasinateDamage = Number(team.game.xml.xml.Order.Units.ninja.stealth.damageToArmour);
            }
            return _damageToArmour + int(assasinateDamage);
         }
         return _damageToArmour;
      }
      
      override public function get damageToNotArmour() : Number
      {
         var assasinateDamage:Number = Number(NaN);
         if(!this.dontStealth)
         {
            assasinateDamage = 0;
            if(team.tech.isResearched(Tech.CLOAK_II))
            {
               assasinateDamage = Number(team.game.xml.xml.Order.Units.ninja.stealth.damageToNotArmour2);
            }
            else if(team.tech.isResearched(Tech.CLOAK))
            {
               assasinateDamage = Number(team.game.xml.xml.Order.Units.ninja.stealth.damageToNotArmour);
            }
            return _damageToNotArmour + int(assasinateDamage);
         }
         return _damageToNotArmour;
      }
      
      override public function attack() : void
      {
         var id:int = 0;
         if(_state != S_ATTACK)
         {
            id = team.game.random.nextInt() % this._attackLabels.length;
            _mc.gotoAndStop("attack_" + this._attackLabels[id]);
            _mc.mc.gotoAndStop(1);
            _state = S_ATTACK;
            hasHit = false;
            attackStartFrame = team.game.frame;
            framesInAttack = _mc.mc.totalFrames;
         }
      }
      
      override public function mayAttack(target:Unit) : Boolean
      {
         if(framesInAttack > team.game.frame - attackStartFrame)
         {
            return false;
         }
         if(isIncapacitated())
         {
            return false;
         }
         if(target == null)
         {
            return false;
         }
         if(this.isDualing == true)
         {
            return false;
         }
         if(_state == S_RUN)
         {
            if(Math.abs(px - target.px) < WEAPON_REACH && Math.abs(py - target.py) < 40 && this.getDirection() == Util.sgn(target.px - px))
            {
               return true;
            }
         }
         return false;
      }
      
      public function get isAutoCloakToggled() : Boolean
      {
         return this._isAutoCloakToggled;
      }
      
      public function set isAutoCloakToggled(value:Boolean) : void
      {
         this._isAutoCloakToggled = value;
      }
      
      public function get autoPendingShadowCloneOnHit() : Boolean
      {
         return this._autoPendingShadowCloneOnHit;
      }
      
      public function set autoPendingShadowCloneOnHit(value:Boolean) : void
      {
         this._autoPendingShadowCloneOnHit = value;
      }
      
      override public function makeBoss(enableDeathBurst:Boolean = false) : void
      {
         this._isBoss = true;
         this.isBossUnit = true;
         this.hasDefaultLoadout = true;
         this.bossAbilitySpawnLockFrames = 30;
         this.isAutoCloakToggled = true;
         this.damageToDeal *= 1.25;
         this.normalVelocity *= 1.12;
         this._maxVelocity = this.normalVelocity;
         if(this.team != null && !this.team.isAi)
         {
            this.markAsPlayerBoss();
         }
      }
      
      public function releaseFromBossPool() : void
      {
         this._isBoss = false;
         this._isPlayerBoss = false;
         this._isAutoCloakToggled = false;
         this._autoPendingShadowCloneOnHit = false;
         Ninja.setItem(mc,"","","");
         this._lastAnimLabel = "";
      }
      
      override public function damage(type:int, amount:int, inflictor:Entity, modifier:Number = 1) : void
      {
         if(this.isBossSummoned && this.team != null && this.team.game != null)
         {
            if(this.spawnProtectionFrames > 0)
            {
               return;
            }
            if(this.isDead || this.health <= 0)
            {
               return;
            }
            this.team.game.projectileManager.initStealthWallExplosion(this.px,this.py,this.team);
            this.team.removeUnit(this,this.team.game);
            if(this.team.game.battlefield.contains(this))
            {
               this.team.game.battlefield.removeChild(this);
            }
            this.health = 0;
            this.isDead = true;
            return;
         }
         if(this.isBoss && this._isPlayerBoss && (this._shadowClone1 != null || this._shadowClone2 != null) && !this._clonesInCombat)
         {
            var retalTarget:Unit = null;
            var retalHasTarget:Boolean = false;
            if(this.team != null && this.team.enemyTeam != null)
            {
               for each(var retalEnemy in this.team.enemyTeam.units)
               {
                  if(retalEnemy != null && retalEnemy.isAlive() && !retalEnemy.isFlying())
                  {
                     var retalDist:Number = Math.sqrt(Math.pow(retalEnemy.px - this.px,2) + Math.pow(retalEnemy.py - this.py,2));
                     if(retalDist < 500)
                     {
                        retalTarget = retalEnemy;
                        retalHasTarget = true;
                        break;
                     }
                  }
               }
               if(!retalHasTarget)
               {
                  for each(var retalWall in this.team.enemyTeam.walls)
                  {
                     if(retalWall != null && retalWall.isAlive())
                     {
                        var wallRetalDist:Number = Math.sqrt(Math.pow(retalWall.px - this.px,2) + Math.pow(retalWall.py - this.py,2));
                        if(wallRetalDist < 500)
                        {
                           retalTarget = retalWall;
                           retalHasTarget = true;
                           break;
                        }
                     }
                  }
               }
               if(!retalHasTarget && this.team.enemyTeam.statue != null && this.team.enemyTeam.statue.isAlive())
               {
                  var statueRetalDist:Number = Math.sqrt(Math.pow(this.team.enemyTeam.statue.px - this.px,2) + Math.pow(this.team.enemyTeam.statue.py - this.py,2));
                  if(statueRetalDist < 500)
                  {
                     retalTarget = this.team.enemyTeam.statue;
                     retalHasTarget = true;
                  }
               }
            }
            if(retalHasTarget)
            {
               var retalFrontCmd:AttackMoveCommand = new AttackMoveCommand(this.team.game);
               retalFrontCmd.type = UnitCommand.ATTACK_MOVE;
               retalFrontCmd.goalX = retalTarget.px;
               retalFrontCmd.goalY = retalTarget.py;
               retalFrontCmd.realX = retalFrontCmd.goalX;
               retalFrontCmd.realY = retalFrontCmd.goalY;
               if(this._shadowClone1 != null)
               {
                  this._shadowClone1.isBossMovementLocked = false;
                  this._shadowClone1.ai.setCommand(this.team.game,retalFrontCmd);
               }
               if(this._shadowClone2 != null)
               {
                  this._shadowClone2.isBossMovementLocked = false;
                  if(retalTarget.type != Unit.U_WALL && retalTarget.type != Unit.U_STATUE && retalTarget.team != null)
                  {
                     var retalFlankCmd:AttackMoveCommand = new AttackMoveCommand(this.team.game);
                     retalFlankCmd.type = UnitCommand.ATTACK_MOVE;
                     retalFlankCmd.goalX = retalTarget.px + retalTarget.team.direction * 140;
                     retalFlankCmd.goalY = retalTarget.py;
                     retalFlankCmd.realX = retalFlankCmd.goalX;
                     retalFlankCmd.realY = retalFlankCmd.goalY;
                     this._shadowClone2.ai.setCommand(this.team.game,retalFlankCmd);
                  }
                  else
                  {
                     this._shadowClone2.ai.setCommand(this.team.game,retalFrontCmd);
                  }
               }
               this._clonesInCombat = true;
            }
         }
         if(this.isBoss && this.bossPendingChainCloak && this.bossPendingChainCloakFrames > 0 && this.dontStealth)
         {
            if(this._isAutoCloakToggled && this.team != null && this.team.tech.isResearched(Tech.NINJA_SHADOW_CLONE))
            {
               this.activateShadowClone();
            }
            this.bossPendingChainCloak = false;
            this.bossPendingChainCloakFrames = 0;
            this.bossWhiffPenaltyFrames = this.bossWhiffPenaltyCooldownMax;
            this.bossNeedsSpecialReset = true;
         }
         if(this.isBoss || this.isBossSummoned)
         {
            modifier *= BOSS_DAMAGE_TAKEN_MULTIPLIER;
         }
         super.damage(type,amount,inflictor,modifier);
         if(this.isBoss && this._isPlayerBoss && this.health <= 0)
         {
            if(this._shadowClone1 != null)
            {
               this._shadowClone1.damage(0,9999,null);
               this._shadowClone1 = null;
            }
            if(this._shadowClone2 != null)
            {
               this._shadowClone2.damage(0,9999,null);
               this._shadowClone2 = null;
            }
         }
      }
      
      public function get isBoss() : Boolean
      {
         return this._isBoss;
      }
      
      public function get isAttackAnimationActive() : Boolean
      {
         return _state == S_ATTACK;
      }
      
      public function markAsPlayerBoss() : void
      {
         this._isPlayerBoss = true;
      }
      
      public function get isPlayerBoss() : Boolean
      {
         return this._isPlayerBoss;
      }
      
      public function tryBossChainCloak() : Boolean
      {
         if(!this.isBoss || this.hasBossAbilitySpawnLock() || !this.bossPendingChainCloak || this.bossPendingChainCloakFrames > 0 || _state == S_ATTACK || this.hasBossWhiffPenalty())
         {
            return false;
         }
         this.bossPendingChainCloak = false;
         this.bossPendingChainCloakFrames = 0;
         if(this._isPlayerBoss && team.tech.isResearched(Tech.NINJA_CLOAK3))
         {
            if(team.mana < 50)
            {
               this.bossWhiffPenaltyFrames = this.bossWhiffPenaltyCooldownMax;
               return false;
            }
            team.mana -= 50;
         }
         return this.bossSpecialStealth(true,true);
      }
      
      public function isBossSpecialTargetingActive() : Boolean
      {
         return this.bossSpecialCloakActive || this.bossPendingChainCloak;
      }
      
      public function getBossCloakCooldownFraction() : Number
      {
         if(this.bossWhiffPenaltyFrames > 0)
         {
            return this.bossWhiffPenaltyFrames / this.bossWhiffPenaltyCooldownMax;
         }
         return 0;
      }
      
      public function shouldEnterBossFinalStand() : Boolean
      {
         if(this.campaignBossEscaping)
         {
            return false;
         }
         if(this._isPlayerBoss)
         {
            return false;
         }
         return this.isBoss && !this._bossEmergencySortie && this.health <= this.maxHealth * BOSS_RETREAT_HEALTH_RATIO;
      }
      
      public function get bossEmergencySortie() : Boolean
      {
         return this._bossEmergencySortie;
      }
      
      public function shouldStartBossLostPhase() : Boolean
      {
         return this.campaignBossEscapeEnabled && !this.campaignBossEscaping && this.health <= this.maxHealth * BOSS_LOST_HEALTH_RATIO;
      }
      
      public function get bossInFinalStand() : Boolean
      {
         return this._bossEmergencySortie;
      }
      
      public function enterBossFinalStand() : void
      {
         if(this._bossEmergencySortie || this.campaignBossEscaping)
         {
            return;
         }
         this._bossEmergencySortie = true;
         this.bossRetreatCooldownFrames = 0;
         this.bossWhiffPenaltyFrames = 0;
         this.bossPendingChainCloak = false;
         this.bossPendingChainCloakFrames = 0;
         this.bossNeedsSpecialReset = false;
         this.bossSpecialCloakActive = false;
         this.bossSpecialCloakHit = false;
         this.bossEscapeInvisibleFrames = 0;
         this.bossImmediateSpecialReady = true;
         this._shadowCloneCooldownFrames = 0;
         this.dontStealth = true;
      }
      
      public function activateShadowClone() : void
      {
         if(this._shadowCloneCooldownFrames > 0)
         {
            return;
         }
         if(team.game.gameScreen is CampaignGameScreen && !team.game.gameScreen.canUseRebelsUnitedBossAbility(this,"shadowClone"))
         {
            return;
         }
         var liveCount:int = 0;
         if(this._shadowClone1 != null)
         {
            liveCount++;
         }
         if(this._shadowClone2 != null)
         {
            liveCount++;
         }
         if(liveCount >= 2)
         {
            if(team.game.gameScreen != null && team.game.gameScreen.userInterface != null)
            {
               team.game.gameScreen.userInterface.helpMessage.showMessage("Already have max Shadow Clones");
            }
            return;
         }
         var game:StickWar = this.team.game;
         if(team.mana < game.xml.xml.Order.Units.ninja.shadowClone.mana)
         {
            return;
         }
         team.mana -= game.xml.xml.Order.Units.ninja.shadowClone.mana;
         var i:int = 0;
         i = 0;
         while(i < 2)
         {
            if(!(i == 0 && this._shadowClone1 != null))
            {
               if(!(i == 1 && this._shadowClone2 != null))
               {
                  var clone:Ninja = game.unitFactory.getUnit(Unit.U_NINJA);
                  this.team.spawn(clone,game);
                  clone.px = this.px + (i - 1) * 30;
                  clone.py = Math.max(80,Math.min(game.map.height - 80,this.py + (i - 1) * 40));
                  clone.x = clone.px;
                  clone.y = clone.py;
                  clone.isBossUnit = true;
                  clone.isBossSummoned = true;
                  clone.spawnProtectionFrames = 90;
                  clone.health = 9999;
                  clone.maxHealth = 9999;
                  clone.healthBar.alpha = 0;
                  clone.isBossMovementLocked = true;
                  clone.population = 0;
                  var holdCommand:HoldCommand = new HoldCommand(game);
                  holdCommand.type = UnitCommand.HOLD;
                  clone.ai.setCommand(game,holdCommand);
                  game.projectileManager.initStealthWallExplosion(clone.px,clone.py,this.team);
                  game.soundManager.playSound("mediumExplosion3",clone.px,clone.py);
                  if(i == 0)
                  {
                     this._shadowClone1 = clone;
                  }
                  else
                  {
                     this._shadowClone2 = clone;
                  }
               }
            }
            i++;
         }
         this._cloneIdleTimerFrames = CLONE_IDLE_TIMEOUT_FRAMES;
         var cloneTarget:Unit = null;
         var hasCloneTarget:Boolean = false;
         if(this._lastCloneRetargetId != -1 && this.team != null && this.team.game != null)
         {
            var cachedTarget:Unit = this.team.game.units[this._lastCloneRetargetId];
            if(cachedTarget != null && cachedTarget.isAlive() && cachedTarget.team != null && cachedTarget.team == this.team.enemyTeam && !cachedTarget.isFlying())
            {
               var cachedDist:Number = Math.sqrt(Math.pow(cachedTarget.px - this.px,2) + Math.pow(cachedTarget.py - this.py,2));
               if(cachedDist < 500)
               {
                  cloneTarget = cachedTarget;
                  hasCloneTarget = true;
               }
            }
         }
         if(!hasCloneTarget)
         {
            cloneTarget = ai.getClosestTarget();
            if(cloneTarget != null && cloneTarget.isAlive() && cloneTarget.team != null && cloneTarget.team != this.team && !cloneTarget.isFlying())
            {
               hasCloneTarget = true;
            }
            else if(this.team != null && this.team.enemyTeam != null)
            {
               for each(var scanEnemy in this.team.enemyTeam.units)
               {
                  if(scanEnemy != null && scanEnemy.isAlive() && !scanEnemy.isFlying())
                  {
                     var scanDist:Number = Math.sqrt(Math.pow(scanEnemy.px - this.px,2) + Math.pow(scanEnemy.py - this.py,2));
                     if(scanDist < 500)
                     {
                        cloneTarget = scanEnemy;
                        hasCloneTarget = true;
                        break;
                     }
                  }
               }
               if(!hasCloneTarget)
               {
                  for each(var scanWall in this.team.enemyTeam.walls)
                  {
                     if(scanWall != null && scanWall.isAlive())
                     {
                        var wallDist:Number = Math.sqrt(Math.pow(scanWall.px - this.px,2) + Math.pow(scanWall.py - this.py,2));
                        if(wallDist < 300)
                        {
                           cloneTarget = scanWall;
                           hasCloneTarget = true;
                           break;
                        }
                     }
                  }
               }
               if(!hasCloneTarget && this.team.enemyTeam.statue != null && this.team.enemyTeam.statue.isAlive())
               {
                  var statueDist:Number = Math.sqrt(Math.pow(this.team.enemyTeam.statue.px - this.px,2) + Math.pow(this.team.enemyTeam.statue.py - this.py,2));
                  if(statueDist < 300)
                  {
                     cloneTarget = this.team.enemyTeam.statue;
                     hasCloneTarget = true;
                  }
               }
            }
         }
         if(hasCloneTarget)
         {
            var frontCmd:AttackMoveCommand = new AttackMoveCommand(game);
            frontCmd.type = UnitCommand.ATTACK_MOVE;
            frontCmd.goalX = cloneTarget.px;
            frontCmd.goalY = cloneTarget.py;
            frontCmd.realX = frontCmd.goalX;
            frontCmd.realY = frontCmd.goalY;
            if(this._shadowClone1 != null)
            {
               this._shadowClone1.isBossMovementLocked = false;
               this._shadowClone1.ai.setCommand(game,frontCmd);
            }
            if(this._shadowClone2 != null)
            {
               this._shadowClone2.isBossMovementLocked = false;
               if(cloneTarget.type != Unit.U_WALL && cloneTarget.type != Unit.U_STATUE && cloneTarget.team != null)
               {
                  var flankCmd:AttackMoveCommand = new AttackMoveCommand(game);
                  flankCmd.type = UnitCommand.ATTACK_MOVE;
                  flankCmd.goalX = cloneTarget.px + cloneTarget.team.direction * 140;
                  flankCmd.goalY = cloneTarget.py;
                  flankCmd.realX = flankCmd.goalX;
                  flankCmd.realY = flankCmd.goalY;
                  this._shadowClone2.ai.setCommand(game,flankCmd);
               }
               else
               {
                  this._shadowClone2.ai.setCommand(game,frontCmd);
               }
            }
            this._clonesInCombat = true;
         }
         else
         {
            this._clonesInCombat = false;
            if(this._shadowClone1 != null)
            {
               this._shadowClone1.isBossMovementLocked = true;
               var defaultHold1:HoldCommand = new HoldCommand(game);
               defaultHold1.type = UnitCommand.HOLD;
               this._shadowClone1.ai.setCommand(game,defaultHold1);
            }
            if(this._shadowClone2 != null)
            {
               this._shadowClone2.isBossMovementLocked = true;
               var defaultHold2:HoldCommand = new HoldCommand(game);
               defaultHold2.type = UnitCommand.HOLD;
               this._shadowClone2.ai.setCommand(game,defaultHold2);
            }
         }
      }
      
      private function removeShadowClone(clone:Ninja) : void
      {
         if(clone == null)
         {
            return;
         }
         if(clone.isDead)
         {
            return;
         }
         if(clone.team != null && clone.team.game != null)
         {
            clone.health = 0;
            clone.isDead = true;
            clone.team.game.projectileManager.initStealthWallExplosion(clone.px,clone.py,clone.team);
            clone.team.removeUnit(clone,clone.team.game);
            if(clone.team.game.battlefield.contains(clone))
            {
               clone.team.game.battlefield.removeChild(clone);
            }
         }
      }
      
      private function updateShadowClones() : void
      {
         if(this._shadowCloneCooldownFrames > 0)
         {
            --this._shadowCloneCooldownFrames;
         }
         if(!this._clonesInCombat)
         {
            if(this._shadowClone1 == null && this._shadowClone2 == null)
            {
               return;
            }
            if(this._shadowClone1 != null && !this._shadowClone1.isAlive())
            {
               this._clonesInCombat = true;
               this._shadowClone1 = null;
               if(this._shadowCloneCooldownFrames == 0)
               {
                  this._shadowCloneCooldownFrames = this.shadowCloneCooldownMax;
               }
            }
            if(this._shadowClone2 != null && !this._shadowClone2.isAlive())
            {
               this._clonesInCombat = true;
               this._shadowClone2 = null;
               if(this._shadowCloneCooldownFrames == 0)
               {
                  this._shadowCloneCooldownFrames = this.shadowCloneCooldownMax;
               }
            }
            if(this._shadowClone1 == null && this._shadowClone2 == null)
            {
               return;
            }
            if(this._cloneIdleTimerFrames > 0)
            {
               --this._cloneIdleTimerFrames;
               if(this._cloneIdleTimerFrames <= 0)
               {
                  this.removeShadowClone(this._shadowClone1);
                  this._shadowClone1 = null;
                  this.removeShadowClone(this._shadowClone2);
                  this._shadowClone2 = null;
                  this._cloneIdleTimerFrames = 0;
                  return;
               }
            }
            var hasNearbyEnemy:Boolean = false;
            if(this.team != null && this.team.enemyTeam != null)
            {
               for each(var enemy in this.team.enemyTeam.units)
               {
                  if(enemy != null && enemy.isAlive())
                  {
                     var d:Number = Math.sqrt(Math.pow(enemy.px - this.px,2) + Math.pow(enemy.py - this.py,2));
                     if(d < 300)
                     {
                        hasNearbyEnemy = true;
                        break;
                     }
                  }
               }
            }
            if(hasNearbyEnemy)
            {
               this._clonesInCombat = true;
               return;
            }
            if(this._shadowClone1 != null)
            {
               this._shadowClone1.isBossMovementLocked = false;
               var forwardCmd1:AttackMoveCommand = new AttackMoveCommand(this.team.game);
               forwardCmd1.type = UnitCommand.ATTACK_MOVE;
               forwardCmd1.goalX = this.team.homeX + this.team.direction * 5000;
               forwardCmd1.goalY = this.py - 20;
               this._shadowClone1.ai.setCommand(this.team.game,forwardCmd1);
            }
            if(this._shadowClone2 != null)
            {
               this._shadowClone2.isBossMovementLocked = false;
               var forwardCmd2:AttackMoveCommand = new AttackMoveCommand(this.team.game);
               forwardCmd2.type = UnitCommand.ATTACK_MOVE;
               forwardCmd2.goalX = this.team.homeX + this.team.direction * 5000;
               forwardCmd2.goalY = this.py + 20;
               this._shadowClone2.ai.setCommand(this.team.game,forwardCmd2);
            }
         }
         else
         {
            var enemiesNear:Boolean = false;
            for each(var checkEnemy in this.team.enemyTeam.units)
            {
               if(checkEnemy != null && checkEnemy.isAlive() && !checkEnemy.isFlying())
               {
                  var closeDist:Number = Math.sqrt(Math.pow(checkEnemy.px - this.px,2) + Math.pow(checkEnemy.py - this.py,2));
                  if(closeDist < 300)
                  {
                     enemiesNear = true;
                     break;
                  }
               }
            }
            if(!enemiesNear)
            {
               for each(var closeWall in this.team.enemyTeam.walls)
               {
                  if(closeWall != null && closeWall.isAlive())
                  {
                     var wallCloseDist:Number = Math.sqrt(Math.pow(closeWall.px - this.px,2) + Math.pow(closeWall.py - this.py,2));
                     if(wallCloseDist < 300)
                     {
                        enemiesNear = true;
                        break;
                     }
                  }
               }
            }
            if(!enemiesNear && this.team.enemyTeam.statue != null && this.team.enemyTeam.statue.isAlive())
            {
               var statueCloseDist:Number = Math.sqrt(Math.pow(this.team.enemyTeam.statue.px - this.px,2) + Math.pow(this.team.enemyTeam.statue.py - this.py,2));
               if(statueCloseDist < 300)
               {
                  enemiesNear = true;
               }
            }
            if(!enemiesNear)
            {
               this._clonesInCombat = false;
               this._cloneIdleTimerFrames = CLONE_IDLE_TIMEOUT_FRAMES;
               if(this._shadowClone1 != null)
               {
                  this._shadowClone1.isBossMovementLocked = false;
                  var idleCmd1:AttackMoveCommand = new AttackMoveCommand(this.team.game);
                  idleCmd1.type = UnitCommand.ATTACK_MOVE;
                  idleCmd1.goalX = this.team.homeX + this.team.direction * 5000;
                  idleCmd1.goalY = this.py - 20;
                  this._shadowClone1.ai.setCommand(this.team.game,idleCmd1);
               }
               if(this._shadowClone2 != null)
               {
                  this._shadowClone2.isBossMovementLocked = false;
                  var idleCmd2:AttackMoveCommand = new AttackMoveCommand(this.team.game);
                  idleCmd2.type = UnitCommand.ATTACK_MOVE;
                  idleCmd2.goalX = this.team.homeX + this.team.direction * 5000;
                  idleCmd2.goalY = this.py + 20;
                  this._shadowClone2.ai.setCommand(this.team.game,idleCmd2);
               }
            }
         }
         if(this._shadowClone1 != null && !this._shadowClone1.isAlive())
         {
            this._clonesInCombat = true;
            this._shadowClone1 = null;
            if(this._shadowCloneCooldownFrames == 0)
            {
               this._shadowCloneCooldownFrames = this.shadowCloneCooldownMax;
            }
         }
         if(this._shadowClone2 != null && !this._shadowClone2.isAlive())
         {
            this._clonesInCombat = true;
            this._shadowClone2 = null;
            if(this._shadowCloneCooldownFrames == 0)
            {
               this._shadowCloneCooldownFrames = this.shadowCloneCooldownMax;
            }
         }
         if(this._shadowClone1 == null && this._shadowClone2 == null)
         {
            this._clonesInCombat = false;
         }
      }
      
      public function shadowCloneCooldownFraction() : Number
      {
         if(this._shadowCloneCooldownFrames > 0)
         {
            return this._shadowCloneCooldownFrames / this.shadowCloneCooldownMax;
         }
         return 0;
      }
      
      public function triggerBossEscapeCloak() : void
      {
         this.bossPendingChainCloak = false;
         this.bossPendingChainCloakFrames = 0;
         this.bossNeedsSpecialReset = false;
         this.bossSpecialCloakActive = false;
         this.bossSpecialCloakHit = false;
         this.bossEscapeInvisibleFrames = BOSS_ESCAPE_INVISIBLE_FRAMES;
         this.dontStealth = false;
         this.team.game.projectileManager.initStealthWallExplosion(this.px,this.py,this.team);
         this.team.game.soundManager.playSound("mediumExplosion3",this.px,this.py);
      }
      
      public function failBossSpecial() : void
      {
         this.bossPendingChainCloak = false;
         this.bossPendingChainCloakFrames = 0;
         this.bossSpecialCloakActive = false;
         this.bossSpecialCloakHit = false;
         this.bossWhiffPenaltyFrames = this.bossWhiffPenaltyCooldownMax;
         this.bossNeedsSpecialReset = true;
         this.dontStealth = true;
      }
      
      public function get needsBossSpecialReset() : Boolean
      {
         return this.bossNeedsSpecialReset;
      }
      
      public function finishBossSpecialReset() : void
      {
         this.bossNeedsSpecialReset = false;
      }
      
      public function hasBossWhiffPenalty() : Boolean
      {
         return this.bossWhiffPenaltyFrames > 0;
      }
      
      public function get isStealthed() : Boolean
      {
         return !this.dontStealth;
      }
      
      private function markBossSpecialCloakHit() : void
      {
         this.bossSpecialCloakHit = true;
         this.bossSpecialCloakActive = false;
         this._stealthSpellTimer.endEffect();
      }
      
      private function updateBossCloakPenaltyState() : void
      {
         var stealthActive:Boolean = this._stealthSpellTimer.inEffect();
         if(this.bossCloakWasActive && !stealthActive && this.bossSpecialCloakActive && !this.bossSpecialCloakHit)
         {
            if(this._isAutoCloakToggled && this.team != null && this.team.tech.isResearched(Tech.NINJA_SHADOW_CLONE))
            {
               this.activateShadowClone();
            }
            this.bossWhiffPenaltyFrames = this.bossWhiffPenaltyCooldownMax;
            this.bossPendingChainCloak = false;
            this.bossPendingChainCloakFrames = 0;
            this.bossNeedsSpecialReset = true;
         }
         if(!stealthActive)
         {
            this.bossSpecialCloakActive = false;
            this.bossSpecialCloakHit = false;
         }
         this.bossCloakWasActive = stealthActive;
      }
   }
}

