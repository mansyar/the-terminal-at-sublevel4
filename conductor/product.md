# Product Definition: The Terminal at Sub-Level 4

## Summary

**The Terminal at Sub-Level 4** is a retro-terminal horror game where you play **Operator 14**, running the graveyard-shift monitoring console for *Facility Boreas*, an underground lab buried in the Siberian permafrost. You never leave your chair: the entire game is a CRT interface of commands, telemetry, and chat. At 02:14 AM a containment alarm trips at Sub-Level 4, and everything you learn afterward arrives through two untrusted channels — sensor logs (objective truth) and desperate staff radio chatter (lies, panic, and bargains). The game is a bounded systems simulation: a single authoritative world state drives every readout, NPCs lie *over* that truth, and death comes only from being socially engineered into a catastrophic command.

## Vision & Design Pillars (Locked v1)

| # | Pillar | Decision |
|---|--------|----------|
| 1 | Architecture | Bounded systems sim: one authoritative world state (~30-50 variables); all commands are queries/mutations on it; endings are flag conditions over end state |
| 2 | Engine | Godot; custom CRT terminal shell (RichTextLabel skin, scanline shader, typing SFX) is a budgeted work item |
| 3 | Death grammar | Deception via terminal — the player dies only by executing something they were tricked into |
| 4 | Epistemology | Telemetry is ground truth; NPCs lie over it; smart play = cross-referencing channels |
| 5 | Power | Dual-role: real resource constraint AND a lie-vector (faked shortages, spoofed reroutes) |
| 6 | Time | Soft real-time: clock advances as the player works; scheduled events; generous-but-felt deadlines |
| 7 | Audio logs | Corrupted transcript scrubbing — diegetic puzzle, no real audio pipeline |
| 8 | Act II fork | Both threads (parasite + military protocol) real every run; limited time/power forces choosing which to dig |
| 9 | Replay | Seeded runs: infection vector, first liar, failure order vary; core story beats fixed |
| 10 | Meta | Knowledge carryover + light unlocks (log archive, post-mortem report hinting at what was missed) |
| 11 | Cast | Dr. Arisova, Security Lead Miller, Chief Engineer Chen + facility system voice |
| 12 | World edge | One external uplink — enables the Whistleblower ending and is the anomaly's eventual channel to the player |

**Core tension (design north star):** the player is physically safe; the threat vector is the terminal itself. The horror's grammar is *calibrating trust in your own instruments*.

## Core Gameplay

- **Interface:** monochrome CRT terminal (green or amber), command line + log/message/sensor panels, typing SFX, static distortions.
- **Commands:** `query [sector/personnel]`, `override [system_id]`, `log [file_id]`, `power [route]`, chat, audio playback — freeform entry with fuzzy matching + autocomplete (strict verb set, no open NLP).
- **Three pillars:** (1) System diagnostics & querying, (2) Communication channel with trust/lie models, (3) Power & resource management with direct operational consequences.

## Narrative Arc

- **Act I — The Alarm:** learn commands; the seal/unseal choice (trap Arisova or risk the leak).
- **Act II — The Discrepancies:** sensor data contradicts survivor reports; both the parasite thread and the illegal military-protocol thread are real; resources force prioritization.
- **Act III — The Breach:** containment fails; power drops to 15%; endgame determined by accumulated state flags.
- **Endings (4-6):** flag conditions over end state — e.g., Quarantine Protocol (purge), Trojan Horse (entity reaches surface), Whistleblower (leak via uplink then cut power), plus seeded variations in epilogue text (who lived, what the final log says).
- **Signature beat:** the final log entry is written by the anomaly using the player's own terminal.

## Scope & Constraints

- **Team:** solo, part-time. **Budget:** hobby (free assets: freesound/Kenney SFX, self-made CRT shader).
- **Timeline target:** ~5-6 months to release-quality.
- **Delivery:** itch.io first (web export), Steam optional later.
- **Explicitly out of scope:** real audio playback pipeline, cast beyond 4 voices, console ports, multiplayer, save/reload mid-run.

## Tooling

- **sprite-gen** (github.com/aldegad/sprite-gen, Apache-2.0): optional late-phase tool only. Not a dependency of the core game (a text terminal needs no sprites). Potential uses: animated "breathe" ID-badge photos for personnel files in the terminal viewer (Phase 4 polish at earliest), and marketing assets (itch.io header GIF, trailer snippets). Re-evaluate only if character photos are wanted in Act I.

## Roadmap

| Phase | Focus | Duration | Exit criteria |
|-------|-------|----------|---------------|
| 0 — Foundations | World-state schema, command parser core, CRT terminal shell | 2-3 wks | `query L4-02` returns an answer from real state |
| 1 — Vertical Slice | Full Act I, seeded variation, one seeded death-by-deception | 4-6 wks | Fresh player completes Act I in 20-30 min, branches or dies believably |
| 2 — The Lie Engine | Discrepancy generation, NPC lie templates, audio scrubbing, power dual-role, Act II content | 4-6 wks | Lies are provable via cross-referencing; Act II fork playable |
| 3 — Act III + Endings | Flag-condition endings, epilogues, uplink endgame | 4-6 wks | All 4-6 endings reachable; final-log beat works |
| 4 — Meta & Polish | Post-mortem reports, unlocks, tuning, shader/audio polish, playtest, release | 3-4 wks | External playtester completes ≥2 runs without designer help |

**Risk note:** Phase 2 has low visible progress for weeks (the lie engine). Mitigation: ship the vertical slice first; keep it playable throughout.
