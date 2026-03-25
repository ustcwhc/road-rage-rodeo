# Input System

> **Status**: In Design
> **Author**: game-designer
> **Last Updated**: 2026-03-23
> **Implements Pillar**: Easy to Play, Hard to Master

## Overview

The Input System translates keyboard and mouse inputs into game actions for the player-controlled rider. It manages three input contexts — Riding, On-Foot, and Menu — switching between them automatically based on the rider's current state. During the Flying state, all gameplay input is disabled (the rider is ragdolling). The system provides a clean abstraction layer so that the Motorcycle Controller and other downstream systems query actions (e.g., "is accelerate pressed?") rather than raw key codes, making it easy to remap controls or add gamepad support later. Without this system, control logic would be scattered across every gameplay script.

## Player Fantasy

The Input System is invisible infrastructure. The player fantasy it serves is **immediacy**: when you press a key, the game responds instantly with zero ambiguity. You never wonder "which button does that?" or "why didn't that register?" The controls feel like an extension of your hands — simple enough to grasp in seconds (Pillar 3: "If a mechanic needs a tutorial longer than one sentence, simplify it"), yet precise enough that skilled players can thread the needle between combat timing and steering.

## Detailed Design

### Core Rules

[To be designed]

### States and Transitions

[To be designed]

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
