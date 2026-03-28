# Architecture Patterns

**Domain:** 3D Arcade Combat Racing (Godot 4.6, WebGL target)
**Researched:** 2026-03-28
**Confidence:** MEDIUM-HIGH (Godot patterns well-documented; WebGL Compatibility renderer constraints verified via official docs; specific 4.6 patterns partially verified)

---

## Recommended Architecture

### High-Level Overview

```
Main (Node3D) ──── "The World"
├── WorldEnvironment
├── DirectionalLight3D
├── Track (Node3D) ──── "Level Geometry"
│   ├── RoadSurface (StaticBody3D)
│   ├── Barriers (StaticBody3D)
│   ├── Obstacles[] (StaticBody3D / Area3D)
│   ├── PickupSpawner (Node3D)
│   │   └── WeaponPickup[] (Area3D)
│   └── FinishLine (Area3D)
├── Riders (Node3D) ──── "All Rider Entities"
│   ├── PlayerRider (CharacterBody3D)
│   └── AIRider[] (CharacterBody3D)
├── Camera (Camera3D) ──── "Detached from rider, follows via script"
├── HUD (CanvasLayer)
│   ├── HPBar (Control)
│   ├── WeaponDisplay (Control)
│   ├── Speedometer (Control)
│   ├── PositionDisplay (Control)
│   └── ProgressBar (Control)
└── RaceManager (Node) ──── "Orchestrates race state"
```

### Design Principles

1. **Composition over inheritance.** Riders share a base scene with swappable behavior scripts (PlayerInput vs AIBrain), not deep class hierarchies. Godot's scene instancing is the composition mechanism.

2. **Camera is a sibling, not a child.** The camera must follow the player across state transitions (RIDING through ON_FOOT). Parenting it to the rider node causes issues when the rider's visual transforms change during ragdoll/lying states. Keep it as a sibling that reads the player's position.

3. **Autoload event bus for cross-system communication.** Systems like HUD, Camera, Juice, and Audio need to react to events (knockouts, weapon pickups, race state changes) without tight coupling. A single `GameEvents` autoload script with signals is the standard Godot pattern for this.

4. **Scene-per-track, shared rider scenes.** Each track is a standalone scene loaded by the level progression system. Rider scenes are instanced into the track at runtime. This keeps track authoring independent of rider logic.

5. **Compatibility renderer from day one.** WebGL export requires the Compatibility rendering method (OpenGL ES 3.0 / WebGL 2.0). Forward+ and Mobile renderers are NOT available for web export. Every visual decision must be made within Compatibility renderer constraints.

---

## Component Boundaries

| Component | Responsibility | Owns | Communicates With |
|-----------|---------------|------|-------------------|
| **RiderBase** (scene) | Movement, state machine, collision shape, visual mesh | Position, velocity, HP, weapon, rider state | GameEvents (emits: knocked_out, remounted, damaged), Physics engine |
| **PlayerInput** (script/node) | Translates keyboard input to rider actions | Input bindings, input context (riding/on-foot) | RiderBase (calls movement/attack methods) |
| **AIBrain** (script/node) | Decides AI rider actions per frame | AI state, target selection, timers | RiderBase (calls same methods as PlayerInput) |
| **Track** (scene) | Level geometry, road boundaries, obstacle placement, pickup spawn points | Road mesh, barriers, obstacles, spawn positions | PickupSpawner, FinishLine (via signals) |
| **PickupSpawner** (node) | Manages weapon/nitro pickup lifecycle | Pickup instances, respawn timers | Riders (via Area3D overlap detection) |
| **WeaponSystem** (resource/script) | Weapon data, damage calc, durability tracking | Weapon definitions (Resource files) | RiderBase (provides weapon stats), GameEvents (emits: weapon_picked_up, weapon_broken) |
| **CrashSystem** (integrated in RiderBase) | Knockout launch, flight physics, sliding, lying, remount | Launch vectors, lying timers, bike marker | GameEvents (emits: crash_started, crash_landed), Camera (for state-aware following) |
| **Camera** (node + script) | Third-person chase cam with state-aware behavior | FOV, offset, smoothing params | Reads player position/state, listens to GameEvents for slow-mo triggers |
| **RaceManager** (node) | Race lifecycle: countdown, in-progress, finished | Race state, rider positions, rankings | GameEvents (emits: race_started, race_finished), Riders (reads positions) |
| **HUD** (CanvasLayer) | All player-facing UI | UI nodes | Listens to GameEvents only; never reads rider state directly |
| **JuiceManager** (node) | Screen shake, hit flash, slow-mo, particles | Effect timers, tween references | Listens to GameEvents (knockout, hit, weapon_pickup) |
| **AudioManager** (autoload or node) | Engine sounds, impact SFX, music | AudioStreamPlayer nodes, music bus | Listens to GameEvents for one-shots; reads player speed for engine loop |

