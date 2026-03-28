# Domain Pitfalls

**Domain:** 3D Arcade Combat Racing Browser Game (Godot 4.6, WebGL)
**Researched:** 2026-03-28
**Confidence:** MEDIUM-HIGH (verified against project prototype, Godot docs, community reports)

---

## Critical Pitfalls

Mistakes that cause rewrites, missed deadlines, or fundamentally broken gameplay.

### Pitfall 1: Developing with Forward+ Then Discovering WebGL Requires Compatibility Renderer

**What goes wrong:** Developer builds the entire game using Forward+ renderer in the Godot editor (which is the default for new 3D projects), designing visuals around its advanced features. At export time, they discover web exports ONLY support the Compatibility renderer (WebGL 2.0). The game looks completely different -- missing lighting features, broken shaders, wrong visual output.

**Why it happens:** Godot defaults new projects to Forward+ renderer. The Compatibility renderer is a separate, less featureful path using OpenGL 3 / WebGL 2. Features available in Forward+ but missing or degraded in Compatibility include: volumetric fog, SDFGI, screen-space reflections, advanced post-processing, certain particle rendering modes, and some shader features. The editor happily lets you use all of these, with zero warnings until export.

**Consequences:** Visual overhaul late in development. Shaders may need rewriting. Lighting setups rebuilt from scratch. Art direction compromised. Potential multi-week delay.

**Prevention:**
1. Set project renderer to Compatibility from day one (`Project Settings > Rendering > Renderer > Rendering Method: gl_compatibility`)
2. Test in Compatibility renderer constantly -- never switch to Forward+ "just to check"
3. Design the art style around Compatibility limitations: the low-poly PS1/PS2 aesthetic specified in PROJECT.md actually plays to Compatibility's strengths
4. Maintain a list of banned rendering features (volumetric fog, SDFGI, SSR, SSAO with full quality)

**Detection:** Visual discrepancies between editor preview and web export. Shader compilation errors on export. "Feature not supported" warnings in the output log when running Compatibility.

**Phase:** Must be addressed in Phase 1 (project setup). Non-negotiable.

**Confidence:** HIGH -- this is documented official Godot behavior.

---

### Pitfall 2: SharedArrayBuffer and Cross-Origin Isolation Breaking Web Deployment

**What goes wrong:** The game builds and runs locally but fails to load on hosting platforms (itch.io, GitHub Pages, custom hosting). Browsers block SharedArrayBuffer unless the page is served with specific CORS headers (`Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp`). Without these, the game shows a blank screen or cryptic JavaScript errors.

**Why it happens:** Godot 4.x web exports require SharedArrayBuffer for threading (including audio mixing). Browsers enforce strict security policies around SharedArrayBuffer since the Spectre/Meltdown mitigations. Many hosting platforms and iframe embedders do not set these headers by default.

**Consequences:** Game works in local testing but breaks on deployment. Audio garbles or fails entirely in single-threaded fallback mode. Game cannot be embedded in iframes on third-party sites without header configuration. itch.io requires specific project settings to work.

**Prevention:**
1. Test web export deployment early (Phase 1 or 2) -- do not wait until the end
2. For itch.io: enable SharedArrayBuffer support in the project's itch.io settings (it has a checkbox for this)
3. For custom hosting: configure server to send required CORS headers
4. For GitHub Pages: use a service worker approach (Godot provides one) to inject headers
5. Test in an incognito window with no extensions to rule out interference
6. Keep a deployment test checklist: Chrome, Firefox, Safari (Safari has the most WebGL 2 issues)

**Detection:** "SharedArrayBuffer is not defined" error in browser console. Audio crackling or silence. Game loads partially then freezes.

**Phase:** Must verify deployment in Phase 1 (hello-world web export). Re-verify after every major milestone.

