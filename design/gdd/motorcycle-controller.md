# Motorcycle Controller

> **Status**: In Design
> **Author**: game-designer
> **Last Updated**: 2026-03-25
> **Implements Pillar**: Visceral Impact, Easy to Play / Hard to Master

## Overview

The Motorcycle Controller governs all player and AI rider movement across three states: Riding (on bike), Flying (knocked off), and On-Foot (walking back to bike). During the Riding state, it translates input actions into arcade-style motorcycle movement — acceleration, braking, and lateral steering on a lane-based road. The controller prioritizes responsive, immediate feel over realistic motorcycle physics; turns are instant lateral movement, not lean-based steering. It manages the rider's forward speed (0–300 km/h), supports temporary Nitro speed boosts (~500 km/h), and enforces road boundaries. The Flying and On-Foot states handle the knockout-to-remount cycle that is central to the game's identity. Without this system, there is no movement, no speed, and no physical comedy — it is the foundation everything else is built on.

## Player Fantasy

You are speed incarnate. The bike responds the instant you touch the controls — accelerate and the world blurs, steer and you weave through gaps that shouldn't exist, brake and you feel the weight shift. At 300 km/h you're threading a needle between rivals, looking for the moment to strike. When you grab a Nitro pickup the speedometer screams past 500 and everything else on the road becomes a slow-motion obstacle course.

Then someone clips you with a bat and you're cartwheeling through the air, watching your bike shrink behind you. You land, dust yourself off, and start the humiliating waddle back — slow, wobbly, vulnerable — while everyone else rockets past. But the moment you remount, you're back to full power. Zero to revenge in seconds.

The controller is invisible when it works right: you never think "I'm pressing buttons" — you think "I'm riding a motorcycle." The three states (riding → flying → walking → riding) aren't mode switches, they're chapters of a story that plays out every 30 seconds.

## Detailed Design

### Core Rules

**1. Movement Model**
- Forward movement is along the +Z axis. Lateral movement is along X.
- Acceleration is continuous while input is held (not instant max speed).
- Steering is instant lateral velocity with a visual lean/tilt on the bike mesh (cosmetic only — collision remains upright capsule).
- Lean angle proportional to lateral input: ~15° tilt at full steering, returns to 0° when centered.
- Road boundaries are hard-clamped (rider cannot leave the road surface).

**2. Speed Behavior**
- **Accelerating** (W held): Speed increases at `ACCELERATION` rate toward `MAX_SPEED` (300 km/h).
- **Braking** (S held): Speed decreases at `BRAKE_FORCE` rate toward 0.
- **Coasting** (no input): Speed decreases slowly at `COAST_DRAG` rate (5% of acceleration — bike maintains momentum like a real vehicle).
- **Nitro**: Adds `NITRO_SPEED_BOOST` on top of current speed. Full boost for `NITRO_DURATION`, then linearly fades over `NITRO_FADE_DURATION` back to base speed.

**3. Speed Zones (visual/audio feedback tiers)**

| Zone | Speed Range | Feedback |
|------|-----------|----------|
| Cruising | 0–100 km/h | Normal visuals, engine idle/low |
| Fast | 100–200 km/h | Wind audio, subtle speed lines |
| Blazing | 200–300 km/h | Camera FOV increase, screen edge blur, louder engine |
| Nitro | 300–500 km/h | Heavy distortion, color shift, camera shake, roaring audio |

**4. Rider Collision**
- Riders have physical capsule colliders and CANNOT pass through each other.
- Side-by-side contact produces a bump/push force proportional to relative speed difference.
- Bumping deals damage to BOTH riders, proportional to the speed difference between them. Higher speed difference = more damage to both.
- Bumping creates lateral knockback — riders shove each other across lanes.
- If bumped into a road barrier, the rider is briefly slowed (barrier friction penalty).
- Bump damage formula is defined in the Formulas section.

**4b. Obstacle Collision**
- Road obstacles (traffic, barriers, debris) have colliders.
- Hitting an obstacle deals damage to the rider proportional to the rider's speed at impact — same formula as rider-to-rider bumping, treating the obstacle as a stationary object (speed = 0).
- Obstacle hits also apply a speed penalty (rider slows down on impact).
- At high enough speed, an obstacle hit can trigger a knockout just like combat damage.

**5. Gravity & Ground**
- Riders are always subject to gravity (9.8 m/s²).
- Riders snap to the road surface during RIDING state.
- During FLYING state, gravity creates the knockout arc — realistic earth gravity means longer, more dramatic flights.

### States and Transitions

| State | Entry Condition | Exit Condition | Player Input | Movement |
|-------|----------------|----------------|-------------|----------|
| **RIDING** | Game start, or remount from ON_FOOT | HP reaches 0 (combat or collision) | Full control: accelerate, brake, steer, attack | Forward speed + lateral steering on road |
| **FLYING** | HP reaches 0 | Body contacts ground after airborne >0.15s | None (disabled) | Ballistic arc: initial velocity from knockout + gravity (9.8 m/s²). Body tumbles in air. |
| **SLIDING** | Flying body hits ground | Slide speed drops below 0.5 m/s | None (disabled) | Ground friction decelerates rider. Body tumbles/scrapes along road surface. |
| **LYING** | Sliding comes to rest | Lying timer expires | None (disabled) | Stationary. Random lying animation from pool. |
| **ON_FOOT** | Lying timer expires (rider gets up) | Reaches stopped bike (distance < 1.5m) | None (automatic) | Auto-walk toward bike at WALK_SPEED (1.5 m/s), exaggerated wobble animation. |

