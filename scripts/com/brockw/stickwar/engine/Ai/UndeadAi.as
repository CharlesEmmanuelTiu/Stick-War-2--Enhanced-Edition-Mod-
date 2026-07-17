package com.brockw.stickwar.engine.Ai
{
   import com.brockw.stickwar.engine.Ai.command.AttackMoveCommand;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.Undead;
   
   public class UndeadAi extends UnitAi
   {
      
      public function UndeadAi(s:Undead)
      {
         super();
         unit = s;
      }
      
      override public function update(game:StickWar) : void
      {
         if(unit.isBossSummoned && !unit.isDead)
         {
            if(game.frame == unit.bossSummonFrame)
            {
               var cmd:AttackMoveCommand = new AttackMoveCommand(game);
               cmd.goalX = unit.team.enemyTeam.statue.px;
               cmd.goalY = unit.py;
               cmd.realX = cmd.goalX;
               cmd.realY = cmd.goalY;
               unit.ai.setCommand(game,cmd);
            }
         }
         baseUpdate(game);
      }
   }
}

