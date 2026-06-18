package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   import flash.display.BlendMode;

   public class NinjaShadowCloneCommand extends UnitCommand
   {
      private static function createButtonBitmap() : Bitmap
      {
          var bmd:BitmapData = new NinjaStack();
         var ct:ColorTransform = new ColorTransform();
         ct.color = 0x4444FF;
         bmd.draw(bmd, null, ct, BlendMode.MULTIPLY);
         return new Bitmap(bmd);
      }

      public static const actualButtonBitmap:Bitmap = createButtonBitmap();

      public function NinjaShadowCloneCommand(game:StickWar)
      {
         super();
         type = UnitCommand.NINJA_SHADOW_CLONE;
         hotKey = 81;
         _hasCoolDown = true;
         _intendedEntityType = Unit.U_NINJA;
         buttonBitmap = actualButtonBitmap;
      }

      override public function coolDownTime(entity:Entity) : Number
      {
         return Ninja(entity).shadowCloneCooldownFraction();
      }

      override public function isFinished(unit:Unit) : Boolean
      {
         return false;
      }
   }
}
