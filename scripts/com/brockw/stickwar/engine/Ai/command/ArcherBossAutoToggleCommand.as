package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.GameScreen;
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.multiplayer.moves.*;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   import flash.display.BlendMode;

   public class ArcherBossAutoToggleCommand extends UnitCommand
   {
      private static function createButtonBitmap() : Bitmap
      {
         var bmd:BitmapData = new ArchidonFire();
         var ct:ColorTransform = new ColorTransform();
         ct.color = 0xFFFFFF;
         bmd.draw(bmd, null, ct, BlendMode.MULTIPLY);
         return new Bitmap(bmd);
      }

      public static const actualButtonBitmap:Bitmap = createButtonBitmap();

      public var toggleTargetState:int = 0;

      public function ArcherBossAutoToggleCommand(game:StickWar)
      {
         super();
         type = UnitCommand.ARCHER_BOSS_AUTO_TOGGLE;
         _hasCoolDown = false;
         _intendedEntityType = Unit.U_ARCHER;
         requiresMouseInput = false;
         isSingleSpell = false;
         isToggle = true;
         this.buttonBitmap = actualButtonBitmap;
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.archer.autoToggle);
         }
      }

      override public function prepareNetworkedMove(gameScreen:GameScreen) : *
      {
         var unit:String = null;
         this.playSound(gameScreen.game);
         var u:UnitMove = new UnitMove();
         u.moveType = this.type;
         for(unit in gameScreen.team.units)
         {
            if(Unit(gameScreen.team.units[unit]).selected)
            {
               if(this.intendedEntityType == -1 || this.intendedEntityType == gameScreen.team.units[unit].type)
               {
                  u.units.push(gameScreen.team.units[unit].id);
               }
            }
         }
         u.arg0 = this.toggleTargetState;
         u.arg1 = 0;
         u.arg4 = this.targetId;
         if(gameScreen.userInterface.keyBoardState.isShift)
         {
            u.queued = true;
         }
         gameScreen.doMove(u,gameScreen.team.id);
      }

      override public function isToggled(entity:Entity) : Boolean
      {
         return Archer(entity).isAutoAbilityEnabled;
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
