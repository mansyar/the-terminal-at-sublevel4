# Implementation Plan: Phase 0 — Foundations

## Phase A: Project Bootstrap & Toolchain

- [~] Task: Create Godot 4.5+ project skeleton
  - `project.godot` with terminal game title; `src/core/`, `src/ui/`, `data/`, `tests/` directories
  - `.gitignore` (`.godot/`, `.gd-tools/`, run logs, exports)
  - Create GitHub remote and push (user action: create repo)
    - **DEVIATION (2026-10-08):** deferred — GitHub repo-creation API returning 500s (server-side incident). Remote + CI verification retried later in this track; Task stays open until then.
- [x] Task: Initialize gd-tools toolchain (SHA: 4037054)
  - Run `gd-tools init`; review generated `gd-tools.toml`, gdlintrc, gdformatrc
  - `gd-tools doctor` passes; `gd-tools install-hooks --hooks format,lint`
- [ ] Task: CI pipeline (GitHub Actions)
  - Workflow running `gd-tools lint`, `format --check`, `test --coverage` on push; green on first run
    - Note: `--min 90` coverage gate is added in Phase B once `src/core/` exists (nothing to gate now)
    - Workflow file committed (SHA: 85b786e); **run verification deferred** until remote exists
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) `[checkpoint: 85b786e]`
  - Verified 2026-10-08: lint/format/test (2/2)/headless import all green; git-notes report on 85b786e; CI run verification deferred with remote.

## Phase B: WorldState Core (TDD)

- [x] Task: Write failing tests for WorldState (red phase) (SHA: 8c9fd59)
- [x] Task: Implement WorldState + seed plumbing (green phase) (SHA: 8c9fd59)
  - `src/core/world_state.gd` — seeded construction from launch flag/env, clock advance API, query accessor API
  - Register as autoload; UI-only consumers
    - Note: autoload registration deferred to Phase D "Wire shell to core" (autoload requires Node wrapper; WorldState is pure RefCounted)
- [x] Task: Write failing tests for data loader, then implement (red→green) (SHA: 9dd7b65)
  - JSON loading from `res://data/`, `schema_version` validation, structure validation errors
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) `[checkpoint: 9dd7b65]`
  - Verified 2026-10-08: 17/17 tests, 100% line+branch coverage on src/core, lint/format clean; git-notes report on 9dd7b65.

## Phase C: Command Parser (TDD)

- [x] Task: Write failing tests for parser (red phase) (SHA: fe12b33)
  - Verb dispatch (`query`/`log`/`help`), argument parsing (sector/personnel/sensor/file_id), fuzzy suggest-the-closest (`quary` → suggests `query`), unknown-command rejection, extensibility for future verbs without restructuring
- [x] Task: Implement parser + read-command execution (green phase) (SHA: beaac49)
  - `src/core/command_parser.gd` + query/log/help handlers against WorldState + data
  - Results as structured records the UI renders
    - Parser committed fe12b33; executor beaac49 (both under this task)
- [x] Task: Phase Verification & Checkpoint (Refer to workflow.md) `[checkpoint: beaac49]`
  - Verified 2026-10-08: 38/38 tests, --min 90 gate passing (94.7% lines / 93.9% branches), lint/format clean; git-notes report on beaac49.

## Phase D: Terminal Shell (presentation — smoke tests, no red phase)

- [x] Task: 80×24 grid terminal surface (SHA: a869c4f)
  - RichTextLabel-based shell honoring the grid contract, deterministic wrapping, bounded scrollback (~200 lines) + per-run file mirror
    - TerminalBuffer (wrap/scrollback/mirror) 2f4626f; scene surface rendering in a869c4f
- [x] Task: CRT shader & display toggles (SHA: a869c4f)
  - Scanlines, vignette, subtle flicker; green default + amber toggle (F1) + reduced-flicker toggle (F2)
    - Note: phosphor persistence approximated (tint glow); true afterimage deferred to Phase 4 polish
- [x] Task: Custom input capture (SHA: a869c4f)
  - Per-keystroke key capture driving typing SFX, cursor rendering; no stock LineEdit
- [x] Task: Autocomplete & history (SHA: b7e12f5)
  - Tab completion (verbs + known args), ↑/↓ history, inline ghost-text from history — all diegetic
- [x] Task: Wire shell to core (SHA: a869c4f)
  - Status header (system status, seed, clock), parser results rendered to screen; smoke tests for shell; lint/format clean
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase E: Content Slice & Export Verification

- [ ] Task: Author Phase 0 content (JSON, schema_versioned)
  - L4 corridor sector (doors, sensors incl. L4-02, env readings); dossiers: Arisova, Miller, Chen; 3-5 lore log entries
- [ ] Task: End-to-end integration
  - `query L4-02` returns real state on the CRT screen; full acceptance-criteria walkthrough (spec items 1-4)
- [ ] Task: Export presets & verification
  - Windows + Web export presets; web export builds and runs in browser
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

---

Commit discipline per `workflow.md`: one conventional commit per task (`feat(core): ...`, `chore(tooling): ...`), task summary via git notes, status markers and SHAs updated in this plan as work proceeds.
