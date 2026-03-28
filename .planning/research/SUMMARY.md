# Project Research Summary

**Project:** Road Rage Rodeo
**Domain:** 3D Arcade Combat Racing (Browser / WebGL)
**Researched:** 2026-03-28
**Confidence:** MEDIUM-HIGH

## Executive Summary

Road Rage Rodeo is a browser-based 3D arcade combat racing game inspired by Road Rash, built with Godot 4.6 targeting WebGL export. The research confirms that Godot's built-in stack (Jolt physics, Compatibility renderer, GDScript, GUT testing) covers all project needs with zero third-party addons required for the core game. The PS1/PS2 low-poly aesthetic is not just a style choice -- it is a strategic advantage that aligns perfectly with WebGL's rendering constraints under the Compatibility renderer, which lacks advanced features like SSAO, volumetric fog, and SSR that the game does not need anyway.

The recommended approach is a composition-based architecture using CharacterBody3D riders with a node-based state machine (5 states: RIDING, FLYING, SLIDING, LYING, ON_FOOT), a GameEvents autoload signal bus for cross-system decoupling, and Resource-based weapon definitions for data-driven tuning. The build order follows a strict dependency chain: Input/Track foundation, then motorcycle feel, then combat, then the crash-fly-remount cycle, then AI and race management, and finally presentation polish. The prototype validated the core loop but exposed three critical weaknesses: AI behavior (2/5), combat discoverability (2/5), and walk-of-shame pacing (2/5) -- these are the areas demanding the most design and implementation attention.

The key risks are WebGL-specific: ragdoll physics budget (Jolt on WebGL is single-threaded, capping simultaneous ragdolls at 2-3), WASM download size (40 MB uncompressed, needs Brotli to reach ~5 MB), and audio garbling tied to frame drops. All three risks are manageable with early profiling and budgeting, but they must be addressed in the first two phases -- not discovered at ship time. The Godot 4.4-4.6 knowledge gap (LLM training cutoff is 4.3) is an ongoing risk requiring constant cross-reference against the project's engine reference docs.

## Key Findings

### Recommended Stack

The entire game ships on Godot 4.6 built-ins with one addon (GUT 9.6.0 for testing). No third-party plugins, no GDExtension C++, no external physics engines. This minimizes compatibility risk across three versions of breaking changes (4.4, 4.5, 4.6) and eliminates WebGL addon compatibility concerns.

**Core technologies:**
- **Godot 4.6 + GDScript**: Game engine and primary language -- fast iteration, zero FFI overhead, `@abstract` and variadic args from 4.5+
- **Jolt Physics (built-in)**: 2-3x faster than GodotPhysics3D, default in 4.6. Use Generic6DOFJoint3D for ragdoll joints (HingeJoint3D `damp` is silently ignored by Jolt)
- **Compatibility Renderer**: The ONLY renderer that exports to WebGL. Forward+ and Mobile cannot export to web. Period.
- **SMAA 1x**: Anti-aliasing choice -- sharper than FXAA, avoids TAA ghosting which is fatal for racing camera movement
- **Single-threaded web export**: Avoids SharedArrayBuffer/CORS header requirements, works on itch.io and game portals without server configuration
- **GUT 9.6.0**: Testing framework with explicit Godot 4.6 support

**Critical version constraint:** Godot 4.6 with Jolt default. The `docs/engine-reference/godot/breaking-changes.md` file must be consulted before implementing any system.

### Expected Features

**Must have (table stakes):**
- Responsive arcade motorcycle controls (prototype scored 4/5 -- validated, needs WebGL tuning)
- Sense of speed (FOV widening, camera shake, environmental cues)
- Weapon pickups on track (3+ weapons minimum: fists, bat, and one more)
- Melee combat while riding (prototype scored 2/5 on discoverability -- needs visual affordances)
- Knockout ragdoll with weapon-specific trajectories (the signature moment)
- Walk-of-shame remount with full HP restore (comedy payoff + comeback mechanic)
- AI opponents with tactical behavior (highest risk system -- prototype scored 2/5)
- HUD: HP, weapon, speed, position, progress
- Audio: engine, impacts, crashes minimum
- 3 distinct point-to-point tracks (stretch goal: 6)
- Basic juice: screen shake on hit, slow-mo on knockout
- Instant restart (< 2 seconds)

