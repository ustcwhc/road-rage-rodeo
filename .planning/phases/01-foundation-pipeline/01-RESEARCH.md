# Phase 1: Foundation & Pipeline - Research

**Researched:** 2026-03-28
**Domain:** Godot 4.6 project setup, WebGL export pipeline, input system, signal bus, physics interpolation
**Confidence:** HIGH

## Summary

Phase 1 establishes the Godot 4.6 project from scratch -- no production code exists yet. The critical decisions are all renderer/export/physics configuration that cannot easily be changed later. The Compatibility renderer is mandatory for WebGL, physics interpolation must be enabled from day one, and the signal bus architecture sets the communication contract for all 9 phases.

The project-level research (STACK.md, ARCHITECTURE.md, PITFALLS.md) already covers the technology decisions comprehensively. This phase-level research focuses on the specific implementation details, gotchas, and verification steps needed to execute FOUND-01 through FOUND-06.

**Primary recommendation:** Configure the Godot project with Compatibility renderer, single-threaded web export, Jolt physics, SMAA, and physics interpolation. Build a minimal test track using MeshInstance3D (not CSG). Scaffold the full GameEvents signal bus. Verify the entire pipeline by exporting to WebGL and confirming it runs in Chrome/Firefox.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-04:** Scaffold the full GameEvents signal list on day one, even though most signals won't fire until later phases. Signals should cover: rider lifecycle, combat events, weapon events, race events, and system events.

### Claude's Discretion
- **D-01:** Use Godot-idiomatic feature folders. Each game system gets its own folder containing both scripts (.gd) and scenes (.tscn) together. Autoloads live in `game/core/`.
- **D-02:** Use prototype-validated bindings as defaults. WASD for movement, Space for attack, Shift for nitro, R for restart, Esc for pause. Use Godot's built-in InputMap system for rebinding.
- **D-03:** Claude picks naming convention for signals (past tense events recommended: `rider_knocked_out`, `weapon_picked_up`, etc.).
- **D-05:** Build whatever test track best validates the WebGL pipeline. Preference: avoid CSG if the effort is comparable, since research flagged CSG as a WebGL performance issue.

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FOUND-01 | Project uses Compatibility renderer from day one | project.godot `rendering/renderer/rendering_method = "gl_compatibility"` -- verified mandatory for WebGL. See Standard Stack > Renderer. |
| FOUND-02 | WebGL export pipeline verified -- game loads and runs in desktop browser | Single-threaded export template, no SharedArrayBuffer headers needed. Export to HTML5, test in Chrome/Firefox. See Architecture Patterns > Web Export. |
| FOUND-03 | WASM size tracked and kept under 10 MB with Brotli compression | Baseline Godot 4.6 WASM is ~40 MB uncompressed, ~5 MB Brotli. Minimal project should be well under 10 MB. Track with export size script. See Common Pitfalls > WASM Size. |
| FOUND-04 | Input system maps keyboard to game actions with configurable bindings | Use Godot InputMap in project.godot. Define actions: `move_forward`, `move_back`, `steer_left`, `steer_right`, `attack`, `nitro`, `restart`, `pause`. Map both WASD and arrow keys. See Architecture Patterns > Input. |
| FOUND-05 | GameEvents autoload signal bus established | Single autoload script with typed signals covering all 14 systems. Past-tense naming convention. See Architecture Patterns > Signal Bus. |
| FOUND-06 | Physics interpolation enabled to prevent visual jitter | `physics/common/physics_interpolation = true` in project.godot. 60 Hz physics tick. Camera in `_process()` not `_physics_process()`. See Common Pitfalls > Jitter. |
</phase_requirements>

## Standard Stack

### Core

| Library/Feature | Version | Purpose | Why Standard |
|-----------------|---------|---------|--------------|
| Godot Engine | 4.6.1 | Game engine | Project-pinned. Verified installed on this machine at `/Users/haocheng_mini/Downloads/Godot.app` |
| Compatibility Renderer | Built-in | WebGL 2.0 rendering | Only renderer that exports to web. Forward+ and Mobile cannot. Non-negotiable. |
| Jolt Physics | Built-in (4.6 default) | 3D physics | Default in 4.6. Better perf and stability than GodotPhysics3D. |
| SMAA 1x | Built-in (4.5+) | Anti-aliasing | Sharper than FXAA, no ghosting like TAA. Ideal for racing camera. |
| GDScript | 4.6 | Primary language | Native, fast iteration, `@abstract` and variadic args (4.5+). |

