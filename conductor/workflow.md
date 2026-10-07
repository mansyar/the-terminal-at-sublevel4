# Project Workflow

## Guiding Principles

1.  **The Plan is the Source of Truth:** All work must be tracked in `plan.md`
2.  **The Tech Stack is Deliberate:** Changes to the tech stack must be
    documented in `tech-stack.md` *before* implementation
3.  **Test-Driven Development — for logic-bearing code only:** Write failing
    tests before implementing any logic-bearing module (WorldState,
    CommandParser, DialogueEngine, EventScheduler, EndingEvaluator, lie
    models, seeding logic). Presentation code (TerminalUI, CRT shader, SFX
    wiring, scene layout) is EXEMPT from the red-phase discipline; it still
    requires smoke tests where feasible and must always pass lint/format.
4.  **High Code Coverage:** Aim for >80% coverage on logic-bearing modules.
    Presentation code is excluded from coverage gates.
5.  **User Experience First:** Every decision should prioritize player
    experience and the fair-play mystery rule (see `product-guidelines.md`).
6.  **Non-Interactive & CI-Aware:** Prefer non-interactive commands. Use
    `CI=true` where relevant for watch-mode tools to ensure single execution.

## Task Workflow

All tasks follow a strict lifecycle:

### Standard Task Workflow

1.  **Select Task:** Choose the next available task from `plan.md` in sequential
    order

2.  **Mark In Progress:** Before beginning work, edit `plan.md` and change the
    task from `[ ]` to `[~]`

3.  **Write Failing Tests (Red Phase) — logic-bearing tasks only:**

    -   Create a new test file for the feature or bug fix (extends
        `GdToolsTest`).
    -   Write one or more unit tests that clearly define the expected behavior
        and acceptance criteria for the task.
    -   **CRITICAL:** Run `gd-tools test` and confirm that the tests fail as
        expected. This is the "Red" phase of TDD. Do not proceed until you have
        failing tests.
    -   **Exemption:** For presentation/UI tasks, skip this step and proceed to
        implementation; add an integration smoke test before committing.

4.  **Implement to Pass Tests (Green Phase):**

    -   Write the minimum amount of application code necessary to make the
        failing tests pass.
    -   Run `gd-tools test` again and confirm that all tests now pass. This is
        the "Green" phase.

5.  **Refactor (Optional but Recommended):**

    -   With the safety of passing tests, refactor the implementation code and
        the test code to improve clarity, remove duplication, and enhance
        performance without changing the external behavior.
    -   Rerun tests to ensure they still pass after refactoring.

6.  **Verify Coverage (logic-bearing modules):** Run
    `gd-tools test --coverage --min 80 --show-uncovered`. Target: >80%
    coverage for new logic-bearing code. Presentation code is excluded via
    `gd-tools.toml` excludes or `# gd-tools: no cover` annotations.

7.  **Document Deviations:** If implementation differs from tech stack:

    -   **STOP** implementation
    -   Update `tech-stack.md` with new design
    -   Add dated note explaining the change
    -   Resume implementation

8.  **Commit Code Changes:**

    -   Stage all code changes related to the task.
    -   Propose a clear, concise commit message e.g,
        `feat(worldstate): Add door state mutations with validation`.
    -   Perform the commit.

9.  **Attach Task Summary with Git Notes:**

    -   **Step 9.1: Get Commit Hash:** Obtain the hash of the *just-completed
        commit* (`git log -1 --format="%H"`).
    -   **Step 9.2: Draft Note Content:** Create a detailed summary for the
        completed task. This should include the task name, a summary of changes,
        a list of all created/modified files, and the core "why" for the change.
    -   **Step 9.3: Attach Note:** Use the `git notes` command to attach the
        summary to the commit.
        `git notes add -m "<note content>" <commit_hash>`

10. **Get and Record Task Commit SHA:**

    -   **Step 10.1: Update Plan:** Read `plan.md`, find the line for the
        completed task, update its status from `[~]` to `[x]`, and append the
        first 7 characters of the *just-completed commit's* commit hash.
    -   **Step 10.2: Write Plan:** Write the updated content back to `plan.md`.

11. **Commit Plan Update:**

    -   **Action:** Stage the modified `plan.md` file.
    -   **Action:** Commit this change with a descriptive message (e.g.,
        `conductor(plan): Mark task 'Implement WorldState schema' as complete`).

### Task Correction & Plan Amendment Workflows

When an implemented task or phase requires corrections, amendments, or additions, follow these standard workflows to maintain plan integrity and avoid untracked code drift:

1.  **In-Flight Refinements:** If minor gaps are found while a task is actively
    in-progress (`[~]`), make the adjustments directly in the active
    implementation stream and ensure passing tests before committing.
