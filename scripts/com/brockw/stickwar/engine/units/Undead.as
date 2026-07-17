package com.brockw.stickwar.engine.units
{
   import com.brockw.game.Util;
   import com.brockw.stickwar.engine.ActionInterface;
   import com.brockw.stickwar.engine.Ai.UndeadAi;
   import com.brockw.stickwar.engine.Ai.command.*;
   import com.brockw.stickwar.engine.StickWar;
   import flash.filters.DropShadowFilter;
   import flash.geom.ColorTransform;
   
   public class Undead extends Unit
   {
      
      private static var WEAPON_REACH:Number;
      
      private var lastAttackFrame:int;
      
      private var attackCooldownFrames:int;
      
      private var infectionDamage:Number;
      
      private var _lastAnimLabel:String;
      
      private var _turnedHeadSkin:String;
      
      private var _glitchStealthFilter:DropShadowFilter;
      
      private var _glitchTimer:int;
      
      public var _firstHitBonus:Number;
      
      private var _infectionSprayCooldown:int;
      
      private var _hitFrame:int;
      
      public function Undead(game:StickWar)
      {
         super(game);
         _mc = new _dead();
         this.init(game);
         addChild(_mc);
         ai = new UndeadAi(this);
         initSync();
         firstInit();
         this.lastAttackFrame = -999;
      }
      
      override public function weaponReach() : Number
      {
         return WEAPON_REACH;
      }
      
      override public function init(game:StickWar) : void
      {
         initBase();
         WEAPON_REACH = 45;
         population = 0;
         _mass = game.xml.xml.Chaos.Units.dead.mass;
         _maxForce = game.xml.xml.Chaos.Units.dead.maxForce;
         _dragForce = game.xml.xml.Chaos.Units.dead.dragForce;
         _scale = game.xml.xml.Chaos.Units.dead.scale;
         _maxVelocity = game.xml.xml.Chaos.Units.dead.maxVelocity;
         loadDamage(game.xml.xml.Chaos.Units.dead);
         maxHealth = health = game.xml.xml.Order.Units.archer.health;
         healthBar.totalHealth = maxHealth;
         healthBar.health = health;
         type = Unit.U_UNDEAD;
         this.attackCooldownFrames = 25;
         this.infectionDamage = 10;
         this._lastAnimLabel = "";
         this._turnedHeadSkin = "";
         if(Boolean(_mc.mc.back))
         {
            _mc.mc.back.gotoAndStop("Default");
         }
         this.mc.filters = [];
         _mc.stop();
         _mc.scaleX = _scale;
         _mc.scaleY = _scale;
         _state = S_RUN;
         _mc.mc.gotoAndStop(1);
         _mc.gotoAndStop(1);
         drawShadow();
         var ct:ColorTransform = new ColorTransform(0.7,1,0.5,1,30,0,0,0);
         _mc.transform.colorTransform = ct;
         this._glitchStealthFilter = new DropShadowFilter();
         this._glitchStealthFilter.knockout = true;
         this._glitchStealthFilter.angle = 0;
         this._glitchStealthFilter.distance = 0;
         this._glitchStealthFilter.color = 0;
         this._glitchTimer = game.frame;
         this._firstHitBonus = 0;
         this._infectionSprayCooldown = 0;
         this._hitFrame = 0;
      }
      
      public function get turnedHeadSkin() : String
      {
         return this._turnedHeadSkin;
      }
      
      public function set turnedHeadSkin(value:String) : void
      {
         this._turnedHeadSkin = value;
      }
      
      override public function update(game:StickWar) : void
      {
         updateCommon(game);
         if(!isDieing)
         {
            if(_state == S_RUN)
            {
               if(isFeetMoving())
               {
                  if(_mc.currentFrameLabel != "run")
                  {
                     _mc.gotoAndStop("run");
                  }
               }
               else
               {
                  var currentLabel:String = _mc.currentFrameLabel;
                  if(!(currentLabel == "stand" || currentLabel == "stand_breath"))
                  {
                     _mc.gotoAndStop("stand");
                  }
               }
            }
            else if(_state == S_ATTACK)
            {
               if(!hasHit && _mc.mc.currentFrame >= this._hitFrame)
               {
                  hasHit = this.checkForHit();
               }
               if(_mc.mc.totalFrames == _mc.mc.currentFrame)
               {
                  _state = S_RUN;
               }
            }
            updateMotion(game);
            if(this._infectionSprayCooldown > 0)
            {
               --this._infectionSprayCooldown;
            }
            if(this._turnedHeadSkin == "Undead Ninja" && game.frame - this._glitchTimer > 0)
            {
               this._glitchTimer = game.frame + 5 + int(Math.random() * 20);
               if(this.mc.filters.length == 0)
               {
                  this.mc.filters = [this._glitchStealthFilter];
               }
               else
               {
                  this.mc.filters = [];
               }
            }
         }
         else if(isDead == false)
         {
            _mc.gotoAndStop(this.getDeathLabel(game));
            this.team.removeUnit(this,game);
            isDead = true;
         }
         if(isDead || _isDualing)
         {
            Util.animateMovieClip(_mc,0);
         }
         else
         {
            if(_mc.mc.currentFrame == _mc.mc.totalFrames)
            {
               _mc.mc.gotoAndStop(1);
            }
            _mc.mc.nextFrame();
         }
         if(Boolean(_mc.mc.head) && this._turnedHeadSkin != "" && this._turnedHeadSkin != "Undead Archer")
         {
            _mc.mc.head.gotoAndStop(this._turnedHeadSkin);
         }
         if(this._lastAnimLabel != _mc.currentLabel)
         {
            this._lastAnimLabel = _mc.currentLabel;
            if(this._turnedHeadSkin != "" && this._turnedHeadSkin != "Undead Archer")
            {
               Dead.setItem(_mc,"",this._turnedHeadSkin,"");
            }
            if(Boolean(_mc.mc.back))
            {
               if(this._turnedHeadSkin == "Undead Archer")
               {
                  _mc.mc.back.gotoAndStop("Archer");
               }
               else if(this._turnedHeadSkin == "Undead Ninja")
               {
                  _mc.mc.back.gotoAndStop("Ninja");
               }
               else
               {
                  _mc.mc.back.gotoAndStop("Default");
               }
            }
         }
         if(game.frame % 30 == 0 && this.team != null && this.team.enemyTeam != null && Boolean(this.team.enemyTeam.deadUnits))
         {
            var deadUnits:Array = this.team.enemyTeam.deadUnits;
            var i:int = deadUnits.length - 1;
            while(i >= 0)
            {
               var corpse:Unit = deadUnits[i];
               if(corpse.isInfected && corpse.timeOfDeath >= 30 + Math.abs(corpse.id * 37 + 17) % 61)
               {
                  if(corpse.type == Unit.U_WALL || corpse.type == Unit.U_STATUE || corpse.type == Unit.U_CHAOS_TOWER)
                  {
                     this.team.enemyTeam.removeDeadUnit(corpse,game);
                     i--;
                     continue;
                  }
                  var undead:Undead = game.unitFactory.getUnit(Unit.U_UNDEAD);
                  if(undead != null)
                  {
                     undead.init(game);
                     this.team.spawn(undead,game);
                     undead.px = corpse.px;
                     undead.x = undead.px;
                     undead.py = corpse.py;
                     undead.y = undead.py;
                     var headSkin:String = "";
                     switch(corpse.type)
                     {
                        case Unit.U_SPEARTON:
                           headSkin = "Undead Spearton";
                           break;
                        case Unit.U_ARCHER:
                           headSkin = "Undead Archer";
                           break;
                        case Unit.U_NINJA:
                           headSkin = "Undead Ninja";
                           break;
                        case Unit.U_MAGIKILL:
                           headSkin = "Undead Magikill";
                     }
                     undead._turnedHeadSkin = headSkin;
                     undead._maxVelocity = game.xml.xml.Chaos.Units.dead.maxVelocity;
                     undead._maxForce = game.xml.xml.Chaos.Units.dead.maxForce;
                     if(headSkin == "Undead Spearton")
                     {
                        undead.maxHealth = undead.health = game.xml.xml.Chaos.Units.dead.health;
                     }
                     else if(headSkin == "Undead Ninja")
                     {
                        undead.maxHealth = undead.health = game.xml.xml.Order.Units.swordwrath.health;
                        undead._maxVelocity *= 1.2;
                        undead._maxForce *= 1.2;
                     }
                     else if(headSkin == "Undead Magikill")
                     {
                        undead.maxHealth = undead.health = game.xml.xml.Order.Units.swordwrath.health;
                     }
                     undead.healthBar.totalHealth = undead.maxHealth;
                     undead.healthBar.health = undead.health;
                     game.projectileManager.initTowerSpawn(undead.px,undead.py,this.team,0.6,6750054);
                     game.projectileManager.initSpawnDrip(undead.px,undead.py,this.team,6750054);
                     var cmd:AttackMoveCommand = new AttackMoveCommand(game);
                     cmd.goalX = this.team.enemyTeam.statue.px;
                     cmd.goalY = corpse.py;
                     undead.ai.setCommand(game,cmd);
                     this.team.enemyTeam.removeDeadUnit(corpse,game);
                  }
               }
               i--;
            }
         }
      }
      
      override public function mayAttack(target:Unit) : Boolean
      {
         if(team.game.frame - lastAttackFrame < attackCooldownFrames)
         {
            return false;
         }
         if(isIncapacitated())
         {
            return false;
         }
         if(target == null || !target.isAlive())
         {
            return false;
         }
         if(_state != S_RUN)
         {
            return false;
         }
         if(Math.abs(px - target.px) < WEAPON_REACH && Math.abs(py - target.py) < 50 && this.getDirection() == Util.sgn(target.px - px))
         {
            return true;
         }
         return false;
      }
      
      override public function attack() : void
      {
         if(_state != S_ATTACK)
         {
            var id:int = team.game.random.nextInt() % 2;
            _mc.gotoAndStop("melee_" + (id + 1));
            _mc.mc.gotoAndStop(1);
            this._hitFrame = Math.max(1,int(_mc.mc.totalFrames * 0.55));
            _state = S_ATTACK;
            hasHit = false;
            lastAttackFrame = team.game.frame;
         }
      }
      
      override protected function checkForHit() : Boolean
      {
         var target:Unit = this.ai.getClosestTarget();
         if(target == null)
         {
            return false;
         }
         var dx:Number = px - target.px;
         var dy:Number = py - target.py;
         if(dx * dx + dy * dy < WEAPON_REACH * WEAPON_REACH * 3)
         {
            target.damage(0,this.damageToDeal,this);
            if(this._firstHitBonus > 0)
            {
               target.damage(0,this._firstHitBonus,this);
               this._firstHitBonus = 0;
            }
            if(target.type != Unit.U_WALL && target.type != Unit.U_STATUE && target.type != Unit.U_CHAOS_TOWER)
            {
               target.isInfected = true;
               target.infectionDamage = this.infectionDamage;
               target.infectionFramesLeft = 240;
            }
            if(this._turnedHeadSkin == "Undead Magikill" && this._infectionSprayCooldown <= 0 && team != null && team.game != null && team.game.random.nextNumber() < 0.9)
            {
               this._infectionSprayCooldown = 180;
               if(Boolean(team.game.projectileManager))
               {
                  team.game.projectileManager.initInfectionSpray(target.px,target.py,this);
               }
            }
            return true;
         }
         return false;
      }
      
      override protected function getDeathLabel(game:StickWar) : String
      {
         if(this._deathLabels.length > 0)
         {
            var id:int = this.team.game.random.nextInt() % this._deathLabels.length;
            return "death_" + this._deathLabels[id];
         }
         return "death_1";
      }
      
      override public function setBuilding() : void
      {
         building = null;
      }
      
      override public function setActionInterface(a:ActionInterface) : void
      {
         super.setActionInterface(a);
         this.setActionInterfaceBase(a);
      }
   }
}