### Supporting

| Library/Feature | Version | Purpose | When to Use |
|-----------------|---------|---------|-------------|
| GUT | 9.6.0 | Unit testing | Install in Phase 1 for validation tests. Only addon in the project. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Compatibility | Forward+ | Forward+ looks better but CANNOT export to WebGL. No alternative. |
| SMAA | TAA | TAA ghosts on fast camera motion -- fatal for racing. |
| SMAA | FXAA | FXAA too blurry, loses low-poly edge definition. |
| Jolt | GodotPhysics3D | Slower, less stable. Jolt is already default. |

## Architecture Patterns

### Project Structure (from D-01)

```
game/                           # Godot project root (contains project.godot)
  core/                         # Autoloads
    game_events.gd              # Signal bus (FOUND-05)
    game_config.gd              # Future: tuning knobs
  track/                        # Track scenes and scripts
    test_track.tscn             # Phase 1 test track
    test_track.gd               # Track script
  rider/                        # (Phase 2+)
  weapons/                      # (Phase 3+)
  camera/                       # (Phase 2+)
  ui/                           # (Phase 8+)
  ai/                           # (Phase 5+)
  data/                         # Resource files (.tres)
  export_presets.cfg            # Web export configuration
  project.godot                 # Engine configuration
```

**Rationale for `game/` as project root:** The repository has other directories (design/, docs/, prototypes/, tools/) that are not part of the Godot project. Placing project.godot inside `game/` keeps the Godot project contained. The prototype uses `prototypes/combat-racing-core/` as its Godot root -- same pattern.

### Pattern 1: project.godot Configuration (FOUND-01, FOUND-06)

The project.godot file is the single source of truth for engine configuration. These settings must be correct from the first commit:

```ini
[application]
config/name="Road Rage Rodeo"
run/main_scene="res://core/main.tscn"
config/features=PackedStringArray("4.6", "GL Compatibility")

[autoload]
GameEvents="*res://core/game_events.gd"

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"

[input]
move_forward={ ... keys: W, Up }
move_back={ ... keys: S, Down }
steer_left={ ... keys: A, Left }
steer_right={ ... keys: D, Right }
attack={ ... keys: Space }
nitro={ ... keys: Shift }
restart={ ... keys: R }
pause={ ... keys: Escape }

[physics]
common/physics_ticks_per_second=60
common/physics_interpolation=true
common/max_physics_steps_per_frame=2

[rendering]
renderer/rendering_method="gl_compatibility"
anti_aliasing/quality/screen_space_aa=2
```

