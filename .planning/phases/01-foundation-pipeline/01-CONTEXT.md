# Phase 1: Foundation & Pipeline - Context

**Gathered:** 2026-03-28
**Status:** Ready for planning

<domain>
## Phase Boundary

Set up a correctly configured Godot 4.6 project that verifiably runs in desktop browsers (WebGL) with all foundational systems in place: Compatibility renderer, input system, GameEvents signal bus, physics interpolation, and a test track to validate the pipeline.

</domain>

<decisions>
## Implementation Decisions

### Project Structure
- **D-01:** Claude's Discretion — Use Godot-idiomatic feature folders. Each game system gets its own folder containing both scripts (.gd) and scenes (.tscn) together. Autoloads live in `game/core/`. This is standard Godot convention and keeps related files co-located.
  ```
  game/core/          → autoloads (game_events.gd, game_config.gd)
  game/rider/         → rider scenes, scripts, states/
  game/weapons/       → weapon data resources, pickup scenes
  game/track/         → track scenes, obstacles, barriers
  game/camera/        → camera scripts
  game/ui/            → HUD, menus
  game/ai/            → AI brain, behaviors
  ```

### Input Mapping
- **D-02:** Claude's Discretion — Use prototype-validated bindings as defaults. WASD for movement, Space for attack, Shift for nitro, R for restart, Esc for pause. Use Godot's built-in InputMap system for rebinding — no custom input framework needed. Support both WASD and arrow keys for movement.

### Signal Bus Design
- **D-03:** Claude's Discretion — Claude picks naming convention for signals (past tense events recommended by research: `rider_knocked_out`, `weapon_picked_up`, etc.).
- **D-04:** Scaffold the full GameEvents signal list on day one, even though most signals won't fire until later phases. This gives downstream phases (2-9) a contract to code against. Signals should cover: rider lifecycle, combat events, weapon events, race events, and system events.

### Test Track
- **D-05:** Claude's Discretion — Build whatever test track best validates the WebGL pipeline and provides a foundation for Phase 2 motorcycle testing. Preference: avoid CSG if the effort is comparable, since research flagged CSG as a WebGL performance issue.

### Claude's Discretion
The user gave broad latitude on all technical decisions for this phase. Claude should make opinionated choices based on:
- Research findings in `.planning/research/STACK.md` (Compatibility renderer, Jolt, SMAA, etc.)
- Research findings in `.planning/research/ARCHITECTURE.md` (scene hierarchy, patterns)
- Research findings in `.planning/research/PITFALLS.md` (WebGL gotchas to avoid)
- Prototype patterns worth preserving from `prototypes/combat-racing-core/`

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Engine Configuration
- `docs/engine-reference/godot/VERSION.md` — Godot 4.6 version info, knowledge gap warning
- `docs/engine-reference/godot/breaking-changes.md` — 4.4-4.6 breaking changes that affect setup
- `docs/engine-reference/godot/current-best-practices.md` — Godot 4.6 patterns and conventions

### Research (Critical for Phase 1)
- `.planning/research/STACK.md` — Full technology stack: Compatibility renderer, Jolt, SMAA, audio, WebGL export config
- `.planning/research/ARCHITECTURE.md` — Scene hierarchy, autoload patterns, physics layers, signal bus design
- `.planning/research/PITFALLS.md` — WebGL deployment gotchas, renderer choice, WASM size, SharedArrayBuffer

### Project Design
- `.planning/PROJECT.md` — Core value, constraints, key decisions
- `.planning/REQUIREMENTS.md` — FOUND-01 through FOUND-06 (this phase's requirements)
- `design/gdd/systems-index.md` — 14 systems with dependency DAG (informs signal bus scaffolding)
- `design/gdd/game-concept.md` — Game pillars and technical considerations

### Prototype Reference
- `prototypes/combat-racing-core/project.godot` — Prototype's Godot project config (reference, don't copy)
- `prototypes/combat-racing-core/main.gd` — Prototype patterns worth preserving
- `prototypes/combat-racing-core/REPORT.md` — Playtest findings informing input mapping

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- No production code exists yet (`src/` is empty)
- Prototype has 2 GDScript files (`main.gd`, `rider.gd`) — reference for patterns, don't copy code

### Established Patterns
- None — this is the first production phase. Patterns established here become the project standard.

### Integration Points
- This phase creates the foundation ALL other phases build on: project config, autoloads, input actions, signal bus
- Phase 2 (Motorcycle & Camera) is the immediate downstream consumer

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches. User wants Claude to make opinionated technical decisions grounded in the research findings.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-foundation-pipeline*
*Context gathered: 2026-03-28*