### Boundary Rules

- **HUD never imports rider scripts.** It connects to `GameEvents` signals only. This means rider internals can change without touching UI code.
- **AIBrain and PlayerInput share zero code.** They both call the same public API on RiderBase (`accelerate()`, `steer()`, `attack()`, `brake()`). The rider does not know or care who is driving it.
- **Track scenes know nothing about riders.** Riders are instanced into tracks by RaceManager at runtime. Track scenes define spawn points (Marker3D nodes), not rider configurations.
- **WeaponSystem is data-driven.** Weapon definitions are Godot Resource files (.tres), not hardcoded constants. This enables tuning without code changes.

---

## Data Flow

### Frame-by-Frame (during RIDING state)

```
Input/AI Decision
       │
       ▼
  RiderBase._physics_process()
       │
       ├── Apply acceleration/steering to velocity
       ├── Apply gravity
       ├── move_and_slide()
       ├── Clamp to road boundaries
       ├── Check weapon attack (if triggered)
       │     └── Find target in range → target.take_damage()
       │           └── If HP <= 0 → _start_flying() → emit GameEvents.rider_knocked_out
       │
       ▼
  GameEvents.rider_knocked_out signal propagates to:
       ├── Camera → switch to wide knockout offset
       ├── JuiceManager → trigger slow-mo, screen shake
       ├── HUD → flash damage indicator
       ├── AudioManager → play crash SFX
       └── RaceManager → update rankings
```

### Knockout-to-Remount Cycle

```
RIDING ──(HP<=0)──► FLYING ──(hit ground)──► SLIDING ──(speed<0.5)──► LYING ──(timer)──► ON_FOOT ──(near bike)──► RIDING
   │                    │                        │                        │                    │                      │
   │                    │                        │                        │                    │                      │
   emit:             emit:                    emit:                   (internal)             emit:                 emit:
   knocked_out       (physics                 crash_landed                                  rider_walking         remounted
                     driven,                                                                                     (HP restored)
                     no signals)
```

### Pickup Collection

```
PickupSpawner
   │
   ├── Area3D.body_entered(rider) ──► rider.pickup_weapon(weapon_resource)
   │                                      │
   │                                      └── emit GameEvents.weapon_picked_up(rider, weapon_type)
   │                                              │
   │                                              ├── HUD → update weapon display
   │                                              └── AudioManager → play pickup SFX
   │
   └── Start respawn timer → re-enable pickup after delay
```

### Race Lifecycle

```
RaceManager
   │
   ├── _ready() → instance riders at spawn points
   ├── Start countdown → emit GameEvents.race_countdown(seconds)
   ├── Race start → emit GameEvents.race_started → enable rider input
   ├── Per-frame → track rider Z positions → compute rankings
   ├── Any rider crosses finish → emit GameEvents.race_finished(rankings)
   └── Level Progression → load next track or show results
```

---

## Signal Architecture (GameEvents Autoload)

Use a single autoload script as the event bus. This is the standard Godot pattern for decoupled cross-system communication.

