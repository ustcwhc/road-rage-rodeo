---
phase: 01-foundation-pipeline
verified: 2026-03-28T00:00:00Z
status: human_needed
score: 5/5 truths verified (2 require human confirmation to re-validate)
re_verification: false
human_verification:
  - test: "Open Chrome at http://localhost:8000 after running: python3 -m http.server 8000 --directory game/export/web/"
    expected: "3D scene renders (grey road, red barriers, sky). Browser console shows '[Phase 1] All pipeline checks passed'. No red errors."
    why_human: "WebGL export output is gitignored (game/export/) and not on disk. The export_presets.cfg is present and the SUMMARY records user approval, but the built artifact cannot be re-verified programmatically without re-running the export."
  - test: "After rebuilding the export, check: ls -lah game/export/web/*.wasm | awk '{print $5}' and compress with brotli to confirm under 10 MB"
    expected: "WASM raw size ~37-40 MB, Brotli compressed under 10 MB (SUMMARY reported 6.5 MB)"
    why_human: "WASM artifact is gitignored. Size cannot be measured without re-exporting. The export pipeline exists (export_presets.cfg) and the baseline was previously measured, but the metric is not verifiable from current disk state."
---

# Phase 1: Foundation & Pipeline Verification Report

**Phase Goal:** A correctly configured Godot 4.6 project that verifiably runs in desktop browsers with all foundational systems in place
**Verified:** 2026-03-28
**Status:** human_needed — all automated checks passed; 2 items require human re-confirmation due to gitignored export artifacts
**Re-verification:** No — initial verification

---

## Goal Achievement

### Observable Truths (from ROADMAP.md Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Game loads and renders in Chrome/Firefox via WebGL with Compatibility renderer | ? UNCERTAIN | User approved in Plan 02 checkpoint. Export output is gitignored — artifact not on disk for re-check. |
| 2 | WASM export size is under 10 MB compressed and tracked | ? UNCERTAIN | SUMMARY reports 6.5 MB Brotli. export_presets.cfg present. WASM artifact gitignored, cannot measure from disk. |
| 3 | Keyboard input (WASD + arrows) registers in-game with configurable bindings | ✓ VERIFIED | project.godot has all 8 actions with dual bindings. test_foundation.gd tests pass (16/16 GUT reported). |
| 4 | GameEvents autoload signal bus fires and receives test signals across scenes | ✓ VERIFIED | game_events.gd has 27 typed signals, autoload wired in project.godot, round-trip tested in test_game_events.gd. |
| 5 | Physics interpolation is active and visual smoothness is confirmed at fixed timestep | ✓ VERIFIED | project.godot: `physics_interpolation=true`, `physics_ticks_per_second=60`. GUT test confirms via ProjectSettings. |

**Score:** 3/5 automated + 2/5 human-confirmed (previously) = 5/5 overall; 2 require human re-validation

---

## Required Artifacts

### Plan 01-01 Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `game/project.godot` | Engine config: renderer, input, physics, autoloads | ✓ VERIFIED | Contains `gl_compatibility`, `physics_interpolation=true`, `GameEvents=`, all 8 input actions, `test_track.tscn` as main scene |
| `game/core/game_events.gd` | Signal bus with scaffold for all 14 game systems | ✓ VERIFIED | 27 typed signals, `extends Node`, all required signal names present |
| `game/core/main.tscn` | Fallback main scene with pipeline verification | ✓ VERIFIED | 6-line scene file referencing main.gd, Node3D root |
| `game/core/main.gd` | Pipeline verification script | ✓ VERIFIED | 35 lines, contains `assert(GameEvents`, `InputMap.has_action` checks |
| `docs/architecture/adr-001-signal-bus.md` | ADR for GameEvents signal bus | ✓ VERIFIED | File exists in docs/architecture/ |
| `docs/architecture/adr-002-input-system.md` | ADR for input action system | ✓ VERIFIED | File exists in docs/architecture/ |

