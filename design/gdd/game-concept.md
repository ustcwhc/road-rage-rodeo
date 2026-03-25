# Game Concept: Road Rage Rodeo

*Created: 2026-03-23*
*Status: Draft*

---

## Elevator Pitch

> It's a 3D combat racing game where you ride motorcycles on increasingly dangerous
> highways, pick up ridiculous weapons to beat rival bikers off their bikes, and
> watch them ragdoll through the air before they have to shamefully run back to
> remount — all in your desktop browser.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | 3D Combat Racing / Vehicular Combat |
| **Platform** | Desktop Browser (WebGL) |
| **Target Audience** | Casual-to-mid-core gamers who enjoy arcade action and slapstick humor |
| **Player Count** | Single-player (vs AI opponents) |
| **Session Length** | 15-20 minutes (full playthrough), 2-3 minutes per race |
| **Monetization** | Free (jam game) |
| **Estimated Scope** | Small (1 week jam) |
| **Comparable Titles** | Road Rash (EA, 1991), Mario Kart (weapon pickups), Happy Wheels (ragdoll comedy) |

---

## Core Fantasy

You're the most dangerous rider on the highway. You swing bats, hurl rubber
chickens, and smash rivals off their bikes at high speed. Every race is a chaotic
brawl where spectacular crashes send riders flying through the air — and the
funniest part is watching them get up and waddle back to their bike while everyone
else zooms past.

This is the power fantasy of being an unstoppable road warrior combined with the
joy of slapstick physical comedy. You can't get this feeling from a clean racing
game or a pure fighting game — it lives in the collision between the two.

---

## Unique Hook

Like Road Rash, AND ALSO every knockout launches riders into spectacular ragdoll
flights — and they have to run back to their bike on foot with full health restored,
creating hilarious "walk of shame" moments and natural comeback mechanics.

The crash-fly-run-remount cycle is the signature mechanic. It turns what would be
a frustrating elimination into the funniest moment of the race.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 1 | Visceral hit impacts, slow-mo ragdoll flights, screen shake, crash sound effects |
| **Fantasy** (make-believe, role-playing) | 3 | Being an untouchable highway warrior swinging ridiculous weapons |
| **Narrative** (drama, story arc) | N/A | No story — pure arcade action |
| **Challenge** (obstacle course, mastery) | 2 | 6 escalating levels, weapon timing mastery, positioning skill |
| **Fellowship** (social connection) | 5 | Shareable "you won't believe this crash" moments |
| **Discovery** (exploration, secrets) | 4 | Finding new weapons, learning what each one does |
| **Expression** (self-expression, creativity) | N/A | Not a focus for jam scope |
| **Submission** (relaxation, comfort zone) | N/A | This game is adrenaline, not relaxation |

### Key Dynamics (Emergent player behaviors)

- Players will position alongside rivals to land weapon hits before pulling ahead
- Players will time weapon usage to conserve durability for critical moments
- Players will deliberately knock rivals into traffic/obstacles for spectacular crashes
- Players will race to weapon pickups, creating contested zones on the track
- Players who get knocked off will sprint back to their bike, creating tense "will I catch up?" moments

### Core Mechanics (Systems we build)

1. **Motorcycle Racing** — arcade-style 3D riding with steering, acceleration, and traffic/obstacle avoidance
2. **Melee Combat** — weapon swinging/throwing while riding, directional attacks on adjacent riders
3. **Health System** — riders have HP (blood), take damage from weapons and crashes, knocked off at zero
4. **Weapon Pickup & Durability** — collect weapons from the road, each with unique damage and durability; reverts to fists when broken
5. **Crash & Fly System** — ragdoll launch on knockout/crash, on-foot run back to bike, full HP restore on remount

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** (freedom, meaningful choice) | Choose when to fight vs. race, which weapons to grab, who to target | Supporting |
| **Competence** (mastery, skill growth) | Improve weapon timing, learn to dodge, master each track's hazards | Core |
| **Relatedness** (connection, belonging) | Shared laughter moments, "watch this crash" social sharing | Minimal |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — Beat all 6 levels, improve placement
- [ ] **Explorers** (discovery, understanding systems, finding secrets) — Minor: discover weapon behaviors
- [x] **Socializers** (relationships, cooperation, community) — Share spectacular crash moments
- [x] **Killers/Competitors** (domination, PvP, leaderboards) — Knock every rival off their bike, finish first

### Flow State Design

- **Onboarding curve**: Level 1 is a straight highway with slow opponents and plentiful weapons — learn to ride, pick up, and swing in 30 seconds
- **Difficulty scaling**: Each level adds speed, more aggressive AI, tighter roads, and opponents with better weapons
- **Feedback clarity**: HP bars visible on all riders, weapon durability indicator, position display, slow-mo on knockouts confirms impact
- **Recovery from failure**: Getting knocked off isn't game over — you fly, run back, remount with full HP. You lose position, not progress. Retry any level instantly.

