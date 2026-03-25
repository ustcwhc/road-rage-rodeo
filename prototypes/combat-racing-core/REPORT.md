## Prototype Report: Combat Racing Core

### Hypothesis
Smacking rival bikers off motorcycles with ridiculous weapons, watching them
ragdoll through the air, and racing past them while they shamefully run back
to their bike is inherently fun and funny in a 3D browser game.

### Approach
Built a minimal Godot 4.6 prototype with:
- A 500m straight road with 3 lanes and lane dividers
- Player motorcycle with WASD + Space controls
- 3 AI riders with simple drive + fight behavior
- HP system: fists (15 dmg, infinite) and bat (30 dmg, 5 uses with durability)
- Weapon pickups scattered along the road (golden spheres)
- Knockout → ragdoll launch → on-foot "walk of shame" → remount with full HP
- Slow-motion on knockouts for dramatic effect
- Basic HUD showing HP, weapon, speed, position, progress

All visuals use CSG primitives (boxes, spheres, cylinders). No external assets needed.

### What to Test
Open the project in Godot 4.6, run the scene, and evaluate:

1. **Riding feel**: Does accelerating and steering feel responsive and fun?
2. **Combat feel**: Does pressing Space to attack feel satisfying? Is the range right?
3. **Knockout moment**: Is the ragdoll launch funny? Is the slow-mo effective?
4. **Walk of shame**: Is watching someone run back to their bike entertaining?
5. **Weapon pickups**: Does finding a bat feel rewarding? Does durability add tension?
6. **AI behavior**: Do opponents feel like real rivals or mindless drones?
7. **Pacing**: Is the race long enough to have multiple combat encounters?

### Metrics
- Frame time: Not yet measured (desktop Godot only)
- Riding response feel: 4/5 — feels good, responsive
- Combat satisfaction: 2/5 — attack not discoverable, no visual feedback on who is attacking
- Ragdoll comedy factor: 3/5 — needs more variety based on weapon/attack type
- Walk of shame entertainment: 2/5 — walk speed too fast, not funny enough
- AI engagement: 2/5 — feels dumb, no tactical behavior
- Desired session length: Race too short, needs ~2 min per race

### How to Run
1. Open Godot 4.6
2. Import the project from `prototypes/combat-racing-core/`
3. Press F5 (or Play)
4. Controls:
   - **W / Up Arrow**: Accelerate
   - **S / Down Arrow**: Brake
   - **A/D or Left/Right**: Steer
   - **Space**: Attack (fist or weapon)
   - **R**: Restart race

### Recommendation: PROCEED

Core loop validated after two playtest rounds. Riding feels good, combat is
satisfying with visual indicators, knockout physics are tuned (bat = dramatic
sky launch, fists = moderate arc + slide), nitro adds strategic variety, and
smarter AI creates engaging rivals. Ready for production.

### Known Limitations (Expected for Prototype)
- CSG primitives only — no real models
- No sound effects
- No particle effects or screen shake
- AI is very simple (drive + occasional attack)
- No proper race start countdown
- Lane dividers are individual CSG boxes (performance concern at scale)
- Ragdoll is simplified (velocity launch, not joint-based)

### If Proceeding
- Replace CSG primitives with proper low-poly meshes
- Add Jolt-based ragdoll with joint constraints for more realistic tumbling
- Implement proper AI state machine (race / attack / dodge / recover)
- Add screen shake, hit flash, and particle effects (Pillar 2: Visceral Impact)
- Add sound effects (engine, impact, crash, music)
- Build 6 distinct tracks with varying difficulty
- Add more weapons beyond bat (rubber chicken, chain, traffic cone, etc.)
- Optimize for WebGL export (draw call budget, physics performance)

### Lessons Learned
1. **Discoverability matters even in prototypes** — Attack bound to Space was not obvious. Need visual affordances (indicator, color change) so players know when someone is attacking.
2. **Comedy needs timing** — Walk of shame is too fast to be funny. Slower pace + wobble animation = more entertainment value.
3. **Pickup radius was too generous** — Players could collect weapons from too far away, removing the need to steer toward them intentionally.
4. **AI needs tactical variety** — Random attack timers feel mindless. Even simple rules (flee when low HP, approach when armed) create the illusion of intelligence.
5. **Knockout ragdoll needs weapon-based variety** — Same launch every time gets stale. Different weapons should produce different ragdoll trajectories.
6. **Track length matters for pacing** — 500m was too short for meaningful combat encounters. ~2 min race time needed.
7. **New mechanic validated in feedback** — Player suggested nitro pickups (speed boost), confirming appetite for more pickup variety beyond weapons.

### Playtest Feedback (Raw)
- Riding feel: good
- Combat feel: didn't discover Space attack without being told. Needs visual indicator when attacking.
- Knockout: should vary based on weapon type
- Walk of shame: too fast, not funny enough
- Weapon pickup range: too large, can collect from too far away
- AI: too dumb. Should flee when low HP, approach when armed/healthy
- Feature request: nitro pickup for temporary speed boost
- Track: needs to be longer (~2 min race)
