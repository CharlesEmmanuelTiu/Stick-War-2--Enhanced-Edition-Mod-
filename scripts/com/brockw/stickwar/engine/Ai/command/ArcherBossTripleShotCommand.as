package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   
   public class ArcherBossTripleShotCommand extends UnitCommand
   {
      
      public static const actualButtonBitmap:Bitmap = createButtonBitmap();
      
      public function ArcherBossTripleShotCommand(game:StickWar)
      {
         super();
         type = UnitCommand.ARCHER_BOSS_TRIPLE_SHOT;
         _hasCoolDown = true;
         _intendedEntityType = Unit.U_ARCHER;
         buttonBitmap = actualButtonBitmap;
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.archer.tripleShot);
         }
      }
      
      private static function createButtonBitmap() : Bitmap
      {
         var bmd:BitmapData = new ArchidonFire();
         var ct:ColorTransform = new ColorTransform();
         ct.color = 16766720;
         bmd.draw(bmd,null,ct,BlendMode.MULTIPLY);
         return new Bitmap(bmd);
      }
      
      override public function coolDownTime(entity:Entity) : Number
      {
         return entity.getBossAbilityCooldownFraction(UnitCommand.ARCHER_BOSS_TRIPLE_SHOT);
      }
      
      override public function isFinished(unit:Unit) : Boolean
      {
         return false;
      }
   }
}

