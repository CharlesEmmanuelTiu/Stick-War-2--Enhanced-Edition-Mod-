# Shadowrath Boss: Final Stand Shadow Clones

## Concept (Reference / Future Implementation)

When the Shadowrath boss enters Final Stand (HP ≤ 5% or statue destroyed), it spawns 2 identical clones. The boss and clones then fight to the death — no retreat, no escape.

## Implementation

### File: `Ninja.as`

#### 1. New fields (near other boss flags, ~line 85)

```actionscript
private var bossClonesSpawned:Boolean;  // one-time spawn flag
```

Initialize to `false` in `init()` and constructor.

#### 2. New method: `spawnBossClones()`

Called at the end of `enterBossFinalStand()`.

```actionscript
private function spawnBossClones() : void
{
    if(this.bossClonesSpawned) return;
    this.bossClonesSpawned = true;

    var game:StickWar = this.team.game;
    var clone:Ninja;
    var attackMove:AttackMoveCommand;
    var i:int;

    for(i = 0; i < 2; i++)
    {
        clone = Ninja(game.unitFactory.getUnit(Unit.U_NINJA));
        this.team.spawn(clone, game);

        // Position at boss location, staggered vertically
        clone.px = this.px;
        clone.py = Math.max(80, Math.min(game.map.height - 80, this.py + (i - 1) * 40));

        // Boss flags — gives boss AI (assassin movement, priority targeting, chain cloak, etc.)
        clone._isBoss = true;
        clone.isBossUnit = true;
        clone.hasDefaultLoadout = true;
        clone.isBossSummoned = true;

        // Copy boss's current low health
        clone.health = this.health;

        // Suppress retreat (shouldBossRetreat checks !_bossEmergencySortie)
        clone._bossEmergencySortie = true;
        clone.bossImmediateSpecialReady = false;  // don't grant free special

        // Suppress escape (shouldStartBossLostPhase checks campaignBossEscapeEnabled)
        clone.campaignBossEscapeEnabled = false;

        // Visual: stealth wall explosion
        game.projectileManager.initStealthWallExplosion(clone.px, clone.py, this.team);

        // Attack-move toward enemy statue
        attackMove = new AttackMoveCommand(game);
        attackMove.type = UnitCommand.ATTACK_MOVE;
        attackMove.goalX = this.team.enemyTeam.statue.px;
        attackMove.goalY = game.map.height / 2;
        attackMove.realX = attackMove.goalX;
        attackMove.realY = attackMove.goalY;
        clone.ai.setCommand(game, attackMove);
    }
}
```

#### 3. Modify `enterBossFinalStand()` (~line 747)

Add at the end, after existing state cleanup:

```actionscript
this.spawnBossClones();
```

## Clone Behaviors

| Behavior | Has it? | Why |
|----------|---------|-----|
| **Boss AI** (assassin movement, priority targeting, auto-cloak) | Yes | `_isBoss = true` gates all of these in NinjaAi |
| **Chain cloak** (re-stealth on hit) | Yes | Gated on `_isBoss` |
| **Whiff penalty** (20s no-cloak on miss) | Yes | Gated on `_isBoss` |
| **Boss skins** (Tribal Ninja, Knifed Pole, Katana) | Yes | Ninja applies boss skins per-frame when `_isBoss` |
| **Damage reduction** (1/1.75 = ~57% damage taken) | Yes | `damage()` checks `this.isBoss` |
| **Cautious retreat** (heal-seek at <50% HP) | No | Blocked by `_bossEmergencySortie = true` |
| **Lost phase** (escape at <5% HP) | No | Blocked by `campaignBossEscapeEnabled = false` |
| **Boss escape cloak** (90 frames untargetable) | No | Blocked by `campaignBossEscapeEnabled = false` |
| **Confuse immunity** | Yes | `isBossUnit = true` |

## Notes

- Clones are one-time spawn only (gated by `bossClonesSpawned` flag)
- Clones copy the boss's current HP at spawn time (likely very low, 5%)
- Since `_bossEmergencySortie = true`, `shouldBossRetreat()` returns false
- Since `campaignBossEscapeEnabled = false`, `shouldStartBossLostPhase()` returns false, and the Unit.as generic escape trigger also checks this flag
- The boss itself still uses its existing Final Stand logic (emergency sortie mode)

## Future removal context

When Cautious Phase, Final Stand, Lost Phase, and BossMovementLock are removed from the enemy boss, this clone ability would be the **replacement** for Final Stand — instead of entering a defensive final stand, the boss spawns clones and fights to the death alongside them.
