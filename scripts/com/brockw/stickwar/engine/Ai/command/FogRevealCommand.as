package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.GameScreen;
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.multiplayer.moves.UnitMove;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   
   public class FogRevealCommand extends UnitCommand
   {
      
      public static const actualButtonBitmap:Bitmap = new Bitmap(new giantLevel1Bitmap());
      
      public function FogRevealCommand(game:StickWar)
      {
         super();
         type = UnitCommand.FOG_REVEAL;
         _hasCoolDown = true;
         _intendedEntityType = Unit.U_MONK;
         requiresMouseInput = false;
         isSingleSpell = true;
         this.buttonBitmap = actualButtonBitmap;
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.monk.fogReveal);
         }
      }
      
      override public function coolDownTime(entity:Entity) : Number
      {
         return entity.getFogRevealCooldownFraction();
      }
      
      override public function isFinished(unit:Unit) : Boolean
      {
         return false;
      }
      
      override public function inRange(entity:Entity) : Boolean
      {
         return true;
      }
      
      override public function prepareNetworkedMove(gameScreen:GameScreen) : *
      {
         var unit:String = null;
         this.playSound(gameScreen.game);
         var u:UnitMove = new UnitMove();
         u.moveType = this.type;
         for(unit in gameScreen.team.units)
         {
            if(gameScreen.team.units[unit].selected)
            {
               if(this.intendedEntityType == -1 || this.intendedEntityType == gameScreen.team.units[unit].type)
               {
                  u.units.push(gameScreen.team.units[unit].id);
               }
            }
         }
         u.arg0 = 0;
         u.arg1 = 0;
         u.arg4 = this.targetId;
         if(gameScreen.userInterface.keyBoardState.isShift)
         {
            u.queued = true;
         }
         gameScreen.doMove(u,gameScreen.team.id);
      }
   }
}

