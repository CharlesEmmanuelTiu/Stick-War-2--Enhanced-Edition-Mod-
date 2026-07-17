package com.brockw.stickwar.engine.projectile
{
   import com.brockw.stickwar.engine.*;
   import flash.display.*;
   
   public class ElectricWall extends Projectile
   {
      
      internal var spellMc:MovieClip;
      
      public var controlledFriendlyFire:Boolean;
      
      public var wallArea:Number;
      
      public var damageToDeal:int;
      
      public var isStunZone:Boolean;
      
      public var frequency:int;
      
      private var childClips:Array;
      
      public function ElectricWall(game:StickWar)
      {
         var mc:DisplayObject = null;
         super();
         type = ELECTRIC_WALL;
         this.spellMc = new electricWallMc();
         this.addChild(this.spellMc);
         this.controlledFriendlyFire = false;
         this.isStunZone = false;
         this.childClips = [];
         var i:* = 0;
         while(i < this.spellMc.numChildren)
         {
            mc = this.spellMc.getChildAt(i);
            if(mc is MovieClip)
            {
               mc.gotoAndStop(Math.floor(game.random.nextNumber() * mc.totalFrames));
               this.childClips.push(mc);
            }
            i++;
         }
         this.wallArea = game.xml.xml.Order.Units.magikill.electricWall.area;
         this.frequency = int(game.xml.xml.Order.Units.magikill.electricWall.frequency);
      }
      
      override public function cleanUp() : void
      {
         super.cleanUp();
         removeChild(this.spellMc);
         this.spellMc = null;
         this.childClips = null;
      }
      
      public function resetForUse() : void
      {
         this.visible = true;
         this.controlledFriendlyFire = false;
         this.isStunZone = false;
      }
      
      override public function update(game:StickWar) : void
      {
         var mc:MovieClip = null;
         this.visible = true;
         this.spellMc.nextFrame();
         var i:* = 0;
         while(i < this.childClips.length)
         {
            mc = this.childClips[i];
            mc.nextFrame();
            if(mc.currentFrame == mc.totalFrames)
            {
               mc.gotoAndStop(1);
            }
            i++;
         }
         if(this.isReadyForCleanup())
         {
            this.visible = false;
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

