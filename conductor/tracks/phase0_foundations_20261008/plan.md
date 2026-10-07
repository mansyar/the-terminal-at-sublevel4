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
- [~] Task: CI pipeline (GitHub Actions)
  - Workflow running `gd-tools lint`, `format --check`, `test --coverage` on push; green on first run
    - Note: `--min 90` coverage gate is added in Phase B once `src/core/` exists (nothing to gate now)
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase B: WorldState Core (TDD)

- [ ] Task: Write failing tests for WorldState (red phase)
  - Seed determinism (same seed+commands → identical state), clock advance-on-command from 01:50 AM, sector/door/sensor/personnel state reads, power allocation fields present, no unseeded randomness
- [ ] Task: Implement WorldState + seed plumbing (green phase)
  - `src/core/world_state.gd` — seeded construction from launch flag/env, clock advance API, query accessor API
  - Register as autoload; UI-only consumers
- [ ] Task: Write failing tests for data loader, then implement (red→green)
  - JSON loading from `res://data/`, `schema_version` validation, structure validation errors
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase C: Command Parser (TDD)

- [ ] Task: Write failing tests for parser (red phase)
  - Verb dispatch (`query`/`log`/`help`), argument parsing (sector/personnel/sensor/file_id), fuzzy suggest-the-closest (`quary` → suggests `query`), unknown-command rejection, extensibility for future verbs without restructuring
- [ ] Task: Implement parser + read-command execution (green phase)
  - `src/core/command_parser.gd` + query/log/help handlers against WorldState + data
  - Results as structured records the UI renders
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase D: Terminal Shell (presentation — smoke tests, no red phase)

- [ ] Task: 80×24 grid terminal surface
  - RichTextLabel-based shell honoring the grid contract, deterministic wrapping, bounded scrollback (~200 lines) + per-run file mirror
- [ ] Task: CRT shader & display toggles
  - Scanlines, vignette, subtle flicker, phosphor persistence; green default + amber toggle + reduced-flicker accessibility toggle
- [ ] Task: Custom input capture
  - Per-keystroke key capture driving typing SFX, cursor rendering; no stock LineEdit
- [ ] Task: Autocomplete & history
  - Tab completion (verbs + known args), ↑/↓ history, inline ghost-text from history — all diegetic
- [ ] Task: Wire shell to core
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
