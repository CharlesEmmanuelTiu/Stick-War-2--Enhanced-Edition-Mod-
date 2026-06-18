# Fix: Mana/cooldown pending path + Safety net message

## Bug: Mana/cooldown not spent when pending ability resolves

### Root cause

When no target is found immediately:
1. `tryBossExplosionArrowManual()` sets `pendingManualAbility` but does NOT deduct mana or set cooldown
2. `checkPendingManualAbility()` later resolves the pending ability and sets `bossAbilityPendingType` but also does NOT deduct mana or set cooldown
3. `shoot()` → `executeBossAbilityOnShoot()` fires the ability — mana never spent, cooldown never set
4. Same issue exists for Arrow Storm's pending path

### Fix: `checkPendingManualAbility()` in Archer.as (lines 637-677)

Add mana spending and cooldown setting when resolving:

**Arrow Storm branch** (after `startBossDrawAnimation`, before `pendingManualAbility = 0`):
```actionscript
team.mana -= 70;
this.bossArrowStormCooldownFrames = BOSS_ARROW_STORM_COOLDOWN_FRAMES;
```

**Explosion Arrow branch — direct path** (when distance >= BOSS_EXPLOSION_ARROW_MIN_DISTANCE):
```actionscript
team.mana -= 25;
this.bossExplosionArrowCooldownFrames = BOSS_EXPLOSION_ARROW_COOLDOWN_FRAMES;
```

**Explosion Arrow branch — setup path** (when distance < BOSS_EXPLOSION_ARROW_MIN_DISTANCE):
- No change needed — `startBossExplosionSetup()` defers to `updateBossExplosionSetup()` which already handles mana/cooldown at line 946-949.

---

## Feature: "Special arrow already loaded" safety net

### What it does

If the player tries to click any special arrow ability (Fire Arrow, Explosion Arrow, Arrow Storm) while ANY special arrow is already loaded, show a message and block the command.

"Loaded" means any of:
- `isFire == true` (Fire Arrow loaded for next shot)
- `bossAbilityPendingType != 0` (boss ability loaded for next shot)
- `pendingManualAbility != 0` (saved for when target comes in range)

### Changes

**1. `Archer.as` — add public method** (after `isAutoAbilityEnabled` around line 606):
```actionscript
public function hasBossSpecialArrowLoaded() : Boolean
{
    return this.isFire || this.bossAbilityPendingType != 0 || this.pendingManualAbility != 0;
}
```

**2. `Archer.as` — guard in `tryBossExplosionArrowManual()`** (after `pendingManualAbility != 0` check, before cooldown check):
```actionscript
if(this.isFire || this.bossAbilityPendingType != 0)
{
    game.gameScreen.userInterface.helpMessage.showMessage("Special arrow already loaded");
    return false;
}
```

**3. `Archer.as` — guard in `tryBossArrowStormManual()`** (same position):
```actionscript
if(this.isFire || this.bossAbilityPendingType != 0)
{
    game.gameScreen.userInterface.helpMessage.showMessage("Special arrow already loaded");
    return false;
}
```

**4. `ActionInterface.as` — UI-level guard** (after line 452, before gold/mana checks, in the click handling block):
```actionscript
if((this.currentActions[action] == UnitCommand.ARCHER_FIRE || this.currentActions[action] == UnitCommand.ARCHER_BOSS_ARROW_STORM || this.currentActions[action] == UnitCommand.ARCHER_BOSS_EXPLOSION) && this.currentEntity is Archer)
{
    if(Archer(this.currentEntity).hasBossSpecialArrowLoaded())
    {
        gameScreen.userInterface.helpMessage.showMessage("Special arrow already loaded");
        continue;
    }
}
```

The UI-level guard catches ALL special arrows (including Fire Arrow) and shows the message BEFORE gold/mana/cooldown checks. The Archer method guards are a safety net in case the command bypasses ActionInterface.

### Message format

Uses the same `helpMessage.showMessage()` pattern as "Not enough gold to cast" (ActionInterface.as:464) and "Ability is on cooldown" (ActionInterface.as:472).

---

## Summary of all 3 files changed

| File | Change |
|------|--------|
| `Archer.as` | Add mana/cooldown in `checkPendingManualAbility()` — both Arrow Storm and Explosion Arrow resolve branches |
| `Archer.as` | Add `hasBossSpecialArrowLoaded()` public method |
| `Archer.as` | Add guard in `tryBossExplosionArrowManual()` and `tryBossArrowStormManual()` |
| `ActionInterface.as` | Add UI-level guard in click handler for ARCHER_FIRE, ARCHER_BOSS_ARROW_STORM, ARCHER_BOSS_EXPLOSION |