**Should have (differentiators):**
- Exaggerated ragdoll comedy (different flight trajectories per weapon)
- Slow-mo knockout moments (0.3-0.5s sweet spot)
- Walk-of-shame environmental comedy (near-misses, stumbles, passing bikes)
- Screen shake + hit flash + impact freeze layering
- Weapon durability as tactical resource
- Position-aware item distribution (light rubber-banding)

**Defer (polish phase or v2):**
- Nitro/boost pickups
- Environmental knockoffs (collision with signs/traffic causes crash)
- Dynamic knockout camera (brief ragdoll follow)
- Per-level weapon roster evolution

**Explicitly NOT building (anti-features):**
- Persistent progression / unlocks / vehicle customization
- Multiplayer / networking
- Projectile weapons (melee-only preserves Road Rash tension)
- Lap-based racing (point-to-point only)
- Full replay system, procedural tracks, minimap, difficulty settings, mobile support, story/cutscenes

### Architecture Approach

The architecture follows Godot-idiomatic composition: scenes as reusable components, a signal bus (GameEvents autoload) for cross-system decoupling, and Resource files for all tunable data. The rider entity is the most complex component, using a node-based state machine where each of the 5 states is a separate Node with its own script. PlayerInput and AIBrain are interchangeable controller scripts that call the same public API on RiderBase, meaning the rider does not know whether a human or AI is driving it. The camera is a sibling node (not a child) that reads player state and lerps between per-state offsets.

**Major components:**
1. **RiderBase** (CharacterBody3D scene) -- movement, state machine, collision, HP, weapon holder. Core entity.
2. **GameEvents** (autoload) -- signal bus for all cross-system communication. HUD, Camera, Juice, Audio all listen here.
3. **RaceManager** (in-scene node) -- race lifecycle (countdown, tracking, finish), rider spawning, position ranking.
4. **WeaponSystem** (Resource-based) -- WeaponData .tres files define damage, durability, range, knockout force, flying style per weapon.
5. **Track** (standalone scene) -- level geometry, barriers, obstacles, pickup spawn points. Knows nothing about riders.
6. **JuiceManager + AudioManager** -- presentation layer that reacts to GameEvents. Never reads rider state directly.

**Key patterns:** Composition via exported PackedScene, Resource-based weapon definitions, state machine with explicit transition validation, detached camera with state-aware offsets. **Key anti-patterns to avoid:** god scripts, CSG in production, global `Engine.time_scale` for slow-mo, hardcoded tuning values, creating/freeing nodes per knockout (use object pooling).

### Critical Pitfalls

1. **Compatibility renderer from day one** -- Forward+ is the Godot default but cannot export to WebGL. Must set `gl_compatibility` in project settings at project creation. Discovering this late means visual overhaul.
2. **Web deployment verification in week 1** -- SharedArrayBuffer/CORS headers break deployment on itch.io and hosting platforms. Deploy a hello-world web build immediately to validate the pipeline.
3. **Never use VehicleBody3D** -- it is designed for 4-wheeled vehicles. Motorcycles fall over. Use CharacterBody3D with arcade physics (prototype validated this).
4. **Ragdoll physics budget on WebGL** -- cap simultaneous active ragdolls at 2-3, use 6-8 bones per ragdoll max, freeze ragdoll physics once LYING state begins. Profile on actual WebGL early.
5. **WASM size management** -- 40 MB uncompressed baseline. Enable Brotli compression, disable unused engine modules, keep assets small. Track export size at every milestone.

## Implications for Roadmap

Based on the dependency chain analysis from ARCHITECTURE.md, feature priorities from FEATURES.md, and phase-specific pitfall warnings from PITFALLS.md, here is the suggested phase structure:

