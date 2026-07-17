package com.brockw.stickwar.engine.units
{
   import com.brockw.game.Util;
   import com.brockw.stickwar.campaign.Campaign;
   import com.brockw.stickwar.campaign.CampaignGameScreen;
   import com.brockw.stickwar.engine.*;
   import com.brockw.stickwar.engine.Ai.*;
   import com.brockw.stickwar.engine.Ai.command.*;
   import com.brockw.stickwar.engine.Team.Chaos.*;
   import com.brockw.stickwar.engine.Team.Team;
   import com.brockw.stickwar.engine.Team.Tech;
   import com.brockw.stickwar.market.MarketItem;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   
   public class Wingidon extends com.brockw.stickwar.engine.units.RangedUnit
   {
      
      private static var WEAPON_REACH:int;
      
      private static const BOSS_HEAD_SKIN:String = "Demon Mask";
      
      private static const BOSS_QUIVER_SKIN:String = "Demon Quiver";
      
      private static const BOSS_HEALTH_MULTIPLIER:Number = 2.4;
      
      private static const BOSS_DAMAGE_MULTIPLIER:Number = 1.25;
      
      private static const BOSS_MARK_DURATION_FRAMES:int = 30 * 12;
      
      private static const BOSS_MARK_COOLDOWN_FRAMES:int = 30 * 12;
      
      private static const BOSS_BURST_COOLDOWN_FRAMES:int = 30 * 16;
      
      private static const BOSS_AURA_DURATION_FRAMES:int = 30 * 10;
      
      private static const BOSS_AURA_COOLDOWN_FRAMES:int = 30 * 25;
      
      private static const BOSS_BURST_STUN_FRAMES:int = 30 * 3;
      
      private static const BOSS_SPECIAL_HIT_WINDOW_FRAMES:int = 30 * 4;
      
      private static const BOSS_AURA_RADIUS:Number = 650;
      
      private static const BOSS_MARK_FOCUS_RADIUS:Number = 750;
      
      private static const BOSS_ARROW_RETREAT_THRESHOLD:Number = 120;
      
      private static const BOSS_PROJECTILE_RESISTANCE_FRAMES:int = 30 * 4;
      
      private static const BOSS_PROJECTILE_RESISTANCE:Number = 0.6;
      
      private static const BOSS_NIGHTFALL_DURATION_FRAMES:int = 30 * 8;
      
      private static const NIGHTFALL_FOG_OFFSET:Number = 350;
      
      private static const BOSS_RETREAT_FRAMES:int = 30;
      
      private static const NIGHTFALL_ADVANCE_SPEED:Number = 5;
      
      private static const NIGHTFALL_RETREAT_SPEED:Number = 5;
      
      private static const BOSS_EXTREME_SLOW_FRAMES:int = 30 * 5;
      
      private static const BOSS_DEFENSE_DEBUFF_FRAMES:int = 30 * 5;
      
      private static const BOSS_DEFENSE_DEBUFF_MULTIPLIER:Number = 1.5;
      
      private static const BOSS_ECLIPSE_MARK_RANGE:int = 900;
      
      private var wingidonSpeedSpell:SpellCooldown;
      
      private var normalVelocity:Number;
      
      private var windStrength:Number;
      
      private var _isBoss:Boolean;
      
      private var eclipseMarkCooldownFrames:int;
      
      private var demonBurstCooldownFrames:int;
      
      private var skyCommanderCooldownFrames:int;
      
      private var skyCommanderAuraFrames:int;
      
      private var pendingEclipseMarkHits:int;
      
      private var eclipseMarkHitWindowFrames:int;
      
      private var pendingEclipseMarkTargetId:int;
      
      private var pendingEclipseMarkDamage:Number;
      
      private var pendingDemonBurstHits:int;
      
      private var demonBurstHitWindowFrames:int;
      
      private var pendingDemonBurstDamage:Number;
      
      private var demonBurstStunnedIds:Object;
      
      private var eclipseMarkedUnitId:int;
      
      private var eclipseMarkUntilFrame:int;
      
      private var projectileResistanceFrames:int;
      
      private var arrowDamageTaken:Number;
      
      private var _hasUsedArrowRetreat:Boolean;
      
      private var _hasShownNightfallMessage:Boolean;
      
      private var _hasTriggeredStatueNightfall:Boolean;
      
      private var _nightfallPhase:int;
      
      private var bossRetreatFrames:int;
      
      private var nightfallActiveFrames:int;
      
      private var _isNightfallActive:Boolean;
      
      private var nightfallFogPosition:Number;
      
      private var _pendingAuraFrames:int;
      
      public function Wingidon(game:StickWar)
      {
         super(game);
         _mc = new _wingidon();
         this.init(game);
         addChild(_mc);
         ai = new WingidonAi(this);
         initSync();
         firstInit();
         this._isBoss = false;
         this.eclipseMarkCooldownFrames = 0;
         this.demonBurstCooldownFrames = 0;
         this.skyCommanderCooldownFrames = 0;
         this.skyCommanderAuraFrames = 0;
         this.pendingEclipseMarkHits = 0;
         this.eclipseMarkHitWindowFrames = 0;
         this.pendingEclipseMarkTargetId = -1;
         this.pendingEclipseMarkDamage = 0;
         this.pendingDemonBurstHits = 0;
         this.demonBurstHitWindowFrames = 0;
         this.pendingDemonBurstDamage = 0;
         this.demonBurstStunnedIds = {};
         this.eclipseMarkedUnitId = -1;
         this.eclipseMarkUntilFrame = 0;
         this.projectileResistanceFrames = 0;
         this.arrowDamageTaken = 0;
         this._hasUsedArrowRetreat = false;
         this._hasShownNightfallMessage = false;
         this._hasTriggeredStatueNightfall = false;
         this._nightfallPhase = 0;
         this.bossRetreatFrames = 0;
         this.nightfallActiveFrames = 0;
         this._isNightfallActive = false;
         this.nightfallFogPosition = 0;
      }
      
      public static function setItem(mc:MovieClip, weapon:String, armor:String, misc:String) : void
      {
         var m:_wingidon = mc;
         if(Boolean(m.mc.body))
         {
            if(Boolean(m.mc.body.head))
            {
               if(armor != "")
               {
                  m.mc.body.head.gotoAndStop(armor);
               }
            }
            if(Boolean(m.mc.body.quiver))
            {
               if(misc != "")
               {
                  m.mc.body.quiver.gotoAndStop(misc);
               }
            }
         }
      }
      
      override public function init(game:StickWar) : void
      {
         initBase();
         this.projectileVelocity = game.xml.xml.Chaos.Units.wingidon.arrowVelocity;
         population = game.xml.xml.Chaos.Units.wingidon.population;
         _mass = game.xml.xml.Chaos.Units.wingidon.mass;
         _maxForce = game.xml.xml.Chaos.Units.wingidon.maxForce;
         _dragForce = game.xml.xml.Chaos.Units.wingidon.dragForce;
         _scale = game.xml.xml.Chaos.Units.wingidon.scale;
         this.createTime = game.xml.xml.Chaos.Units.wingidon.cooldown;
         this.windStrength = game.xml.xml.Chaos.Units.wingidon.win.sStrength;
         this.normalVelocity = _maxVelocity = game.xml.xml.Chaos.Units.wingidon.maxVelocity;
         _maximumRange = game.xml.xml.Chaos.Units.wingidon.maximumRange;
         maxHealth = health = game.xml.xml.Chaos.Units.wingidon.health;
         type = Unit.U_WINGIDON;
         flyingHeight = 250 * 1;
         this.wingidonSpeedSpell = new SpellCooldown(game.xml.xml.Chaos.Units.wingidon.wind.effect,game.xml.xml.Chaos.Units.wingidon.wind.cooldown,game.xml.xml.Chaos.Units.wingidon.wind.mana);
         loadDamage(game.xml.xml.Chaos.Units.wingidon);
         _mc.stop();
         _mc.width *= _scale;
         _mc.height *= _scale;
         _hitBoxWidth = 25;
         _state = S_RUN;
         _mc.mc.gotoAndPlay(1);
         _mc.gotoAndStop(1);
         py = 0;
         pz = -flyingHeight * (game.backScale + py / game.map.height * (game.frontScale - game.backScale));
         y = -100;
         if(game != null)
         {
            mc.mc.body.wings1.gotoAndPlay(Math.floor(mc.mc.body.wings1.totalFrames * game.random.nextNumber()));
            mc.mc.body.wings2.gotoAndPlay(mc.mc.body.wings1.currentFrame);
         }
         drawShadow();
         this.healthBar.y = -mc.mc.height * 0.9;
      }
      
      override public function setBuilding() : void
      {
         building = team.buildings["ArcheryBuilding"];
      }
      
      override public function setActionInterface(a:ActionInterface) : void
      {
         super.setActionInterface(a);
      }
      
      public function speedSpell() : void
      {
         if(this.wingidonSpeedSpell.spellActivate(team))
         {
         }
      }
      
      public function speedSpellCooldown() : Number
      {
         return this.wingidonSpeedSpell.cooldown();
      }
      
      override public function update(game:StickWar) : void
      {
         var arms:MovieClip = null;
         this.updateBossTimers(game);
         this.wingidonSpeedSpell.update();
         super.update(game);
         updateCommon(game);
         if(!isDieing)
         {
            if(_mc.mc.body.legs != null)
            {
               _mc.mc.body.legs.rotation = getDirection() * _dx / _maxVelocity * game.xml.xml.Chaos.Units.wingidon.legRotateAngleWhenFlying;
               mc.mc.body.legs.nextFrame();
               if(mc.mc.body.legs.currentFrame == mc.mc.body.legs.totalFrames)
               {
                  mc.mc.body.legs.gotoAndStop(1);
               }
            }
            if(mc.mc.body.wings1 != null)
            {
               if(this.wingidonSpeedSpell.inEffect())
               {
                  mc.mc.body.wings1.nextFrame();
                  mc.mc.body.wings2.nextFrame();
                  game.projectileManager.airEffects.push([px + team.direction * 100,py,team.direction * this.windStrength,team]);
               }
               mc.mc.body.wings1.nextFrame();
               mc.mc.body.wings2.nextFrame();
               if(mc.mc.body.wings1.currentFrame == mc.mc.body.wings1.totalFrames)
               {
                  mc.mc.body.wings1.gotoAndStop(1);
               }
               if(mc.mc.body.wings2.currentFrame == mc.mc.body.wings2.totalFrames)
               {
                  mc.mc.body.wings2.gotoAndStop(1);
               }
            }
            updateMotion(game);
            arms = _mc.mc.body.arms;
            if(arms != null)
            {
               if(arms.currentFrame != 1)
               {
                  arms.nextFrame();
                  if(!this.isBoss && this.hasNearbySkyCommanderAura())
                  {
                     if(arms.currentFrame != 1 && arms.currentFrame != arms.totalFrames)
                     {
                        arms.nextFrame();
                     }
                  }
                  if(arms.currentFrame == arms.totalFrames)
                  {
                     arms.gotoAndStop(1);
                  }
               }
               arms.rotation = bowAngle;
            }
            if(!this.isBoss)
            {
               if(this.hasNearbySkyCommanderAura())
               {
                  this.filters = [new GlowFilter(16737792,0.9,14,14,3,1)];
               }
               else
               {
                  this.filters = [];
               }
            }
            if(_isDualing)
            {
               _mc.gotoAndStop(_currentDual.attackLabel);
               moveDualPartner(_dualPartner,_currentDual.xDiff);
               if(_mc.mc.currentFrame == _mc.mc.totalFrames)
               {
                  _isDualing = false;
                  _state = S_RUN;
                  px += Util.sgn(mc.scaleX) * _currentDual.finalXOffset * this.scaleX * this._scale * _worldScaleX * this.perspectiveScale;
                  dx = 0;
                  dy = 0;
               }
            }
            else if(_state == S_RUN)
            {
               if(Math.abs(_dx) + Math.abs(_dy) > 0.1)
               {
               }
            }
            else if(_state == S_ATTACK)
            {
               if(_mc.mc.currentFrame > _mc.mc.totalFrames / 2 && !hasHit)
               {
                  hasHit = this.checkForHit();
               }
               if(_mc.mc.totalFrames == _mc.mc.currentFrame)
               {
                  _state = S_RUN;
               }
            }
         }
         else if(isDead == false)
         {
            isDead = true;
            if(this._isNightfallActive)
            {
               this._isNightfallActive = false;
               this._nightfallPhase = 0;
               game.fogOfWar.isNightfallActive = false;
               game.fogOfWar.unlockForwardPosition();
            }
            if(!this.isBoss)
            {
               if(this.hasNearbySkyCommanderAura())
               {
                  this.filters = [new GlowFilter(16737792,0.9,14,14,3,1)];
               }
               else
               {
                  this.filters = [];
               }
            }
            if(_isDualing)
            {
               _mc.gotoAndStop(_currentDual.defendLabel);
            }
            else
            {
               _mc.gotoAndStop(getDeathLabel(game));
            }
            this.team.removeUnit(this,game);
         }
         if(!isDead && _mc.mc.currentFrame == _mc.mc.totalFrames)
         {
            _mc.mc.gotoAndStop(1);
         }
         if(!isDead && _mc.mc != null)
         {
            _mc.mc.nextFrame();
            if(_mc.mc.currentFrame == _mc.mc.totalFrames)
            {
               _mc.mc.gotoAndStop(1);
            }
         }
         if(!isDead && _mc.mc.wings1 != null)
         {
            _mc.mc.gotoAndStop(_mc.mc.wings1.currentFrame);
         }
         if(isDead)
         {
            Util.animateMovieClip(_mc,3);
            if(_mc.mc.body != null && _mc.mc.body.quiver != null)
            {
               _mc.mc.body.quiver.gotoAndStop(1);
            }
            else if(_mc.mc.quiver != null)
            {
               _mc.mc.quiver.gotoAndStop(1);
            }
         }
         if(!hasDefaultLoadout)
         {
            if(this.isBoss)
            {
               Wingidon.setItem(mc,"",BOSS_HEAD_SKIN,BOSS_QUIVER_SKIN);
            }
            else
            {
               Wingidon.setItem(mc,team.loadout.getItem(this.type,MarketItem.T_WEAPON),team.loadout.getItem(this.type,MarketItem.T_ARMOR),team.loadout.getItem(this.type,MarketItem.T_MISC));
            }
         }
      }
      
      private function updateBossTimers(game:StickWar) : void
      {
         if(!this.isBoss)
         {
            return;
         }
         if(!this._hasTriggeredStatueNightfall && team != null && team.statue != null && team.statue.health <= team.statue.maxHealth * 0.5)
         {
            this._hasTriggeredStatueNightfall = true;
            if(game.gameScreen is CampaignGameScreen && game.gameScreen.main != null && game.gameScreen.main.campaign != null && game.gameScreen.main.campaign.getCurrentLevel() != null && game.gameScreen.main.campaign.getCurrentLevel().title == "Shadow of the moon: Eclipsors Attack.")
            {
               this._isNightfallActive = true;
               game.fogOfWar.isNightfallActive = true;
               game.soundManager.playSoundFullVolume("Nightfall");
               this.nightfallFogPosition = team.homeX;
               game.fogOfWar.isForwardPositionLocked = true;
               game.fogOfWar.lockedForwardPosition = this.nightfallFogPosition;
               this._nightfallPhase = 1;
               this.nightfallActiveFrames = 0;
               if(!this._hasShownNightfallMessage)
               {
                  this._hasShownNightfallMessage = true;
                  game.gameScreen.showBossMessage("Nightfall pushes the fog forward, hiding enemies beyond it and making them untargetable.");
               }
            }
         }
         if(this._isNightfallActive)
         {
            if(this._nightfallPhase == 1)
            {
               var advTargetX:Number = game.team.homeX + 1600;
               if(this.nightfallFogPosition < advTargetX)
               {
                  this.nightfallFogPosition = Math.min(this.nightfallFogPosition + NIGHTFALL_ADVANCE_SPEED,advTargetX);
               }
               else
               {
                  this.nightfallFogPosition = Math.max(this.nightfallFogPosition - NIGHTFALL_ADVANCE_SPEED,advTargetX);
               }
               game.fogOfWar.lockedForwardPosition = this.nightfallFogPosition;
               if(this.nightfallFogPosition == advTargetX)
               {
                  this.nightfallFogPosition = advTargetX;
                  this._nightfallPhase = 2;
                  this.nightfallActiveFrames = BOSS_NIGHTFALL_DURATION_FRAMES;
               }
            }
            else if(this._nightfallPhase == 2)
            {
               game.fogOfWar.lockedForwardPosition = game.team.homeX + 1600;
               --this.nightfallActiveFrames;
               if(this.nightfallActiveFrames <= 0)
               {
                  this._nightfallPhase = 3;
               }
            }
            else if(this._nightfallPhase == 3)
            {
               var naturalPos:Number = game.team.getVisionRange();
               if(this.nightfallFogPosition < naturalPos)
               {
                  this.nightfallFogPosition = Math.min(this.nightfallFogPosition + NIGHTFALL_RETREAT_SPEED,naturalPos);
               }
               else
               {
                  this.nightfallFogPosition = Math.max(this.nightfallFogPosition - NIGHTFALL_RETREAT_SPEED,naturalPos);
               }
               game.fogOfWar.lockedForwardPosition = this.nightfallFogPosition;
               if(this.nightfallFogPosition == naturalPos)
               {
                  this._isNightfallActive = false;
                  this._nightfallPhase = 0;
                  game.fogOfWar.isNightfallActive = false;
                  game.fogOfWar.unlockForwardPosition();
               }
            }
         }
         if(this.eclipseMarkCooldownFrames > 0)
         {
            --this.eclipseMarkCooldownFrames;
         }
         if(this.demonBurstCooldownFrames > 0)
         {
            --this.demonBurstCooldownFrames;
         }
         if(this.skyCommanderCooldownFrames > 0)
         {
            --this.skyCommanderCooldownFrames;
         }
         if(this.skyCommanderAuraFrames > 0)
         {
            --this.skyCommanderAuraFrames;
            if(this.skyCommanderAuraFrames == 0)
            {
               this.skyCommanderCooldownFrames = BOSS_AURA_COOLDOWN_FRAMES;
            }
         }
         if(this._pendingAuraFrames > 0)
         {
            --this._pendingAuraFrames;
            if(this._pendingAuraFrames == 0)
            {
               this.skyCommanderAuraFrames = BOSS_AURA_DURATION_FRAMES;
               team.game.soundManager.playSoundFullVolume("Rage1");
            }
         }
         if(this.eclipseMarkHitWindowFrames > 0)
         {
            --this.eclipseMarkHitWindowFrames;
         }
         else
         {
            this.pendingEclipseMarkHits = 0;
            this.pendingEclipseMarkTargetId = -1;
            this.pendingEclipseMarkDamage = 0;
         }
         if(this.demonBurstHitWindowFrames > 0)
         {
            --this.demonBurstHitWindowFrames;
         }
         else
         {
            this.pendingDemonBurstHits = 0;
            this.pendingDemonBurstDamage = 0;
            this.demonBurstStunnedIds = {};
         }
         if(this.projectileResistanceFrames > 0)
         {
            --this.projectileResistanceFrames;
         }
         if(this.bossRetreatFrames > 0)
         {
            --this.bossRetreatFrames;
            this.walk(-team.direction * 2,0,-team.direction);
         }
         if(this.campaignBossEscaping && !this.wingidonSpeedSpell.inEffect())
         {
            this.speedSpell();
         }
         this.updateBossGlow();
      }
      
      private function updateBossGlow() : void
      {
         if(this.skyCommanderAuraFrames > 0)
         {
            this.filters = [new GlowFilter(16737792,0.9,14,14,3,1)];
         }
         else if(this.projectileResistanceFrames > 0)
         {
            this.filters = [new GlowFilter(3342387,0.85,10,10,3,1)];
         }
         else
         {
            this.filters = [];
         }
      }
      
      override public function makeBoss(enableDeathBurst:Boolean = false) : void
      {
         if(this._isBoss)
         {
            return;
         }
         this._isBoss = true;
         this.isBossUnit = true;
         this.bossAbilitySpawnLockFrames = 30 * 2;
         this.hasDefaultLoadout = false;
         maxHealth *= BOSS_HEALTH_MULTIPLIER;
         health = maxHealth;
         this.healthBar.totalHealth = maxHealth;
         this.healthBar.health = health;
         damageToDeal *= BOSS_DAMAGE_MULTIPLIER;
         this._damageToArmour *= BOSS_DAMAGE_MULTIPLIER;
         this._damageToNotArmour *= BOSS_DAMAGE_MULTIPLIER;
         if(team != null && team.tech != null)
         {
            team.tech.isResearchedMap[Tech.WINGIDON_SPEED] = true;
         }
      }
      
      public function tryBossAbilities(game:StickWar) : Boolean
      {
         var target:Unit = null;
         if(!this.isBoss || this.hasBossAbilitySpawnLock() || this.isBusy() || this.isGarrisoned || this.campaignBossEscaping || this.wingidonSpeedSpell.inEffect())
         {
            return false;
         }
         if(this.eclipseMarkCooldownFrames > 0 && this.demonBurstCooldownFrames > 0)
         {
            return false;
         }
         target = this.chooseEclipseMarkTarget(game);
         if(target == null)
         {
            target = this.chooseBossAbilityTarget();
         }
         if(target == null)
         {
            return false;
         }
         if(this.eclipseMarkCooldownFrames == 0 && this.fireBossEclipseMark(game,target))
         {
            this.pendingEclipseMarkHits = 1;
            this.pendingEclipseMarkTargetId = target.id;
            this.pendingEclipseMarkDamage = damageToDeal * 0.8;
            this.eclipseMarkHitWindowFrames = BOSS_SPECIAL_HIT_WINDOW_FRAMES;
            this.eclipseMarkCooldownFrames = BOSS_MARK_COOLDOWN_FRAMES;
            return true;
         }
         if(this.demonBurstCooldownFrames == 0 && this.fireBossDemonBurst(game,target))
         {
            this.pendingDemonBurstHits = 3;
            this.pendingDemonBurstDamage = damageToDeal * 0.75;
            this.demonBurstHitWindowFrames = BOSS_SPECIAL_HIT_WINDOW_FRAMES;
            this.demonBurstStunnedIds = {};
            this.demonBurstCooldownFrames = BOSS_BURST_COOLDOWN_FRAMES;
            return true;
         }
         return false;
      }
      
      private function chooseEclipseMarkTarget(game:StickWar) : Unit
      {
         var enemy:Unit = null;
         var best:Unit = null;
         var score:Number = Number.NaN;
         var bestScore:Number = Number.POSITIVE_INFINITY;
         var sqrDist:Number = Number.NaN;
         if(team == null || team.enemyTeam == null)
         {
            return null;
         }
         for each(enemy in team.enemyTeam.units)
         {
            if(!(enemy == null || !enemy.isAlive() || !enemy.isTargetable() || enemy.isGarrisoned))
            {
               if(!(enemy.team.currentAttackState != Team.G_DEFEND && enemy.ai.currentCommand.type != UnitCommand.MOVE))
               {
                  sqrDist = this.sqrDistanceToTarget(enemy);
                  if(sqrDist <= BOSS_ECLIPSE_MARK_RANGE * BOSS_ECLIPSE_MARK_RANGE)
                  {
                     score = sqrDist;
                     if(enemy.type == Unit.U_ARCHER || enemy.type == Unit.U_MONK || enemy.type == Unit.U_MAGIKILL || enemy.type == Unit.U_ENSLAVED_GIANT)
                     {
                        score *= 0.35;
                     }
                     if(score < bestScore)
                     {
                        bestScore = score;
                        best = enemy;
                     }
                  }
               }
            }
         }
         return best;
      }
      
      private function chooseBossAbilityTarget() : Unit
      {
         var enemy:Unit = null;
         var best:Unit = null;
         var score:Number = Number(NaN);
         var bestScore:Number = Number.POSITIVE_INFINITY;
         if(team == null || team.enemyTeam == null)
         {
            return null;
         }
         for each(enemy in team.enemyTeam.units)
         {
            if(!(enemy == null || !enemy.isAlive() || !enemy.isTargetable() || enemy.isGarrisoned || enemy.pz != 0 && !this.canAttackAir() || !this.inRange(enemy)))
            {
               score = this.sqrDistanceToTarget(enemy);
               if(enemy.type == Unit.U_ARCHER || enemy.type == Unit.U_MONK || enemy.type == Unit.U_MAGIKILL || enemy.type == Unit.U_ENSLAVED_GIANT)
               {
                  score *= 0.35;
               }
               if(score < bestScore)
               {
                  bestScore = score;
                  best = enemy;
               }
            }
         }
         return best;
      }
      
      private function fireBossEclipseMark(game:StickWar, target:Unit) : Boolean
      {
         return this.fireBossBoltAtTarget(game,target,damageToDeal * 0.8,0,4,0);
      }
      
      private function fireBossDemonBurst(game:StickWar, target:Unit) : Boolean
      {
         var fired:int = 0;
         if(this.fireBossBoltAtTarget(game,target,damageToDeal * 0.75,0,5,-4))
         {
            fired++;
         }
         if(this.fireBossBoltAtTarget(game,target,damageToDeal * 0.75,0,5,0))
         {
            fired++;
         }
         if(this.fireBossBoltAtTarget(game,target,damageToDeal * 0.75,0,5,4))
         {
            fired++;
         }
         return fired > 0;
      }
      
      private function fireBossBoltAtTarget(game:StickWar, target:Unit, damage:Number, slowFrames:int, boltStyle:int, dyOffset:Number = 0) : Boolean
      {
         var arms:MovieClip = null;
         var p:Point = null;
         var angle:Number = Number(NaN);
         var rotation:Number = Number(NaN);
         if(target == null || !target.isAlive())
         {
            return false;
         }
         arms = _mc.mc.body.arms;
         if(arms == null)
         {
            return false;
         }
         angle = angleToTarget(target);
         if(angle == -1.35)
         {
            return false;
         }
         rotation = angleToBowSpace(angle);
         this.faceDirection(target.px - px);
         this.bowAngle = rotation;
         arms.rotation = rotation;
         if(arms.currentFrame == 1)
         {
            arms.nextFrame();
         }
         p = arms.localToGlobal(new Point(0,0));
         p = game.battlefield.globalToLocal(p);
         game.soundManager.playSoundRandom("launchArrow",4,px,py);
         if(mc.scaleX < 0)
         {
            game.projectileManager.initBolt(p.x,p.y,180 - rotation,projectileVelocity,target.py,angleToTargetW(target,projectileVelocity,angle) + dyOffset,this,damage,slowFrames,false,boltStyle);
         }
         else
         {
            game.projectileManager.initBolt(p.x,p.y,rotation,projectileVelocity,target.py,angleToTargetW(target,projectileVelocity,angle) + dyOffset,this,damage,slowFrames,false,boltStyle);
         }
         return true;
      }
      
      public function modifyBossProjectileDamage(target:Unit, type:int, damage:Number) : Number
      {
         if(target == null)
         {
            return damage;
         }
         if(this.pendingEclipseMarkHits > 0 && this.eclipseMarkHitWindowFrames > 0)
         {
            return damage;
         }
         return damage;
      }
      
      public function onBossProjectileDamagedTarget(target:Unit, type:int, amount:int) : void
      {
         if(target == null || !target.isAlive())
         {
            return;
         }
         if(this.pendingEclipseMarkHits > 0 && this.eclipseMarkHitWindowFrames > 0 && target.id == this.pendingEclipseMarkTargetId && Math.abs(amount - this.pendingEclipseMarkDamage) < 0.01)
         {
            --this.pendingEclipseMarkHits;
            this.pendingEclipseMarkTargetId = -1;
            this.pendingEclipseMarkDamage = 0;
            target.applyExtremeSlow(BOSS_EXTREME_SLOW_FRAMES);
            this.eclipseMarkedUnitId = target.id;
            this.eclipseMarkUntilFrame = team.game.frame + BOSS_MARK_DURATION_FRAMES;
            return;
         }
         if(this.isBoss && this.pendingDemonBurstHits > 0 && this.demonBurstHitWindowFrames > 0 && Math.abs(amount - this.pendingDemonBurstDamage) < 0.01)
         {
            --this.pendingDemonBurstHits;
            if(this.demonBurstStunnedIds == null)
            {
               this.demonBurstStunnedIds = {};
            }
            if(!(target.id in this.demonBurstStunnedIds))
            {
               this.demonBurstStunnedIds[target.id] = true;
               target.applyDefenseDebuff(BOSS_DEFENSE_DEBUFF_FRAMES);
            }
         }
      }
      
      public function getMarkedPreyTarget(game:StickWar) : Unit
      {
         var boss:Wingidon = null;
         var target:Unit = null;
         if(this.isBoss)
         {
            return null;
         }
         if(team == null || team.currentAttackState != Team.G_ATTACK)
         {
            return null;
         }
         boss = this.getNearbySkyCommanderBoss(true);
         if(boss == null || boss.eclipseMarkedUnitId < 0 || game.frame > boss.eclipseMarkUntilFrame || boss.team.currentAttackState != Team.G_ATTACK)
         {
            return null;
         }
         if(!(boss.eclipseMarkedUnitId in game.units) || !(game.units[boss.eclipseMarkedUnitId] is Unit))
         {
            return null;
         }
         target = game.units[boss.eclipseMarkedUnitId];
         if(target == null || !target.isAlive() || !target.isTargetable() || target.isGarrisoned || this.sqrDistanceToTarget(target) > BOSS_MARK_FOCUS_RADIUS * BOSS_MARK_FOCUS_RADIUS)
         {
            return null;
         }
         return target;
      }
      
      private function countNearbyWingidons() : int
      {
         var unit:Unit = null;
         var count:int = 0;
         if(team == null || team.unitGroups == null || !Boolean(team.unitGroups[Unit.U_WINGIDON]))
         {
            return 0;
         }
         for each(unit in team.unitGroups[Unit.U_WINGIDON])
         {
            if(unit != null && unit != this && unit is Wingidon && unit.isAlive() && !unit.isGarrisoned && this.sqrDistanceToTarget(unit) <= BOSS_AURA_RADIUS * BOSS_AURA_RADIUS)
            {
               count++;
            }
         }
         return count;
      }
      
      public function hasNearbySkyCommanderAura() : Boolean
      {
         var boss:Wingidon = this.getNearbySkyCommanderBoss(false);
         if(boss == null)
         {
            return false;
         }
         if(team == null || team.game == null || team.game.main == null || team.game.main.campaign == null)
         {
            return true;
         }
         var diff:int = team.game.main.campaign.difficultyLevel;
         if(diff == Campaign.D_INSANE)
         {
            return true;
         }
         if(diff == Campaign.D_NORMAL)
         {
            return false;
         }
         if(this.isBoss)
         {
            return true;
         }
         var unit:Unit = null;
         var closerCount:int = 0;
         var thisSqrDist:Number = this.sqrDistanceToTarget(boss);
         for each(unit in team.unitGroups[Unit.U_WINGIDON])
         {
            if(unit != null && unit != this && unit is Wingidon && unit.isAlive() && !unit.isGarrisoned && !unit.isBoss)
            {
               if(unit.sqrDistanceToTarget(boss) < thisSqrDist)
               {
                  if(++closerCount >= 3)
                  {
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      private function getNearbySkyCommanderBoss(requireMark:Boolean) : Wingidon
      {
         var unit:Unit = null;
         var boss:Wingidon = null;
         if(team == null || team.unitGroups == null || !Boolean(team.unitGroups[Unit.U_WINGIDON]))
         {
            return null;
         }
         for each(unit in team.unitGroups[Unit.U_WINGIDON])
         {
            if(unit is Wingidon)
            {
               boss = unit;
               if(boss.isBoss && boss.isAlive() && !boss.isGarrisoned)
               {
                  if(!requireMark && boss.skyCommanderAuraFrames > 0)
                  {
                     return boss;
                  }
                  if(requireMark && boss.eclipseMarkedUnitId >= 0)
                  {
                     return boss;
                  }
               }
            }
         }
         return null;
      }
      
      override public function mayAttack(target:Unit) : Boolean
      {
         if(isIncapacitated())
         {
            return false;
         }
         if(this.wingidonSpeedSpell.inEffect())
         {
            return false;
         }
         return super.mayAttack(target);
      }
      
      override public function damage(type:int, amount:int, inflictor:Entity, modifier:Number = 1) : void
      {
         if(Boolean(type & Unit.D_ARROW))
         {
            if(this.skyCommanderAuraFrames > 0 || !this.isBoss && this.hasNearbySkyCommanderAura())
            {
               team.game.soundManager.playSound("ironHit" + (1 + team.game.random.nextInt() % 4),this.px,this.py);
               var impactPX:Number = this.lastArrowHitX;
               var impactPY:Number = this.lastArrowHitY;
               var impactPZ:Number = this.lastArrowHitZ;
               if(isNaN(impactPX))
               {
                  impactPX = this.px;
                  impactPY = this.py;
                  impactPZ = this.pz;
                  if(inflictor != null)
                  {
                     impactPX = this.px - Util.sgn(inflictor.px - this.px) * 20;
                  }
               }
               this.lastArrowHitX = Number.NaN;
               team.game.projectileManager.initDeflectedArrow(impactPX,impactPY,impactPZ,team.game);
               return;
            }
            if(this.projectileResistanceFrames > 0)
            {
               modifier *= 1 - BOSS_PROJECTILE_RESISTANCE;
            }
         }
         super.damage(type,amount,inflictor,modifier);
         if(this.isBoss && this._pendingAuraFrames == 0 && this.skyCommanderAuraFrames == 0 && this.skyCommanderCooldownFrames == 0)
         {
            this._pendingAuraFrames = 60;
         }
         else if(!this.isBoss && this.hasNearbySkyCommanderAura())
         {
            for each(var unit in team.unitGroups[Unit.U_WINGIDON])
            {
               if(unit is Wingidon)
               {
                  var w:Wingidon = unit;
                  if(w.isBoss && w.isAlive() && !w.isGarrisoned && w._pendingAuraFrames == 0 && w.skyCommanderAuraFrames == 0 && w.skyCommanderCooldownFrames == 0)
                  {
                     w._pendingAuraFrames = 60;
                     break;
                  }
               }
            }
         }
         if(this.isBoss && Boolean(type & Unit.D_ARROW) && !this._hasUsedArrowRetreat && this.health <= this.maxHealth * 0.5 && !this.campaignBossEscaping)
         {
            this._hasUsedArrowRetreat = true;
            this.projectileResistanceFrames = BOSS_PROJECTILE_RESISTANCE_FRAMES;
            this.bossRetreatFrames = BOSS_RETREAT_FRAMES;
            team.game.soundManager.playSoundFullVolume("Rage2");
         }
      }
      
      override public function shoot(game:StickWar, target:Unit) : void
      {
         var arms:MovieClip = null;
         var p:Point = null;
         if(_state != S_ATTACK)
         {
            arms = _mc.mc.body.arms;
            if(arms.currentFrame != 1)
            {
               return;
            }
            game.soundManager.playSoundRandom("launchArrow",4,px,py);
            arms.nextFrame();
            p = arms.localToGlobal(new Point(0,0));
            p = game.battlefield.globalToLocal(p);
            if(mc.scaleX < 0)
            {
               game.projectileManager.initBolt(p.x,p.y,180 - arms.rotation,projectileVelocity,target.py,angleToTargetW(target,projectileVelocity,angleToTarget(target)),this,20,30 * 4,false);
            }
            else
            {
               game.projectileManager.initBolt(p.x,p.y,arms.rotation,projectileVelocity,target.py,angleToTargetW(target,projectileVelocity,angleToTarget(target)),this,20,30 * 4,false);
            }
         }
      }
      
      override public function walk(x:Number, y:Number, intendedX:int) : void
      {
         if(isAbleToWalk() && !this.wingidonSpeedSpell.inEffect())
         {
            baseWalk(x,y,intendedX);
         }
      }
      
      public function get isBoss() : Boolean
      {
         return this._isBoss;
      }
   }
}

