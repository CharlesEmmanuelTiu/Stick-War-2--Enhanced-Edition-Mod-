package com.brockw.stickwar.engine.Ai.command
{
   import com.brockw.stickwar.engine.Entity;
   import com.brockw.stickwar.engine.StickWar;
   import com.brockw.stickwar.engine.units.*;
   import flash.display.*;

   public class MagikillSummonCommand extends UnitCommand
   {
       public static const actualButtonBitmap:Bitmap = new Bitmap(new MagikillSummon());

       public function MagikillSummonCommand(game:StickWar)
       {
           super();
           type = UnitCommand.MAGIKILL_SUMMON;
           _hasCoolDown = true;
           _intendedEntityType = Unit.U_MAGIKILL;
           requiresMouseInput = false;
           isSingleSpell = true;
           this.buttonBitmap = actualButtonBitmap;
           if(game != null)
           {
               this.loadXML(game.xml.xml.Order.Units.magikill.summon);
           }
       }

        override public function coolDownTime(entity:Entity) : Number
        {
            var magikill:Magikill = Magikill(entity);
            if(magikill.summonCooldown() > 0)
            {
                return magikill.summonCooldown();
            }
            if(magikill.hasBossAbilitySpawnLock() || !magikill.canBossSummonAnyGuardType() || (magikill.isSummonUpgradeActive() && magikill.team.mana < 70))
            {
                return 0.01;
            }
            return 0;
        }

       override public function isFinished(unit:Unit) : Boolean
       {
           return false;
       }
   }
}
