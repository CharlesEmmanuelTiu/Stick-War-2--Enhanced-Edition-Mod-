package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   import flash.display.BlendMode;

   public class NinjaCloak3Command extends UnitCommand
   {
      private static function createButtonBitmap() : Bitmap
      {
         var bmd:BitmapData = new NinjaCloak();
         var ct:ColorTransform = new ColorTransform();
         ct.color = 0xAA00FF;
         bmd.draw(bmd, null, ct, BlendMode.MULTIPLY);
         return new Bitmap(bmd);
      }

      public static const actualButtonBitmap:Bitmap = createButtonBitmap();

      public function NinjaCloak3Command(game:StickWar)
      {
         super();
         type = UnitCommand.NINJA_CLOAK3;
         hotKey = 81;
         _hasCoolDown = true;
         _intendedEntityType = Unit.U_NINJA;
         buttonBitmap = actualButtonBitmap;
      }

      override public function coolDownTime(entity:Entity) : Number
      {
         return Ninja(entity).getBossCloakCooldownFraction();
      }

      override public function isFinished(unit:Unit) : Boolean
      {
         return false;
      }
   }
}