package com.brockw.stickwar.engine.projectile
{
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   
   public class DeflectedArrow extends Entity
   {
      
      public var vx:Number;
      
      public var vy:Number;
      
      public var groundFrames:int;
      
      private var arrow:arrowMc;
      
      public function DeflectedArrow()
      {
         super();
         this.vx = -4;
         this.vy = -10;
         this.groundFrames = 0;
         this.arrow = new arrowMc();
         this.arrow.gotoAndStop(1);
         addChild(this.arrow);
      }
      
      public function update(game:StickWar) : void
      {
         this.rotation += 25;
         this.vy += 0.5;
         this.pz += this.vy;
         this.px += this.vx;
         this.x = this.px;
         this.y = this.pz + this.py;
         var ps:Number = game.backScale + this.py / game.map.height * (game.frontScale - game.backScale);
         this.scaleX = ps;
         this.scaleY = ps;
         if(this.pz >= 0)
         {
            this.pz = 0;
            this.vx = 0;
            this.vy = 0;
            this.rotation = 0;
            this.arrow.gotoAndStop(3);
            ++this.groundFrames;
         }
      }
   }
}