```gdscript
# src/core/game_events.gd
extends Node

# -- Combat --
signal rider_damaged(rider: CharacterBody3D, amount: int, source: Node)
signal rider_knocked_out(rider: CharacterBody3D, knockout_force: float, weapon_type: StringName)
signal rider_remounted(rider: CharacterBody3D)

# -- Weapons --
signal weapon_picked_up(rider: CharacterBody3D, weapon_name: StringName)
signal weapon_broken(rider: CharacterBody3D)
signal nitro_picked_up(rider: CharacterBody3D)

# -- Race --
signal race_countdown(seconds_left: int)
signal race_started()
signal race_finished(rankings: Array)
signal race_position_changed(rider: CharacterBody3D, new_position: int)

# -- Camera/Juice --
signal slow_mo_requested(duration: float, time_scale: float)
signal screen_shake_requested(intensity: float, duration: float)

# -- Crash Cycle --
signal crash_started(rider: CharacterBody3D)
signal crash_landed(rider: CharacterBody3D)
signal rider_standing_up(rider: CharacterBody3D)
signal rider_walking_to_bike(rider: CharacterBody3D)
```

### When to Use Signals vs Direct Calls

| Pattern | When | Example |
|---------|------|---------|
| **Direct method call** | Parent configuring child, or known 1:1 relationship | `rider.accelerate(delta)`, `rider.take_damage(amount)` |
| **GameEvents signal** | Cross-system reactions, 1:many broadcast | Knockout triggers camera + HUD + audio + juice |
| **Local signal** | Component-to-parent within a scene | Rider scene internal: collision detected |
| **Groups** | Broadcast to all entities of a type | `get_tree().get_nodes_in_group("riders")` for proximity checks |

---

## Rider Scene Architecture (Detailed)

The rider is the most complex entity. Here is the recommended scene structure:

```
RiderBase (CharacterBody3D)
├── CollisionShape3D (CapsuleShape3D — upright, never rotates)
├── BikeMesh (Node3D) ──── visual only, hidden during knockout
│   ├── Frame (MeshInstance3D)
│   ├── FrontWheel (MeshInstance3D)
│   └── RearWheel (MeshInstance3D)
├── RiderMesh (Node3D) ──── visual only, rotates/tumbles during crash
│   ├── Torso (MeshInstance3D)
│   ├── Head (MeshInstance3D)
│   ├── ArmL (MeshInstance3D)
│   └── ArmR (MeshInstance3D)
├── AttackArea (Area3D + CollisionShape3D) ──── weapon hit detection
├── HitboxArea (Area3D + CollisionShape3D) ──── receiving hits (optional, can use groups instead)
├── BikeMarkerScene (PackedScene — instanced on knockout, freed on remount)
└── InputController (Node) ──── PlayerInput.gd OR AIBrain.gd (swapped per rider type)
```

### State Machine Pattern

Use the node-based state machine pattern. Each state is a child Node with its own script. The state machine parent manages transitions.

```
RiderBase (CharacterBody3D)
└── StateMachine (Node)
    ├── RidingState (Node)
    ├── FlyingState (Node)
    ├── SlidingState (Node)
    ├── LyingState (Node)
    └── OnFootState (Node)
```

Each state script implements:

```gdscript
# src/gameplay/states/base_state.gd
@abstract
class_name BaseRiderState extends Node

var rider: CharacterBody3D  # Set by StateMachine on _ready()

@abstract
func enter(prev_state: StringName) -> void:
    pass

@abstract
func exit(next_state: StringName) -> void:
    pass

@abstract
func physics_update(delta: float) -> void:
    pass

func transition_to(state_name: StringName) -> void:
    get_parent().transition_to(state_name)
```

The StateMachine node:

```gdscript
# src/gameplay/state_machine.gd
class_name RiderStateMachine extends Node

@export var initial_state: BaseRiderState
var current_state: BaseRiderState
var states: Dictionary = {}  # StringName → BaseRiderState

func _ready() -> void:
    var rider := get_parent() as CharacterBody3D
    for child in get_children():
        if child is BaseRiderState:
            states[child.name] = child
            child.rider = rider
    current_state = initial_state
    current_state.enter(&"")

func _physics_process(delta: float) -> void:
    current_state.physics_update(delta)

func transition_to(state_name: StringName) -> void:
    if not states.has(state_name):
        push_error("State not found: " + state_name)
        return
    var prev_name := current_state.name
    current_state.exit(state_name)
    current_state = states[state_name]
    current_state.enter(prev_name)
```