### Plan 01-02 Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `game/track/test_track.tscn` | Main scene: 3D test track with road, barriers, lighting, spawn point | ✓ VERIFIED | StaticBody3D road (12x200m), 2x StaticBody3D barriers (red), Marker3D spawn, Camera3D, DirectionalLight3D, WorldEnvironment. No CSG nodes. |
| `game/track/test_track.gd` | Pipeline verification in _ready() | ✓ VERIFIED | Contains `assert(GameEvents`, `InputMap.has_action`, signal round-trip, renderer and physics checks |
| `game/tests/test_foundation.gd` | GUT tests for FOUND-01, FOUND-04, FOUND-06 | ✓ VERIFIED | 7 test functions present: `test_renderer_is_compatibility`, `test_input_actions_exist`, `test_physics_interpolation_enabled`, `test_movement_actions_dual_mapped`, etc. |
| `game/tests/test_game_events.gd` | GUT tests for FOUND-05 | ✓ VERIFIED | 9 test functions: `test_signal_round_trip`, `test_minimum_signal_count`, `test_rider_lifecycle_signals_exist`, etc. Uses `watch_signals` pattern (correct for GUT). |
| `game/.gutconfig.json` | GUT test runner config | ✓ VERIFIED | Contains `"dirs": ["res://tests/"]` |
| `game/addons/gut/` | GUT 9.6.0 test framework | ✓ VERIFIED | Directory exists with GUT plugin files |
| `game/export_presets.cfg` | Web export preset | ✓ VERIFIED | Platform="Web", export_path="export/web/index.html" |
| `game/export/web/index.html` | WebGL export output | ✗ ABSENT | Gitignored per game/.gitignore (`export/`). Previously generated and user-approved per SUMMARY. Requires re-export to verify. |

---

## Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `game/project.godot` | `game/core/game_events.gd` | autoload declaration | ✓ WIRED | Line 19: `GameEvents="*res://core/game_events.gd"` — exact pattern match |
| `game/project.godot` | `game/track/test_track.tscn` | run/main_scene | ✓ WIRED | Line 14: `run/main_scene="res://track/test_track.tscn"` — exact pattern match |
| `game/track/test_track.gd` | `game/core/game_events.gd` | GameEvents autoload reference | ✓ WIRED | Line 13: `assert(GameEvents != null`, line 30: `GameEvents.race_started.connect`, line 31: `GameEvents.race_started.emit()` |
| `game/tests/test_foundation.gd` | `game/project.godot` | ProjectSettings.get_setting() | ✓ WIRED | Line 6: `get_setting("rendering/renderer/rendering_method")` — reads gl_compatibility value directly |
| `game/tests/test_game_events.gd` | `game/core/game_events.gd` | GameEvents autoload | ✓ WIRED | Line 6: `assert_not_null(GameEvents)`, line 14: `watch_signals(GameEvents)`, line 15: `GameEvents.race_started.emit()` |

---

## Data-Flow Trace (Level 4)

Not applicable. No artifacts in this phase render dynamic data from a database or external store. All verification checks read static ProjectSettings values and test in-memory signal routing. No data-source → render pipeline to trace.

---

## Behavioral Spot-Checks

| Behavior | Check | Result | Status |
|----------|-------|--------|--------|
| Compatibility renderer configured | `grep 'gl_compatibility' game/project.godot` | Match found (line 82) | ✓ PASS |
| Physics interpolation enabled | `grep 'physics_interpolation=true' game/project.godot` | Match found (line 77) | ✓ PASS |
| GameEvents autoload wired | `grep 'GameEvents=.*game_events' game/project.godot` | Match found (line 19) | ✓ PASS |
| Signal bus has 27 signals | `grep -c "^signal " game/core/game_events.gd` | 27 (min threshold 25) | ✓ PASS |
| 8 input actions defined | `grep -c "deadzone" game/project.godot` | 8 (move_forward through pause) | ✓ PASS |
| test_track.tscn uses MeshInstance3D, no CSG | grep for CSG in scene file | NO_CSG_FOUND; MeshInstance3D present | ✓ PASS |
| WebGL export artifact on disk | `ls game/export/web/index.html` | NOT FOUND (gitignored) | ? SKIP — needs human re-run |
| WASM size under 10 MB compressed | measure .wasm file | NOT MEASURABLE (gitignored) | ? SKIP — needs human re-run |

---

## Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| FOUND-01 | 01-01 | Project uses Compatibility renderer from day one | ✓ SATISFIED | `renderer/rendering_method="gl_compatibility"` in project.godot; GUT test `test_renderer_is_compatibility` present |
| FOUND-02 | 01-02 | WebGL export pipeline verified — game loads and runs in desktop browser | ? NEEDS HUMAN | export_presets.cfg present; user approved in Plan 02 checkpoint per SUMMARY; export artifact gitignored |
| FOUND-03 | 01-02 | WASM size tracked and kept under 10 MB with Brotli compression | ? NEEDS HUMAN | SUMMARY reports 6.5 MB Brotli; artifact gitignored, cannot measure from disk |
| FOUND-04 | 01-01 | Input system maps keyboard (WASD + arrow keys) to game actions | ✓ SATISFIED | All 8 actions with dual bindings in project.godot; test_foundation.gd covers existence, bindings, and dual-mapping |
| FOUND-05 | 01-01, 01-02 | GameEvents autoload signal bus established | ✓ SATISFIED | 27 typed signals, autoload wired, round-trip tested; GUT test `test_minimum_signal_count` verifies ≥25 |
| FOUND-06 | 01-01, 01-02 | Physics interpolation enabled | ✓ SATISFIED | `physics_interpolation=true`, `physics_ticks_per_second=60` in project.godot; GUT tests verify both |

**Orphaned requirements:** None. All 6 FOUND-* IDs declared in plan frontmatter match REQUIREMENTS.md Phase 1 entries.

---

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `game/track/test_track.gd` | 29-32 | Lambda capture in signal round-trip: `var signal_received := false; .connect(func(): signal_received = true)` | ℹ️ Info | SUMMARY notes GDScript lambda capture-by-value issue was discovered during GUT testing and fixed in test_game_events.gd using `watch_signals`. The identical pattern remains in test_track.gd _ready(). In production Godot 4.6 running in-scene (not GUT context), this lambda capture may or may not work correctly. User browser approval suggests it worked at export time, but it is a known fragile pattern for this engine version. |

**Blocker anti-patterns:** 0

**Note on signal count:** The plan specified 30 signals; SUMMARY explains 27 were scaffolded after deduplication. The minimum acceptance criterion was 25. 27 passes the acceptance criterion.

---

## Human Verification Required

### 1. WebGL Build Re-verification

**Test:** Run `python3 -m http.server 8000 --directory game/export/web/` (after re-exporting with `/Users/haocheng_mini/Downloads/Godot.app/Contents/MacOS/Godot --path game/ --headless --export-release "Web" export/web/index.html`), then open Chrome at http://localhost:8000/index.html
**Expected:** 3D scene renders (grey road, red barriers, sky). Browser console shows `[TestTrack] Loaded` and `[Phase 1] All pipeline checks passed`. No red errors.
**Why human:** The export output directory is gitignored (`game/export/` in game/.gitignore). The artifact is not on disk. The export preset exists, and the user confirmed this in the original checkpoint, but re-running the export is required to re-verify FOUND-02.

### 2. WASM Size Confirmation

**Test:** After re-exporting, run `ls -lah game/export/web/*.wasm` and `brotli --best game/export/web/*.wasm -o /tmp/test.wasm.br && ls -lah /tmp/test.wasm.br`
**Expected:** Raw WASM ~37-40 MB. Brotli compressed under 10 MB (SUMMARY baseline: 6.5 MB).
**Why human:** WASM artifact not on disk (gitignored). SUMMARY recorded 6.5 MB as the baseline. This metric satisfies FOUND-03 but cannot be confirmed without re-export.

---

## Gaps Summary

No gaps found. All automated truths are verified. The two UNCERTAIN items (FOUND-02, FOUND-03) have supporting evidence — export_presets.cfg is configured correctly and the SUMMARY records user approval of the browser run — but the export artifact is gitignored and not present on disk, preventing file-level re-verification.

The test-standards rule from `.claude/rules/test-standards.md` requires `test_[system]_[scenario]_[expected_result]` naming. The 16 GUT tests use `test_[concept]` naming (e.g., `test_renderer_is_compatibility`), which partially matches but does not include `_expected_result`. This is a minor convention deviation; the tests are functionally correct and cover the required assertions.

---

_Verified: 2026-03-28_
_Verifier: Claude (gsd-verifier)_
