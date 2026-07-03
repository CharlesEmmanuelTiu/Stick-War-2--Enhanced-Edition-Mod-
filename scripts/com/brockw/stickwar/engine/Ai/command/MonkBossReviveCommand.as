package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.GameScreen;
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.display.BlendMode;

   public class MonkBossReviveCommand extends UnitCommand
   {
      private var _highlightedCorpse:Unit;

      private static function createButtonBitmap() : Bitmap
      {
         var bmd:BitmapData = new HealBitmap();
         var ct:ColorTransform = new ColorTransform();
         ct.color = 0xFFD700;
         bmd.draw(bmd, null, ct, BlendMode.MULTIPLY);
         return new Bitmap(bmd);
      }

      public static const actualButtonBitmap:Bitmap = createButtonBitmap();

      public function MonkBossReviveCommand(game:StickWar)
      {
         super();
         type = UnitCommand.MONK_BOSS_REVIVE;
         _hasCoolDown = true;
         _intendedEntityType = Unit.U_MONK;
         requiresMouseInput = true;
         isSingleSpell = true;
         this.buttonBitmap = actualButtonBitmap;
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.monk.revive);
         }
      }

      override public function drawCursorPreClick(canvas:Sprite, gameScreen:GameScreen) : Boolean
      {
         if(this._highlightedCorpse != null)
         {
            this._highlightedCorpse.filters = [];
            this._highlightedCorpse = null;
         }
         var mx:Number = gameScreen.game.battlefield.mouseX;
         var my:Number = gameScreen.game.battlefield.mouseY;
         for each(var corpse:Unit in gameScreen.team.deadUnits)
         {
            if(corpse != null && !corpse.forceTowerSpawnVisual && Math.abs(corpse.px - mx) < 25 && Math.abs(corpse.py - my) < 25)
            {
               corpse.filters = [new GlowFilter(0x00FF00, 0.8, 8, 8)];
               this._highlightedCorpse = corpse;
               break;
            }
         }
         return super.drawCursorPreClick(canvas, gameScreen);
      }

      override public function cleanUpPreClick(canvas:Sprite) : void
      {
         if(this._highlightedCorpse != null)
         {
            this._highlightedCorpse.filters = [];
            this._highlightedCorpse = null;
         }
         super.cleanUpPreClick(canvas);
      }

      override public function coolDownTime(entity:Entity) : Number
      {
         return Monk(entity).getReviveCooldownFraction();
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
