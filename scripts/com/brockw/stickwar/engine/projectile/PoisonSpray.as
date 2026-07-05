package com.brockw.stickwar.engine.projectile
{
   import com.brockw.stickwar.engine.*;
   import com.brockw.stickwar.engine.units.Unit;
   import flash.display.*;
   
   public class PoisonSpray extends Projectile
   {
      
      internal var spellMc:MovieClip;
      
      public var startX:Number;
      
      public var startY:Number;
      
      public var endX:Number;
      
      public var endY:Number;
      
      public var controlledFriendlyFire:Boolean;
      
      public function PoisonSpray(game:StickWar)
      {
         super();
         type = POISON_SPRAY;
         this.spellMc = new poisonMagikilleffect();
         this.addChild(this.spellMc);
         this.controlledFriendlyFire = false;
      }
      
      override public function cleanUp() : void
      {
         super.cleanUp();
         removeChild(this.spellMc);
         this.spellMc = null;
      }
      
      override public function update(game:StickWar) : void
      {
         this.visible = true;
         this.spellMc.nextFrame();
         this.scaleX = 1 * (game.backScale + py / game.map.height * (game.frontScale - game.backScale));
         this.scaleY = 1 * (game.backScale + py / game.map.height * (game.frontScale - game.backScale));
         var units:Array = this.controlledFriendlyFire ? team.units : team.enemyTeam.units;
         var n:int = int(units.length);
         var r:Number = this.spellMc.currentFrame / 20;
         if(r > 1)
         {
            return;
         }
         var rx:Number = r * (this.endX - this.startX) + this.startX;
         var ry:Number = r * (this.endY - this.startY) + this.startY;
         var i:int = 0;
         while(i < n)
         {
            if(units[i] is Unit && (!this.controlledFriendlyFire && units[i].team != this.team || this.controlledFriendlyFire && units[i].team == this.team && units[i] != this.inflictor && !units[i].isBossUnit && units[i].type != Unit.U_STATUE))
            {
               if(Math.pow(units[i].px - rx,2) + Math.pow(units[i].py - ry,2) < Math.pow(game.xml.xml.Order.Units.magikill.poisonSpray.area,2))
               {
                  units[i].poison(this.poisonDamage);
               }
            }
            i++;
         }
      }
      
      override public function isReadyForCleanup() : Boolean
      {
         return this.spellMc.currentFrame == this.spellMc.totalFrames;
      }
      
      override public function isInFlight() : Boolean
      {
         return this.spellMc.currentFrame != this.spellMc.totalFrames;
      }
   }
}

