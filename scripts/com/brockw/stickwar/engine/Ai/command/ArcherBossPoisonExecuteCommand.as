package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   import flash.display.BlendMode;

   public class ArcherBossPoisonExecuteCommand extends UnitCommand
   {
      private static function createButtonBitmap() : Bitmap
      {
         var bmd:BitmapData = new ArchidonFire();
         var ct:ColorTransform = new ColorTransform();
         ct.color = 0x00FF00;
         bmd.draw(bmd, null, ct, BlendMode.MULTIPLY);
         return new Bitmap(bmd);
      }

      public static const actualButtonBitmap:Bitmap = createButtonBitmap();

      public function ArcherBossPoisonExecuteCommand(game:StickWar)
      {
         super();
         type = UnitCommand.ARCHER_BOSS_POISON_EXECUTE;
         _hasCoolDown = true;
         _intendedEntityType = Unit.U_ARCHER;
         buttonBitmap = actualButtonBitmap;
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.archer.poisonExecute);
         }
      }

      override public function coolDownTime(entity:Entity) : Number
      {
         return Archer(entity).getBossAbilityCooldownFraction(UnitCommand.ARCHER_BOSS_POISON_EXECUTE);
      }

      override public function isFinished(unit:Unit) : Boolean
      {
         return false;
      }
   }
}
