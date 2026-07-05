package com.brockw.stickwar.engine.Ai
{
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
         baseUpdate(game);
      }
   }
}

