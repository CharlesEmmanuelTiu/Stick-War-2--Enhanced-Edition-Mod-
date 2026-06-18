# Cloak 3 — Tech Research + Mechanic for Player's Ninja Boss

## Overview

New researchable tech in BarracksBuilding. Replaces the STEALTH button with a CLOAK_3 button for the player's boss. Cloak 3 costs mana on use (20 activate, 10 chain), with no upfront cooldown — only a 20s whiff penalty on miss.

## Tech Data

| Field | Value |
|-------|-------|
| Constant | `NINJA_CLOAK3 = -66` |
| Research cost | 200 gold, 200 mana |
| Prereq | `CLOAK` + `CLOAK_II` |
| Boss-only | Yes (non-boss Ninjas ignore this tech) |

## Action Bar Logic (`setActionInterface`)

| CLOAK | CLOAK_III | Boss? | Button at (0,0) |
|-------|-----------|-------|-----------------|
| No | — | — | None |
| Yes | No | No | STEALTH |
| Yes | No | Yes | STEALTH (dead button — boss can't use normal stealth) |
| Yes | Yes | Yes | **CLOAK_3** (purple tinted NinjaCloak) |

Auto-cloak toggle (CURE button at 1,0) remains unchanged — it already calls `bossSpecialStealth()` for boss units.

## Mana Costs

| Action | Cost | If insufficient mana |
|--------|------|---------------------|
| **Activate Cloak 3** | 20 mana | Cloak fails, no penalty |
| **Successful chain** | 10 mana | Chain fails → **whiff penalty** (20s) |
| **Miss (whiff)** | — | Whiff penalty (20s), no extra mana cost |

## Implementation Plan

### 1. `Tech.as:135` — New constant
```actionscript
public static const NINJA_CLOAK3:int = -66;
```

### 2. `GoodTech.as` — Register tech with purple NinjaCloak icon
```actionscript
// After CLOAK_II registration (~line 70):
if(false) {} // placeholder for NINJA_CLOAK3
else if(!tech.isResearched(Tech.NINJA_CLOAK3)) {
    var cloak3Bmd:BitmapData = new BitmapData(new NinjaCloak().width, new NinjaCloak().height, true, 0);
    var cloak3Bitmap:Bitmap = new Bitmap(cloak3Bmd);
    // Apply purple tint (0xAA00FF) using ColorTransform + BlendMode.MULTIPLY
    this.addNewUpgrade(Tech.NINJA_CLOAK3, game.xml.xml.Order.Tech.cloak3, cloak3Bitmap, 81);
}
```

(Same tinting approach as Archer boss techs — use `ColorTransform` with 0xAA00FF and `BlendMode.MULTIPLY`.)

### 3. `BarracksBuilding.as` — Research button
```actionscript
// After CLOAK_II button (~line 52-56):
if(!tech.isResearched(Tech.NINJA_CLOAK3)) {
    a.setAction(0, 3, Tech.NINJA_CLOAK3);
}
```

### 4. `CampaignGameScreen.as` — Tech allowed
```actionscript
// Add NINJA_CLOAK3 to the campaign techAllowed set (alongside ARCHER_BOSS_ARROW_STORM etc.)
```

### 5. XML — Add tech entry (`scripts/_assets/10208_com.brockw.game.XMLLoader_GameConstants.bin`)
```
Order.Tech.cloak3
```
(Using JPEX to add the XML node with cost, description, etc.)

### 6. `UnitCommand.as:106` — New command constant
```actionscript
public static const NINJA_CLOAK3:int = 55;
```

### 7. New file: `NinjaCloak3Command.as`
```actionscript
package com.brockw.stickwar.engine.Ai.command
{
    import com.brockw.stickwar.engine.Entity;
    import com.brockw.stickwar.engine.StickWar;
    import com.brockw.stickwar.engine.units.*;
    import flash.display.*;

    public class NinjaCloak3Command extends UnitCommand
    {
        public static const actualButtonBitmap:Bitmap = /* purple tinted NinjaCloak */;

        public function NinjaCloak3Command(game:StickWar)
        {
            super();
            type = UnitCommand.NINJA_CLOAK3;
            hotKey = 81;
            _hasCoolDown = true;
            _intendedEntityType = Unit.U_NINJA;
            buttonBitmap = actualButtonBitmap;
            // XML loading: use cloak 3 data or reuse stealth XML
        }

        override public function coolDownTime(entity:Entity) : Number
        {
            return Ninja(entity).getBossCloakCooldownFraction();
        }

        override public function isFinished(unit:Unit) : Boolean
        {
            return false;
        }
    }
}
```

### 8. `CommandFactory.as` — Register command
```actionscript
this.commandMap[UnitCommand.NINJA_CLOAK3] = NinjaCloak3Command;
```

### 9. `ActionInterface.as` — Register button + tooltip
In `setUpActions()`: `a.setAction(0, 0, UnitCommand.NINJA_CLOAK3);` (gated on CLOAK_III research + boss)
In tooltip handler: add tooltip text for Cloak 3.

### 10. `Ninja.as` — `bossSpecialStealth()` mana deduction
```actionscript
public function bossSpecialStealth(ignoreCooldown:Boolean = false, isChainCloak:Boolean = false) : Boolean
{
    // ... existing guards ...

    // Cloak 3 mana cost (player boss only)
    if(this._isPlayerBoss && team.tech.isResearched(Tech.NINJA_CLOAK3))
    {
        var manaCost:int = isChainCloak ? 10 : 20;
        if(team.mana < manaCost) return false;
        team.mana -= manaCost;
    }

    // ... rest of activation ...
}
```

### 11. `Ninja.as` — `tryBossChainCloak()` chain mana
```actionscript
public function tryBossChainCloak() : Boolean
{
    // ... existing guards ...

    // Cloak 3 chain mana (player boss only)
    if(this._isPlayerBoss && team.tech.isResearched(Tech.NINJA_CLOAK3))
    {
        if(team.mana < 10)
        {
            this.bossWhiffPenaltyFrames = BOSS_WHIFF_PENALTY_FRAMES;  // 20s
            return false;
        }
        team.mana -= 10;
    }

    return this.bossSpecialStealth(true, true);  // existing chain cloak call
}
```

### 12. `Ninja.as` — `getBossCloakCooldownFraction()`
```actionscript
public function getBossCloakCooldownFraction() : Number
{
    if(this.bossWhiffPenaltyFrames > 0)
        return this.bossWhiffPenaltyFrames / BOSS_WHIFF_PENALTY_FRAMES;
    return 0;
}
```

### 13. `Ninja.as` — `setActionInterface()` button swap
```actionscript
// Replace STEALTH with CLOAK_3 button for boss + CLOAK_III researched:
if(this.isBoss && team.tech.isResearched(Tech.NINJA_CLOAK3))
{
    a.setAction(0, 0, UnitCommand.NINJA_CLOAK3);
}
else if(team.tech.isResearched(Tech.CLOAK))
{
    a.setAction(0, 0, UnitCommand.STEALTH);
}
```

### 14. `NinjaAi.as` — Command handler for NINJA_CLOAK3
```actionscript
if(currentCommand.type == UnitCommand.NINJA_CLOAK3)
{
    Ninja(unit).bossSpecialStealth();
    restoreMove(game);
}
```

### 15. `NinjaAi.as` — `tryAutoCloak()`
No change needed — already calls `bossSpecialStealth()` for boss. The Cloak 3 mana deduction is inside that method.

## Summary of All Files Changed

| # | File | Change |
|---|------|--------|
| 1 | `Tech.as` | +`NINJA_CLOAK3 = -66` |
| 2 | `GoodTech.as` | Register tech with purple NinjaCloak icon |
| 3 | `BarracksBuilding.as` | Add research button |
| 4 | `CampaignGameScreen.as` | Add to tech allowed |
| 5 | XML game constants | Add `cloak3` tech node |
| 6 | `UnitCommand.as` | +`NINJA_CLOAK3 = 55` |
| 7 | `NinjaCloak3Command.as` | New command class (purple icon) |
| 8 | `CommandFactory.as` | Register command |
| 9 | `ActionInterface.as` | Register button + tooltip |
| 10 | `Ninja.as` | Mana costs in `bossSpecialStealth()` + `tryBossChainCloak()` |
| 11 | `Ninja.as` | +`getBossCloakCooldownFraction()` |
| 12 | `Ninja.as` | Swap STEALTH → CLOAK_3 in action bar |
| 13 | `NinjaAi.as` | +`NINJA_CLOAK3` command handler |