**Why node-based over enum-based:** The prototype uses an enum + match block, which works but becomes unwieldy as states accumulate logic (the rider.gd prototype is already 650+ lines). Node-based states keep each state's logic isolated, testable, and debuggable (visible in scene tree). Godot 4.5+ `@abstract` annotation enforces the interface contract.

---

## Physics Layers

Godot supports 32 collision layers. Assign them deliberately to avoid unexpected interactions.

| Layer | Name | Used By |
|-------|------|---------|
| 1 | `road_surface` | Road mesh (StaticBody3D), ground planes |
| 2 | `riders` | All rider CharacterBody3D nodes (player + AI) |
| 3 | `barriers` | Road edge barriers, walls (StaticBody3D) |
| 4 | `obstacles` | Traffic, debris, destructibles (StaticBody3D / RigidBody3D) |
| 5 | `pickups` | Weapon/nitro pickup Area3D nodes |
| 6 | `attack_zones` | Weapon attack Area3D hitboxes |
| 7 | `finish_line` | Finish line Area3D |
| 8 | `bike_markers` | Stopped bike markers (for on-foot navigation, not physics collision) |

### Collision Matrix

| Object | Layer (is) | Mask (collides with) |
|--------|-----------|---------------------|
| Road surface | 1 | -- (static, doesn't initiate) |
| Rider (CharacterBody3D) | 2 | 1 (road), 2 (other riders), 3 (barriers), 4 (obstacles) |
| Barrier | 3 | -- (static) |
| Obstacle | 4 | -- (static) or 2 (if moveable) |
| Pickup (Area3D) | 5 | 2 (detects riders entering) |
| Attack zone (Area3D) | 6 | 2 (detects riders in range) |
| Finish line (Area3D) | 7 | 2 (detects riders crossing) |

**Key decision:** Riders collide with each other (layer 2 masks layer 2). This enables the bump/shove mechanic from the GDD. If performance is a concern with many riders, this can be toggled off for AI-vs-AI collisions by putting AI on a separate layer, but start with all riders on the same layer.

---

## Resource Management for WebGL

### Compatibility Renderer Constraints

WebGL export requires the **Compatibility** rendering method. This means:

| Feature | Available | Notes |
|---------|-----------|-------|
| StandardMaterial3D | YES | Core material system works |
| Dynamic lighting | YES | But limit to 1-2 lights for performance |
| Shadows | YES | Use low-res shadow maps (1024-2048) |
| Fog | YES | Distance fog works, volumetric fog does NOT |
| Post-processing (glow, DOF) | LIMITED | Glow works; DOF expensive on WebGL |
| Particles (GPUParticles3D) | NO | Use CPUParticles3D instead |
| SSAO, SSR, SDFGI, VoxelGI | NO | Compatibility renderer lacks these |
| Volumetric fog | NO | Not available in Compatibility |
| Screen-space effects | LIMITED | Basic effects only |
| Shader complexity | LIMITED | Avoid dynamic loops in shaders |

### Memory and Loading Strategy

1. **Preload weapon/pickup resources at scene load.** Don't lazy-load during gameplay -- WebGL has higher latency for resource loading than native.

2. **Use ResourcePreloader node** in each track scene for track-specific assets (obstacle meshes, materials). This bundles them with the scene file.

3. **Limit simultaneous ragdoll riders to 2-3.** The prototype report flags this as a performance risk. When a 4th rider gets knocked out, immediately transition the oldest knocked-out rider to ON_FOOT state (skip remaining lying time).

4. **Pool stopped bike markers.** Don't create/free Node3D instances every knockout. Pre-create a pool of 4-6 bike marker scenes and show/hide them.

5. **Mesh LOD is not critical** for low-poly art style, but use `visibility_range_end` on distant objects (lane dividers, far obstacles) to reduce draw calls.

6. **Audio streaming:** Use `.ogg` for music (streamed), `.wav` for short SFX (loaded). Limit concurrent audio streams to ~8-12.

### Export Size Optimization

- Disable unused engine modules in export (3D navigation server if not using navmesh, 2D physics if pure 3D)
- Compress textures with BPTC/S3TC for desktop WebGL
- Target total export size under 15-20MB for fast browser loading
- Use `.wasm` + `.pck` split for parallel download

---

## Autoload Singletons

Keep autoloads minimal. Each one persists across scene changes and consumes memory.

| Autoload | Purpose | Justification |
|----------|---------|---------------|
| `GameEvents` | Signal bus | Required for cross-system decoupling |
| `GameConfig` | Tuning knobs, difficulty settings | Data-driven balance requires global access to config values |
| `AudioManager` | Music/SFX playback | Audio must persist across scene transitions (music crossfade between levels) |

**NOT autoloads:**
- RaceManager -- lives in-scene, created/destroyed per race
- HUD -- lives in-scene, different HUDs possible per context (race HUD vs results screen)
- JuiceManager -- lives in-scene, connects to GameEvents on ready

---

## Patterns to Follow

### Pattern 1: Composition via Exported PackedScene

**What:** Use `@export var rider_scene: PackedScene` on RaceManager instead of hardcoding rider instantiation.
**When:** Any time you need to spawn entities at runtime.
**Why:** Enables swapping rider scenes (e.g., different bike models per level) without changing code.

```gdscript
# src/gameplay/race_manager.gd
@export var player_rider_scene: PackedScene
@export var ai_rider_scene: PackedScene
@export var riders_per_race: int = 4

func _spawn_riders(spawn_points: Array[Marker3D]) -> void:
    var player := player_rider_scene.instantiate() as CharacterBody3D
    player.global_position = spawn_points[0].global_position
    riders_node.add_child(player)
    # ... instance AI riders similarly
```

### Pattern 2: Resource-Based Weapon Definitions

**What:** Define weapons as custom Resource scripts, not enum constants.
**When:** Any data that needs tuning (weapons, difficulty curves, speed zones).
**Why:** Resources are editable in Godot's inspector, can be saved as .tres files, and support inheritance.

```gdscript
# src/data/weapon_data.gd
class_name WeaponData extends Resource

@export var name: StringName
@export var damage: int
@export var durability: int  # 0 = infinite (fists)
@export var attack_range: float
@export var attack_cooldown: float
@export var knockout_launch_force: float
@export var knockout_launch_angle: float  # degrees from horizontal
@export var flying_style: StringName  # "scrappy_tumble", "home_run_spin", etc.
@export var hit_sfx: AudioStream
@export var impact_particles: PackedScene
```

### Pattern 3: State Machine with Transition Validation

**What:** Encode valid transitions explicitly; reject invalid ones.
**When:** The motorcycle controller's 5-state machine with strict transition rules.
**Why:** The GDD defines 7 explicitly invalid transitions. Encode them in code to catch bugs early.

```gdscript
# In StateMachine
const VALID_TRANSITIONS: Dictionary = {
    &"Riding": [&"Flying"],
    &"Flying": [&"Sliding", &"Lying"],  # Lying if hitting wall mid-flight
    &"Sliding": [&"Lying"],
    &"Lying": [&"OnFoot", &"Lying"],  # Lying→Lying for run-over reset
    &"OnFoot": [&"Riding"],
}

func transition_to(state_name: StringName) -> void:
    var allowed: Array = VALID_TRANSITIONS.get(current_state.name, [])
    if state_name not in allowed:
        push_warning("Invalid transition: %s → %s" % [current_state.name, state_name])
        return
    # ... proceed with transition
```

### Pattern 4: Detached Camera with State-Aware Offsets

**What:** Camera reads player state and smoothly lerps between per-state offsets.
**When:** The camera must handle 5 different rider states gracefully.
**Why:** Prototype already does this -- formalize it with exported per-state config.

```gdscript
# src/core/chase_camera.gd
extends Camera3D

@export var target: CharacterBody3D
@export var riding_offset: Vector3 = Vector3(0, 4.5, -8)
@export var flying_offset: Vector3 = Vector3(0, 7, -12)
@export var sliding_offset: Vector3 = Vector3(0, 6, -10)
@export var lying_offset: Vector3 = Vector3(0, 5, -9)
@export var on_foot_offset: Vector3 = Vector3(0, 5, -9)
@export var follow_speed: float = 4.0
```

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: God Script

**What:** Putting all rider logic (movement, combat, AI, visuals, state machine) in one script.
**Why bad:** The prototype's `rider.gd` is already 650+ lines and handles everything. In production this becomes untestable and unmaintainable.
**Instead:** Split into: RiderBase (physics + state machine), per-state scripts, PlayerInput/AIBrain, and separate visual controller.

### Anti-Pattern 2: CSG for Production Geometry

**What:** Using CSGBox3D/CSGSphere3D for road, barriers, and rider meshes.
**Why bad:** CSG nodes are editor tools, not runtime geometry. They generate meshes at runtime (slow), don't batch well (high draw calls), and perform poorly in WebGL. The prototype's lane dividers (individual CSG boxes every 40 units for 6000m = 150 CSG nodes per lane) would destroy browser performance.
**Instead:** Use MeshInstance3D with imported .glb/.gltf meshes, or at minimum use ArrayMesh generated at `_ready()` and cached. Use MultiMeshInstance3D for repeated elements (lane dividers, barrier segments).

### Anti-Pattern 3: Engine.time_scale for Slow-Mo

**What:** Setting `Engine.time_scale = 0.25` globally (as the prototype does).
**Why bad:** This slows ALL physics, timers, and animations. If you have a UI timer counting down, or audio that shouldn't slow down, everything breaks. Stacking slow-mo from multiple knockouts creates unpredictable behavior.
**Instead:** Use a dedicated slow-mo manager that tracks requests, uses `Engine.time_scale` but also provides `unscaled_delta` for systems that should ignore slow-mo (UI timers, audio pitch correction).

### Anti-Pattern 4: Hardcoded Tuning Values

**What:** `const MAX_SPEED: float = 83.3` in rider script.
**Why bad:** GDD mandates "gameplay values must be data-driven." Hardcoded constants require recompiling to tune. With 14 systems and hundreds of tuning knobs, this doesn't scale.
**Instead:** Use Resource files for all gameplay data. Load from `res://data/` directory. Editable in Godot inspector without touching code.

### Anti-Pattern 5: Creating Nodes Every Knockout

**What:** `var stopped_bike_marker = Node3D.new()` then `queue_free()` on remount.
**Why bad:** Node creation/destruction is expensive in WebGL. With 4-6 riders getting knocked out repeatedly, this creates GC pressure and frame hitches.
**Instead:** Object pooling. Pre-create bike markers and pickup visual nodes. Show/hide rather than create/destroy.

---

## Scalability Considerations

| Concern | 4 Riders (MVP) | 6 Riders (Target) | 8+ Riders (Stretch) |
|---------|----------------|-------------------|---------------------|
| Physics bodies | Fine | Fine | May need AI-vs-AI collision disabled |
| Simultaneous ragdolls | Allow all | Cap at 3 | Cap at 2 |
| Draw calls | ~100-200 | ~200-400 | Needs MultiMesh for track objects |
| Pickup proximity checks | Brute force OK | Brute force OK | Spatial hash if > 50 pickups |
| AI pathfinding | None needed (forward road) | None needed | None needed |
| Audio streams | 4 engines + SFX | 6 engines + SFX = ~12 streams | Prioritize closest 4 engines |
| WebGL frame budget | Comfortable | Tight but achievable | Requires aggressive LOD/culling |

---

## Suggested Build Order (Dependencies-Based)

This order is derived from the 14-system dependency DAG in `systems-index.md`, combined with architectural dependencies discovered during research.

### Phase 1: Foundation (no dependencies)

Build order within phase:
1. **Project scaffolding** -- directory structure, autoloads (GameEvents, GameConfig), Compatibility renderer setup, WebGL export profile
2. **Input System** -- InputMap actions, 3 contexts (riding, combat, on-foot). Foundation for everything.
3. **Track System** -- One straight track with proper MeshInstance3D geometry (not CSG), collision layers, spawn points, pickup spawn points. The "stage" everything else performs on.

**Rationale:** Nothing else can be tested without a track to drive on and inputs to read.

### Phase 2: Core Vehicle + Camera

Build order within phase:
1. **Motorcycle Controller (RIDING state only)** -- CharacterBody3D with acceleration, braking, steering, road clamping. Test with keyboard input on Track.
2. **Camera System** -- Chase cam with RIDING offset. Needs a target to follow.

**Rationale:** The entire game is built on "does the motorcycle feel good?" This must be nailed before anything else. Prototype validated the feel; production version needs proper architecture (state machine nodes, resource-based config).

### Phase 3: Combat Foundation

Build order within phase:
1. **Health System** -- HP resource/component, damage application, death threshold
2. **Weapon System** -- WeaponData resources, pickup Area3D, durability tracking
3. **Melee Combat** -- Attack area, target detection, damage dealing, weapon-based knockback

**Rationale:** Combat is the core differentiator. Health must exist before weapons can deal damage. Weapons must exist before melee combat can use them.

### Phase 4: Crash Cycle (The Signature Mechanic)

Build order within phase:
1. **FLYING state** -- Launch vectors (weapon-type-based), ballistic arc, gravity, tumble animation
2. **SLIDING state** -- Ground friction, deceleration, scrape animation
3. **LYING state** -- Timer (force-based duration), lying animations, run-over detection
4. **ON_FOOT state** -- Auto-walk to bike, wobble animation, remount trigger
5. **Bike marker system** -- Pooled markers, arrow indicators

**Rationale:** These are sequential states that must be built in order (each state transitions to the next). This is the most technically risky system (ragdoll in WebGL) and should be built and profiled early.

### Phase 5: AI + Race Management

Build order within phase:
1. **AI Riders** -- AIBrain script using same RiderBase API as PlayerInput. State-based behavior (race, attack, flee, recover).
2. **Race Manager** -- Countdown, position tracking, finish detection, results

**Rationale:** AI needs ALL previous systems working (movement, combat, crash cycle). Race manager needs AI riders to create a race. This is the point where the full core loop becomes playable.

### Phase 6: Presentation

Build order within phase:
1. **HUD** -- HP bar, weapon display, speedometer, position, progress (connects to GameEvents only)
2. **Level Progression** -- Track loading, level select, difficulty scaling
3. **Juice & Feedback** -- Screen shake, hit flash, slow-mo manager, particles (CPUParticles3D)
4. **Audio System** -- Engine loop, impact SFX, music, AudioManager autoload

**Rationale:** Presentation layers depend on all gameplay systems being stable. Juice and audio are the difference between "functional" and "fun" but should not be built until the underlying systems are solid.

### Dependency Chain Summary

```
Input + Track (foundation)
       │
       ▼
  Motorcycle Controller + Camera (core feel)
       │
       ▼
  Health + Weapons + Combat (core gameplay)
       │
       ▼
  Crash Cycle (signature mechanic, performance risk)
       │
       ▼
  AI + Race Manager (full loop)
       │
       ▼
  HUD + Progression + Juice + Audio (presentation + polish)
```

**Critical path:** Input → Motorcycle → Combat → Crash Cycle → AI → Race Manager. Any delay on this chain delays everything downstream.

**Parallel opportunities:**
- Health System can be built alongside Motorcycle Controller (no dependency)
- Camera can be built alongside or immediately after Motorcycle Controller
- HUD can start as soon as GameEvents signals are defined (stub data)
- Audio can be prototyped with placeholder sounds at any point

---

## File Structure (Production)

```
src/
├── core/
│   ├── game_events.gd          # Autoload: signal bus
│   ├── game_config.gd          # Autoload: tuning knobs
│   ├── chase_camera.gd         # Camera controller
│   └── input_manager.gd        # Input context switching
├── gameplay/
│   ├── rider/
│   │   ├── RiderBase.tscn      # Scene: CharacterBody3D + children
│   │   ├── rider_base.gd       # Core rider logic + state machine host
│   │   ├── player_input.gd     # PlayerInput controller
│   │   └── ai_brain.gd         # AI controller
│   ├── states/
│   │   ├── base_state.gd       # Abstract base
│   │   ├── riding_state.gd
│   │   ├── flying_state.gd
│   │   ├── sliding_state.gd
│   │   ├── lying_state.gd
│   │   └── on_foot_state.gd
│   ├── combat/
│   │   ├── health_component.gd
│   │   ├── weapon_holder.gd
│   │   └── melee_attack.gd
│   ├── track/
│   │   ├── track_base.gd
│   │   └── pickup_spawner.gd
│   └── race_manager.gd
├── ui/
│   ├── hud.gd
│   ├── hp_bar.gd
│   ├── weapon_display.gd
│   └── results_screen.gd
├── juice/
│   ├── juice_manager.gd
│   └── slow_mo_controller.gd
└── audio/
    └── audio_manager.gd

data/
├── weapons/
│   ├── fists.tres
│   ├── bat.tres
│   ├── rubber_chicken.tres
│   └── chain.tres
├── riders/
│   ├── player_config.tres
│   └── ai_configs/
│       ├── aggressive.tres
│       ├── defensive.tres
│       └── balanced.tres
└── tracks/
    ├── level_1_config.tres
    └── ...

assets/
├── models/
│   ├── bike.glb
│   ├── rider.glb
│   └── weapons/
├── audio/
│   ├── sfx/
│   └── music/
└── textures/
```

---

## Sources

- [Scene organization -- Godot Engine (stable)](https://docs.godotengine.org/en/stable/tutorials/best_practices/scene_organization.html) -- HIGH confidence, official docs
- [3D rendering limitations -- Godot Engine (stable)](https://docs.godotengine.org/en/stable/tutorials/3d/3d_rendering_limitations.html) -- HIGH confidence, official docs
- [Optimizing 3D performance -- Godot Engine (latest)](https://docs.godotengine.org/en/latest/tutorials/performance/optimizing_3d_performance.html) -- HIGH confidence, official docs
- [Finite State Machine in Godot 4 -- GDQuest](https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/) -- HIGH confidence, authoritative community source
- [Events bus singleton -- GDQuest](https://www.gdquest.com/tutorial/godot/design-patterns/event-bus-singleton/) -- HIGH confidence, authoritative community source
- [Godot Signals Architecture Best Practices 2026](https://blog.febucci.com/2024/12/godot-signals-architecture/) -- MEDIUM confidence, community guide
- [Collision layers and masks -- GDQuest](https://school.gdquest.com/glossary/collision_layers_and_masks) -- HIGH confidence, well-documented pattern
- [Web Platform Export -- Godot docs DeepWiki](https://deepwiki.com/godotengine/godot-docs/7.4-web-platform-export) -- MEDIUM confidence, third-party aggregation of official docs
- [Arcade-style Car -- Godot Recipes](https://kidscancode.org/godot_recipes/4.x/3d/3d_sphere_car/index.html) -- MEDIUM confidence, practical tutorial
- [Godot architecture organization advice -- GitHub](https://github.com/abmarnie/godot-architecture-organization-advice) -- LOW confidence, community repo
- Project files: `docs/engine-reference/godot/current-best-practices.md` -- verified Godot 4.6 specifics (Jolt default, @abstract, Compatibility renderer)
- Project files: `design/gdd/systems-index.md` -- 14-system dependency DAG
- Project files: `design/gdd/motorcycle-controller.md` -- 5-state machine design
- Project files: `prototypes/combat-racing-core/` -- validated prototype architecture and lessons learned
