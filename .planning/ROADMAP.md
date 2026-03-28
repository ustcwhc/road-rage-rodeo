# Roadmap: Road Rage Rodeo

## Overview

Build a 3D arcade combat racing game in Godot 4.6 for WebGL, delivering the crash-and-combat comedy experience across 9 phases. Foundation and pipeline verification come first to catch WebGL pitfalls early. Then motorcycle feel and camera, followed by health/weapons data layer, then combat and the signature crash-fly-remount cycle. AI riders and race management make the full loop playable. Track content fills out the world. HUD and juice make it feel amazing. Audio, UI polish, and browser compatibility ship it.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation & Pipeline** - Project scaffolding, WebGL export verification, input system, signal bus
- [ ] **Phase 2: Motorcycle & Camera** - Arcade motorcycle controls with state machine, chase camera with state-aware behavior
- [ ] **Phase 3: Health & Weapons** - HP system for all riders, weapon data resources, pickups, durability
- [ ] **Phase 4: Combat & Crash Cycle** - Melee combat while riding, ragdoll knockout, walk of shame, remount
- [ ] **Phase 5: AI Riders** - AI pathfinding, combat behavior, tactical personalities
- [ ] **Phase 6: Race Management** - Race lifecycle, position tracking, level progression, level select
- [ ] **Phase 7: Track Content** - 3+ distinct tracks with hazards, difficulty escalation, proper meshes
- [ ] **Phase 8: HUD & Juice** - Full HUD overlay, screen shake, slow-mo, hit flash, particles
- [ ] **Phase 9: Audio, Polish & Ship** - Sound effects, music, title screen, browser compatibility, 60fps

## Phase Details

### Phase 1: Foundation & Pipeline
**Goal**: A correctly configured Godot 4.6 project that verifiably runs in desktop browsers with all foundational systems in place
**Depends on**: Nothing (first phase)
**Requirements**: FOUND-01, FOUND-02, FOUND-03, FOUND-04, FOUND-05, FOUND-06
**Success Criteria** (what must be TRUE):
  1. Game loads and renders in Chrome/Firefox via WebGL with Compatibility renderer
  2. WASM export size is under 10 MB compressed and tracked
  3. Keyboard input (WASD + arrows) registers in-game with configurable bindings
  4. GameEvents autoload signal bus fires and receives test signals across scenes
  5. Physics interpolation is active and visual smoothness is confirmed at fixed timestep
**Plans**: 2 plans

Plans:
- [x] 01-01-PLAN.md — Godot project config, input actions, GameEvents signal bus, physics interpolation
- [x] 01-02-PLAN.md — Test track, GUT tests, WebGL export verification, WASM size baseline

### Phase 2: Motorcycle & Camera
**Goal**: A motorcycle that feels responsive and fun to ride, with a camera that intelligently follows the rider across all states
**Depends on**: Phase 1
**Requirements**: MOTO-01, MOTO-02, MOTO-03, MOTO-04, MOTO-05, CAM-01, CAM-02, CAM-03
**Success Criteria** (what must be TRUE):
  1. Player can accelerate, steer, and brake with responsive arcade feel on a test track
  2. Sense of speed is conveyed through FOV widening and camera effects at high speed
  3. Road boundaries are visible barriers, not invisible walls
  4. Rider state machine transitions through all 5 states (RIDING, FLYING, SLIDING, LYING, ON_FOOT) with correct behavior per state
  5. Camera follows rider across all states with distinct offsets and briefly tracks ragdoll flight before snapping back
**Plans**: TBD

Plans:
- [ ] 02-01: TBD
- [ ] 02-02: TBD

### Phase 3: Health & Weapons
**Goal**: Riders have health that drives knockout mechanics, and weapons exist as data-driven pickups with durability
**Depends on**: Phase 2
**Requirements**: HLTH-01, HLTH-02, HLTH-03, HLTH-04, WEAP-01, WEAP-02, WEAP-03, WEAP-04, WEAP-05
**Success Criteria** (what must be TRUE):
  1. All riders display visible HP bars that decrease on damage
  2. At zero HP, rider is knocked off bike and enters FLYING state
  3. Rider restores full HP on remount (comeback mechanic confirmed working)
  4. 6-8 weapons are defined as Resource files with unique damage, durability, range, and ragdoll properties
  5. Weapon pickups appear on track with tighter pickup radius, and weapons break after durability depletes (fists always available)
**Plans**: TBD

Plans:
- [ ] 03-01: TBD
- [ ] 03-02: TBD

### Phase 4: Combat & Crash Cycle
**Goal**: Players experience the signature crash-and-combat loop -- melee fighting while riding, spectacular ragdoll knockouts, and the funny walk of shame back to remount
**Depends on**: Phase 3
**Requirements**: CMBT-01, CMBT-02, CMBT-03, CMBT-04, CRSH-01, CRSH-02, CRSH-03, CRSH-04, CRSH-05, CRSH-06
**Success Criteria** (what must be TRUE):
  1. Player can swing weapon at adjacent riders while both are riding
  2. Visual attack indicators show when someone is attacking (combat discoverability fix)
  3. Each weapon produces a distinct ragdoll trajectory on knockout (bat = sky launch, chain = horizontal whip)
  4. Walk of shame is slow and funny with wobble animation and near-misses with traffic
  5. Bike marker is visible so rider knows where to run back to, and simultaneous ragdolls are capped at 2-3 with object pooling
