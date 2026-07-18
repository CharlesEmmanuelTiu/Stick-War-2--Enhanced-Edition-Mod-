# Fix: Auto-cycle abilities blocking manual override

## Problem

Auto cycle loads Triple Shot/Poison Execute onto `bossAbilityPendingType`. When user turns auto OFF and clicks Explosion Arrow manually, `hasBossSpecialArrowLoaded()` returns true (because `bossAbilityPendingType != 0`), blocking the manual click. Boss then fires the stale auto-loaded ability into a dead target — nothing happens.

## Fix

**File: `Archer.as` line 608-611**

Remove `bossAbilityPendingType` from `hasBossSpecialArrowLoaded()`:

```actionscript
// OLD:
public function hasBossSpecialArrowLoaded() : Boolean
{
    return this.isFire || this.bossAbilityPendingType != 0 || this.pendingManualAbility != 0;
}

// NEW:
public function hasBossSpecialArrowLoaded() : Boolean
{
    return this.isFire || this.pendingManualAbility != 0;
}
```

## What changes

| Scenario | Before | After |
|----------|--------|-------|
| Auto loaded Triple Shot, user clicks Explosion | Blocked "Special arrow already loaded" | **Allowed — overrides Triple Shot** |
| User saved Explosion as pending, clicks Arrow Storm | Blocked by `pendingManualAbility != 0` | **Blocked by `pendingManualAbility != 0`** (unchanged) |
| Fire Arrow loaded, user clicks Explosion | Blocked by `isFire` | **Blocked by `isFire`** (unchanged) |
| No special arrow loaded, user clicks Explosion | Allowed | **Allowed** (unchanged) |

The `pendingManualAbility != 0` check still prevents stacking saved pending abilities, and `isFire` still protects Fire Arrow. Triple Shot/Poison Execute cost 0 mana so overriding them wastes nothing.