### Phase 1: Foundation and Pipeline Verification
**Rationale:** Every other phase depends on a correctly configured project with verified WebGL export. Three of the top 5 pitfalls (renderer choice, web deployment, WASM size) must be caught here or they cascade into expensive late rework.
**Delivers:** Project scaffolding, autoloads (GameEvents, GameConfig, AudioManager), Compatibility renderer setup, verified WebGL export pipeline, input system, one straight test track with proper MeshInstance3D geometry and collision layers.
**Addresses:** Input System, Track System (basic), project configuration
**Avoids:** Pitfalls #1 (renderer), #2 (SharedArrayBuffer), #4 (WASM size baseline), #11 (physics interpolation)

### Phase 2: Core Vehicle and Camera
**Rationale:** "Does the motorcycle feel good?" is the single most important question. The prototype validated the concept (4/5) but production needs proper architecture (node-based state machine, resource config). Camera must follow the rider across all states.
**Delivers:** CharacterBody3D motorcycle with RIDING state, chase camera with state-aware offsets, physics interpolation, road boundary feedback (not invisible clamping).
**Addresses:** Motorcycle Controller, Camera System, basic Health System (can parallel)
**Avoids:** Pitfalls #3 (VehicleBody3D), #11 (jitter), #15 (invisible walls)

### Phase 3: Combat and Crash Cycle
**Rationale:** Combat is the core differentiator and the crash-fly-remount cycle is the signature mechanic. These must be built and profiled before AI (which depends on them). Ragdoll performance on WebGL is the biggest technical risk and must be validated here.
**Delivers:** Weapon system with Resource-based definitions, melee combat with attack areas, full 5-state crash cycle (FLYING, SLIDING, LYING, ON_FOOT), ragdoll physics with WebGL performance profiling, bike marker pooling, weapon pickups.
**Addresses:** Weapon System, Melee Combat, Crash & Fly system, Walk of Shame, Health System integration
**Avoids:** Pitfalls #5 (ragdoll budget), #10 (boring walk of shame), #14 (random durability)

### Phase 4: AI and Race Management
**Rationale:** AI is the integration point -- it depends on movement, combat, and crash cycle all working. It is also the highest-risk system (prototype scored 2/5). Race management needs AI riders to create a complete race. This is where the full core loop becomes playable.
**Delivers:** AIBrain with personality-based behavior (aggressive/defensive/balanced), priority-weighted decisions (race vs fight vs flee), rubber-banding, race lifecycle (countdown, position tracking, finish detection), level progression.
**Addresses:** AI Opponents, Race Manager, Level Progression
**Avoids:** Pitfall #6 (brain-dead or cheating AI)

### Phase 5: Presentation and Polish
**Rationale:** Presentation layers depend on stable gameplay systems. Juice and audio are the difference between "functional" and "fun" but should not be built until underlying systems are solid. This is also where combat discoverability (prototype 2/5) gets addressed through visual feedback.
**Delivers:** Full HUD, juice system (screen shake, hit flash, slow-mo manager with intensity setting), audio system (engine loop, impact SFX, music), visual combat affordances (attack indicators, range preview).
**Addresses:** HUD, Juice & Feedback, Audio System, visual polish
**Avoids:** Pitfalls #7 (juice causing nausea), #9 (audio garbling)

### Phase 6: Content and Ship
**Rationale:** With all systems working, the remaining work is content creation (tracks 2-6), final tuning, browser compatibility testing, and export optimization.
**Delivers:** Additional tracks (target 6, minimum 3), per-level weapon rosters, difficulty tuning across levels, Safari testing, final WASM size optimization, deployment to target platform.
**Addresses:** Multiple tracks, difficulty progression, browser compatibility, deployment

### Phase Ordering Rationale

