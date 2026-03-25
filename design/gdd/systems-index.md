# Systems Index: Road Rage Rodeo

> **Status**: Draft
> **Created**: 2026-03-23
> **Last Updated**: 2026-03-23
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

Road Rage Rodeo is a 3D combat racing game with 14 identified systems spanning
arcade motorcycle riding, melee weapon combat, ragdoll crash physics, and AI
opponents. The core loop — race, fight, crash, fly, run back, remount — requires
11 tightly coupled MVP systems to function. The game's pillars (Hilarious Chaos,
Visceral Impact, Easy to Play/Hard to Master) mean that physics feel, combat
feedback, and AI behavior are the highest-risk design areas.

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Input System | Core | MVP | Not Started | — | — |
| 2 | Track System | Core | MVP | Not Started | — | — |
| 3 | Health System | Gameplay | MVP | Not Started | — | — |
| 4 | Motorcycle Controller | Core | MVP | Not Started | — | Input System, Track System |
| 5 | Camera System | Core | MVP | Not Started | — | Motorcycle Controller |
| 6 | Weapon System | Gameplay | MVP | Not Started | — | Health System, Motorcycle Controller |
| 7 | Melee Combat | Gameplay | MVP | Not Started | — | Weapon System, Health System, Motorcycle Controller |
| 8 | Crash & Fly | Gameplay | MVP | Not Started | — | Health System, Motorcycle Controller, Camera System |
| 9 | AI Riders | Gameplay | MVP | Not Started | — | Motorcycle Controller, Melee Combat, Weapon System, Track System |
| 10 | Race Manager | Gameplay | MVP | Not Started | — | Motorcycle Controller, Track System, AI Riders |
| 11 | HUD | UI | MVP | Not Started | — | Health System, Weapon System, Race Manager |
| 12 | Level Progression | UI | Vertical Slice | Not Started | — | Race Manager, Track System |
| 13 | Juice & Feedback | Polish | Vertical Slice | Not Started | — | Melee Combat, Crash & Fly, Camera System |
| 14 | Audio System | Audio | Alpha | Not Started | — | Motorcycle Controller, Melee Combat, Crash & Fly |

---

## Categories

| Category | Description | Systems in This Game |
|----------|-------------|----------------------|
| **Core** | Foundation systems everything depends on | Input System, Track System, Motorcycle Controller, Camera System |
| **Gameplay** | The systems that make the game fun | Health System, Weapon System, Melee Combat, Crash & Fly, AI Riders, Race Manager |
| **UI** | Player-facing information displays | HUD, Level Progression |
| **Audio** | Sound and music systems | Audio System |
| **Polish** | Feedback, effects, and feel | Juice & Feedback |

---

## Priority Tiers

| Tier | Definition | Systems | Count |
|------|------------|---------|-------|
| **MVP** | Required for the core loop: race, fight, crash, remount | Input, Track, Health, Motorcycle Controller, Camera, Weapon, Melee Combat, Crash & Fly, AI Riders, Race Manager, HUD | 11 |
| **Vertical Slice** | Turns one race into a full 6-level game with satisfying feel | Level Progression, Juice & Feedback | 2 |
| **Alpha** | Complete audio experience | Audio System | 1 |

---

## Dependency Map

### Foundation Layer (no dependencies)

1. **Input System** — maps keyboard/mouse to game actions; 3 input contexts (riding, combat, on-foot)
2. **Track System** — world geometry, lanes, traffic/obstacles, start/finish lines

### Core Layer (depends on foundation)

3. **Motorcycle Controller** — depends on: Input System, Track System
4. **Health System** — standalone HP data system, foundational for combat and crash triggers
5. **Camera System** — depends on: Motorcycle Controller (target to follow)

### Feature Layer (depends on core)

6. **Weapon System** — depends on: Health System, Motorcycle Controller
7. **Melee Combat** — depends on: Weapon System, Health System, Motorcycle Controller
8. **Crash & Fly** — depends on: Health System, Motorcycle Controller, Camera System
9. **AI Riders** — depends on: Motorcycle Controller, Melee Combat, Weapon System, Track System
10. **Race Manager** — depends on: Motorcycle Controller, Track System, AI Riders

### Presentation Layer (depends on features)

11. **HUD** — depends on: Health System, Weapon System, Race Manager
12. **Level Progression** — depends on: Race Manager, Track System

### Polish Layer (depends on everything)

13. **Juice & Feedback** — depends on: Melee Combat, Crash & Fly, Camera System
14. **Audio System** — depends on: Motorcycle Controller, Melee Combat, Crash & Fly

---

## Recommended Design Order

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | Input System | MVP | Foundation | game-designer | S |
| 2 | Track System | MVP | Foundation | game-designer, level-designer | M |
| 3 | Health System | MVP | Core | systems-designer | S |
| 4 | Motorcycle Controller | MVP | Core | game-designer, gameplay-programmer | M |
| 5 | Camera System | MVP | Core | game-designer | S |
| 6 | Weapon System | MVP | Feature | systems-designer, economy-designer | M |
| 7 | Melee Combat | MVP | Feature | game-designer, systems-designer | M |
| 8 | Crash & Fly | MVP | Feature | game-designer, technical-artist | M |
| 9 | AI Riders | MVP | Feature | ai-programmer, game-designer | L |
| 10 | Race Manager | MVP | Feature | game-designer | S |
| 11 | HUD | MVP | Presentation | ux-designer, ui-programmer | S |
| 12 | Level Progression | V. Slice | Presentation | game-designer | S |
| 13 | Juice & Feedback | V. Slice | Polish | technical-artist, sound-designer | M |
| 14 | Audio System | Alpha | Polish | audio-director, sound-designer | S |

Effort: S = 1 session, M = 2-3 sessions, L = 4+ sessions

---

## Circular Dependencies

None found. The dependency graph is a clean DAG (directed acyclic graph).

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| AI Riders | Design + Technical | Most complex system — must race AND fight simultaneously. Simple state machine may produce boring or exploitable behavior. | Prototype with 2 states (race/attack) first. Add complexity only if needed. |
| Motorcycle Controller | Technical | Arcade motorcycle physics must feel good in browser. Too realistic = frustrating, too loose = boring. The entire game depends on this feeling right. | Prototype FIRST. Iterate on feel before building anything else on top. |
| Crash & Fly | Technical | Ragdoll physics in WebGL could hit performance limits. Multiple simultaneous ragdolls may tank framerate. | Low-poly ragdoll, limit simultaneous ragdolls to 2, profile early in browser. |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 14 |
| Design docs started | 0 |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| MVP systems designed | 0/11 |
| Vertical Slice systems designed | 0/2 |

---

## Next Steps

- [ ] Design MVP-tier systems first (use `/design-system [system-name]`)
- [ ] Start with Input System, Track System, and Health System (foundation + core)
- [ ] Prototype Motorcycle Controller early — it's the highest-risk bottleneck
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check pre-production` when MVP systems are designed
