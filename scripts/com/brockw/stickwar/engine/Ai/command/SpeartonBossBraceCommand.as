package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.multiplayer.moves.*;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   
   public class SpeartonBossBraceCommand extends UnitCommand
   {
      
      public static const actualButtonBitmap:Bitmap = createButtonBitmap();
      
      public function SpeartonBossBraceCommand(game:StickWar)
      {
         super();
         type = UnitCommand.SPEARTON_BOSS_BRACE;
         _hasCoolDown = false;
         _intendedEntityType = Unit.U_SPEARTON;
         requiresMouseInput = false;
         isSingleSpell = false;
         isToggle = true;
         this.buttonBitmap = actualButtonBitmap;
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.spearton.brace);
         }
      }
      
      private static function createButtonBitmap() : Bitmap
      {
         var bmd:BitmapData = new SpeartanShieldWall();
         var ct:ColorTransform = new ColorTransform();
         ct.color = 49151;
         bmd.draw(bmd,null,ct,BlendMode.MULTIPLY);
         return new Bitmap(bmd);
      }
      
      override public function isToggled(entity:Entity) : Boolean
      {
         return entity.isAutoBraceToggled;
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

