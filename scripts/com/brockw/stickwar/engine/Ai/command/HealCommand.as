package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.GameScreen;
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.multiplayer.moves.*;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;
   
   public class HealCommand extends UnitCommand
   {
      
      public static const actualButtonBitmap:Bitmap = new Bitmap(new HealBitmap());
      
      public var toggleTargetState:int = 0;
      
      public function HealCommand(game:StickWar)
      {
         super();
         type = UnitCommand.HEAL;
         hotKey = 81;
         _hasCoolDown = false;
         _intendedEntityType = -1;
         requiresMouseInput = false;
         isSingleSpell = false;
         isToggle = true;
         this.buttonBitmap = actualButtonBitmap;
         if(game != null)
         {
            this.loadXML(game.xml.xml.Order.Units.monk.heal);
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
          if(entity is Archer)
          {
             return Archer(entity).isAutoKiteToggled;
          }
          return Monk(entity).isHealToggled;
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
         if(entity is Archer)
         {
            return true;
         }
         return Math.pow(realX - entity.px,2) + Math.pow(realY - entity.py,2) < Math.pow(Unit(entity).team.game.xml.xml.Order.Units.monk.heal.range,2);
      }
   }
}