2.  **Code Review Corrections (`conductor-review`):** If issues are identified
    during or after a code review, instruct the agent to review your changes
    (e.g., *"run a review"* or triggering the action manually in compatible
    clients). The review agent will automatically append a `Review Fixes` phase
    to `plan.md` so that correction tasks are formally tracked and
    checkpointed.
3.  **Logical State Reversions (`conductor-revert`):** If a task implementation
    is fundamentally flawed or needs to be redone, instruct the agent to revert
    the changes (e.g., *"revert the last task"* or triggering the action
    manually in compatible clients). This safely rolls back associated git
    commits and resets the task state in `plan.md` back to pending `[ ]` to
    allow a clean restart.

### Phase Completion Verification and Checkpointing Protocol

**Trigger:** This protocol is executed immediately after a task is completed
that also concludes a phase in `plan.md`.

1.  **Announce Protocol Start:** Inform the user that the phase is complete and
    the verification and checkpointing protocol has begun.

2.  **Ensure Test Coverage for Phase Changes:**

    -   **Step 2.1: Determine Phase Scope:** To identify the files changed in
        this phase, you must first find the starting point. Read `plan.md` to
        find the Git commit SHA of the *previous* phase's checkpoint. If no
        previous checkpoint exists, the scope is all changes since the first
        commit.
    -   **Step 2.2: List Changed Files:** Execute `git diff --name-only
        <previous_checkpoint_sha> HEAD` to get a precise list of all files
        modified during this phase.
    -   **Step 2.3: Verify and Create Tests:** For each file in the list:
        -   **CRITICAL:** First, check its extension. Exclude non-code files
            (e.g., `.json`, `.md`, `.yaml`, `.gdshader`, `.tres`, `.tscn` with
            no attached script, art assets).
        -   For each remaining **logic-bearing** code file, verify a
            corresponding test file exists. Presentation files need only a
            smoke test or documented manual verification.
        -   If a test file is missing, you **must** create one. Before writing
            the test, **first, analyze other test files in the repository to
            determine the correct naming convention and testing style.** The
            new tests **must** validate the functionality described in this
            phase's tasks (`plan.md`).

3.  **Execute Automated Tests with Proactive Debugging:**

    -   Before execution, you **must** announce the exact shell command you will
        use to run the tests.
    -   **Example Announcement:** "I will now run the automated test suite to
        verify the phase. **Command:** `gd-tools test --coverage --min 80`"
    -   Execute the announced command.
    -   If tests fail, you **must** inform the user and begin debugging. You may
        attempt to propose a fix a **maximum of two times**. If the tests still
        fail after your second proposed fix, you **must stop**, report the
        persistent failure, and ask the user for guidance.

4.  **Propose a Detailed, Actionable Manual Verification Plan:**

    -   **CRITICAL:** To generate the plan, first analyze `product.md`,
        `product-guidelines.md`, and `plan.md` to determine the user-facing
        goals of the completed phase.
    -   You **must** generate a step-by-step plan that walks the user through
        the verification process, including any necessary commands and specific,
        expected outcomes.
    -   For this project, manual verification means launching the game
        (editor run or exported build) and playing through the phase's
        playable content.

5.  **Await Explicit User Feedback:**

    -   After presenting the detailed plan, ask the user for confirmation:
        "**Does this meet your expectations? Please confirm with yes or provide
        feedback on what needs to be changed.**"
    -   **PAUSE** and await the user's response. Do not proceed without an
        explicit yes or confirmation.

6.  **Identify Target Commit for Report:**

    -   Do NOT create a new empty commit for checkpointing.
    -   Identify the hash of the last functional commit made during this phase. This will be the target for the verification report.

7.  **Attach Auditable Verification Report using Git Notes:**

    -   **Step 7.1: Draft Note Content:** Create a detailed verification report
        including the automated test command, the manual verification steps, and
        the user's confirmation.
    -   **Step 7.2: Attach Note:** Use the `git notes` command to attach the full report to the target commit identified in step 6.

8.  **Get and Record Phase Checkpoint SHA:**

    -   **Step 8.1: Get Commit Hash:** Obtain the hash of the *just-created
        checkpoint commit* (`git log -1 --format="%H"`).
    -   **Step 8.2: Update Plan:** Read `plan.md`, find the heading for the
        completed phase, and append the first 7 characters of the commit hash in
        the format `[checkpoint: <sha>]`.
    -   **Step 8.3: Write Plan:** Write the updated content back to `plan.md`.

9.  **Commit Plan Update:**

    -   **Action:** Stage the modified `plan.md` file.
    -   **Action:** Commit this change with a descriptive message following the
        format `conductor(plan): Mark phase '<PHASE NAME>' as complete`.

10. **Announce Completion:** Inform the user that the phase is complete and the
    checkpoint has been created, with the detailed verification report attached
    as a git note.

### Quality Gates

Before marking any task complete, verify:

- [ ] All tests pass (`gd-tools test`)
- [ ] Coverage meets requirements (>80% for logic-bearing modules;
      `gd-tools test --coverage --min 80`)
