# Fix: Explosion Arrow misplacement

## Root Cause

My previous change removed `magikill.nuke.range` from `findBossExplosionArrowTarget()`, allowing the boss to target enemies up to ~720px away. But `ProjectileManager.initNuke()` clamps the explosion to within `nuke.range` (~400px) of the **archer** (inflictor), not the target.

When the arrow hits a target at 700px, the explosion gets snapped to only 400px from the archer.

## Changes Needed

### 1. `scripts/com/brockw/stickwar/engine/projectile/ProjectileManager.as` line 450

Add optional `clampToRange:Boolean = true` parameter. Wrap the range clamp in `if(clampToRange)`:

```actionscript
// OLD:
public function initNuke(x:Number, y:Number, unit:Unit, damage:Number) : void
{
   // ...
   if(Math.abs(x - unit.px) > unit.team.game.xml.xml.Order.Units.magikill.nuke.range)
   {
      x = unit.px + Util.sgn(x - unit.px) * unit.team.game.xml.xml.Order.Units.magikill.nuke.range;
   }
   // ...
}

// NEW:
public function initNuke(x:Number, y:Number, unit:Unit, damage:Number, clampToRange:Boolean = true) : void
{
   // ...
   if(clampToRange && Math.abs(x - unit.px) > unit.team.game.xml.xml.Order.Units.magikill.nuke.range)
   {
      x = unit.px + Util.sgn(x - unit.px) * unit.team.game.xml.xml.Order.Units.magikill.nuke.range;
   }
   // ...
}
```

Default `true` preserves existing behavior for all other callers (Magikill, Bomber, ChaosTower).

### 2. `scripts/com/brockw/stickwar/engine/projectile/Arrow.as` line 89

Pass `false` to skip the range clamp for arrow-based explosions:

```actionscript
// OLD:
game.projectileManager.initNuke(this.px,this.py,this.inflictor,this.explosionDamage);

// NEW:
game.projectileManager.initNuke(this.px,this.py,this.inflictor,this.explosionDamage,false);
```

## Why this works

Arrow impact `this.px` = target position (correct). The explosion should be placed exactly where the arrow lands. The range clamp was designed for Magikill's direct-targeting nuke ability and doesn't apply to projectile-based explosions.
