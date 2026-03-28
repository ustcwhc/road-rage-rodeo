# Road Rage Rodeo

## What This Is

A 3D arcade combat racing game where players ride motorcycles on increasingly dangerous highways, smash rival bikers off their bikes with ridiculous weapons, and watch them ragdoll through the air before they shamefully run back to remount. Built with Godot 4.6 for desktop browsers (WebGL). Single-player vs AI, 15-20 minute full playthrough across 6 levels.

## Core Value

The crash-and-combat experience must be hilarious and visceral. Every knockout must produce a spectacular, funny ragdoll flight, and every weapon hit must feel powerful and satisfying. If the crashes are comedy gold and the hits feel amazing, the game works — everything else serves that.

## Requirements

### Validated

- ✓ Core loop is fun — race, fight, crash, remount cycle validated via prototype (PROCEED verdict)
- ✓ 5-state rider machine works — Riding/Flying/Sliding/Lying/On Foot transitions feel natural
- ✓ Arcade motorcycle controls feel responsive (4/5 in playtest)
- ✓ Weapon-based ragdoll variety adds comedy (bat = sky launch, fists = moderate arc)

### Active

- [ ] 6 distinct tracks with escalating difficulty and hazards
- [ ] 6-8 weapons with unique damage, durability, and ragdoll effects
- [ ] Visceral combat feel — screen shake, slow-mo, hit flash, sound effects
- [ ] Hilarious crash comedy — exaggerated ragdoll flights, funny walk of shame
- [ ] Smart AI riders — tactical behavior (flee when hurt, aggressive when armed)
- [ ] Full audio — engine sounds, weapon impacts, crash SFX, music per level
- [ ] Level progression — beat levels 1-6 in order
- [ ] HUD — HP, weapon, speed, position, progress
- [ ] Camera system — third-person chase cam
- [ ] Polish — particle effects, juice, title screen, difficulty tuning
- [ ] WebGL export — playable in desktop browsers at 60fps

### Out of Scope

- Multiplayer/networking — single-player only, complexity not justified for scope
- Persistent progression/unlocks — no skill trees, garage, or upgrades; pick-up-and-play
- Mobile support — desktop browser only
- Procedural track generation — hand-crafted levels for quality control
- Story/narrative — pure arcade action
- Monetization — free game
- Native desktop builds — WebGL is the target platform

## Context

- **Prototype validated**: `prototypes/combat-racing-core/` confirmed core loop is fun. Key findings: combat needs better discoverability (scored 2/5), walk of shame needs to be slower/funnier (2/5), AI needs tactical behavior (2/5). All three will be addressed in production.
- **Engine pinned**: Godot 4.6 with GDScript, Jolt physics (default). Engine reference docs in `docs/engine-reference/godot/`.
- **Systems designed**: 14 systems mapped in `design/gdd/systems-index.md` with dependency DAG. 2 of 14 GDDs partially started (Motorcycle Controller ~30%, Input System ~25%).
- **Art style**: Low-poly gritty (PS1/PS2-era aesthetic with modern lighting). Achievable solo, good WebGL performance.
- **Design pillars**: Hilarious Chaos, Visceral Impact, Easy to Play/Hard to Master.

## Constraints

- **Timeline**: ~1 month (target completion late April 2026)
- **Engine**: Godot 4.6, GDScript primary, C++ via GDExtension for performance-critical paths
- **Platform**: Desktop browser via WebGL — must hit 60fps with 4-6 riders + ragdoll physics
- **Art pipeline**: Low-poly 3D, CSG primitives acceptable for early milestones, proper meshes for final
- **Solo developer**: All design, code, art, and audio done through Claude Code agent architecture

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Godot 4.6 over Unity/Unreal | Best WebGL export, GDScript for fast iteration, Jolt physics default, repo already configured | — Pending |
| Jolt physics for ragdoll | Godot 4.6 default, good performance, adequate for arcade ragdoll | — Pending |
| Low-poly art style | Achievable solo, good WebGL perf, distinct visual identity | — Pending |
| Single-player only | Networking adds massive complexity for no core value gain | ✓ Good |
| Prototype code is throwaway | Prototype validated concept but code is not production quality; rewrite to standards | ✓ Good |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-28 after initialization*
