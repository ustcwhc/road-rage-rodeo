---
phase: 1
slug: foundation-pipeline
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-28
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | GUT 9.6.0 (Godot Unit Test) |
| **Config file** | `game/.gutconfig.json` (Wave 0 — must create) |
| **Quick run command** | `godot -s addons/gut/gut_cmdln.gd -d --path game/` |
| **Full suite command** | `godot -s addons/gut/gut_cmdln.gd -d --path game/ -gexit` |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick test on affected test file
- **After every plan wave:** Run full GUT suite
- **Before `/gsd:verify-work`:** Full suite must be green + manual WebGL browser test
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| TBD | 01 | 0 | FOUND-01 | unit | `test_foundation.gd::test_renderer_is_compatibility` | ❌ W0 | ⬜ pending |
| TBD | 01 | 0 | FOUND-02 | manual+smoke | Export then open in browser | N/A | ⬜ pending |
| TBD | 01 | 0 | FOUND-03 | smoke | `ls -la game/export/web/*.wasm` size check | ❌ W0 | ⬜ pending |
| TBD | 01 | 0 | FOUND-04 | unit | `test_foundation.gd::test_input_actions` | ❌ W0 | ⬜ pending |
| TBD | 01 | 0 | FOUND-05 | unit | `test_game_events.gd` | ❌ W0 | ⬜ pending |
| TBD | 01 | 0 | FOUND-06 | unit | `test_foundation.gd::test_physics_interpolation` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `game/addons/gut/` — GUT 9.6.0 installation
- [ ] `game/.gutconfig.json` — GUT configuration (test directory, log level)
- [ ] `game/tests/test_foundation.gd` — covers FOUND-01, FOUND-04, FOUND-06
- [ ] `game/tests/test_game_events.gd` — covers FOUND-05

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| WebGL export loads in browser | FOUND-02 | Requires browser environment | Export project, open in Chrome/Firefox, verify renders |
| WASM size under 10MB | FOUND-03 | Requires export artifact | Export, check file size with `ls -la` |

---

## Validation Sign-Off

- [ ] All tasks have automated verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
