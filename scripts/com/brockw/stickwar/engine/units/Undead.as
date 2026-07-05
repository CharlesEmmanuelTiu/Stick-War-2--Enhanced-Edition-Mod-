package com.brockw.stickwar.engine.units
{
   import com.brockw.game.Util;
   import com.brockw.stickwar.engine.ActionInterface;
   import com.brockw.stickwar.engine.Ai.UndeadAi;
   import com.brockw.stickwar.engine.Ai.command.*;
   import com.brockw.stickwar.engine.StickWar;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   
   public class Undead extends Unit
   {
      
      private static var WEAPON_REACH:Number;
      
      private var lastAttackFrame:int;
      
      private var attackCooldownFrames:int;
      
      private var undeadPoisonDamage:Number;
      
      private var poisonChance:Number;
      
      private var _lastAnimLabel:String;
      
      private var _turnedHeadSkin:String;
      
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
         maxHealth = health = game.xml.xml.Order.Units.archer.health;
         loadDamage(game.xml.xml.Chaos.Units.dead);
         type = Unit.U_UNDEAD;
         this.attackCooldownFrames = 25;
         this.undeadPoisonDamage = 5;
         this.poisonChance = 0.5;
         this._lastAnimLabel = "";
         this._turnedHeadSkin = "";
         _mc.stop();
         _mc.width *= _scale;
         _mc.height *= _scale;
         _state = S_RUN;
         _mc.mc.gotoAndPlay(1);
         _mc.gotoAndStop(1);
         drawShadow();
         var ct:ColorTransform = new ColorTransform(0.7,1,0.5,1,30,0,0,0);
         _mc.transform.colorTransform = ct;
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
               if(!hasHit)
               {
                  hasHit = this.checkForHit();
               }
               if(_mc.mc.totalFrames == _mc.mc.currentFrame)
               {
                  _state = S_RUN;
               }
            }
            updateMotion(game);
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
         if(this._lastAnimLabel != _mc.currentLabel)
         {
            this._lastAnimLabel = _mc.currentLabel;
            if(this._turnedHeadSkin != "")
            {
               Dead.setItem(_mc,"",this._turnedHeadSkin,"");
            }
         }
         if(game.frame % 30 == 0 && this.team != null && this.team.enemyTeam != null && Boolean(this.team.enemyTeam.deadUnits))
         {
            var deadUnits:Array = this.team.enemyTeam.deadUnits;
            var i:int = deadUnits.length - 1;
            while(i >= 0)
            {
               var corpse:Unit = deadUnits[i];
               if(corpse.isInfected && corpse.timeOfDeath >= 300)
               {
                  var undead:Undead = game.unitFactory.getUnit(Unit.U_UNDEAD);
                  if(undead != null)
                  {
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
                        case Unit.U_NINJA:
                           headSkin = "Undead Ninja";
                           break;
                        case Unit.U_MAGIKILL:
                           headSkin = "Undead Magikill";
                     }
                     undead._turnedHeadSkin = headSkin;
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
            target.isInfected = true;
            if(team.game.random.nextNumber() < this.poisonChance)
            {
               target.poison(this.undeadPoisonDamage);
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

