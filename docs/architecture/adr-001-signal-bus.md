# ADR-001: Global Signal Bus (GameEvents Autoload)

**Status:** Accepted
**Date:** 2026-03-28
**Deciders:** Project lead + Claude

## Context

Road Rage Rodeo has 14 interconnected game systems (rider lifecycle, combat, weapons, nitro, race, camera/juice, system). These systems need to communicate without tight coupling.

## Decision

Use a single autoloaded Node (`GameEvents`) as a global signal bus. All cross-system communication goes through typed signals on this singleton.

- Signals are scaffolded for all 14 systems on day one (D-04)
- Naming convention: past-tense snake_case (e.g., `rider_knocked_out`, `weapon_picked_up`) (D-03)
- Typed parameters on every signal for editor autocomplete and static analysis
- Extends Node (not RefCounted) so it lives in the scene tree as an autoload

## Consequences

- **Pro:** Zero coupling between systems -- any system can emit/listen without importing others
- **Pro:** Single file to grep for all game events -- discoverability
- **Pro:** Typed parameters catch mismatches at parse time
- **Con:** All signals in one file -- could grow large (mitigated: 30 signals is manageable)
- **Con:** No namespacing -- relies on naming convention to avoid collisions

## Alternatives Considered

- **Per-system signal nodes:** More granular but harder to discover. Rejected for a game of this scale.
- **Direct method calls:** Tight coupling between systems. Rejected.
- **Custom event system:** Over-engineered for this project size. Rejected.
