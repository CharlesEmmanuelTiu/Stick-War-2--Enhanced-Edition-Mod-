package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   
   public class NinjaShadowCloneCommand extends UnitCommand
   {
      
      public static const actualButtonBitmap:Bitmap = createButtonBitmap();
      
      public function NinjaShadowCloneCommand(game:StickWar)
      {
         super();
         type = UnitCommand.NINJA_SHADOW_CLONE;
         _hasCoolDown = true;
         _intendedEntityType = Unit.U_NINJA;
         buttonBitmap = actualButtonBitmap;
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.ninja.shadowClone);
         }
      }
      
      private static function createButtonBitmap() : Bitmap
      {
         var bmd:BitmapData = new NinjaStack();
         var ct:ColorTransform = new ColorTransform();
         ct.color = 4474111;
         bmd.draw(bmd,null,ct,BlendMode.MULTIPLY);
         return new Bitmap(bmd);
      }
      
      override public function coolDownTime(entity:Entity) : Number
      {
         return entity.shadowCloneCooldownFraction();
      }
      
      override public function isFinished(unit:Unit) : Boolean
      {
         return false;
      }
   }
}

