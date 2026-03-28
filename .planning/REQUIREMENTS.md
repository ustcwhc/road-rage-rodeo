# Requirements: Road Rage Rodeo

**Defined:** 2026-03-28
**Core Value:** The crash-and-combat experience must be hilarious and visceral — every knockout produces spectacular ragdoll comedy, every weapon hit feels powerful and satisfying.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Foundation

- [ ] **FOUND-01**: Project uses Compatibility renderer from day one (WebGL-only renderer)
- [ ] **FOUND-02**: WebGL export pipeline verified — game loads and runs in desktop browser
- [ ] **FOUND-03**: WASM size tracked and kept under 10 MB with Brotli compression
- [ ] **FOUND-04**: Input system maps keyboard (WASD + arrow keys) to game actions with configurable bindings
- [ ] **FOUND-05**: GameEvents autoload signal bus established for cross-system communication
- [ ] **FOUND-06**: Physics interpolation enabled to prevent visual jitter at fixed timestep

### Track

- [ ] **TRCK-01**: At least 3 distinct point-to-point tracks with unique visual themes and hazards (stretch: 6)
- [ ] **TRCK-02**: Each track has traffic and obstacles that create weaving/dodging challenges
- [ ] **TRCK-03**: Tracks use MeshInstance3D/MultiMeshInstance3D (no CSG nodes in production)
- [ ] **TRCK-04**: Track difficulty escalates across levels — faster speeds, tighter roads, more hazards
- [ ] **TRCK-05**: Weapon and nitro pickup spawn points placed along each track

### Motorcycle

- [ ] **MOTO-01**: Arcade motorcycle controls feel responsive — accelerate, steer, brake via CharacterBody3D
- [ ] **MOTO-02**: Sense of speed — FOV widening, camera effects, environmental blur at high speed
- [ ] **MOTO-03**: Road boundary feedback — visible barriers, not invisible walls
- [ ] **MOTO-04**: Node-based state machine with 5 states: RIDING, FLYING, SLIDING, LYING, ON_FOOT
- [ ] **MOTO-05**: Full state transition cycle works: RIDING → (knockout) → FLYING → SLIDING → LYING → ON_FOOT → (remount) → RIDING

### Camera

- [ ] **CAM-01**: Third-person chase camera follows rider across all 5 states
- [ ] **CAM-02**: Camera has state-aware offsets — different behavior for riding vs flying vs on-foot
- [ ] **CAM-03**: Camera briefly follows ragdoll flight before snapping back (dynamic knockout camera)

### Health

- [ ] **HLTH-01**: All riders have visible HP bars
- [ ] **HLTH-02**: Riders take damage from weapon hits and environmental collisions
- [ ] **HLTH-03**: At zero HP, rider is knocked off bike and enters FLYING state
- [ ] **HLTH-04**: Full HP restored on remount — comeback mechanic, not elimination

### Weapons

- [ ] **WEAP-01**: 6-8 weapons with unique damage, durability, range, and ragdoll effects
- [ ] **WEAP-02**: Weapons defined as Resource files (.tres) for data-driven tuning
- [ ] **WEAP-03**: Weapon pickups scattered along tracks — tighter pickup radius than prototype
- [ ] **WEAP-04**: Weapon durability system — limited uses, reverts to fists when broken
- [ ] **WEAP-05**: Fists always available as baseline weapon (infinite durability, lower damage)

### Combat

- [ ] **CMBT-01**: Melee combat while riding — swing weapon at adjacent riders
- [ ] **CMBT-02**: Visual combat affordances — attack indicators so players know when someone is attacking
- [ ] **CMBT-03**: Each weapon produces a distinct ragdoll trajectory on knockout (bat = sky launch, chain = horizontal whip, etc.)
- [ ] **CMBT-04**: Combat feels visceral — screen shake on hit, hit flash on contact, slow-mo on knockout

### Crash & Fly

- [ ] **CRSH-01**: Knockout launches rider into exaggerated ragdoll flight (comedy over realism)
- [ ] **CRSH-02**: Ragdoll trajectory varies by weapon type that delivered the knockout
- [ ] **CRSH-03**: Walk of shame is slow and funny — wobble animation, near-misses with traffic
- [ ] **CRSH-04**: Bike marker visible so rider knows where to run back to
- [ ] **CRSH-05**: Simultaneous active ragdolls capped at 2-3 for WebGL performance
- [ ] **CRSH-06**: Object pooling for bike markers, particles, and knockout effects (no create/destroy per knockout)

