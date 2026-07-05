package com.brockw.stickwar.engine.Ai
{
   import com.brockw.stickwar.engine.Ai.command.UnitCommand;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.Archer;
   
   public class ArcherAi extends RangedAi
   {
      
      public function ArcherAi(s:Archer)
      {
         super(s);
         unit = s;
      }
      
      override public function update(game:StickWar) : void
      {
         checkNextMove(game);
         if(unit.shouldStartCampaignBossEscape())
         {
            unit.startCampaignBossEscape();
         }
         if(unit.updateCampaignBossEscape(game))
         {
            return;
         }
         if(unit.isBoss)
         {
            this.mayKite = true;
            unit.tryBossAbilities(game);
            unit.isBossMovementLocked = false;
            if(unit.handleBossExplosionSetupMovement(game))
            {
               return;
            }
         }
         if(unit.team == unit.team.game.team)
         {
            this.mayKite = unit.isAutoKiteToggled;
         }
         if(currentCommand.type == UnitCommand.HEAL)
         {
            unit.isAutoKiteToggled = currentCommand.realX != 0;
            this.mayKite = unit.isAutoKiteToggled;
            restoreMove(game);
            super.update(game);
            return;
         }
         if(currentCommand.type == UnitCommand.ARCHER_FIRE)
         {
            unit.archerFireArrow();
            nextMove(game);
         }
         if(currentCommand.type == UnitCommand.ARCHER_BOSS_AUTO_TOGGLE)
         {
            unit.bossAutoAbilityEnabled = currentCommand.realX != 0;
            restoreMove(game);
            super.update(game);
            return;
         }
         if(currentCommand.type == UnitCommand.ARCHER_BOSS_ARROW_STORM)
         {
            unit.tryBossArrowStormManual(unit.team.game);
            nextMove(game);
         }
         if(currentCommand.type == UnitCommand.ARCHER_BOSS_EXPLOSION)
         {
            unit.tryBossExplosionArrowManual(unit.team.game);
            nextMove(game);
         }
         super.update(game);
      }
   }
}

