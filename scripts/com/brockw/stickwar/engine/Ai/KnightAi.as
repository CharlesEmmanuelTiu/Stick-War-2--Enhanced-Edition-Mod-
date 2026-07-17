package com.brockw.stickwar.engine.Ai
{
   import com.brockw.stickwar.engine.Ai.command.UnitCommand;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.Knight;
   
   public class KnightAi extends UnitAi
   {
      
      public function KnightAi(s:Knight)
      {
         super();
         unit = s;
      }
      
      override public function update(game:StickWar) : void
      {
         if(unit.shouldStartCampaignBossEscape())
         {
            unit.startCampaignBossEscape();
         }
         if(unit.updateCampaignBossEscape(game))
         {
            return;
         }
         unit.tryBossCharge();
         if(currentCommand != null && currentCommand.type == UnitCommand.KNIGHT_CHARGE)
         {
            unit.charge();
            nextMove(game);
         }
         baseUpdate(game);
      }
   }
}

