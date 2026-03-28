# Feature Landscape

**Domain:** 3D Arcade Combat Racing (Browser / WebGL)
**Researched:** 2026-03-28
**Confidence:** MEDIUM-HIGH (well-established genre with clear precedents)

---

## Table Stakes

Features users expect from a combat racing game. Missing any of these and the game feels broken or incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Responsive arcade controls** | Players judge racing games in the first 5 seconds of steering. Sluggish or floaty = instant bounce. | Med | Prototype scored 4/5 -- validated. Needs tuning for WebGL input latency. |
| **Sense of speed** | Racing without speed sensation is just driving. FOV widening, motion blur, camera shake, environmental blur streaks. | Med | Road Rash and every arcade racer since Pole Position nails this. Non-negotiable. |
| **Weapon pickups on track** | The genre-defining mechanic from Road Rash and Mario Kart. Players expect to grab weapons from the road. | Low | Already prototyped. Pickup radius was too generous per playtest -- tighten it. |
| **Melee/weapon combat while riding** | This IS the game. Swinging weapons at adjacent riders is the core differentiator from pure racing. | Med | Prototype scored 2/5 on discoverability. Needs visual combat affordances (attack indicators, range preview). |
| **Health system with visible HP** | Players need to know how close they are to being knocked off and how close rivals are to knockout. | Low | Simple HP bars on all riders. Already prototyped. |
| **Knockout/crash with ragdoll** | The payoff moment. Getting knocked off must be spectacular, not just a respawn. Ragdoll physics = comedy + visceral feedback. | Med-High | Prototype validated the concept. Needs weapon-specific ragdoll trajectories (bat = sky launch, chain = horizontal whip). |
| **Remount mechanic** | The "walk of shame" is Road Rage Rodeo's signature loop. Without it, knockout is just frustrating elimination. Full HP restore on remount = comeback mechanic. | Med | Prototype found walk speed too fast (2/5). Needs slower pace + wobble animation for comedy value. |
| **AI opponents that race AND fight** | Single-player combat racing lives or dies on AI quality. Opponents must feel like rivals, not pylons. | High | Highest-risk system. Prototype AI scored 2/5 -- "too dumb." Needs tactical behavior: flee when hurt, approach when armed, vary aggression. |
| **Third-person chase camera** | Standard for arcade racers since Pole Position (1982). Provides spatial awareness for both racing and combat. | Med | Needs combat-aware behavior: widen FOV during fights, track knockout ragdoll flights, dynamic tilt on turns. |
| **HUD (HP, weapon, speed, position)** | Players need constant feedback on race state and combat state. | Low | Standard racing HUD + weapon durability indicator. Already in prototype. |
| **Multiple tracks with difficulty progression** | One track is a demo, not a game. 6 tracks with escalating difficulty is the project target. | High (content) | Each track needs distinct visual identity, hazards, and pacing. This is the biggest content investment. |
| **Race start/finish structure** | Players expect a clear start (countdown), race flow (laps or point-to-point), and finish (results). | Low | Race Manager system. Standard pattern. |
| **Weapon variety** (4-6 minimum) | Same weapon every time gets stale fast. Each weapon needs distinct feel, damage, durability, and ragdoll effect. | Med | Prototype lesson: ragdoll variety per weapon is critical. Bat vs. fists vs. chain must feel completely different. |
| **Traffic/obstacles on track** | Environmental hazards add tension and skill expression. Weaving through traffic while fighting is the core challenge. | Med | Validates Road Rash's design -- interactive environment with signs, vehicles, barriers. |
| **Audio feedback** | Engine sounds, weapon impact SFX, crash sounds. Pillar 2 (Visceral Impact) cannot exist without audio. | Med | No audio in prototype. Critical for production -- a silent hit feels like nothing. |
| **Instant restart** | Browser game players have zero patience. Must be able to retry a level in under 2 seconds. | Low | Essential for "one more try" retention. |

---

## Differentiators

