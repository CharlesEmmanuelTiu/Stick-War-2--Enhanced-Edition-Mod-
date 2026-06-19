package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   import flash.display.BlendMode;

   public class MonkBossAutoReviveToggleCommand extends UnitCommand
   {
      private static function createButtonBitmap() : Bitmap
      {
         var bmd:BitmapData = new HealBitmap();
         var ct:ColorTransform = new ColorTransform();
         ct.color = 0x00BFFF;
         bmd.draw(bmd, null, ct, BlendMode.MULTIPLY);
         return new Bitmap(bmd);
      }

      public static const actualButtonBitmap:Bitmap = createButtonBitmap();

      public function MonkBossAutoReviveToggleCommand(game:StickWar)
      {
         super();
         type = UnitCommand.MONK_BOSS_AUTO_REVIVE_TOGGLE;
         _hasCoolDown = false;
         _intendedEntityType = Unit.U_MONK;
         requiresMouseInput = false;
         isSingleSpell = false;
         isToggle = true;
         this.buttonBitmap = actualButtonBitmap;
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.monk.autoRevive);
         }
      }

      override public function isToggled(entity:Entity) : Boolean
      {
         return Monk(entity).isAutoReviveToggled;
      }

      override public function coolDownTime(entity:Entity) : Number
      {
         return 0;
      }

      override public function isFinished(unit:Unit) : Boolean
      {
         return false;
      }

      override public function inRange(entity:Entity) : Boolean
      {
         return true;
      }
   }
}