**Plans**: TBD

Plans:
- [ ] 04-01: TBD
- [ ] 04-02: TBD

### Phase 5: AI Riders
**Goal**: AI opponents that feel like real rivals with tactical behavior, not mindless pylons
**Depends on**: Phase 4
**Requirements**: AI-01, AI-02, AI-03, AI-04, AI-05
**Success Criteria** (what must be TRUE):
  1. AI riders follow the track path, avoid obstacles, and maintain competitive speed
  2. AI riders target nearby riders, use weapons, and attack at appropriate range
  3. AI exhibits tactical behavior -- fleeing when low HP, being aggressive when armed
  4. Multiple AI personality types (aggressive/defensive/balanced) create distinct rival encounters
  5. 4-6 AI riders per race that race, fight, crash, and remount through the full gameplay loop
**Plans**: TBD

Plans:
- [ ] 05-01: TBD
- [ ] 05-02: TBD

### Phase 6: Race Management
**Goal**: A complete race experience from countdown to results, with level progression that unlocks new tracks
**Depends on**: Phase 5
**Requirements**: RACE-01, RACE-02, RACE-03, RACE-04, RACE-05
**Success Criteria** (what must be TRUE):
  1. Race starts with countdown, tracks positions during the race, and ends with a results screen
  2. Player sees their rank among all riders during the race (e.g., "3rd of 6")
  3. Beating a level unlocks the next level in sequence (1 through 6)
  4. Player can restart any level in under 2 seconds
  5. Completed levels are replayable via level select
**Plans**: TBD
**UI hint**: yes

Plans:
- [ ] 06-01: TBD
- [ ] 06-02: TBD

### Phase 7: Track Content
**Goal**: Multiple distinct tracks with unique themes, hazards, and escalating difficulty that give the game variety and replayability
**Depends on**: Phase 6
**Requirements**: TRCK-01, TRCK-02, TRCK-03, TRCK-04, TRCK-05
**Success Criteria** (what must be TRUE):
  1. At least 3 distinct point-to-point tracks exist with unique visual themes
  2. Each track has traffic and obstacles that create weaving/dodging gameplay
  3. All tracks use MeshInstance3D/MultiMeshInstance3D (zero CSG nodes in production)
  4. Difficulty escalates across levels -- faster speeds, tighter roads, more hazards
  5. Weapon and nitro pickup spawn points are placed strategically along each track
**Plans**: TBD

Plans:
- [ ] 07-01: TBD
- [ ] 07-02: TBD

### Phase 8: HUD & Juice
**Goal**: Players get constant visual feedback that makes every hit feel powerful and every knockout feel spectacular
**Depends on**: Phase 6
**Requirements**: HUD-01, HUD-02, HUD-03, HUD-04, HUD-05, JUICE-01, JUICE-02, JUICE-03, JUICE-04, JUICE-05, JUICE-06
**Success Criteria** (what must be TRUE):
  1. HUD displays player HP, nearby rival HP, current weapon with durability, speed, race position, and progress to finish
  2. Screen shakes on weapon hits with intensity varying by weapon type
  3. Knockout triggers slow-motion (0.3-0.5s, per-rider not global), hit flash on contact, and impact freeze on the knockout blow
  4. CPUParticles3D produce hit sparks, crash debris, and dust trails (no GPUParticles3D)
  5. Juice intensity is configurable via settings for accessibility
**Plans**: TBD
**UI hint**: yes

Plans:
- [ ] 08-01: TBD
- [ ] 08-02: TBD

### Phase 9: Audio, Polish & Ship
**Goal**: The game sounds as good as it looks, has proper menus, and ships as a browser-playable product at 60fps
**Depends on**: Phase 7, Phase 8
**Requirements**: AUD-01, AUD-02, AUD-03, AUD-04, AUD-05, PLSH-01, PLSH-02, PLSH-03, PLSH-04, PLSH-05
**Success Criteria** (what must be TRUE):
  1. Engine sound loop varies with speed, weapon impacts have distinct sounds per weapon, crashes have launch/impact sounds
  2. Background music plays during races with audio autoplay splash screen for browser compliance
  3. Title screen with game branding is the first thing players see
  4. Level select UI and race results screen are functional and polished
  5. Game runs at 60fps with 6 riders on screen, verified in Chrome, Firefox, and Edge (Safari best-effort)
**Plans**: TBD
**UI hint**: yes

Plans:
- [ ] 09-01: TBD
- [ ] 09-02: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation & Pipeline | 0/2 | Planned | - |
| 2. Motorcycle & Camera | 0/0 | Not started | - |
| 3. Health & Weapons | 0/0 | Not started | - |
| 4. Combat & Crash Cycle | 0/0 | Not started | - |
| 5. AI Riders | 0/0 | Not started | - |
| 6. Race Management | 0/0 | Not started | - |
| 7. Track Content | 0/0 | Not started | - |
| 8. HUD & Juice | 0/0 | Not started | - |
| 9. Audio, Polish & Ship | 0/0 | Not started | - |