---

## Core Loop

### Moment-to-Moment (30 seconds)
Race forward on your motorcycle, weave through traffic and obstacles. Spot a weapon
pickup on the road — grab it. Pull alongside a rival, swing your bat / hurl your
rubber chicken — SMACK. Watch their HP drop. Land the knockout blow and see them
ragdoll off their bike in spectacular fashion. Or get hit yourself, lose HP, and
fight back. At zero HP, you launch off the bike, ragdoll through the air, land,
and sprint back to remount with full health — behind, but not out.

### Short-Term (2-3 minutes — one race)
Complete one level: race from start to finish while fighting rival bikers. Manage
weapon durability (save your good weapon for tough opponents, or burn it early?).
Try to finish in the highest position possible. Each race has a clear start and
end line with 4-6 AI opponents.

### Session-Level (15-20 minutes — full playthrough)
Play through all 6 levels in order, easy to hard. Each level introduces new
challenges: faster speeds, more aggressive opponents, more dangerous roads.
Natural stopping point after each level. The full run is short enough to replay
for better performance.

### Long-Term Progression
For jam scope, progression is purely level-based: beat level 1, unlock level 2,
through to level 6. Replayability comes from improving placement and chasing
personal best performances. No persistent upgrades or unlocks.

### Retention Hooks
- **Curiosity**: "What's the next level like? What new weapons appear?"
- **Investment**: Minimal — jam game, pick-up-and-play
- **Social**: "You have to see this crash I just had"
- **Mastery**: "I can definitely beat level 5 if I manage my weapon durability better"

---

## Game Pillars

### Pillar 1: Hilarious Chaos
Every race should produce at least one moment that makes you laugh out loud —
a spectacular ragdoll flight, a chain-reaction pileup, or a perfectly timed
knockout.

*Design test*: If choosing between a realistic physics outcome and a funnier one,
choose funny. Exaggerate the ragdoll. Make the crashes bigger. Comedy over simulation.

### Pillar 2: Visceral Impact
Every hit, crash, and knockout must FEEL powerful — screen shake, slow-mo, ragdoll
physics, satisfying sound effects. Weapons must feel different from each other.

*Design test*: If a weapon doesn't feel satisfying to land, it's not ready. If a
crash doesn't make you wince and laugh, add more juice.

### Pillar 3: Easy to Play, Hard to Master
Anyone can pick up a weapon and start smashing in 30 seconds. Mastering weapon
timing, durability management, positioning, and traffic avoidance separates good
riders from great ones.

*Design test*: If a mechanic needs a tutorial longer than one sentence, simplify it.

### Anti-Pillars (What This Game Is NOT)

- **NOT a simulation**: Physics serve comedy, not realism. If a crash looks funnier with exaggerated ragdoll, do that. Motorcycles handle like arcade vehicles, not real bikes.
- **NOT a deep progression game**: No skill trees, no garage, no upgrades, no unlockable bikes. Pick up and play. The fun is in the moment, not the metagame.
- **NOT competitive esports**: Chaos is the point. Unfair moments are funny, not frustrating. Balance serves fun, not fairness.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Road Rash (EA, 1991) | Highway combat racing, melee weapons on bikes, gritty tone | 3D instead of 2D, ragdoll physics, crash-fly-remount cycle, browser-based | Validates the core concept — combat racing on motorcycles is inherently fun |
| Mario Kart (Nintendo) | Weapon pickups on the track, rubber-banding, accessible controls | Gritty tone instead of cute, melee-focused instead of projectile-focused, HP system instead of instant effects | Validates that weapon pickups + racing = replayable fun |
| Happy Wheels (Jim Bonacci) | Ragdoll physics as comedy, spectacular crashes as the main attraction | Structured racing game instead of sandbox, consistent 3D art style | Validates that ragdoll crashes are inherently entertaining and shareable |