**Confidence:** HIGH -- extensively documented in Godot issues (#85938, #93508, #6616).

---

### Pitfall 3: VehicleBody3D for Motorcycle Physics Is a Dead End

**What goes wrong:** Developer uses Godot's built-in `VehicleBody3D` + `VehicleWheel3D` for the motorcycle, expecting it to handle 2-wheeled vehicle physics. The motorcycle immediately falls over, wobbles uncontrollably, or requires increasingly hacky workarounds (locking rotation axes, invisible stabilizer wheels) that fight the physics engine.

**Why it happens:** `VehicleBody3D` is designed for 4-wheeled vehicles. Two-wheeled vehicles are inherently unstable in a physics simulation -- real motorcycles stay upright through gyroscopic effects and rider countersteering, neither of which VehicleBody3D models. Community reports confirm this is a known pain point with no clean solution within VehicleBody3D.

**Consequences:** Weeks wasted fighting physics. Hacky stabilization creates other problems (wrong collision behavior, strange AI interactions, physics jitter). Eventually forces a rewrite to a custom solution.

**Prevention:** The motorcycle controller GDD already specifies the correct approach: use `CharacterBody3D` (or a custom `RigidBody3D` setup) with fake arcade physics. The prototype validated this. Specifically:
1. Use `CharacterBody3D` for the rider+bike unit during RIDING state
2. Forward movement along Z axis, lateral movement along X -- no lean physics, just cosmetic tilt on the mesh
3. Capsule collider stays upright always -- visual lean is decoupled from physics
4. Only switch to ragdoll physics (`RigidBody3D` with joints) during FLYING state
5. Never use `VehicleBody3D` for any part of this project

**Detection:** If anyone suggests VehicleBody3D in a design discussion, flag immediately. If the bike falls over in testing, the physics model is wrong.

**Phase:** Phase 1 (core movement). The prototype already validated the CharacterBody3D approach.

**Confidence:** HIGH -- confirmed by community reports and the project's own prototype.

---

### Pitfall 4: WebGL WASM Size and Loading Time Killing First Impressions

**What goes wrong:** The exported web build has a 40+ MB WASM file. Players click the link, wait 15-30 seconds staring at a loading bar, and leave before the game starts. Browser games live or die by first-load time -- casual players expect near-instant play.

**Why it happens:** Godot 4.x web exports produce ~40 MB uncompressed WASM binaries by default. The browser must download, decompress, compile, and instantiate this before the game can start. On mobile broadband or slower connections, this is unacceptable. Additionally, the browser must compile the WASM module, which adds CPU-bound loading time even on fast connections.

**Consequences:** Player abandonment before gameplay. Particularly bad for a casual browser game targeting "pick-up-and-play" audiences. May exceed hosting limits (e.g., Cloudflare Pages has a 25 MB limit per file).

**Prevention:**
1. Enable Brotli compression on the hosting server (reduces ~40 MB to ~5 MB transfer)
2. Build custom export templates with unused engine modules disabled (disable 2D engine, advanced text server, unused importers)
3. Keep asset sizes small -- low-poly meshes and compressed textures are already planned
4. Add a visually engaging loading screen with progress indication (not just a progress bar -- show game art, tips, etc.)
5. Profile the export size at each milestone -- track it like a performance metric
6. Consider lazy-loading non-essential assets after initial game load

**Detection:** Measure time-to-first-frame on a real web deployment. If > 5 seconds on a decent connection, optimize. Check WASM file size in the export directory.

**Phase:** Address in Phase 1 (establish build pipeline and size baseline). Monitor throughout.

**Confidence:** HIGH -- file sizes documented in Godot blog posts and community benchmarks.

---

### Pitfall 5: Ragdoll Physics Budget Blowing Frame Rate on WebGL

**What goes wrong:** The game runs smoothly with 1-2 ragdolls active but drops to 20-30 fps when 3+ riders are simultaneously in ragdoll state (e.g., a chain-reaction crash). WebGL's single-threaded physics execution is significantly slower than native, and ragdolls with multiple joint-constrained rigid bodies are expensive.

**Why it happens:** Each ragdoll requires multiple `RigidBody3D` nodes connected by `Joint3D` nodes (typically 8-12 bodies per ragdoll). With 4-6 riders potentially in ragdoll state simultaneously, that is 32-72 active rigid bodies all needing collision detection and constraint solving per physics frame. Jolt physics is fast natively, but WebGL's single-threaded execution and JavaScript overhead cut performance significantly.

**Consequences:** Frame drops during the most exciting moments (knockouts and crashes) -- exactly when smooth performance matters most for "Visceral Impact" pillar. Players experience the game's signature feature at its worst performance.

**Prevention:**
1. Budget ragdoll complexity: 6-8 bones per ragdoll maximum, not anatomically accurate
2. Limit simultaneous active ragdolls to 2-3 at any time -- queue additional knockouts or use simplified ragdolls (single body with animated tumble) for distant/off-screen riders
3. Use LOD for ragdoll physics: full ragdoll for the player and nearby riders, simplified velocity-based arc for distant riders
4. Set ragdoll lifetime limits -- after LYING state begins, disable ragdoll physics and freeze the body
5. Profile on actual WebGL early and often -- editor performance is not representative
6. Consider the prototype's approach (velocity launch, not joint-based) as the default, with joint-based ragdoll reserved for the player's knockouts only

**Detection:** Frame time spikes during multi-knockout events. Monitor `Engine.get_frames_per_second()` in debug builds. Test the worst case: all AI riders knocked out simultaneously.

**Phase:** Must be profiled in Phase 2 (physics systems). Architecture decisions about ragdoll complexity depend on this.

**Confidence:** MEDIUM -- Jolt on WebGL performance is not well-benchmarked in community reports. The constraint is real but the exact budget is project-specific. Profile early.

---

## Moderate Pitfalls

### Pitfall 6: Racing AI That Feels Either Brain-Dead or Cheating

**What goes wrong:** AI riders either follow the track path mechanically (ignoring the player, never making mistakes, perfectly optimal) or behave randomly (attacking at wrong times, driving into walls, getting stuck). Both break immersion and fun.

**Why it happens:** Racing AI is a deceptive challenge. Simple path-following (PathFollow3D) produces robotic movement. Adding combat decisions on top of racing decisions creates complex state interactions. The prototype already identified this: AI scored 2/5 for engagement, feeling "dumb" with random attack timers.

**Consequences:** The game's core loop depends on AI being fun to fight and race against. Bad AI makes the game boring (too easy to beat) or frustrating (rubber-banding that feels unfair). Combat discoverability also depends on AI attacking the player -- if AI doesn't attack, players may not realize combat exists (scored 2/5 in prototype).

**Prevention:**
1. Use waypoint/spline-based racing with deliberate imperfection: add random lateral offset to waypoints, vary speed targets per AI rider, introduce "personality" (aggressive vs. defensive)
2. Implement a priority-based behavior system, not a simple state machine: `race_priority` vs `combat_priority` weighted by situation (distance to player, HP level, weapon status, race position)
3. AI should telegraph actions: lean toward player before attacking, accelerate before overtaking. This makes them feel intentional, not random.
4. Add rubber-banding that is invisible: AI speed adjusts based on distance to player, but through "effort" (they accelerate harder or coast) not teleportation
5. Test AI separately from all other systems -- build an AI-only test scene where you can observe 6 riders racing and fighting without player input
6. Implement the prototype's feedback: flee when low HP, approach when armed, vary aggression by "personality"

**Detection:** Watch full races without player input. Do AI riders look believable? Do they produce interesting races against each other? Time how long until AI behavior feels repetitive.

**Phase:** Phase 3 (AI systems). This is the highest-complexity system in the project. Budget extra time.

**Confidence:** MEDIUM -- AI design principles are well-established but implementation quality depends heavily on tuning.

---

### Pitfall 7: Combat "Juice" That Causes Motion Sickness or Annoyance

**What goes wrong:** Screen shake is too aggressive, slow-mo triggers too frequently, hit flash is disorienting. Players feel nauseated or annoyed rather than excited. The "Visceral Impact" pillar becomes a liability.

**Why it happens:** Juice effects feel great in isolation but compound badly. Screen shake on every hit + slow-mo on every knockout + camera FOV change at high speed + hit flash = sensory overload. Indie developers testing their own game become desensitized and keep increasing intensity. Additionally, screen shake in a racing game compounds with the camera's natural movement from steering.

**Consequences:** Players disable effects or stop playing. Some players experience motion sickness. The game gets negative feedback for the exact feature meant to be its strength.

**Prevention:**
1. Layer effects with clear hierarchy: screen shake for HITS (small), slow-mo for KNOCKOUTS only (rare, dramatic), FOV for SPEED (gradual, constant)
2. Never stack the same effect type -- if two hits happen in rapid succession, the second shake replaces the first, it does not add
3. Screen shake must decay quickly (< 0.3s) and have small amplitude. Never shake more than ~5-8 pixels equivalent.
4. Slow-mo should be reserved for player knockouts and player-inflicted knockouts only (not every AI-on-AI knockout)
5. Implement a "juice intensity" setting (0-100%) that scales all effects. Default to 70%, not 100%.
6. Test with fresh eyes: have someone who has NOT been developing the game play for 5 minutes and ask about comfort
7. The racing camera already has inherent motion from following the bike -- account for this baseline motion when adding effects on top

**Detection:** If you feel slightly queasy after 5 minutes of testing, reduce everything by 50%. If effects feel "just right" to you after weeks of development, they are probably too strong for fresh players.

**Phase:** Phase 4 (polish/juice). Build the systems with configurable intensity from the start. Tune last.

**Confidence:** HIGH -- this is a well-documented game design pattern with extensive industry writing.

---

### Pitfall 8: Godot 4.4-4.6 API Assumptions from Stale LLM Knowledge

**What goes wrong:** Claude (or any LLM-assisted coding) generates GDScript using APIs, patterns, or defaults from Godot 4.2-4.3 (within training data). The code either fails silently, produces wrong behavior, or uses deprecated patterns. Three full versions of breaking changes (4.4, 4.5, 4.6) are beyond the training cutoff.

**Why it happens:** LLM training data covers Godot through ~4.3. Versions 4.4-4.6 introduced: Jolt as default physics (4.6), glow processing change (4.6), quaternion initialization change (4.6), variadic args and @abstract (4.5), FileAccess return type changes (4.4), shader texture type changes (4.4), physics interpolation rearchitecture (4.5), and more. The project's `docs/engine-reference/godot/breaking-changes.md` documents these.

**Consequences:** Subtle bugs from wrong API usage. Physics behaving differently than expected (Jolt vs GodotPhysics differences). Rendering looking wrong (glow before vs after tonemapping). Time wasted debugging issues caused by outdated knowledge.

**Prevention:**
1. Always cross-reference `docs/engine-reference/godot/breaking-changes.md` before implementing any system
2. For physics: remember Jolt is default in 4.6. Some GodotPhysics-specific features (like HingeJoint3D `damp`) only work with GodotPhysics, not Jolt.
3. For rendering: glow now processes BEFORE tonemapping in 4.6. Any glow setup must account for this.
4. For GDScript: 4.5 added variadic args (`...`) and `@abstract` -- use these where appropriate instead of workarounds
5. When LLM-generated code produces unexpected behavior, check the breaking changes doc FIRST before debugging the logic
6. Pin specific Godot version in CI/build pipeline to prevent accidental upgrades

**Detection:** Unexpected physics behavior. Rendering differences between expectation and output. GDScript warnings or errors referencing changed APIs. Any time something "should work" but does not.

**Phase:** Ongoing -- every phase. Highest risk in Phase 1-2 when core systems are built.

**Confidence:** HIGH -- breaking changes are documented in the project's own reference files.

---

### Pitfall 9: Audio Garbling and Crackling in WebGL Builds

**What goes wrong:** Audio sounds fine in the editor but crackles, pops, or has gaps in the web export. Engine sounds become a buzzing mess. Impact SFX play with noticeable delay. Music stutters during physics-heavy moments.

**Why it happens:** In Godot web exports, audio mixing is tied to the frame rate when SharedArrayBuffer threading is limited. If the frame rate drops (physics-heavy combat moments), there are not enough audio frames to fill the buffer, causing garbling. This is a known Godot issue documented in the web export progress reports.

**Consequences:** Audio is critical for the "Visceral Impact" pillar. Crackling engine sounds and delayed impact SFX destroy the feeling of speed and power. The signature knockout slow-mo moment sounds terrible if audio is garbling.

**Prevention:**
1. Keep audio assets lightweight: use OGG Vorbis (not WAV) for music, keep SFX short
2. Maintain frame rate above 50 fps at all times -- audio quality degrades with frame drops
3. Limit simultaneous audio streams: prioritize (knockout SFX > weapon impact > engine > ambient)
4. Use an audio bus system with ducking: when a knockout happens, reduce other audio to ensure the impact SFX plays cleanly
5. Test audio quality specifically during worst-case performance scenarios (multi-ragdoll events)
6. Consider pre-mixing some layered sounds rather than playing many streams simultaneously

**Detection:** Play the web export with headphones during a busy combat scene. Any crackling or popping = problem. Test in Firefox specifically -- it handles audio differently from Chrome.

**Phase:** Phase 4 (audio implementation). But frame rate budgeting in Phase 1-2 directly affects audio quality.

**Confidence:** MEDIUM -- documented as a Godot web export issue, but severity depends on frame rate maintenance.

---

### Pitfall 10: The "Walk of Shame" Being Tedious Instead of Funny

**What goes wrong:** The on-foot return-to-bike sequence feels like dead time. The player watches their character slowly walk back to the bike with nothing to do, no input, and no entertainment. What should be a comedy moment becomes a punishment that makes players want to quit.

**Why it happens:** The prototype already flagged this (scored 2/5): walk speed was too fast to be funny but the sequence still felt like downtime. The tension between "comedy requires slow, exaggerated movement" and "player wants to get back to racing quickly" is hard to balance. Without proper animation, sound, and environmental interaction, walking is just... waiting.

**Consequences:** The game's signature mechanic (the crash-fly-remount cycle) ends on a low note every time. Players dread getting knocked off instead of finding it entertaining. The core loop becomes punishing instead of funny.

**Prevention:**
1. The walk must have entertainment value independent of player input: wobble animation, stumble, near-misses with passing bikes, reactive flinch when riders zoom past
2. Keep it SHORT: 3-5 seconds maximum walk time. Comedy has a shelf life.
3. Add environmental comedy: other riders zoom past and honk, the walker trips over debris, gets clipped by a passing bike (small bounce, no damage), shakes fist at passing riders
4. Make the camera work interesting: track the walker while showing the race continuing around them
5. Give minimal player input: maybe tap to sprint slightly faster, or dodge left/right to avoid being run over
6. Sound design sells it: sad trombone, shuffling footsteps, whoosh of bikes passing, comedic "oof" sounds
7. Test by watching someone else get knocked off -- is it funny to watch? If you are not laughing, it is not working.

**Detection:** Time the walk sequence. If > 5 seconds, it is too long. Watch player faces during the walk -- boredom = failure, laughing = success.

**Phase:** Phase 3 (state machine refinement) for timing, Phase 4 (polish) for comedy and animation.

**Confidence:** HIGH -- validated by prototype feedback and fundamental game design principle (dead time kills pacing).

---

## Minor Pitfalls

### Pitfall 11: Physics Tick Rate Mismatch Causing Jitter

**What goes wrong:** The motorcycle and camera stutter or jitter, especially at high speeds. Movement looks smooth at 60 fps but jitters when frame rate varies.

**Prevention:**
1. Enable physics interpolation in project settings (`physics/common/physics_interpolation = true`)
2. Note: Godot 4.5 rearchitected 3D interpolation (moved from RenderingServer to SceneTree). API is the same but verify it works correctly with Jolt in 4.6.
3. Keep physics tick at 60 Hz to match target frame rate
4. Camera must use `_process()` (frame rate) not `_physics_process()` (tick rate) for smooth following

**Phase:** Phase 1 (core movement setup).

---

### Pitfall 12: CSG Primitives Leaking into Production

**What goes wrong:** Prototype used CSG primitives (boxes, spheres, cylinders) for quick visuals. These are computationally expensive for collision and rendering compared to proper meshes. They persist into production through incremental "we will replace them later" thinking.

**Prevention:**
1. Prototype code is explicitly throwaway (documented in project rules)
2. Set a hard deadline: no CSG primitives after Phase 2. All geometry must be proper meshes.
3. CSG is especially bad for WebGL -- each primitive generates draw calls that eat into the limited budget

**Phase:** Phase 2-3 (asset pipeline). Block any milestone completion that still has CSG.

---

### Pitfall 13: Safari WebGL 2 Compatibility Issues

**What goes wrong:** The game loads and plays in Chrome and Firefox but has rendering glitches, crashes, or fails to load in Safari. Safari's WebGL 2 implementation has known issues and inconsistencies.

**Prevention:**
1. Test in Safari early and at every milestone
2. If Safari is not a hard requirement, document it as "best effort" and prioritize Chrome/Firefox
3. Avoid WebGL features known to be problematic in Safari: certain texture formats, some framebuffer configurations
4. The project targets "desktop browsers" -- confirm whether Safari support is required or nice-to-have

**Phase:** Phase 1 (deployment verification).

---

### Pitfall 14: Weapon Durability Math Making Combat Feel Random

**What goes wrong:** Weapons break at unpredictable times. Player picks up a bat, expects to use it several times, and it breaks on the second hit due to durability being tied to damage dealt rather than hit count. The randomness of durability depletion makes combat feel unreliable.

**Prevention:**
1. Make durability depletion deterministic and visible: "This bat has 5 hits remaining" not "This bat has 150 durability points"
2. Show remaining uses on the HUD clearly
3. Never let a weapon break on the first hit (minimum 2 uses)
4. Play a warning effect on the last-hit weapon swing so the player knows it is about to break

**Phase:** Phase 2-3 (combat systems).

---

### Pitfall 15: Lane-Based Movement Creating Invisible Walls

**What goes wrong:** The motorcycle controller uses hard-clamped road boundaries (specified in the GDD). Players steer into the boundary and the bike stops moving laterally with no physical feedback -- it feels like hitting an invisible wall rather than a road edge.

**Prevention:**
1. Road boundaries should have physical barriers (guard rails, barriers) with collision feedback (spark VFX, scraping sound, slight speed reduction)
2. Never use invisible clamping -- always provide visual and audio feedback for boundary contact
3. The GDD mentions "hard-clamped" -- this needs to be implemented as "physical barrier with feedback" not "invisible position clamp"

**Phase:** Phase 2 (track design and movement).

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| Project Setup (Phase 1) | Forward+ renderer selected instead of Compatibility (#1) | Set Compatibility renderer on first project setup. Verify with web export. |
| Project Setup (Phase 1) | Web deployment fails (#2) | Deploy a hello-world web build in week 1. Test CORS headers. |
| Project Setup (Phase 1) | WASM size not baselined (#4) | Measure and record baseline export size. Set size budget. |
| Core Movement (Phase 1-2) | VehicleBody3D temptation (#3) | Use CharacterBody3D. Refer to prototype validation. |
| Core Movement (Phase 1-2) | Physics jitter (#11) | Enable interpolation. Test at variable frame rates. |
| Physics Systems (Phase 2) | Ragdoll performance on WebGL (#5) | Profile ragdoll budget on web early. Set simultaneous ragdoll limit. |
| Physics Systems (Phase 2) | Stale Godot API usage (#8) | Cross-reference breaking-changes.md for every physics API call. |
| Combat Systems (Phase 2-3) | Weapon durability feels random (#14) | Use hit-count durability, not damage-based. Show remaining uses. |
| AI Systems (Phase 3) | Brain-dead or cheating AI (#6) | Build AI test scene. Implement personality system. Budget extra time. |
| State Machine (Phase 3) | Walk of shame is boring (#10) | Keep under 5 seconds. Add environmental comedy. Test with fresh players. |
| Track Design (Phase 2-3) | Invisible walls (#15) | Physical barriers with feedback, never invisible clamping. |
| Polish/Juice (Phase 4) | Juice causes nausea (#7) | Layer effects with hierarchy. Add intensity setting. Default to 70%. |
| Audio (Phase 4) | Audio garbling in WebGL (#9) | Keep frame rate high. Limit audio streams. Test in web build. |
| Art Pipeline (Phase 2-3) | CSG primitives persist (#12) | Hard deadline to replace all CSG. Block milestones with CSG. |
| Browser Compat (Phase 1+) | Safari breaks (#13) | Test Safari early. Document support level. |

---

## Sources

- [Godot Web Export Issues - SharedArrayBuffer](https://github.com/godotengine/godot/issues/85938)
- [Godot Web Export 4.3 Progress Report](https://godotengine.org/article/progress-report-web-export-in-4-3/)
- [Godot Web Export 100% CPU Issue](https://github.com/godotengine/godot/issues/85431)
- [Godot VehicleBody3D Motorcycle Balancing](https://forum.godotengine.org/t/need-help-balancing-a-vehiclebody3d-that-has-2-vehiclewheel3d-aka-a-bike/78984)
- [Arcade-style Car Recipe (KidsCanCode)](https://kidscancode.org/godot_recipes/4.x/3d/3d_sphere_car/index.html)
- [Godot Rendering Overview](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html)
- [Godot Web Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)
- [Optimize Size of Godot Web Releases](https://amann.dev/blog/2025/godot_web_size/)
- [How to Minify Godot Build Size](https://popcar.bearblog.dev/how-to-minify-godots-build-size/)
- [Juice Problem in Game Design (Wayline)](https://www.wayline.io/blog/the-juice-problem-how-exaggerated-feedback-is-harming-game-design)
- [6 Mistakes That Drain Juice (Game Developer)](https://www.gamedeveloper.com/design/6-mistakes-that-ll-drain-the-juice-out-of-your-game)
- [Godot Ragdoll System Docs](https://docs.godotengine.org/en/stable/tutorials/physics/ragdoll_system.html)
- [Active Ragdoll with Jolt Physics Discussion](https://forum.godotengine.org/t/active-ragdoll-with-jolt-physics/122856)
- [Godot SharedArrayBuffer Proposal](https://github.com/godotengine/godot-proposals/issues/6616)
- [Compatibility Renderer Startup Time Issue](https://github.com/godotengine/godot/issues/106310)
- Project files: `docs/engine-reference/godot/breaking-changes.md`, `prototypes/combat-racing-core/REPORT.md`, `design/gdd/motorcycle-controller.md`
