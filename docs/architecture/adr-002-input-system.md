# ADR-002: Input Action System

**Status:** Accepted
**Date:** 2026-03-28
**Deciders:** Project lead + Claude

## Context

Road Rage Rodeo needs responsive keyboard controls for motorcycle racing and combat. The game targets WebGL (browser) with keyboard as primary input.

## Decision

Use Godot's built-in InputMap system with 8 named actions defined in project.godot:

| Action | Primary Key | Secondary Key | Purpose |
|--------|------------|---------------|---------|
| move_forward | W | Up Arrow | Accelerate |
| move_back | S | Down Arrow | Brake/reverse |
| steer_left | A | Left Arrow | Steer left |
| steer_right | D | Right Arrow | Steer right |
| attack | Space | - | Swing weapon |
| nitro | Left Shift | - | Activate boost |
| restart | R | - | Restart level |
| pause | Escape | - | Pause game |

- Movement actions have dual bindings (WASD + arrows) for accessibility (D-02)
- All bindings defined in project.godot [input] section using InputEventKey objects
- No custom input framework -- Godot's InputMap handles rebinding natively
- Deadzone set to 0.2 on all actions (future gamepad support)

## Consequences

- **Pro:** Native Godot system -- zero custom code, works with Input.is_action_pressed()
- **Pro:** Dual bindings for movement accommodate different player preferences
- **Pro:** InputMap supports runtime rebinding if needed later
- **Con:** Gamepad not configured yet (deferred -- keyboard-first for WebGL target)

## Alternatives Considered

- **Custom input manager:** Unnecessary overhead. Godot's InputMap is sufficient.
- **Input handled in _unhandled_input only:** Too restrictive for racing (need continuous polling via is_action_pressed).