Features that set Road Rage Rodeo apart from competitors. Not expected, but when present, they create memorable moments and competitive advantage.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Exaggerated ragdoll comedy** | The signature hook. Not just "you crashed" but "you flew 50 meters, bounced off a truck, and landed in a ditch." Happy Wheels proved ragdoll-as-comedy is inherently shareable. | Med-High | Push beyond realistic. Pillar 1 (Hilarious Chaos) demands exaggeration over simulation. Different weapons = different flight trajectories = comedy variety. |
| **Slow-mo knockout moments** | Brief slow-motion on knockout hit creates the "did you see that?!" moment. Screamer (2026) uses similar hit-pause mechanics. | Low-Med | Already in prototype. Needs tuning: too long = tedious, too short = missed. 0.3-0.5s sweet spot. |
| **Walk of shame as comedy mechanic** | Unique to Road Rage Rodeo. The wobbling run back to the bike IS the joke. Other racers just respawn you -- this game makes the failure state funny. | Med | Needs animation investment: wobble, stumble, dodge traffic on foot. The slower and funnier this is, the better the game's identity. |
| **Screen shake + hit flash + impact freeze** | Layered "juice" that makes every hit feel powerful. Screen shake on impact, brief white flash on contact, hit-stop freeze frame on knockout. | Med | Pillar 2 (Visceral Impact). Research confirms: screen shake simulates physical impact, hit-stop reinforces collision weight. These are cheap to implement, massive ROI on feel. |
| **Weapon durability as tactical resource** | Not just "pick up weapon, use until bored." Limited uses force decisions: save the bat for the leader? Burn it on a nearby rival? Revert to fists when broken. | Low | Already in prototype. Creates a tactical layer on top of moment-to-moment combat. |
| **Position-aware item distribution** | Mario Kart's core insight: give better items to trailing players. For Road Rage Rodeo: better weapons spawn more frequently for players behind, worse weapons for the leader. | Low-Med | Subtle rubber-banding that keeps races competitive without feeling unfair. The crash-remount cycle already provides natural catch-up, so this can be light-touch. |
| **Environmental knockoffs** | Getting knocked into a sign, barrier, or oncoming traffic should cause a crash -- not just weapon hits. Creates environmental awareness and "did that just happen?" moments. | Med | Road Rash had this with signs and traffic. Extends combat beyond melee to positioning warfare. |
| **Nitro/boost pickups** | Playtest feedback requested this. Speed boost pickups add another contested resource on the track beyond weapons. | Low | Validated by player suggestion in prototype. Simple to implement, adds variety to pickup ecosystem. |
| **Dynamic camera on knockouts** | Camera briefly follows the ragdoll flight before snapping back to the bike. Creates a cinematic "replay" moment without a replay system. | Med | Much cheaper than a full replay system. Achieves the "watch this crash" feeling organically. |
| **Per-level weapon roster evolution** | Early levels: fists + bat. Later levels: chain, rubber chicken, traffic cone. New weapons per level = discovery incentive to keep playing. | Low (design) | Content-gated, not code-gated. Same weapon system, different spawn tables per track. |

---

## Anti-Features

Features to explicitly NOT build. Each one has been considered and rejected with clear reasoning.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **Persistent progression / unlocks** | Skill trees, garages, and upgrade paths add weeks of design and balancing work for a 15-minute arcade game. They also gate the fun behind grind. Anti-Pillar: "NOT a deep progression game." | Pure pick-up-and-play. All weapons available via track pickups. Fun is in the moment, not the metagame. |
| **Vehicle customization / upgrades** | Vehicle variety means balancing multiple handling models, speeds, and stats. Solo dev, 1-month timeline. One motorcycle that feels great beats 5 that feel mediocre. | One bike model, one handling model, perfected. Variety comes from weapons and tracks, not vehicle stats. |
| **Multiplayer / networking** | Networking adds 2-4 weeks of development (netcode, lobbies, sync, latency compensation) for a single-player-scoped project. Already explicitly out of scope. | Strong AI rivals that feel like human opponents. Shareability through screenshots/clips replaces live multiplayer social element. |
| **Projectile weapons** (guns, missiles, thrown items with tracking) | Projectile weapons require ballistics, collision detection at range, targeting UI, and dodge mechanics. They also shift the game from Road Rash's intimate melee brawl to Mario Kart's ranged item spam. | Melee-only combat preserves the "riding side by side" tension. Thrown items (rubber chicken) are arc-based and short-range, not homing projectiles. |
| **Lap-based racing** | Road Rash used point-to-point races, not laps. Laps dilute the "dangerous highway" fantasy and require loop track design. Point-to-point matches the "highway gauntlet" identity. | Point-to-point races: start line to finish line, one direction. Each track is a unique route, not a circuit. |
| **Full replay system** | Replay recording, playback UI, camera controls -- significant engineering for a short arcade game. | Dynamic knockout camera (brief ragdoll follow) gives the "replay moment" feeling for 10% of the effort. |
| **Procedural track generation** | Handcrafted tracks are better for a 6-track game. Procedural generation adds complexity and inconsistent quality. Already out of scope. | 6 hand-designed tracks with escalating difficulty, distinct visual themes, and curated hazard placement. |
| **Minimap** | Combat racing at high speed on a highway doesn't benefit from a minimap. The track is essentially linear (point-to-point). A minimap adds UI clutter without adding useful information. | Progress bar showing distance to finish + position indicator is sufficient. |
| **Difficulty settings menu** | Adds UI complexity and splits the balancing target. The 6-level structure IS the difficulty curve. | Level 1 is easy. Level 6 is hard. The game teaches through escalation, not settings. |
| **Mobile support** | Touch controls for melee combat while steering a motorcycle is a terrible UX. Desktop browser is the target. | Keyboard + mouse only. Optimize for desktop browsers at 60fps. |
| **Story / cutscenes** | Zero narrative value for a 15-minute arcade brawler. Development time wasted on non-core content. | Pure arcade: title screen, level select, race, results. No cutscenes, no dialogue, no lore. |