**Transition Flow:**
```
RIDING → FLYING → SLIDING → LYING → ON_FOOT → RIDING
                                ↑
                          (run-over → lying timer reset)
```

**Transition Details:**

- **RIDING → FLYING**: HP ≤ 0. Bike stops at current position + forward momentum offset. Rider launches with velocity based on weapon type + speed at impact. Slow-mo triggers (0.25x, 0.6s).
- **FLYING → SLIDING**: Body contacts ground after min 0.15s airborne. Retains horizontal velocity, vertical velocity zeroed. Body switches from tumble to ground-scrape animation.
- **SLIDING → LYING**: Horizontal speed < 0.5 m/s. Body settles into a random lying pose. Lying duration = `BASE_LIE_TIME + knockout_force * LIE_FORCE_SCALE + impact_speed * LIE_SPEED_SCALE`. Harder hits and faster knockouts = longer lying.
- **LYING (run-over)**: If another rider drives over a lying rider, the lying rider bounces (small upward impulse + comedic squash animation) and the lying timer resets. The riding rider takes no damage. Can happen multiple times.
- **LYING → ON_FOOT**: Lying timer expires. Rider plays a get-up animation, then begins auto-walk toward bike.
- **ON_FOOT → RIDING**: Within 1.5m of bike. Full HP restore, speed = 0, weapon = FISTS. Bike marker removed from world.

**Invalid Transitions:**
- RIDING → ON_FOOT (no voluntary dismount)
- RIDING → SLIDING (must fly first)
- RIDING → LYING (must fly and slide first)
- ON_FOOT → FLYING (can't be knocked out while walking)
- SLIDING → RIDING (must lie then walk)
- FLYING → RIDING (must slide, lie, then walk)
- LYING → RIDING (must walk back)

**Lying Animation Pool** (randomly selected on entry):
1. Face-down, arms spread — motionless for 1s then slight groan movement
2. On back, twitching legs — dazed cartoon style
3. Fetal curl — slowly uncurling
4. Sprawled sideways — one arm reaching toward bike

#### Flying Animations

**Trigger-Based Flight Style:**

| Knockout Source | Flight Style | Description |
|----------------|-------------|-------------|
| Fist knockout | Scrappy tumble | Sloppy sideways spin, arms flailing. Low arc. |
| Bat knockout | Home-run spin | Clean head-over-heels cartwheel. High dramatic arc. |
| Low-speed obstacle hit | Flop | Falls off bike sideways, lazy rotation. Short arc. |
| High-speed obstacle hit | Catapult | Launches forward over handlebars, somersault. Very high/far arc. |
| Side collision (rider bump) | Lateral spin | Spins horizontally like a top, knocked sideways off bike. |

**Direction influence:** Hit from left = launch right, hit from behind = somersault forward, etc. Launch direction always away from impact source.

**Speed influence:** Overlaid on the flight style — faster speed = faster spin rate, longer air time, wider arc.

**Mid-Air Poses (blended during flight):**
- Classic cartwheel (spinning head-over-heels)
- Ragdoll limb flailing (arms and legs spread, chaotic)
- Helicopter spin (horizontal rotation)
- Superman pose transitioning into tumble
- All selected based on flight style, with randomized spin rates for variety

**Landing Outcomes:**

| Condition | Landing Type | Next State |
|-----------|-------------|------------|
| Hits a large obstacle mid-flight (barrier, wall) | Hard splat against obstacle, drops straight down | LYING (skip SLIDING) |
| Hits a small obstacle mid-flight (traffic cone, sign) | Bounces off obstacle, deflects trajectory | Continues FLYING with altered direction |
| Lands on open road, high speed | Belly flop → bounce → SLIDING | SLIDING |
| Lands on open road, low speed | Tumble roll → short SLIDING | SLIDING |
| Lands on open road, very low speed | Flop → minimal slide | SLIDING (brief) |

**Landing animation matches flight style:**
- Cartwheel flight → tumble roll landing
- Flop flight → belly flop landing
- Catapult flight → hard splat or bounce landing
- Helicopter spin → spinning slide landing

**Mid-Flight Obstacle Collision:**
- If rider collides with a large immovable obstacle (barrier, building), velocity is zeroed and rider drops into LYING immediately. No sliding phase.
- If rider collides with a small/breakable obstacle, rider bounces with reduced velocity and altered direction. Flight continues.
- Obstacle size/type determines which behavior triggers (defined in Track System GDD).

### Interactions with Other Systems

[To be designed]

## Formulas

[To be designed]

## Edge Cases

[To be designed]

## Dependencies

[To be designed]

## Tuning Knobs

[To be designed]

## Visual/Audio Requirements

[To be designed]

## UI Requirements

[To be designed]

## Acceptance Criteria

[To be designed]

## Open Questions

[To be designed]
