# Track Specification: Phase 0 — Foundations

**Track ID:** `phase0_foundations_20261008` · **Type:** MVP · **Phase:** 0 of 5

## Overview

Bootstrap *The Terminal at Sub-Level 4* from an empty repository to a playable proof of the core pipeline: a seeded, authoritative `WorldState` answering read-only commands through a fully styled CRT terminal shell, with the complete dev toolchain (gd-tools + CI) enforcing quality from the first commit. Exit criterion (from the roadmap): typing `query L4-02` at the prompt returns an answer derived from real world state, on a CRT screen that already *feels* like the game.

## Functional Requirements

**FR1 — Project Skeleton**
- Godot 4.5+ project with `res://src/core/` (pure logic, no scene-tree dependencies), `res://src/ui/` (terminal shell), `res://data/` (JSON content).
- `WorldState` exposed as autoload; consumed only by UI layer; core classes referenced via preload.
- `.gitignore` covering `.godot/`, `.gd-tools/`, run logs, exports.

**FR2 — WorldState (seeded, clocked)**
- Single authoritative state: run seed, in-game clock (starts 01:50 AM, advances as commands execute), sector/door/sensor values, personnel records, power allocation fields (schema present; mutation mechanics deferred).
- Born from a seed supplied at startup (launch flag/env), **displayed in the status header**; deterministic: same seed + same command sequence → same state.
- Initial variable set sized for the L4 corridor slice (~15-20 variables now; grows toward 30-50 in later phases).

**FR3 — Command Parser (read-only)**
- Strict verb set: `query`, `log`, `help`. Fuzzy matching with suggest-the-closest errors (`Unknown command 'quary'. Did you mean: query?`).
- `query [sector/personnel/sensor]` and `log [file_id]` return answers rendered from real WorldState + data files.
- Parser architecture must accept future verbs (`override`, `power`, `chat`, `playback`) without restructuring.

**FR4 — Terminal Shell (full CRT)**
- **80×24 character-grid layout contract**; all output designed to fit; deterministic wrapping.
- CRT shader: scanlines, vignette, subtle flicker, phosphor persistence. Phosphor green default + amber toggle + reduced-flicker accessibility toggle.
- Custom key-capture input (not stock LineEdit): every keystroke drives typing SFX, cursor rendering, CRT feel.
- Autocomplete: Tab completes verbs and known arguments; ↑/↓ history recall; inline ghost-text suggestion from history. All diegetic — no popup widgets.
- Bounded scrollback (~200 lines) mirrored to a per-run local log file.

**FR5 — Content Slice (real, not stub)**
- L4 corridor sector definition (doors, sensors incl. L4-02, environmental readings), three personnel dossiers (Arisova, Miller, Chen), 3-5 lore log entries.
- JSON under `res://data/`, each file carrying `schema_version`; loader validates version and structure.

**FR6 — Dev Toolchain & CI**
- `gd-tools init` (native test + coverage addons, `gd-tools.toml`, gdlintrc, gdformatrc); format+lint pre-commit hooks.
- GitHub Actions workflow: `gd-tools lint`, `format --check`, `test --coverage` on push (requires GitHub remote, created during this track).
- Export presets (Windows + **Web**) configured and **web export verified to build and run**.

## Non-Functional Requirements

- **Coverage:** ≥90% line coverage on `src/core/` (UI excluded from gate, per workflow).
- **Determinism:** seeded runs reproducible in tests — no wall-clock or unseeded randomness in core logic.
- **Feel:** no perceptible input latency; typing SFX latency immaterial but must not stutter scrollback.
- **Style:** all code passes gdlint + gdformat; typed GDScript in core.

## Acceptance Criteria

1. Fresh clone → `gd-tools doctor` passes → project opens in Godot → `gd-tools test` green.
2. On the CRT terminal (green phosphor, scanlines visible), typing `query L4-02` with Tab-completion and keystroke SFX returns sensor/door state sourced from WorldState data.
3. `log <id>` retrieves a lore entry; `help` lists verbs; `quary` suggests `query`.
4. Two runs with the same seed and command sequence produce identical output; different seeds alter seeded fields (verified by test).
5. CI workflow green on push; coverage gate enforces ≥90% on core.
6. Web export builds and runs in a browser showing the working terminal.

## Out of Scope

- Mutating commands (`override`, `power`) and their consequences — Phase 1.
- Chat/messages UI, EventScheduler, lie engine, NPC dialogue — Phase 1/2.
- Seeded *variation* logic (infection vector, first liar) — only the seed plumbing arrives now.
- Full facility data model, Act I content, save/reload, itch.io release, post-mortem/unlock meta.
