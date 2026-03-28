# Phase 1: Foundation & Pipeline - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-28
**Phase:** 01-Foundation & Pipeline
**Areas discussed:** Project Structure, Input Mapping, Signal Bus Design, Test Track Scope

---

## Project Structure

| Option | Description | Selected |
|--------|-------------|----------|
| Mirror repo structure | src/ for GDScript, scenes/ for .tscn, code and scenes separate | |
| Godot-idiomatic feature folders | Each feature self-contained with scripts + scenes together | |
| You decide | Claude picks best Godot convention | ✓ |

**User's choice:** You decide
**Notes:** Claude leaning toward option B (Godot-idiomatic feature folders) as standard convention.

---

## Input Mapping

| Option | Description | Selected |
|--------|-------------|----------|
| Prototype-based | Keep WASD/Space, add Shift (nitro), E (look back), R (restart), Esc (pause) | |
| Left-hand optimized | WASD move, F attack, Shift nitro, Space drift | |
| You decide | Claude picks sensible defaults based on genre conventions | ✓ |

**User's choice:** You decide
**Notes:** Claude going with prototype-based since already validated. Godot InputMap for rebinding.

---

## Signal Bus Design

### Naming Convention

| Option | Description | Selected |
|--------|-------------|----------|
| Past tense events | rider_knocked_out, weapon_picked_up — listeners react to facts | |
| Action requests | knock_out_rider, pick_up_weapon — emitters request actions | |
| Mixed | Past tense for gameplay, imperative for system commands | |
| You decide | Claude picks | ✓ |

**User's choice:** You decide

### Signal Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal | Only signals needed for Phase 1 testing | |
| Scaffold all | Full signal list up front as downstream contract | ✓ |
| You decide | Claude picks | |

**User's choice:** Scaffold all signals up front
**Notes:** User wants downstream phases to have a contract to code against from day one.

---

## Test Track Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Bare minimum | Flat colored plane, single collision shape | |
| Basic road | Straight 3-lane road like prototype, CSG ok | |
| Proper geometry | MeshInstance3D from day one, no CSG in production | |
| You decide | Claude picks | ✓ |

**User's choice:** You decide
**Notes:** Claude preference to avoid CSG based on research findings about WebGL performance.

---

## Claude's Discretion

User deferred all 4 areas to Claude's judgment. Decisions should be grounded in research findings (STACK.md, ARCHITECTURE.md, PITFALLS.md) and prototype patterns.

## Deferred Ideas

None — discussion stayed within phase scope.
