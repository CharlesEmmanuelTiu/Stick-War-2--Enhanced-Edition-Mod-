# Player's Shadowrath (Ninja) Boss — Phase Suppression & Responsiveness

## Problem

The Ninja boss AI has automated phases (Cautious retreat, Final Stand, Lost Phase) and `BossMovementLock` that are designed for the enemy campaign boss. For the **player's boss**, these need to be suppressed so the player retains full control.

## Key Question

How to distinguish **player's boss** from **enemy boss**?

The enemy campaign Shadowrath uses these phases as part of its AI. We need to add a `_isPlayerBoss` flag to Ninja so the AI knows which behaviors to skip.

## Changes

### 1. `Ninja.as` — Add `_isPlayerBoss` field

**After line 99** (`bossCautiousPhaseDisabled`):
```actionscript
private var _isPlayerBoss:Boolean;
```

**In constructor** (around line 129):
```actionscript
this._isPlayerBoss = false;
```

**In `init()`** (around line 216):
```actionscript
this._isPlayerBoss = false;
```

### 2. `Ninja.as` — Add `markAsPlayerBoss()` + getter

**New method** (near `makeBoss()`, around line 631):
```actionscript
public function markAsPlayerBoss() : void
{
    this._isPlayerBoss = true;
    this.bossCautiousPhaseDisabled = true;
}

public function get isPlayerBoss() : Boolean
{
    return this._isPlayerBoss;
}
```

This is separate from `makeBoss()` because `makeBoss()` is also called for enemy campaign bosses (disguise reveal). The player boss upgrade process would call `makeBoss()` then `markAsPlayerBoss()`.

### 3. `Ninja.as` — `shouldBossRetreat()` (line 668)

Add early return for player boss:
```actionscript
public function shouldBossRetreat() : Boolean
{
    if(this.campaignBossEscaping) return false;
    if(this._isPlayerBoss) return false;                   // ADD
    if(this.bossCautiousPhaseDisabled) return false;       // ADD
    return this.isBoss && ...
}
```

If either flag is set, retreat never triggers.

### 4. `NinjaAi.as` — `update()` (line 129-164 boss branch)

Skip all phase checks for player boss:
```actionscript
if(Ninja(unit).isBoss)
{
    Ninja(unit).isBossMovementLocked = false;
    
    // --- ADD: Skip ALL phase checks for player boss ---
    if(!Ninja(unit).isPlayerBoss)
    {
        if(Ninja(unit).shouldBossRetreat())
        {
            if(Ninja(unit).isBossCautiousPhaseDisabled || this.isEnemyPlayerDefendingBase())
            {
                Ninja(unit).enterBossFinalStand();
                ...
            }
            else
            {
                Ninja(unit).startBossRetreat();
                ...
            }
        }
        if(Ninja(unit).bossIsRetreating)
        {
            ...
        }
    }
    // --- END ADD ---
    
    Ninja(unit).tryBossChainCloak();
    this.updateBossSpecialAbortState();
    if(this.updateBossSpecialReset()) return;
}
```

The player boss still gets chain cloak, special abort, and special reset — only the phase transitions are skipped.

### 5. `NinjaAi.as` — `tryBossAssassinMovement()` (line 355)

Don't set `isBossMovementLocked` for player boss, so player commands can override:
```actionscript
private function tryBossAssassinMovement() : Boolean
{
    // ... existing checks ...
    
    // --- ADD: Skip movement lock for player boss ---
    if(!Ninja(unit).isPlayerBoss)
    {
        Ninja(unit).isBossMovementLocked = true;
    }
    // --- instead of: Ninja(unit).isBossMovementLocked = true; ---
    
    unit.mayWalkThrough = true;
    unit.walk((strikeX - unit.px) / 60, ...);
    ...
}
```

Replace all 3 `Ninja(unit).isBossMovementLocked = true;` lines (lines 377, 387, 393) with the guard.

### 6. `NinjaAi.as` — `update()` (line 180)

Skip `tryBossAssassinMovement()` for player boss if a player command is active:
```actionscript
// OLD:
if(Ninja(unit).isBoss && this.tryBossAssassinMovement())
{
    return;
}

// NEW:
if(Ninja(unit).isBoss && !(Ninja(unit).isPlayerBoss && currentCommand.type != UnitCommand.NONE) && this.tryBossAssassinMovement())
{
    return;
}
```

This allows player commands (attack-move, attack-target, move) to override the assassin movement AI.

### 7. `getClosestTarget()` override (line 187)

Keep as-is — priority targeting only activates during `isBossSpecialTargetingActive()` (cloaked). When the player gives a direct attack order, the AI's `baseUpdate` uses the commanded target, not `getClosestTarget()`. The override only affects auto-targeting when the boss is idle.

## Summary

| Change | File | What |
|--------|------|------|
| Field `_isPlayerBoss` | `Ninja.as:101` | New boolean, default false |
| Init in constructor + `init()` | `Ninja.as` | Initialize to false |
| `markAsPlayerBoss()` | `Ninja.as` | Sets `_isPlayerBoss = true`, `bossCautiousPhaseDisabled = true` |
| `shouldBossRetreat()` guard | `Ninja.as:670-671` | Return false if player boss |
| Phase branch guard | `NinjaAi.as:129-164` | Skip retreat/Final Stand checks for player boss |
| `isBossMovementLocked` guards | `NinjaAi.as:377,387,393` | Don't lock movement for player boss |
| Assassin movement skip | `NinjaAi.as:180` | Skip if player command active |
