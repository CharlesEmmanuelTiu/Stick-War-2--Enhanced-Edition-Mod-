package com.brockw.stickwar.engine.Ai
{
    import com.brockw.game.Util;
     import com.brockw.stickwar.engine.Ai.command.UnitCommand;
   import com.brockw.stickwar.engine.StickWar;
    import com.brockw.stickwar.engine.Team.Team;
    import com.brockw.stickwar.engine.Team.Tech;
    import com.brockw.stickwar.engine.units.Archer;
    import com.brockw.stickwar.engine.units.Bomber;
    import com.brockw.stickwar.engine.units.Cat;
    import com.brockw.stickwar.engine.units.Dead;
    import com.brockw.stickwar.engine.units.EnslavedGiant;
    import com.brockw.stickwar.engine.units.Giant;
    import com.brockw.stickwar.engine.units.Knight;
    import com.brockw.stickwar.engine.units.Magikill;
    import com.brockw.stickwar.engine.units.Medusa;
    import com.brockw.stickwar.engine.units.Monk;
    import com.brockw.stickwar.engine.units.Ninja;
    import com.brockw.stickwar.engine.units.Skelator;
    import com.brockw.stickwar.engine.units.Statue;
    import com.brockw.stickwar.engine.units.Unit;
    import com.brockw.stickwar.engine.units.Wingidon;
   
   public class NinjaAi extends UnitAi
   {
      private static const BOSS_TARGET_LOCK_FRAMES:int = 30;

      private static const BOSS_SPECIAL_ABORT_FRAMES:int = 30 * 3;

      private static const BOSS_OPENER_TRIGGER_RANGE:Number = 500;

      private static const BOSS_ASSASSIN_STRIKE_OFFSET:Number = 20;

      private static const BOSS_ASSASSIN_BACK_STRIKE_OFFSET:Number = 95;

      private static const BOSS_SPECIAL_RESET_DISTANCE:Number = 260;

      private static const BOSS_SQUAD_RADIUS_X:Number = 260;

      private static const BOSS_SQUAD_RADIUS_Y:Number = 120;

      private var bossFocusTargetId:int;

      private var bossFocusFrames:int;

      private var cachedBossPriorityTarget:Unit;

      private var cachedBossPriorityTargetFrame:int;

      private var cachedNearbyAttackerCount:int;

      private var cachedNearbyAttackerCountFrame:int;

      private var cachedNearbyBossLeader:Ninja;

      private var cachedNearbyBossLeaderFrame:int;

      private var bossSpecialAbortFrames:int;

      private var lastFriendlyStatueHealth:Number;

      public function NinjaAi(s:Ninja)
      {
         super();
         unit = s;
         this.bossFocusTargetId = -1;
         this.bossFocusFrames = 0;
         this.cachedBossPriorityTarget = null;
         this.cachedBossPriorityTargetFrame = -1;
         this.cachedNearbyAttackerCount = 0;
         this.cachedNearbyAttackerCountFrame = -1;
         this.cachedNearbyBossLeader = null;
         this.cachedNearbyBossLeaderFrame = -1;
          this.bossSpecialAbortFrames = 0;
          this.lastFriendlyStatueHealth = -1;
      }
      
      override public function update(game:StickWar) : void
      {
         var statueDamagedThisFrame:Boolean = false;
         if(!Ninja(unit).isBoss)
         {
            unit.isBossMovementLocked = false;
         }
         if(this.bossFocusFrames > 0)
         {
            --this.bossFocusFrames;
         }
         if(Ninja(unit).isBoss)
         {
            statueDamagedThisFrame = this.didFriendlyStatueTakeDamageThisFrame();
            if(Ninja(unit).shouldStartBossLostPhase())
            {
               unit.startCampaignBossEscape();
            }
         }
         else if(unit.shouldStartCampaignBossEscape())
         {
            unit.startCampaignBossEscape();
         }
         if(unit.updateCampaignBossEscape(game))
         {
            Ninja(unit).isBossMovementLocked = true;
            return;
         }
           if(Ninja(unit).isBoss)
           {
              Ninja(unit).isBossMovementLocked = false;
               if(unit.team != null && unit.team.isAi)
               {
                  if(Ninja(unit).shouldEnterBossFinalStand())
                  {
                     Ninja(unit).enterBossFinalStand();
                     this.bossSpecialAbortFrames = 0;
                  }
              }
              Ninja(unit).tryBossChainCloak();
            this.updateBossSpecialAbortState();
            if(this.updateBossSpecialReset())
            {
               return;
            }
         }
         if(currentCommand.type == UnitCommand.CURE)
         {
            Ninja(unit).isAutoCloakToggled = !Ninja(unit).isAutoCloakToggled;
            restoreMove(game);
         }
          if(currentCommand.type == UnitCommand.STEALTH)
          {
             Ninja(unit).stealth();
             restoreMove(game);
          }
           if(currentCommand.type == UnitCommand.NINJA_CLOAK3)
           {
              Ninja(unit).bossSpecialStealth();
              restoreMove(game);
           }
           if(currentCommand.type == UnitCommand.NINJA_SHADOW_CLONE)
           {
              Ninja(unit).activateShadowClone();
              restoreMove(game);
           }
         if(Ninja(unit).isAutoCloakToggled)
          {
             this.tryAutoAbilityCycle();
          }
           if(Ninja(unit).isBoss && !(unit.team != null && !unit.team.isAi && currentCommand.type != UnitCommand.NONE) && this.tryBossAssassinMovement())
          {
             return;
          }
         baseUpdate(game);
      }

      override public function getClosestTarget() : Unit
       {
          var prioritized:Unit = null;
          var closest:Unit = null;
           if(!Ninja(unit).isBoss)
           {
              return super.getClosestTarget();
           }
          if(!Ninja(unit).isBossSpecialTargetingActive())
          {
             return super.getClosestTarget();
          }
          prioritized = this.getBossPriorityTarget();
          if(prioritized != null)
          {
             return prioritized;
          }
          closest = super.getClosestTarget();
          if(closest != null && Math.abs(closest.px - unit.px) <= 1000)
          {
             return closest;
          }
          return null;
       }

      private function tryAutoAbilityCycle() : void
      {
         var closestTarget:Unit = null;
         if(Ninja(unit).isBoss && (Ninja(unit).hasBossWhiffPenalty() || Ninja(unit).hasBossAbilitySpawnLock()))
         {
            return;
         }
          if(Ninja(unit).isBoss && (Ninja(unit).campaignBossEscaping || Ninja(unit).isBossSpecialTargetingActive()))
         {
            return;
         }
         closestTarget = Ninja(unit).isBoss ? super.getClosestTarget() : this.getClosestTarget();
         var cloneResearched:Boolean = Ninja(unit).team != null && Ninja(unit).team.tech.isResearched(Tech.NINJA_SHADOW_CLONE);
         if(closestTarget != null && closestTarget.isAlive())
         {
            if(Math.abs(closestTarget.px - unit.px) < BOSS_OPENER_TRIGGER_RANGE)
            {
                 if(Ninja(unit).isBoss && unit.team != null && unit.team.tech.isResearched(Tech.NINJA_CLOAK3))
                 {
                    if(!Ninja(unit).bossSpecialStealth() && cloneResearched)
                    {
                       Ninja(unit).autoPendingShadowCloneOnHit = true;
                    }
                 }
                 else if(unit.team != null && unit.team.tech.isResearched(Tech.CLOAK))
                {
                   Ninja(unit).stealth();
                   if(cloneResearched)
                   {
                      Ninja(unit).autoPendingShadowCloneOnHit = true;
                   }
                }
                 else if(cloneResearched)
                {
                   Ninja(unit).autoPendingShadowCloneOnHit = true;
                }
            }
         }
      }

      private function getBossPriorityTarget() : Unit
       {
          var enemy:Unit = null;
          var best:Unit = null;
          var bestPriority:int = 999;
          var priority:int = 0;
          if(unit.team != null && unit.team.game != null && this.cachedBossPriorityTargetFrame == unit.team.game.frame)
          {
             return this.cachedBossPriorityTarget;
          }
          best = this.getLockedBossPriorityTarget();
          if(best != null)
          {
             this.cacheBossPriorityTarget(best);
             return best;
          }
            if(unit.team != null && !unit.team.isAi && this.currentCommand != null && this.currentCommand.targetId != -1)
           {
              var cmdTarget:Unit = unit.team.game.units[this.currentCommand.targetId];
              if(cmdTarget != null && cmdTarget is Unit && cmdTarget.isAlive() && cmdTarget.isTargetable() && cmdTarget.team.id != unit.team.id)
             {
                this.lockBossFocusTarget(cmdTarget);
                this.cacheBossPriorityTarget(cmdTarget);
                return cmdTarget;
             }
          }
          for each(enemy in unit.team.enemyTeam.units)
          {
             if(enemy == null || !enemy.isAlive())
             {
                continue;
             }
             if(Math.abs(enemy.px - unit.px) > 1000)
             {
                continue;
             }
             priority = this.getBossTargetPriority(enemy);
             if(priority < bestPriority)
             {
                bestPriority = priority;
                best = enemy;
             }
          }
          if(best != null)
          {
             this.lockBossFocusTarget(best);
          }
          this.cacheBossPriorityTarget(best);
          return best;
       }

      private function cacheBossPriorityTarget(target:Unit) : void
      {
         this.cachedBossPriorityTarget = target;
         if(unit.team != null && unit.team.game != null)
         {
            this.cachedBossPriorityTargetFrame = unit.team.game.frame;
         }
      }

      private function getBossTargetPriority(enemy:Unit) : int
       {
          if(enemy is Wingidon)
          {
             return 999;
          }
          if(enemy is Archer)
          {
             return 1;
          }
          if(enemy is Monk)
          {
             return 2;
          }
          if(enemy is Magikill)
          {
             return 3;
          }
          if(enemy is EnslavedGiant)
          {
             return 4;
          }
          if(enemy is Dead)
          {
             return 5;
          }
          if(enemy is Medusa)
          {
             return 6;
          }
          if(enemy is Skelator)
          {
             return 7;
          }
          if(enemy is Bomber)
          {
             return 8;
          }
          if(enemy is Knight)
          {
             return 9;
          }
          if(enemy is Giant)
          {
             return 10;
          }
          if(enemy is Cat)
          {
             return 11;
          }
          return 20 + int(Math.abs(enemy.px - unit.px) / 100);
       }

      private function tryBossAssassinMovement() : Boolean
      {
         var target:Unit = this.getBossPriorityTarget();
         var strikeX:Number = NaN;
         var strikeY:Number = NaN;
         var closeToStrike:Boolean = false;
         if(!Ninja(unit).isBossSpecialTargetingActive())
         {
            this.clearBossFocusTarget();
            return false;
         }
          if(target == null || !target.isAlive() || unit.isGarrisoned)
         {
            return false;
         }
         if(Ninja(unit).hasBossWhiffPenalty())
         {
            return false;
         }
         this.lockBossFocusTarget(target);
           if(unit.mayAttack(target))
           {
              if(unit.team != null && unit.team.isAi)
              {
                 Ninja(unit).isBossMovementLocked = true;
              }
              unit.faceDirection(target.px - unit.px);
              unit.attack();
              return true;
           }
           strikeX = target is Statue ? target.px - target.team.direction * 90 : target.px - target.team.direction * this.getBossStrikeOffset(target);
           strikeY = target.py;
           closeToStrike = Math.abs(unit.px - strikeX) < 8 && Math.abs(unit.py - strikeY) < 8;
           if(closeToStrike)
           {
              if(unit.team != null && unit.team.isAi)
              {
                 Ninja(unit).isBossMovementLocked = true;
              }
              unit.mayWalkThrough = true;
              unit.walk(0,0,Util.sgn(target.px - unit.px));
              unit.faceDirection(target.px - unit.px);
              return true;
           }
           if(unit.team != null && unit.team.isAi)
           {
              Ninja(unit).isBossMovementLocked = true;
           }
          unit.mayWalkThrough = true;
          unit.walk((strikeX - unit.px) / 60,(strikeY - unit.py) / 60,Util.sgn(target.px - unit.px));
         unit.faceDirection(target.px - unit.px);
         return true;
      }

      private function getBossStrikeOffset(target:Unit) : Number
      {
         if(target is Archer)
         {
            return BOSS_ASSASSIN_BACK_STRIKE_OFFSET;
         }
         return BOSS_ASSASSIN_STRIKE_OFFSET;
      }

      private function tryBossAssassinSquadMovement() : Boolean
      {
         var leader:Ninja = null;
         var target:Unit = null;
         var flankX:Number = NaN;
         var flankY:Number = NaN;
         leader = this.getNearbyBossAssassinLeader();
         if(leader == null)
         {
            return false;
         }
         target = this.getBossSquadTargetForLeader(leader);
         if(target == null || !target.isAlive() || !target.isTargetable())
         {
            return false;
         }
         if(Ninja(unit).isStealthed)
         {
            return false;
         }
         if(unit.mayAttack(target))
         {
            return false;
         }
         if(Ninja(unit).stealthCooldown() == 0)
         {
            Ninja(unit).stealth();
         }
         flankX = target.px - target.team.direction * 140;
         flankY = target.py + this.getBossSquadFlankYOffset(leader,target);
         if(Math.abs(unit.px - flankX) < 25 && Math.abs(unit.py - flankY) < 25)
         {
            return false;
         }
         unit.isBossMovementLocked = true;
         unit.mayWalkThrough = true;
         unit.walk((flankX - unit.px) / 60,(flankY - unit.py) / 60,Util.sgn(flankX - unit.px));
         unit.faceDirection(target.px - unit.px);
         return true;
      }

      private function shouldUseBossAssassinProtocol() : Boolean
      {
         return Ninja(unit).isBossSpecialTargetingActive();
      }

      private function countNearbyAlliedAttackers() : int
      {
         var ally:Unit = null;
         var count:int = 0;
         if(unit.team != null && unit.team.game != null && this.cachedNearbyAttackerCountFrame == unit.team.game.frame)
         {
            return this.cachedNearbyAttackerCount;
         }
         for each(ally in unit.team.units)
         {
            if(ally == null || ally == unit || !ally.isAlive() || ally.isGarrisoned || ally is Statue)
            {
               continue;
            }
            if(ally.type == Unit.U_MINER || ally.type == Unit.U_CHAOS_MINER || ally.type == Unit.U_MONK)
            {
               continue;
            }
            if(Math.abs(ally.px - unit.px) < 280 && Math.abs(ally.py - unit.py) < 120)
            {
               ++count;
            }
         }
         this.cachedNearbyAttackerCount = count;
         if(unit.team != null && unit.team.game != null)
         {
            this.cachedNearbyAttackerCountFrame = unit.team.game.frame;
         }
         return count;
      }

      private function getLockedBossPriorityTarget() : Unit
      {
         var locked:Unit = null;
         if(this.bossFocusFrames <= 0 || this.bossFocusTargetId == -1)
         {
            return null;
         }
         if(!(this.bossFocusTargetId in unit.team.enemyTeam.game.units))
         {
            this.clearBossFocusTarget();
            return null;
         }
         locked = unit.team.enemyTeam.game.units[this.bossFocusTargetId];
         if(locked == null || !locked.isAlive() || !locked.isTargetable())
         {
            this.clearBossFocusTarget();
            return null;
         }
         return locked;
      }

      private function lockBossFocusTarget(target:Unit) : void
      {
         this.bossFocusTargetId = target.id;
         this.bossFocusFrames = BOSS_TARGET_LOCK_FRAMES;
      }

      private function clearBossFocusTarget() : void
      {
         this.bossFocusTargetId = -1;
         this.bossFocusFrames = 0;
      }

      private function hasBossFrontlineBlockers(target:Unit) : Boolean
      {
         var enemy:Unit = null;
         var minX:Number = Math.min(unit.px,target.px);
         var maxX:Number = Math.max(unit.px,target.px);
         for each(enemy in unit.team.enemyTeam.units)
         {
            if(enemy == null || !enemy.isAlive() || enemy == target)
            {
               continue;
            }
            if(enemy.type == Unit.U_SWORDWRATH || enemy.type == Unit.U_SPEARTON || enemy.type == Unit.U_NINJA || enemy.type == Unit.U_ENSLAVED_GIANT)
            {
               if(enemy.px > minX && enemy.px < maxX && Math.abs(enemy.py - target.py) < 85)
               {
                  return true;
               }
            }
         }
         return false;
      }

      private function getBossFlankYOffset(target:Unit) : Number
      {
         if(int(target.px + target.py) % 2 == 0)
         {
            return 70;
         }
         return -70;
      }

      private function getNearbyBossAssassinLeader() : Ninja
      {
         var ally:Unit = null;
         if(unit.team != null && unit.team.game != null && this.cachedNearbyBossLeaderFrame == unit.team.game.frame)
         {
            return this.cachedNearbyBossLeader;
         }
         for each(ally in unit.team.unitGroups[Unit.U_NINJA])
         {
            if(!(ally is Ninja) || ally == unit || !ally.isAlive())
            {
               continue;
            }
             if(!Ninja(ally).isBoss || Ninja(ally).bossEmergencySortie || ally.isGarrisoned || !Ninja(ally).isStealthed || Ninja(ally).hasBossWhiffPenalty())
            {
               continue;
            }
            if(ally.team.currentAttackState != Team.G_ATTACK)
            {
               continue;
            }
            if(Math.abs(ally.px - unit.px) <= BOSS_SQUAD_RADIUS_X && Math.abs(ally.py - unit.py) <= BOSS_SQUAD_RADIUS_Y)
            {
               this.cachedNearbyBossLeader = Ninja(ally);
               if(unit.team != null && unit.team.game != null)
               {
                  this.cachedNearbyBossLeaderFrame = unit.team.game.frame;
               }
               return this.cachedNearbyBossLeader;
            }
         }
         this.cachedNearbyBossLeader = null;
         if(unit.team != null && unit.team.game != null)
         {
            this.cachedNearbyBossLeaderFrame = unit.team.game.frame;
         }
         return null;
      }

      private function getBossSquadTargetForLeader(leader:Ninja) : Unit
      {
         var target:Unit = null;
         if(leader == null || !(leader.ai is NinjaAi))
         {
            return null;
         }
         target = NinjaAi(leader.ai).getClosestTarget();
         return target != null && target.isAlive() && target.isTargetable() ? target : null;
      }

      private function getBossSquadFlankYOffset(leader:Ninja, target:Unit) : Number
      {
         var index:int = unit.id % 3;
         if(index == 0)
         {
            return this.getBossFlankYOffset(target) - 35;
         }
         if(index == 1)
         {
            return this.getBossFlankYOffset(target) + 35;
         }
         return this.getBossFlankYOffset(target);
      }

      private function didFriendlyStatueTakeDamageThisFrame() : Boolean
      {
         var currentHealth:Number = NaN;
         var didTakeDamage:Boolean = false;
         if(unit.team == null || unit.team.statue == null)
         {
            return false;
         }
         currentHealth = unit.team.statue.health;
         if(this.lastFriendlyStatueHealth < 0)
         {
            this.lastFriendlyStatueHealth = currentHealth;
            return false;
         }
         didTakeDamage = currentHealth < this.lastFriendlyStatueHealth;
         this.lastFriendlyStatueHealth = currentHealth;
         return didTakeDamage;
      }

      private function updateBossSpecialAbortState() : void
      {
          if(!Ninja(unit).isBossSpecialTargetingActive() || unit.isGarrisoned)
         {
            this.bossSpecialAbortFrames = 0;
            return;
         }
         if(unit.team.currentAttackState == Team.G_ATTACK || this.hasImmediateBossEngageTarget())
         {
            this.bossSpecialAbortFrames = 0;
            return;
         }
         ++this.bossSpecialAbortFrames;
         if(this.bossSpecialAbortFrames >= BOSS_SPECIAL_ABORT_FRAMES)
         {
            Ninja(unit).failBossSpecial();
            this.bossSpecialAbortFrames = 0;
            this.clearBossFocusTarget();
         }
      }

      private function updateBossSpecialReset() : Boolean
      {
         var anchor:Unit = null;
         var resetX:Number = NaN;
         var resetY:Number = NaN;
         if(!Ninja(unit).needsBossSpecialReset)
         {
            return false;
         }
         anchor = this.getBossSpecialResetAnchor();
         if(anchor != null)
         {
            resetX = anchor.px - unit.team.direction * BOSS_SPECIAL_RESET_DISTANCE;
            resetY = anchor.py;
         }
         else
         {
            resetX = unit.team.medianPosition - unit.team.direction * BOSS_SPECIAL_RESET_DISTANCE;
            resetY = unit.team.game.map.height / 2;
            if(unit.team.direction * resetX > unit.team.direction * unit.team.homeX)
            {
               resetX = unit.team.homeX + unit.team.direction * 220;
            }
         }
         if(Math.abs(unit.px - resetX) < 35 && Math.abs(unit.py - resetY) < 55)
         {
            Ninja(unit).finishBossSpecialReset();
            return false;
         }
         Ninja(unit).isBossMovementLocked = true;
         unit.mayWalkThrough = true;
         unit.walk((resetX - unit.px) / 90,(resetY - unit.py) / 90,Util.sgn(resetX - unit.px));
         unit.faceDirection(resetX - unit.px);
         return true;
      }

      private function getBossSpecialResetAnchor() : Unit
      {
         var ally:Unit = null;
         var best:Unit = null;
         for each(ally in unit.team.units)
         {
            if(ally == null || ally == unit || !ally.isAlive() || ally.isGarrisoned)
            {
               continue;
            }
            if(ally.type == Unit.U_MINER || ally.type == Unit.U_CHAOS_MINER)
            {
               continue;
            }
            if(best == null || ally.px * unit.team.direction > best.px * unit.team.direction)
            {
               best = ally;
            }
         }
         return best;
      }

      private function hasImmediateBossEngageTarget() : Boolean
      {
         var target:Unit = super.getClosestTarget();
         return target != null && target.isAlive() && Math.abs(target.px - unit.px) < BOSS_OPENER_TRIGGER_RANGE;
      }

   }
}
