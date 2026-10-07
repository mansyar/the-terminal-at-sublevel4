# Technology Stack

## Engine & Language

- **Engine:** Godot 4.5+ (required by gd-tools; current stable 4.x)
- **Language:** GDScript (typed, strict mode where practical)
- **Export targets:** Web (itch.io primary), Windows desktop; Linux/macOS optional later. Steam wrapper decided at Phase 4.

## Core Architecture (per locked Pillar #1)

- **`WorldState`** — single authoritative state object (~30-50 variables): character flags (alive/infected/dead/location), door states, power budget/allocation, sensor values, comms integrity, run seed. *All* commands are queries/mutations on it. No parallel truth sources.
- **`CommandParser`** — strict verb set (`query`, `override`, `log`, `power`, `chat`, `playback`, `help`) + fuzzy matching + autocomplete; no open NLP.
- **`DialogueEngine`** — NPC lines as template functions of WorldState; lie behavior layered over true state; per-character lie models.
- **`EventScheduler`** — soft real-time clock advancing on player actions; scheduled beats (02:31 power surge, etc.).
- **`EndingEvaluator`** — flag conditions over end-state → one of 4-6 endings.
- **`TerminalUI`** — Godot RichTextLabel skin, scanline/CRT shader (self-made), typing SFX, input history/autocomplete.

## Quality Toolchain: gd-tools

- **Tool:** [gd-tools](https://github.com/mansyar/gd-tools) (`pip install gd-tools-cli`) — unified lint/format/test/coverage for GDScript on Godot 4.5+ (MIT).
- **Bootstrap:** `gd-tools init` in the Godot project (deploys native test + coverage addons, generates `gd-tools.toml`, `gdlintrc`, `gdformatrc`).
- **Commands in daily use:** `gd-tools lint` (gdlint), `gd-tools format --check` (gdformat), `gd-tools test` (native `GdToolsTest` runtime — tests run inside Godot, can touch real scene tree/signals), `gd-tools test --coverage --min 80` for coverage gates, `gd-tools test --watch` during development, `gd-tools coverage run` during manual playtests.
- **Pre-commit:** `gd-tools install-hooks --hooks format,lint` (add `test` once suite is fast).
- **Note:** GUT is NOT used (removed support in gd-tools v0.6.0). All suites extend `GdToolsTest`.

## Assets

- **SFX:** freesound.org / Kenney audio (free licenses, attribution tracked in `CREDITS.md`).
- **Font:** monospace terminal font (e.g., VT323 / IBM Plex Mono — verify license before bundling).
- **Shader:** self-made CRT (scanlines, vignette, flicker, phosphor persistence).

## Project Structure & Workflow

- **VCS:** git (initialized). Godot `.godot/`, `.gd-tools/` caches gitignored.
- **Testing:** TDD per `workflow.md`; WorldState and lie engine are pure-logic and must have high coverage; UI shell gets integration smoke tests.