---

## Feature Dependencies

```
Input System ──────────────────────────────┐
Track System ──────────────────────────────┤
                                           ▼
Health System ───────► Weapon System ───► Melee Combat ───► AI Riders
                           │                    │               │
                           ▼                    ▼               ▼
Motorcycle Controller ─────┴──► Crash & Fly   Race Manager ──► Level Progression
       │                            │               │
       ▼                            ▼               ▼
Camera System ─────────────► Juice & Feedback    HUD
                                    │
                                    ▼
                              Audio System
```

Key dependency chains that constrain build order:

1. **Controls must come first**: Input System + Motorcycle Controller must feel right before anything builds on top. Prototype validated this.
2. **Combat before AI**: Weapon System + Melee Combat define the combat rules that AI must understand and use.
3. **AI is the integration point**: AI Riders depend on almost everything (controller, combat, weapons, track). It is the last MVP system to build and the highest risk.
4. **Juice is a layer, not a system**: Screen shake, hit flash, slow-mo, and particles overlay on top of combat and crash systems. They can be added incrementally without blocking anything.
5. **Audio is independent but critical**: Can be added in parallel with other systems but must not be deferred past alpha. Silent combat violates Pillar 2.

---

## MVP Recommendation

### Must ship (Table Stakes, no exceptions):

1. **Arcade motorcycle controls** -- the foundation everything rides on (pun intended)
2. **Melee combat with 3+ weapons** -- fists, bat, and one more. Each must feel distinct.
3. **Knockout ragdoll with weapon-specific trajectories** -- the signature moment
4. **Walk of shame remount** -- the comedy payoff and comeback mechanic
5. **AI opponents with tactical behavior** -- flee/attack/chase states minimum
6. **3 distinct tracks** (stretch to 6) -- point-to-point, escalating difficulty
7. **HUD** -- HP, weapon, speed, position, progress
8. **Audio** -- engine, impacts, crashes at minimum. Music is nice-to-have.
9. **Basic juice** -- screen shake on hit, slow-mo on knockout. Cheap, massive impact.

### Defer to polish phase:

- **Nitro pickups**: Fun but not core. Add after weapon system is solid.
- **Environmental knockoffs**: Requires additional collision logic. Add after core combat works.
- **Dynamic knockout camera**: Requires camera system maturity. Add after basic chase cam.
- **Position-aware item distribution**: Requires race manager + spawn system integration. Fine-tune late.
- **Per-level weapon roster**: Content decision, not code decision. Define spawn tables after weapons are built.

### Cut if timeline demands it:

- Tracks 4-6 (ship 3 good tracks over 6 mediocre ones)
- Walk of shame animation polish (functional first, funny second)
- Slow-mo duration tuning per weapon type

---

## Sources

- [Road Rash - Wikipedia](https://en.wikipedia.org/wiki/Road_Rash) -- core genre reference
- [Road Rash retrospective - Fextralife](https://fextralife.com/retrospective-road-rash/) -- what made Road Rash fun
- [Rubber-Banding as a Design Requirement - Gamedeveloper.com](https://www.gamedeveloper.com/design/rubber-banding-as-a-design-requirement) -- Mario Kart catch-up mechanics
- [Vehicular Combat Game - Wikipedia](https://en.wikipedia.org/wiki/Vehicular_combat_game) -- genre feature survey
- [Stainless Games on vehicular combat design - Unreal Engine](https://www.unrealengine.com/en-US/developer-interviews/stainless-games-explains-how-to-design-a-modern-vehicular-combat-game) -- modern combat vehicle design
- [25 Best Combat Racing Games - Ultra Fanboy](https://ultrafanboy.com/best-combat-racing-games/) -- genre landscape 2025
- [Screamer on Steam](https://store.steampowered.com/app/2814990/Screamer/) -- 2026 combat racing reference
- [Screen Shake and Hit Stop research - Oreate AI](https://www.oreateai.com/blog/research-on-the-mechanism-of-screen-shake-and-hit-stop-effects-on-game-impact/decf24388684845c565d0cc48f09fa24) -- game feel research
- [Game Feel beginner guide - Game Design Skills](https://gamedesignskills.com/game-design/game-feel/) -- juice and feedback design
- [Racing Game Mechanics guide - JuegoStudio](https://www.juegostudio.com/blog/racing-game-mechanics) -- racing game mechanics overview
- [Browser Racing Games 2025 - Game Duddles](https://www.gameduddles.com/blog/best-racing-games-browser-2025) -- browser racing landscape
- [A Rational Approach to Racing Game Track Design - Gamedeveloper.com](https://www.gamedeveloper.com/design/a-rational-approach-to-racing-game-track-design) -- track design principles