- **Dependency-driven:** The critical path is Input -> Motorcycle -> Combat -> Crash Cycle -> AI -> Race Manager. Any delay on this chain delays everything downstream.
- **Risk-front-loaded:** WebGL pipeline verification (Phase 1), ragdoll performance profiling (Phase 3), and AI complexity (Phase 4) are the three highest risks -- all addressed in the first four phases.
- **Parallel opportunities:** Health System alongside Motorcycle Controller; Camera alongside or immediately after Motorcycle; HUD stubs as soon as GameEvents signals are defined; Audio prototyping with placeholders at any point.
- **Pitfall-aware:** Each phase explicitly addresses the pitfalls flagged for that development stage, preventing late-stage surprises.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 3 (Combat and Crash Cycle):** Ragdoll physics on WebGL with Jolt is not well-benchmarked in community reports. The exact performance budget is project-specific and must be profiled. May need `/gsd:research-phase` to investigate ragdoll LOD strategies.
- **Phase 4 (AI and Race Management):** AI behavior design for combat racing is a deep topic. The priority-weighted behavior system needs careful design. Consider `/gsd:research-phase` for AI architecture patterns specific to racing games.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Foundation):** Well-documented Godot project setup patterns. Engine reference docs cover all 4.6 specifics.
- **Phase 2 (Core Vehicle):** CharacterBody3D arcade movement is a well-established Godot pattern. Prototype already validated the approach.
- **Phase 5 (Presentation):** Juice, HUD, and audio patterns are extensively documented in both Godot docs and game design literature.
- **Phase 6 (Content and Ship):** Content creation and export optimization are standard workflows.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All technologies are Godot built-ins verified against local engine reference docs. Zero third-party dependencies for core game. |
| Features | MEDIUM-HIGH | Well-established genre with clear precedents (Road Rash, Mario Kart). Prototype validated core loop. AI quality is the main uncertainty. |
| Architecture | MEDIUM-HIGH | Godot composition patterns well-documented by official docs and GDQuest. Node-based state machine is standard. WebGL-specific constraints verified. |
| Pitfalls | MEDIUM-HIGH | Critical pitfalls verified against official Godot docs and community reports. Ragdoll WebGL performance budget is the main unknown (MEDIUM confidence). |

**Overall confidence:** MEDIUM-HIGH

### Gaps to Address

- **Jolt ragdoll performance on WebGL:** No reliable benchmarks exist for Jolt physics with multiple joint-constrained ragdolls in a WebGL context. Must profile empirically in Phase 3. Have a fallback plan: velocity-based arc (no joints) for AI ragdolls, full joint ragdoll only for player.
- **Godot 4.6 Compatibility renderer particle support:** GPUParticles3D is confirmed unavailable; CPUParticles3D is the replacement. But specific particle counts and performance envelopes on WebGL need validation.
- **Safari WebGL 2 support level:** Decision needed on whether Safari is a hard requirement or best-effort. This affects rendering decisions and testing investment.
- **Audio mixing quality on WebGL at low frame rates:** Severity of audio garbling depends on maintaining 50+ fps. If ragdoll scenes cause drops below this, audio quality degrades. These two issues are linked and must be co-profiled.
- **AI behavior tuning time:** The prototype scored AI at 2/5. Improving this to 4/5 requires significant iteration time that may exceed initial estimates. Budget buffer time in Phase 4.

## Sources

### Primary (HIGH confidence)
- Godot 4.6 release notes and local engine reference (`docs/engine-reference/godot/`) -- verified 2026-02-12
- Godot official documentation: rendering, web export, physics, audio, UI, scene organization
- Project prototype: `prototypes/combat-racing-core/REPORT.md` -- validated core loop with scored metrics
- Project GDD: `design/gdd/systems-index.md`, `design/gdd/motorcycle-controller.md` -- 14-system dependency DAG and 5-state machine design

### Secondary (MEDIUM confidence)
- GDQuest tutorials: state machines, event bus, collision layers -- authoritative community source
- Godot GitHub issues: SharedArrayBuffer (#85938, #93508), Compatibility renderer (#66458)
- Game design sources: Road Rash retrospective, rubber-banding design, screen shake research, track design principles

### Tertiary (LOW confidence)
- Jolt on WebGL performance estimates -- inferred from native benchmarks, no WebGL-specific data
- Safari WebGL 2 compatibility -- general community reports, not Godot 4.6 specific
- Audio garbling severity -- documented issue, but project-specific impact unknown until profiled

---
*Research completed: 2026-03-28*
*Ready for roadmap: yes*