### AI

- [ ] **AI-01**: AI riders race the track — follow path, avoid obstacles, maintain speed
- [ ] **AI-02**: AI riders fight — target nearby riders, use weapons, attack at appropriate range
- [ ] **AI-03**: AI has tactical behavior — flee when low HP, aggressive when armed, vary by personality
- [ ] **AI-04**: AI personalities vary (aggressive/defensive/balanced) to create diverse rival encounters
- [ ] **AI-05**: 4-6 AI riders per race that feel like real rivals, not pylons

### Race

- [ ] **RACE-01**: Race start with countdown, race flow with position tracking, finish with results
- [ ] **RACE-02**: Position display shows player rank among all riders during race
- [ ] **RACE-03**: Level progression — beat level 1 to unlock level 2, through level 6
- [ ] **RACE-04**: Instant restart — retry any level in under 2 seconds
- [ ] **RACE-05**: Level select screen for replaying completed levels

### HUD

- [ ] **HUD-01**: HP bar for player and visible HP for nearby rivals
- [ ] **HUD-02**: Current weapon and durability indicator
- [ ] **HUD-03**: Speed indicator
- [ ] **HUD-04**: Race position (e.g., "3rd of 6")
- [ ] **HUD-05**: Progress bar showing distance to finish line

### Juice & Feedback

- [ ] **JUICE-01**: Screen shake on weapon hits (intensity varies by weapon)
- [ ] **JUICE-02**: Slow-motion on knockouts (0.3-0.5s, per-rider not global Engine.time_scale)
- [ ] **JUICE-03**: Hit flash on weapon contact
- [ ] **JUICE-04**: Impact freeze (brief hit-stop) on knockout blow
- [ ] **JUICE-05**: CPUParticles3D for hit sparks, crash debris, dust trails (no GPUParticles3D on WebGL)
- [ ] **JUICE-06**: Juice intensity configurable via settings (accessibility)

### Audio

- [ ] **AUD-01**: Engine sound loop that varies with speed
- [ ] **AUD-02**: Weapon impact sound effects — distinct per weapon type
- [ ] **AUD-03**: Crash and ragdoll launch sounds
- [ ] **AUD-04**: Background music (at least 1 track, stretch: per-level music)
- [ ] **AUD-05**: Audio autoplay splash screen (browser requirement)

### Polish

- [ ] **PLSH-01**: Title screen with game branding
- [ ] **PLSH-02**: Level select UI
- [ ] **PLSH-03**: Race results screen showing final positions
- [ ] **PLSH-04**: Browser compatibility verified — Chrome, Firefox, Edge minimum; Safari best-effort
- [ ] **PLSH-05**: 60fps target maintained with 6 riders on screen

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Expanded Content

- **V2-01**: Nitro/boost pickups as additional contested resource on track
- **V2-02**: Environmental knockoffs — collision with signs/traffic causes crash
- **V2-03**: Per-level weapon roster evolution — new weapons introduced each level
- **V2-04**: Position-aware item distribution (light rubber-banding for trailing players)

### Social

- **V2-05**: Screenshot/clip capture for sharing spectacular crashes
- **V2-06**: Leaderboards for best times per track

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Multiplayer/networking | Networking adds 2-4 weeks; single-player scope is already ambitious for 1 month |
| Persistent progression/unlocks | Not a progression game — fun is in the moment, not the metagame |
| Vehicle customization/upgrades | One bike perfected > 5 mediocre bikes; solo dev timeline |
| Projectile weapons | Melee-only preserves Road Rash's intimate side-by-side tension |
| Lap-based racing | Point-to-point matches "highway gauntlet" identity |
| Full replay system | Dynamic knockout camera gives replay feeling for 10% of effort |
| Procedural track generation | 6 handcrafted tracks > inconsistent procedural quality |
| Minimap | Linear point-to-point tracks don't benefit from minimap |
| Difficulty settings menu | 6-level structure IS the difficulty curve |
| Mobile support | Touch controls for melee combat while steering = terrible UX |
| Story/cutscenes | Zero narrative value for a 15-minute arcade brawler |
| Native desktop builds | WebGL is the target; native adds build/test matrix complexity |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| (populated during roadmap creation) | | |

**Coverage:**
- v1 requirements: 56 total
- Mapped to phases: 0
- Unmapped: 56

---
*Requirements defined: 2026-03-28*
*Last updated: 2026-03-28 after initial definition*
