# Technology Stack

**Project:** Road Rage Rodeo
**Researched:** 2026-03-28
**Overall Confidence:** MEDIUM-HIGH (engine reference docs verified locally; some Compatibility renderer specifics rely on community sources)

---

## Recommended Stack

### Engine & Language

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Godot | 4.6 | Game engine | Already pinned. Jolt default, WebGL export, GDScript for fast iteration. Best open-source option for browser 3D games. | HIGH |
| GDScript | 4.6 | Primary language | Native to Godot, zero FFI overhead, variadic args + `@abstract` (4.5+) for cleaner architecture. Fast iteration loop. | HIGH |
| C++ (GDExtension) | N/A | Performance-critical paths | Reserve for IF profiling shows GDScript bottlenecks (unlikely for this scope). Do NOT preemptively use. | HIGH |

### Physics

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Jolt Physics | Built-in (4.6 default) | 3D physics, ragdoll, collisions | Default in Godot 4.6. 2-3x perf over GodotPhysics3D. Better determinism and stability. Proven in AAA (Horizon Forbidden West). | HIGH |

**Ragdoll Setup (Jolt):**
- Use `PhysicalBoneSimulator3D` (NOT the deprecated Skeleton3D physical_bones functions)
- Generate PhysicalBone3D nodes via "Create physical skeleton" button on Skeleton3D
- Prune small/utility bones -- each simulated bone has perf cost
- Use collision layers to separate ragdoll bodies from CharacterBody3D capsules
- Joints: Generic6DOFJoint3D preferred over HingeJoint3D (Jolt doesn't support `damp` on HingeJoint3D)
- Limit simultaneous active ragdolls to 2-3 for WebGL performance

**Jolt Gotcha:** HingeJoint3D `damp` property is silently ignored by Jolt. Use Generic6DOFJoint3D with angular damping instead, or switch to GodotPhysics3D (not recommended).

### Rendering

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Compatibility Renderer | Built-in | WebGL 2.0 rendering | **Mandatory** for web export. Forward+ and Mobile do NOT export to web. This is the only option. | HIGH |
| SMAA 1x | Built-in (4.5+) | Anti-aliasing | Sharper than FXAA, cheaper than TAA. Good balance for low-poly aesthetic at WebGL perf budget. | HIGH |

**Compatibility Renderer -- What You Lose vs Forward+:**

| Feature | Forward+ | Compatibility | Impact on This Game |
|---------|----------|---------------|---------------------|
| SSAO | Yes | **NO** | Low -- low-poly art doesn't rely on AO. Bake AO into vertex colors if needed. |
| SDFGI | Yes | **NO** | None -- not needed for arcade racing. |
| Volumetric Fog | Yes | **NO** | Low -- use particle-based fog or shader fog instead. |
| SSIL | Yes | **NO** | None -- unnecessary for this art style. |
| SSR | Yes | **NO** | None -- no reflective surfaces needed. |
| Alpha Hash transparency | Yes | **NO** | Low -- use standard alpha blend. |
| VoxelGI / LightmapGI | Yes | Partial | Use baked lightmaps where needed; simpler GI approach fine for moving scenes. |

**Bottom line:** The missing features do not meaningfully impact a low-poly arcade racing game. The PS1/PS2 aesthetic actually benefits from simpler rendering.

**Rendering Settings for WebGL Performance:**
- Anti-aliasing: SMAA 1x (not TAA -- TAA ghosts on fast camera movement, critical flaw for racing)
- Shadow quality: Low-Medium (directional light only, no point light shadows)
- LOD: Use Godot's built-in LOD system for track-side objects
- Shader Baker: Pre-compile shaders to eliminate startup hitching (4.5+)
- Tonemapper: AgX (4.6 default) works well -- has new white point / contrast controls

### Audio

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Godot AudioServer | Built-in | Audio bus routing, mixing | Stable API since 4.0, no breaking changes through 4.6. Bus-based architecture covers all needs. | HIGH |
| AudioStreamPlayer3D | Built-in | Spatial audio for engine/combat SFX | Attenuation models, max distance, unit size -- all configurable per-source. | HIGH |
| AudioStreamPlayer | Built-in | Non-spatial (music, UI) | Simple 2D playback for BGM and UI sounds. | HIGH |
| OGG Vorbis | Built-in | Music format | Compressed, streamable, good quality. Preferred over WAV for music (smaller file size for WebGL). | HIGH |
| WAV | Built-in | SFX format | Uncompressed, no decode latency. Use for short SFX (impacts, crashes). Keep files small for WebGL. | HIGH |

**Audio Bus Layout:**
```
Master
  +-- Music       (background tracks, per-level)
  +-- SFX         (3D spatial: engine, impacts, crashes)
  +-- UI          (non-spatial: menu clicks, notifications)
  +-- Voice       (optional: announcer/commentary if added later)
```

**WebGL Audio Gotcha:** Browsers block audio autoplay. MUST have a user interaction (click/keypress) before playing any audio. Design a "Press to Start" splash screen -- this is not optional.

**SFX Pooling:** Pre-allocate 8-12 AudioStreamPlayer nodes per bus to avoid runtime allocation. See `docs/engine-reference/godot/modules/audio.md` for the pooling pattern.

### UI Framework

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Godot Control nodes | Built-in | HUD, menus, overlays | Native, theme-aware, container-based layout. No addon needed. | HIGH |
| Theme resources (.tres) | Built-in | Consistent UI styling | Single theme file controls all UI appearance. Change once, propagates everywhere. | HIGH |
| CanvasLayer | Built-in | HUD rendering layer | Draws on top of 3D world, unaffected by camera. Standard approach for game HUD. | HIGH |

**HUD Architecture:**
- Root: `CanvasLayer` (layer 1, above game world)
- Layout: `MarginContainer` -> `VBoxContainer`/`HBoxContainer` for edges
- Health bars: `TextureProgressBar` with custom theme
- Speed/position: `Label` nodes with theme overrides
- Weapon indicator: `TextureRect` + `Label`

**4.6 Dual-Focus Note:** Mouse and keyboard/gamepad focus are now separate. For menu screens, test with BOTH input methods. `grab_focus()` only affects keyboard/gamepad -- mouse hover is independent.

### Asset Pipeline

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| glTF 2.0 (.glb) | Godot built-in | 3D model import | Recommended format. Best feature support. Binary format for smaller files. | HIGH |
| Blender | 4.x | 3D modeling (if needed) | Free, glTF export built-in, Godot auto-imports .blend files. | HIGH |
| Godot Import System | Built-in | Asset processing | Auto-reimport on file change. Configure per-asset import settings. | HIGH |
| CSG nodes | Built-in | Rapid prototyping | Use for blockout/greybox phase. Replace with proper meshes for final. NOT for production geometry (perf cost). | HIGH |

**Low-Poly Workflow:**
1. Model in Blender (target 500-2000 tris per prop, 2000-5000 for vehicles)
2. Export as `.glb` (binary glTF, smaller than `.gltf`)
3. Godot auto-imports with configurable settings (mesh compression, LOD generation)
4. Collision: Use simplified convex hull or primitive shapes, NOT mesh collision (too expensive for WebGL)
5. Materials: Use Godot's StandardMaterial3D with vertex colors for PS1 aesthetic -- avoid heavy textures

**WebGL File Size Budget:**
- Base WASM: ~40 MB uncompressed, ~5 MB Brotli-compressed
- Asset budget: Keep total under 50 MB uncompressed for reasonable load times
- Textures: Low-res (64x64 to 256x256 max) -- PS1 aesthetic is a feature, not a limitation
- Audio: OGG for music (target 96-128 kbps), WAV for short SFX only

### Testing

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| GUT (Godot Unit Test) | 9.6.0 | Unit/integration testing | Actively maintained, explicit Godot 4.6 support. GDScript-native. | HIGH |

**Why GUT over GdUnit4:** GUT is simpler, GDScript-focused (no C# needed), lighter weight. GdUnit4 has more features (mocking, scene testing) but adds complexity this project doesn't need. GUT 9.6.0 explicitly targets Godot 4.6.

### Web Export

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Single-threaded export | Built-in (4.3+) | Browser compatibility | No SharedArrayBuffer/COOP/COEP headers required. Works on itch.io, Poki, CrazyGames without server config. | HIGH |
| Brotli compression | Server-side | Reduce download size | WASM compresses from ~40 MB to ~5 MB. Most hosting platforms handle this automatically. | MEDIUM |

**Single-Thread vs Multi-Thread:**
- **Use single-threaded.** Multi-threaded requires SharedArrayBuffer + cross-origin isolation headers. Most game portals (itch.io, etc.) don't support this. The performance difference is acceptable for this game's scope.
- Godot 4.3+ solved the web export SharedArrayBuffer nightmare -- single-thread export is the standard path now.

---

## Addons & Plugins

### Recommended: None for MVP

This project should ship with **zero third-party addons** for the core game. Rationale:

1. **Godot 4.6 built-ins cover all needs** -- Jolt physics, Compatibility renderer, audio buses, Control UI, glTF import
2. **Addon compatibility risk** -- Godot 4.4-4.6 introduced significant breaking changes. Many addons haven't caught up. Each addon is a maintenance liability.
3. **WebGL export risk** -- Addons may not be tested against Compatibility renderer / WebGL. Native code addons (GDExtension) may not compile for web.
4. **1-month timeline** -- No time to debug addon issues. Built-in systems are battle-tested.

### Consider Only If Needed

| Addon | When to Consider | Why Not by Default |
|-------|------------------|--------------------|
| GUT 9.6.0 | Phase 1 (foundation) | Only addon worth adding -- testing framework. Install via Asset Library. |
| Phantom Camera | If camera feel needs significant tuning beyond basic `Camera3D` + `SpringArm3D` | Adds dependency; basic chase cam is sufficient for arcade racing. |
| LimboAI | If AI behavior trees needed | Simple state machine in GDScript should suffice for 5-state AI. Behavior trees add complexity without clear benefit for this scope. |

---

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Engine | Godot 4.6 | Unity | Worse WebGL export story, heavier runtime, licensing concerns, project already configured |
| Engine | Godot 4.6 | Unreal | No viable WebGL export, massive overkill for low-poly arcade game |
| Physics | Jolt (built-in) | GodotPhysics3D | Slower, less stable, no reason to use legacy engine |
| Physics | Jolt (built-in) | Rapier (addon) | Unnecessary -- Jolt is now built-in and better integrated |
| Renderer | Compatibility | Forward+ | Forward+ cannot export to web. Period. |
| AA | SMAA 1x | TAA | TAA ghosts on fast motion -- fatal for racing game camera |
| AA | SMAA 1x | FXAA | FXAA too blurry, loses low-poly edge definition |
| Testing | GUT 9.6.0 | GdUnit4 | GdUnit4 heavier, C# support unnecessary, GUT is simpler for GDScript |
| AI | State machine (custom) | LimboAI | 5-state AI doesn't justify behavior tree framework overhead |
| Music format | OGG Vorbis | MP3 | OGG is smaller at similar quality, no licensing concerns |
| Model format | glTF (.glb) | FBX | glTF is Godot's recommended format, better feature support |
| Model format | glTF (.glb) | OBJ | OBJ lacks animation, skeleton, PBR material support |

---

## What NOT to Use

| Technology | Why Avoid |
|------------|-----------|
| Forward+ renderer | Cannot export to WebGL. No exceptions. |
| Mobile renderer | Also cannot export to WebGL. Only Compatibility works. |
| TAA | Ghosting on fast camera movement. Ruins racing game feel. |
| GDExtension / C++ | Don't preemptively optimize. GDScript is fast enough. Profile first, optimize only proven bottlenecks. |
| Third-party physics addons | Jolt is built-in now. External physics addons add risk with no benefit. |
| Heavy texture workflows | PS1 aesthetic means low-res textures. 256x256 max. Vertex colors preferred. Don't over-produce art assets. |
| Mesh collision shapes | Too expensive for WebGL. Use convex hull or primitive collision shapes. |
| Multiple simultaneous ragdolls (>3) | WebGL physics budget is tight. Cap active ragdolls and convert distant ones to static poses. |
| `process` for physics | Always use `_physics_process` for movement/physics code. `_process` creates frame-rate dependent behavior. |

---

## Installation / Project Setup

```bash
# No package manager -- Godot uses Asset Library and manual addon installation

# Project structure already exists. Key settings to verify in project.godot:
# 1. Rendering → Renderer → Compatibility (for WebGL)
# 2. Physics → 3D → Physics Engine → Jolt Physics (should be default)
# 3. Rendering → Anti Aliasing → Screen Space AA → SMAA
# 4. Display → Window → Stretch → Mode → canvas_items (for resolution independence)
```

```
# GUT Installation (only addon):
# 1. Asset Library → Search "GUT" → Install GUT 9.6.0
# 2. Enable plugin: Project Settings → Plugins → GUT → Enable
# 3. Tests go in tests/ directory matching project structure
```

---

## WebGL-Specific Configuration Checklist

| Setting | Value | Why |
|---------|-------|-----|
| Renderer | Compatibility | Only renderer that exports to web |
| Thread Support | Disabled (single-threaded) | Avoids SharedArrayBuffer requirement |
| Texture compression | ETC2 + S3TC | Cover both desktop GPUs and mobile WebGL |
| VRAM compression | Enabled | Reduces GPU memory on constrained browsers |
| Max physics ticks/frame | 2 (cap) | Prevent physics spiral on slow frames |
| Audio driver | Web | Automatic for web export |
| Shader Baker | Enabled | Pre-compile to avoid runtime shader compilation stutter |

---

## Performance Budget (WebGL @ 60fps)

| Resource | Budget | Notes |
|----------|--------|-------|
| Frame time | 16.6ms | Hard cap for 60fps |
| Active rigid bodies | 30-40 max | Riders (6) + weapons + obstacles + ragdoll bones |
| Active ragdolls | 2-3 simultaneous | Each ragdoll = ~8-12 PhysicalBone3D bodies |
| Draw calls | < 200 | Low-poly helps. Use MultiMeshInstance3D for repeated objects (traffic, barriers). |
| Texture memory | < 64 MB VRAM | Low-res textures, vertex colors, atlas textures |
| Total download | < 50 MB uncompressed | ~8-10 MB compressed. Target < 5s load on broadband. |

---

## Sources

- Godot 4.6 release notes: https://godotengine.org/releases/4.6/ (verified via local engine reference docs)
- Local engine reference: `docs/engine-reference/godot/` (verified 2026-02-12) -- HIGH confidence
- Jolt Physics integration: https://github.com/jrouwe/JoltPhysics/discussions/1764
- Godot ragdoll docs: https://docs.godotengine.org/en/stable/tutorials/physics/ragdoll_system.html
- Godot web export docs: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- Web export SharedArrayBuffer fix (4.3): https://godotengine.org/article/progress-report-web-export-in-4-3/
- Godot renderers comparison: https://docs.godotengine.org/en/4.4/tutorials/rendering/renderers.html
- Compatibility renderer tracker: https://github.com/godotengine/godot/issues/66458
- GUT 9.6.0: https://gut.readthedocs.io/
- GdUnit4: https://github.com/MikeSchulze/gdUnit4
- Godot audio buses: https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html
- Godot 3D import formats: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html
- Godot UI system: https://docs.godotengine.org/en/stable/tutorials/ui/index.html