- [ ] Code passes `gd-tools format --check` and `gd-tools lint`
- [ ] Code follows project's code style guidelines (as defined in
      `code_styleguides/` and enforced by gdlint/gdformat)
- [ ] All public functions/methods are documented (GDScript docstrings)
- [ ] Type safety is enforced (typed GDScript where practical)
- [ ] Fair-play rule respected: any new player-facing truth is queryable
      before it matters
- [ ] Documentation updated if needed
- [ ] No security vulnerabilities introduced (e.g., no hardcoded secrets,
      user input sanitized before command execution)

## Development Commands

### Setup

```bash
# Install gd-tools (Python 3.10+ and a Godot 4.5+ binary required)
pip install gd-tools-cli

# Bootstrap the Godot project (deploys test/coverage addons, generates configs)
gd-tools init

# Verify the environment
gd-tools doctor

# Install pre-commit hooks (format + lint)
gd-tools install-hooks --hooks format,lint
```

### Daily Development

```bash
gd-tools test --watch          # run affected suites on .gd file changes
gd-tools test                  # full suite
gd-tools test --changed        # only suites mapped from git-changed files
gd-tools lint                  # gdlint
gd-tools format                # gdformat
```

### Before Committing

```bash
gd-tools format --check        # formatting gate
gd-tools lint                  # lint gate
gd-tools test --coverage --min 80   # tests + coverage gate
```

## Testing Requirements

### Unit Testing (logic-bearing code)

- Every logic-bearing module must have corresponding tests extending
  `GdToolsTest`.
- Tests run inside Godot; use the real engine objects where meaningful.
- Use doubles/stubs to isolate collaborators; test both success and failure
  cases.
- WorldState rules (power economy, door interlocks, seed behavior) and lie
  models require the strictest coverage.

### Integration / Smoke Testing

- Command-parser end-to-end tests: input string → WorldState mutation →
  rendered output.
- UI shell gets smoke tests (scene loads, input accepted, output rendered).

### Manual Playtest Verification

- Use `gd-tools coverage run` to collect coverage during manual playtest
  sessions.
- Narrative pacing and dread cannot be automated: every phase checkpoint
  includes a manual playtest of that phase's playable content.

## Code Review Process

### Self-Review Checklist

Before requesting review:

1.  **Functionality**
    - Feature works as specified
    - Edge cases handled (invalid commands, impossible states)
    - Error messages read like a real terminal would emit them

2.  **Code Quality**
    - Follows style guide
    - DRY principle applied
    - Clear variable/function names
    - Appropriate comments

3.  **Testing**
    - Unit tests comprehensive (logic-bearing code)
    - Integration tests pass
    - Coverage adequate (>80% logic)

4.  **Fair-Play & Design Integrity**
    - No truth hidden from queryable channels
    - No NPC lie contradicts WorldState
    - New commands honor the strict verb set

5.  **Performance**
    - No per-frame allocations in hot paths
    - Typing input latency negligible

## Commit Guidelines

### Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons, etc.
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests
- `chore`: Maintenance tasks

### Examples

```bash
git commit -m "feat(parser): Add fuzzy matching for query verb"
git commit -m "fix(worldstate): Correct power allocation underflow"
git commit -m "test(lies): Add tests for Miller deflection model"
git commit -m "style(ui): Improve terminal cursor blink timing"
```

## Definition of Done

A task is complete when:

1. All code implemented to specification
2. Unit tests written and passing (logic-bearing code)
3. Code coverage meets project requirements
4. Documentation complete (if applicable)
5. Code passes all configured linting and formatting checks
6. Implementation notes added to `plan.md`
7. Changes committed with proper message
8. Git note with task summary attached to the commit

## Emergency Procedures

### Critical Bug in a Shippable Build

1. Write failing test for the bug (if logic-bearing)
2. Implement minimal fix
3. Re-verify the affected narrative branch manually
4. Tag a patched release
5. Document in plan.md

### Broken Narrative Consistency (lie contradicts state)

1. Stop feature work — this is the game's cardinal sin
2. Write a failing test that captures the contradiction
3. Fix the state model or the lie template (never the telemetry truth)
4. Re-run full suite
5. Document in plan.md

## Release Workflow (itch.io)

### Pre-Release Checklist

- [ ] All tests passing
- [ ] Coverage >80% on logic modules
- [ ] No linting errors
- [ ] Web export verified in a real browser
- [ ] Save/meta-progression persistence verified
- [ ] CREDITS.md complete (asset attribution)

### Release Steps

1. Tag release version
2. Export Web + Windows builds
3. Upload to itch.io with correct channel files
4. Verify the uploaded build plays end-to-end
5. Monitor player feedback

## Continuous Improvement

- Review workflow after each phase checkpoint
- Update based on pain points
- Document lessons learned
- Keep things simple and maintainable
