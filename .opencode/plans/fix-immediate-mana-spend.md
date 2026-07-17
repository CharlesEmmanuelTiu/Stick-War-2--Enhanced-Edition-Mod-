# Fix: Spend mana and set cooldown immediately on manual ability click

## Problem

Currently, mana/cooldown is only spent when the ability resolves (target found). It should be spent immediately on click, after guard checks pass.

## Changes

### `Archer.as` — `tryBossExplosionArrowManual()`

Move `team.mana -= 25` and `this.bossExplosionArrowCooldownFrames = ...` from after `findBossExplosionArrowTarget()` to before it, but after the guard checks:

```actionscript
// OLD:
if(this.pendingManualAbility != 0) return false;
if(this.hasBossSpecialArrowLoaded()) { showMessage; return false; }
if(cooldown/research/mana check) return false;
target = this.findBossExplosionArrowTarget();
if(target == null) { this.pendingManualAbility = ...; return true; }
team.mana -= 25;
this.bossExplosionArrowCooldownFrames = ...;
this.bossAbilityPendingType = ...;
...

// NEW:
if(this.pendingManualAbility != 0) return false;
if(this.hasBossSpecialArrowLoaded()) { showMessage; return false; }
if(cooldown/research/mana check) return false;
team.mana -= 25;                          // <-- moved here
this.bossExplosionArrowCooldownFrames = ...; // <-- moved here
target = this.findBossExplosionArrowTarget();
if(target == null) { this.pendingManualAbility = ...; return true; }
this.bossAbilityPendingType = ...;
...
```

### `Archer.as` — `tryBossArrowStormManual()`

Same pattern — add mana/cooldown at the top before target finding:

```actionscript
// OLD:
if(this.pendingManualAbility != 0) return false;
if(this.hasBossSpecialArrowLoaded()) { showMessage; return false; }
if(cooldown/research/mana check) return false;
archers = this.getNearbyBossStormArchers();
targetPoint = this.getBossStormTargetPointManual(game);
if(targetPoint == null) { this.pendingManualAbility = ...; return true; }
if(!hasValidBossStormShooter) { this.pendingManualAbility = ...; return true; }
team.mana -= 70;
this.bossArrowStormCooldownFrames = ...;
...

// NEW:
if(this.pendingManualAbility != 0) return false;
if(this.hasBossSpecialArrowLoaded()) { showMessage; return false; }
if(cooldown/research/mana check) return false;
team.mana -= 70;                          // <-- moved here
this.bossArrowStormCooldownFrames = ...;  // <-- moved here
archers = this.getNearbyBossStormArchers();
targetPoint = this.getBossStormTargetPointManual(game);
if(targetPoint == null) { this.pendingManualAbility = ...; return true; }
if(!hasValidBossStormShooter) { this.pendingManualAbility = ...; return true; }
...
```

### `Archer.as` — `checkPendingManualAbility()`

Remove the mana/cooldown lines I added in the previous round (lines 657-658, 677-678) — they're no longer needed since mana/cooldown is now spent on click:

```actionscript
// Arrow Storm resolve — remove lines:
//   team.mana -= 70;
//   this.bossArrowStormCooldownFrames = ...;

// Explosion Arrow direct resolve — remove lines:
//   team.mana -= 25;
//   this.bossExplosionArrowCooldownFrames = ...;
```

## Safety

The `hasBossSpecialArrowLoaded()` guard runs BEFORE the spend, so:
- If Fire Arrow is loaded → message shown, no spend
- If boss ability pending → message shown, no spend
- If saved pending → message shown, no spend
- If all clear → spend on click, ability fires later