**Critical note on `config/features`:** The prototype has `"Forward Plus"` in its features list. The production project MUST use `"GL Compatibility"` instead. This is the most common Phase 1 mistake (Pitfall #1 from PITFALLS.md).

**SMAA value:** Screen space AA value `2` corresponds to SMAA in Godot 4.5+. Value `0` = disabled, `1` = FXAA.

### Pattern 2: GameEvents Signal Bus (FOUND-05, D-03, D-04)

Full signal scaffold covering all 14 systems from systems-index.md. Past-tense naming per D-03. Typed parameters for contract clarity.

```gdscript
# game/core/game_events.gd
extends Node
## Global event bus for cross-system communication.
## Signals are scaffolded for all 14 systems even if unused in early phases.
## This provides a stable contract for downstream development.

# -- Rider Lifecycle --
signal rider_spawned(rider: CharacterBody3D)
signal rider_damaged(rider: CharacterBody3D, amount: int, source: Node)
signal rider_knocked_out(rider: CharacterBody3D, launch_force: float, weapon_type: StringName)
signal rider_crashed_landed(rider: CharacterBody3D)
signal rider_stood_up(rider: CharacterBody3D)
signal rider_started_walking(rider: CharacterBody3D)
signal rider_remounted(rider: CharacterBody3D)

# -- Combat --
signal attack_started(attacker: CharacterBody3D)
signal attack_hit(attacker: CharacterBody3D, target: CharacterBody3D, damage: int)

# -- Weapons --
signal weapon_picked_up(rider: CharacterBody3D, weapon_name: StringName)
signal weapon_broken(rider: CharacterBody3D)
signal weapon_swung(rider: CharacterBody3D, weapon_name: StringName)

# -- Nitro --
signal nitro_picked_up(rider: CharacterBody3D)
signal nitro_activated(rider: CharacterBody3D)
signal nitro_expired(rider: CharacterBody3D)

# -- Race --
signal race_countdown_tick(seconds_left: int)
signal race_started()
signal race_finished(rankings: Array)
signal race_restarted()
signal rider_finished(rider: CharacterBody3D, position: int)
signal race_position_changed(rider: CharacterBody3D, new_position: int)

# -- Camera / Juice --
signal slow_mo_requested(duration: float, time_scale: float)
signal screen_shake_requested(intensity: float, duration: float)
signal hit_flash_requested()

# -- System --
signal level_loaded(level_index: int)
signal game_paused()
signal game_resumed()
```

**Why scaffold everything now:** Downstream phases (2-9) can immediately `connect()` to these signals without waiting for the emitting system to exist. This is the "contract-first" approach. Adding signals later is trivial but knowing the contract upfront prevents coupling.

### Pattern 3: Input Action Definition (FOUND-04, D-02)

Godot's InputMap stores actions in project.godot. Actions are defined with string names and bound to physical keys. Both WASD and arrow keys are mapped to the same actions for movement.

```gdscript
# These are defined in Project Settings > Input Map, stored in project.godot.
# Runtime rebinding uses InputMap.action_erase_events() + InputMap.action_add_event()

# Movement (dual-mapped: WASD + Arrows)
# move_forward: W, Up
# move_back: S, Down
# steer_left: A, Left
# steer_right: D, Right

# Actions
# attack: Space
# nitro: Left Shift
# restart: R
# pause: Escape
```

**Configurable bindings:** For runtime rebinding, use `InputMap.action_erase_events(action)` to clear existing bindings, then `InputMap.action_add_event(action, event)` to set new ones. Persist with `ConfigFile` to `user://keybindings.cfg`. This is standard Godot pattern -- no custom framework needed.

### Pattern 4: Test Track (D-05)

Build a minimal straight track using MeshInstance3D + ArrayMesh or imported .glb, NOT CSG. The test track validates:
1. Compatibility renderer renders 3D correctly
2. Physics collisions work (StaticBody3D road + barriers)
3. WebGL export includes the scene
4. Physics interpolation produces smooth motion

```gdscript
# Minimal test track structure:
# TestTrack (Node3D)
#   WorldEnvironment
#   DirectionalLight3D
#   Road (StaticBody3D)
#     MeshInstance3D (BoxMesh or imported road.glb)
#     CollisionShape3D (BoxShape3D)
#   BarrierLeft (StaticBody3D)
#     MeshInstance3D
#     CollisionShape3D
#   BarrierRight (StaticBody3D)
#     MeshInstance3D
#     CollisionShape3D
#   SpawnPoint (Marker3D)
```

**Why not CSG:** The prototype uses ~300+ CSG nodes for lane dividers alone. Each CSG node generates geometry at runtime and creates separate draw calls. MeshInstance3D with a pre-built mesh (even a simple BoxMesh resource) is dramatically cheaper. For repeated elements like lane dividers, use MultiMeshInstance3D.

**For Phase 1 simplicity:** Use Godot's built-in primitive meshes (BoxMesh, CylinderMesh) assigned to MeshInstance3D nodes. These are NOT CSG -- they are pre-computed mesh resources. This gives us proper geometry without needing to import .glb files in Phase 1.

### Pattern 5: Web Export Configuration (FOUND-02, FOUND-03)

```
# export_presets.cfg key settings:
# - Platform: Web
# - Thread Support: Disabled (single-threaded)
# - Texture Format: ETC2 + S3TC (covers desktop + mobile WebGL)
# - VRAM Compression: Enabled
```

**Export verification checklist:**
1. Export from Godot: Project > Export > Web
2. Serve locally: `python3 -m http.server 8000` from export directory
3. Open Chrome at `http://localhost:8000/index.html`
4. Verify: scene renders, no console errors, input responds
5. Check WASM file size: `ls -la *.wasm` (target: under 40 MB raw, under 10 MB compressed)

**No SharedArrayBuffer needed:** Single-threaded export (default since Godot 4.3) eliminates the CORS header requirement. This means the game works on itch.io, GitHub Pages, and other hosting without special server configuration.

### Anti-Patterns to Avoid

- **Forward+ in config/features:** The prototype has `"Forward Plus"`. Production MUST use `"GL Compatibility"`. This is the #1 pitfall.
- **CSG for any geometry:** Even "temporary" CSG tends to persist. Use MeshInstance3D with primitive mesh resources from day one.
- **Camera in `_physics_process()`:** Camera must update in `_process()` for smooth interpolated following. Physics process runs at fixed tick rate and causes stutter without interpolation.
- **Hardcoded input checks:** Never use `Input.is_key_pressed(KEY_W)`. Always use `Input.is_action_pressed("move_forward")` via InputMap actions.
- **`Engine.time_scale` for slow-mo without safeguards:** The prototype does this. Production needs a managed approach (Phase 8), but the foundation should not set this pattern.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Input rebinding | Custom key capture + storage system | Godot InputMap API + ConfigFile persistence | InputMap handles all edge cases (modifier keys, duplicates, gamepad). ConfigFile serializes to user:// automatically. |
| Anti-aliasing | Custom shader post-process | Built-in SMAA 1x setting | Engine-integrated, zero overhead to configure, optimized for each renderer. |
| Physics interpolation | Manual lerp between physics frames | `physics/common/physics_interpolation = true` | Engine handles the interpolation math, including edge cases like teleportation resets. |
| Signal bus | Custom event system with dictionaries | Godot signals on an autoload Node | Typed signals are faster, editor-integrated (autocomplete), and garbage-collected. |
| Web export serving | Custom build pipeline | Godot's built-in Export > Web + python3 http.server for testing | The export template handles WASM compilation, .pck packaging, and HTML wrapper generation. |

## Common Pitfalls

### Pitfall 1: Compatibility Renderer Not Set from First Commit

**What goes wrong:** Project starts with Forward+ (Godot default for new 3D projects). Everything looks fine in editor. On first web export attempt, visuals break or features are missing.
**Why it happens:** Godot defaults new projects to Forward+. The editor does not warn you.
**How to avoid:** Set `rendering/renderer/rendering_method = "gl_compatibility"` in the very first project.godot commit. Verify by checking the title bar -- it should say "Compatibility" not "Forward+".
**Warning signs:** Title bar shows "Forward+". Features like volumetric fog, SDFGI, or GPUParticles3D appear available in inspector.

### Pitfall 2: Physics Interpolation Not Verified

**What goes wrong:** Setting is enabled but interpolation is not actually working. Objects still jitter at variable frame rates.
**Why it happens:** Godot 4.5 rearchitected 3D interpolation (moved from RenderingServer to SceneTree). The API is the same but behavior may differ. Some node types may not interpolate correctly.
**How to avoid:** Create a test: move a MeshInstance3D in `_physics_process()` at high speed, lock physics to 30 Hz temporarily, verify visual smoothness at 60 fps display. If smooth = interpolation works. If stuttery = investigate.
**Warning signs:** Visible stutter when physics tick rate differs from display rate. Objects "teleporting" between positions.

### Pitfall 3: WASM Size Not Baselined

**What goes wrong:** Export size grows unnoticed through development. By Phase 5+, the WASM exceeds 10 MB compressed and it is unclear what caused the growth.
**How to avoid:** Record baseline WASM size after Phase 1 export. Track it at each phase milestone. Godot 4.6 base WASM should be ~5 MB compressed with Brotli for a minimal project.
**Warning signs:** WASM file grows > 1 MB between phases without corresponding feature addition.

### Pitfall 4: Input Actions Not Dual-Mapped

**What goes wrong:** WASD works but arrow keys don't (or vice versa). Requirement FOUND-04 specifies both.
**How to avoid:** Each movement action gets TWO key bindings in InputMap. Verify both in the test scene.

### Pitfall 5: GameEvents Autoload Path Wrong

**What goes wrong:** Autoload path in project.godot doesn't match file location. Game crashes on launch with "Cannot open file" error.
**How to avoid:** Use the exact path format: `GameEvents="*res://core/game_events.gd"`. The `*` prefix enables the autoload. Path must be relative to project root (game/).

### Pitfall 6: Prototype project.godot Copied Instead of Fresh Start

**What goes wrong:** Someone copies the prototype's project.godot as a starting point. It has `"Forward Plus"` in features, wrong window settings, no autoloads, no input actions.
**How to avoid:** Create project.godot from scratch or via Godot editor "New Project". Never copy from prototype. Reference the prototype for patterns, not configuration.

## Code Examples

### Minimal Main Scene for Pipeline Verification

```gdscript
# game/core/main.gd
extends Node3D
## Phase 1 pipeline verification scene.
## Tests: renderer, physics, input, signal bus, export.

func _ready() -> void:
    # Verify GameEvents autoload is accessible
    assert(GameEvents != null, "GameEvents autoload not found")

    # Emit a test signal to verify signal bus works
    GameEvents.race_countdown_tick.emit(3)
    print("Phase 1 pipeline verification: OK")

func _process(_delta: float) -> void:
    # Verify input actions are configured
    if Input.is_action_just_pressed("move_forward"):
        print("move_forward detected (W or Up)")
    if Input.is_action_just_pressed("attack"):
        print("attack detected (Space)")
```

### Signal Bus Test (Cross-Scene Verification)

```gdscript
# game/core/signal_test.gd (temporary, for FOUND-05 verification)
extends Node

func _ready() -> void:
    GameEvents.rider_knocked_out.connect(_on_knockout)
    GameEvents.weapon_picked_up.connect(_on_weapon)
    GameEvents.race_started.connect(_on_race_start)

func _on_knockout(rider: CharacterBody3D, force: float, weapon: StringName) -> void:
    print("Signal received: rider_knocked_out - force=%s weapon=%s" % [force, weapon])

func _on_weapon(rider: CharacterBody3D, name: StringName) -> void:
    print("Signal received: weapon_picked_up - %s" % name)

func _on_race_start() -> void:
    print("Signal received: race_started")
```

### Physics Interpolation Verification

```gdscript
# Temporary test: attach to a MeshInstance3D to verify interpolation
extends MeshInstance3D

var speed: float = 20.0

func _physics_process(delta: float) -> void:
    position.z += speed * delta
    # If interpolation works, this should appear smooth even at
    # mismatched physics/display rates
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| GodotPhysics3D default | Jolt Physics default | 4.6 (Jan 2026) | Better ragdoll perf. HingeJoint3D `damp` only works with GodotPhysics. |
| FXAA only | SMAA 1x available | 4.5 (Late 2025) | Sharper AA for low-poly. Use `screen_space_aa=2`. |
| Physics interpolation via RenderingServer | Physics interpolation via SceneTree | 4.5 (Late 2025) | Same API, different internals. Verify behavior. |
| No abstract enforcement | `@abstract` decorator | 4.5 (Late 2025) | Use for BaseRiderState interface. |
| SharedArrayBuffer required for web | Single-threaded export default | 4.3 (In training data) | No CORS headers needed. Simplifies deployment. |
| Glow after tonemapping | Glow before tonemapping | 4.6 (Jan 2026) | Glow intensity may need adjustment if using WorldEnvironment glow. |

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Godot Engine | All | Yes | 4.6.1.stable | Move from Downloads to /Applications |
| Python 3 | Local web server for testing | Yes | 3.14.3 | Node http-server also works |
| Chrome/Firefox | WebGL verification | Yes (macOS) | System browsers | -- |
| GUT addon | Test framework | Not yet installed | 9.6.0 target | Install via Asset Library in Phase 1 |

**Missing dependencies with no fallback:**
- None -- all required tools are available.

**Missing dependencies with fallback:**
- GUT 9.6.0 not yet installed -- install during Phase 1 setup via Godot Asset Library or git clone into `game/addons/gut/`.

**Note on Godot location:** Godot is in `~/Downloads/Godot.app` which is non-standard. It works but may be accidentally deleted. Recommend moving to `/Applications/` or `/usr/local/bin/` for stability, but this is not blocking.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | GUT 9.6.0 (Godot Unit Test) |
| Config file | `game/.gutconfig.json` (Wave 0 -- must create) |
| Quick run command | `godot -s addons/gut/gut_cmdln.gd -d --path game/` |
| Full suite command | `godot -s addons/gut/gut_cmdln.gd -d --path game/ -gexit` |

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FOUND-01 | Compatibility renderer is set | unit (read project.godot) | `godot --path game/ -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_foundation.gd::test_renderer_is_compatibility -gexit` | No -- Wave 0 |
| FOUND-02 | WebGL export loads in browser | manual + smoke | Export then open in browser -- cannot fully automate | N/A |
| FOUND-03 | WASM under 10 MB compressed | smoke (file size check) | `ls -la game/export/web/*.wasm` + size assertion script | No -- Wave 0 |
| FOUND-04 | Input actions configured with dual bindings | unit | `godot --path game/ -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_foundation.gd::test_input_actions -gexit` | No -- Wave 0 |
| FOUND-05 | GameEvents signals fire and receive | unit | `godot --path game/ -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_game_events.gd -gexit` | No -- Wave 0 |
| FOUND-06 | Physics interpolation enabled | unit (read project setting) | `godot --path game/ -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_foundation.gd::test_physics_interpolation -gexit` | No -- Wave 0 |

### Sampling Rate

- **Per task commit:** Quick run on affected test file
- **Per wave merge:** Full GUT suite
- **Phase gate:** Full suite green + manual WebGL browser test before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `game/addons/gut/` -- GUT 9.6.0 installation
- [ ] `game/.gutconfig.json` -- GUT configuration (test directory, log level)
- [ ] `game/tests/test_foundation.gd` -- covers FOUND-01, FOUND-04, FOUND-06
- [ ] `game/tests/test_game_events.gd` -- covers FOUND-05

## Open Questions

1. **Godot CLI path**
   - What we know: Godot 4.6.1 is at `~/Downloads/Godot.app/Contents/MacOS/Godot`
   - What's unclear: Whether the user has a `godot` alias or PATH entry set up for CLI usage
   - Recommendation: Create a local alias or use the full path in scripts. The planner should include a setup step.

2. **GUT installation method**
   - What we know: GUT 9.6.0 supports Godot 4.6 and can be installed via Asset Library or git
   - What's unclear: Whether Asset Library access works from CLI, or if manual download is needed
   - Recommendation: Clone from GitHub (`git clone https://github.com/bitwes/Gut.git`) and copy `addons/gut/` into the project. More reliable than Asset Library for CI/CLI workflows.

3. **SMAA project setting value**
   - What we know: SMAA was added in 4.5 as a screen_space_aa option
   - What's unclear: Exact enum integer for SMAA in project.godot (likely `2` but not 100% confirmed for 4.6)
   - Recommendation: Set via Godot editor UI to ensure correct value, then verify in project.godot text. LOW confidence on raw integer -- verify at implementation time.

## Sources

### Primary (HIGH confidence)
- Local engine reference: `docs/engine-reference/godot/VERSION.md` -- Godot 4.6 version info
- Local engine reference: `docs/engine-reference/godot/breaking-changes.md` -- 4.4-4.6 breaking changes
- Local engine reference: `docs/engine-reference/godot/current-best-practices.md` -- 4.6 patterns
- Project research: `.planning/research/STACK.md` -- Full technology stack decisions
- Project research: `.planning/research/ARCHITECTURE.md` -- Scene hierarchy, signal bus, physics layers
- Project research: `.planning/research/PITFALLS.md` -- WebGL deployment gotchas
- Prototype reference: `prototypes/combat-racing-core/project.godot` -- Config to NOT copy (Forward+ wrong)
- Prototype reference: `prototypes/combat-racing-core/main.gd` -- Input and scene patterns to reference
- [GUT 9.6.0 documentation](https://gut.readthedocs.io/en/v9.6.0/) -- Godot 4.6 test framework
- [GUT command line docs](https://gut.readthedocs.io/en/latest/Command-Line.html) -- CLI test execution
- [Godot web export docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) -- Single-threaded export, renderer requirements

### Secondary (MEDIUM confidence)
- [Godot physics interpolation quick start](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_quick_start_guide.html) -- Interpolation setup steps
- [Godot InputMap API](https://docs.godotengine.org/en/stable/classes/class_inputmap.html) -- Runtime rebinding
- [Godot renderers comparison](https://docs.godotengine.org/en/4.4/tutorials/rendering/renderers.html) -- Compatibility vs Forward+ feature matrix
- [Physics interpolation default proposal](https://github.com/godotengine/godot-proposals/issues/12950) -- Confirms not yet default in 4.6

### Tertiary (LOW confidence)
- SMAA enum value (integer 2) -- inferred from FXAA=1 pattern, needs verification in editor

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all decisions verified against local engine docs and project research
- Architecture: HIGH -- patterns from ARCHITECTURE.md + prototype validation + official Godot conventions
- Pitfalls: HIGH -- documented in PITFALLS.md with official sources
- Validation (GUT setup): MEDIUM -- GUT 9.6.0 confirmed for Godot 4.6, but CLI invocation needs testing on this machine

**Research date:** 2026-03-28
**Valid until:** 2026-04-28 (stable -- Godot 4.6 is pinned, no upstream changes expected)
