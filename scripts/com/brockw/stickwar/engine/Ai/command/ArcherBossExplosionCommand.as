package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   import flash.display.BlendMode;

   public class ArcherBossExplosionCommand extends UnitCommand
   {
      private static function createButtonBitmap() : Bitmap
      {
         var bmd:BitmapData = new ArchidonFire();
         var ct:ColorTransform = new ColorTransform();
         ct.color = 0xFF0000;
         bmd.draw(bmd, null, ct, BlendMode.MULTIPLY);
         return new Bitmap(bmd);
      }

      public static const actualButtonBitmap:Bitmap = createButtonBitmap();

      public function ArcherBossExplosionCommand(game:StickWar)
      {
         super();
         type = UnitCommand.ARCHER_BOSS_EXPLOSION;
         _hasCoolDown = true;
         _intendedEntityType = Unit.U_ARCHER;
         buttonBitmap = actualButtonBitmap;
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.archer.explosion);
         }
      }

      override public function coolDownTime(entity:Entity) : Number
      {
         return Archer(entity).getBossAbilityCooldownFraction(UnitCommand.ARCHER_BOSS_EXPLOSION);
      }

      override public function isFinished(unit:Unit) : Boolean
      {
         return false;
      }
   }
}