**Non-game inspirations**: Road Rash's original gritty highway aesthetic, slapstick physical comedy (Jackass, Tom & Jerry-style over-the-top violence that's funny rather than graphic), demolition derby culture.

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 16-35 |
| **Gaming experience** | Casual to mid-core — comfortable with WASD/arrow keys |
| **Time availability** | 15-30 minute sessions, often during breaks |
| **Platform preference** | Desktop browser — no install, play instantly |
| **Current games they play** | Browser action games, Krunker, Shell Shockers, retro game fans |
| **What they're looking for** | Quick, visceral fun with no commitment — something to play during a break that makes them laugh |
| **What would turn them away** | Slow start, complex controls, mandatory tutorials, pay-to-play |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot 4.6 — GDScript for fast jam development, built-in 3D physics for ragdoll, WebGL export for browser target. Repo already has Godot version docs pinned. |
| **Key Technical Challenges** | 3D motorcycle physics that feel arcade-fun (not realistic), ragdoll on knockout, AI that races and fights, WebGL performance with multiple riders |
| **Art Style** | Low-poly gritty — PS1/PS2-era aesthetic with modern lighting. Achievable solo, distinct visual identity, good performance in WebGL |
| **Art Pipeline Complexity** | Low-Medium (low-poly 3D models, can leverage free asset packs + modifications) |
| **Audio Needs** | Moderate — engine sounds, weapon impact SFX, crash sounds, background music per level. Audio is critical for Pillar 2 (Visceral Impact) |
| **Networking** | None — single-player vs AI |
| **Content Volume** | 6 levels/tracks, 5-8 weapons, 4-6 AI riders per race, 1-2 bike models, ~15-20 min total gameplay |
| **Procedural Systems** | None — hand-crafted levels for jam scope |

---

## Risks and Open Questions

### Design Risks
- **Core loop saturation**: 6 levels of the same mechanic may feel repetitive — mitigate with escalating hazards, new weapons per level, and increasing chaos
- **Combat vs. racing balance**: If combat is too dominant, racing feels pointless. If racing is too dominant, combat feels tacked on. The sweet spot is where fighting IS how you win the race.

### Technical Risks
- **3D motorcycle physics in browser**: Needs to feel good with arcade handling. Godot's Jolt physics (default in 4.6) should handle this, but needs early prototyping
- **Ragdoll performance**: Multiple ragdoll riders + physics objects in WebGL could hit performance limits. Low-poly art style helps, but need to profile early
- **AI complexity**: Riders need to race (follow track, avoid obstacles) AND fight (target player, use weapons). Simple state machine should suffice but is the most complex system to build

### Market Risks
- **Niche genre**: Combat racing is underserved, which means opportunity but also unproven browser demand
- **Discoverability**: Browser games depend on sharing and portals — the "funny crash" shareable moments are the main marketing vector

### Scope Risks
- **One week is tight**: 3D + physics + AI + 6 levels in one week is ambitious. MVP (1 track, 3 weapons, basic AI) must be prioritized ruthlessly
- **Art production**: Even low-poly 3D takes time. May need to start with primitive shapes and iterate

### Open Questions
- What's the exact weapon roster? Need to define damage, durability, and special effects for each — prototype with 2-3 weapons first
- How does the track design work? Straight highways, curved roads, intersections? Start with a straight highway for MVP
- What's the camera perspective? Third-person chase cam is most likely, but exact positioning needs testing
- How far should ragdoll flights go? Need to find the sweet spot between "funny" and "tedious run back"

---

## MVP Definition

**Core hypothesis**: "Smacking rival bikers off their motorcycles with ridiculous
weapons, watching them ragdoll, and racing past them while they run back to their
bike is inherently fun and funny."

**Required for MVP**:
1. One straight highway track with basic traffic/obstacles
2. Arcade motorcycle controls (accelerate, steer, brake)
3. HP system on all riders
4. 2-3 weapons (bat, rubber chicken, fists) with durability
5. Basic melee combat (swing weapon at adjacent rider)
6. Ragdoll launch on knockout
7. On-foot run back to bike with full HP restore
8. 3 AI riders with simple race + fight behavior

**Explicitly NOT in MVP** (defer to later):
- Multiple tracks/levels (just need one to test the loop)
- Slow-mo replay system
- Level select / progression
- Sound design (test with placeholder or silence)
- Polish (screen shake, particles, juice)

### Scope Tiers

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 1 track, 3 weapons | Core loop: race, fight, crash, remount | Day 1-2 |
| **Playable** | 3 tracks, 5 weapons | Difficulty scaling, level progression, basic audio | Day 3-4 |
| **Target** | 6 tracks, 6-8 weapons | Slow-mo knockouts, screen shake, full audio, level select | Day 5-6 |
| **Polish** | 6 tracks, 8 weapons | Particle effects, replay moments, title screen, difficulty tuning | Day 7 |

---

## Next Steps

- [ ] Configure Godot 4.6 as the engine (`/setup-engine godot 4.6`)
- [ ] Validate concept completeness (`/design-review design/gdd/game-concept.md`)
- [ ] Decompose concept into systems (`/map-systems` — maps dependencies, assigns priorities, guides per-system GDD writing)
- [ ] Author per-system GDDs with `/design-system` (guided, section-by-section)
- [ ] Prototype the core loop (`/prototype combat-racing-core`) — 1 track, fists + 1 weapon, 2 AI riders
- [ ] Validate with playtest (`/playtest-report`)
- [ ] Plan the jam week (`/sprint-plan new`)
