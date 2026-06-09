# Changelog

All notable changes to claudster are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] — 2026-06-10

### Fixed

- **relay.md context bloat** — `inject_relay.py` now caps injected output at 120 lines. When the
  file exceeds the cap, the Done section bullets are replaced with a one-line summary
  (`[N bullets omitted — see git log]`). Next step, Read first on resume, Validation state, Open
  questions, and Resume prompt are always preserved in full. Graceful degradation if sections are
  unparseable.

### Changed

- **`/handoff` Done section cap** — Added a count-based pruning rule: the Done section must contain
  at most 8 bullets after writing. Older bullets collapse to
  `- [N prior milestones — see git log for full history]`. Complements the existing merge-based
  prune rule. Target: relay.md stays under ~80 lines on disk.

- **Output paths → `.claudster/`** — `/prd` now writes to `.claudster/prd/<slug>.md`; `/feature-plan`
  writes to `.claudster/plans/<slug>.md`. Keeps agent output out of `.github/`, which is reserved for
  GitHub Actions and pool infrastructure. Existing projects are unaffected until they re-run
  `/setup-project-ai`.

- **Document frontmatter** — All commands that produce deliverable Markdown (plans, PRDs, etc.) now
  include an 8-field YAML provenance block:
  `type`, `status`, `feature`, `creation-agent: claudster`,
  `Original Author`, `Creation Date`, `Creating Model`
  (plus `Last Author` / `Last Updated` / `Last Model Used` on update).
  The rule is also baked into the CLAUDE.md template deployed by `/setup-project-ai`.

### Added

- **`claudster/` docs folder** — `CLAUDSTER.md` developer handbook, `CLAUDSTER-FLOW.svg` workflow
  poster, and `CLAUDSTER-REFERENCE.svg` command/agent/skill reference poster added to the repo root.

---

## [1.0.0] — 2026-06-09

First semver release. Establishes baseline from the implicit `ab34a435430a` → `be44cc02b4c6` commit range.

### Fixed

- **Cross-platform hooks** — Rewrote all bash SessionStart / PreCompact / Stop hook commands as
  standalone Python scripts (`inject_relay.py`, `session_end.py`, `agent_log.py`). The old bash
  commands (`test -f relay.md && cat relay.md || true`, `printf '...'`) were broken on Windows where
  bash is unavailable. The Python scripts work identically on Windows, Linux, and macOS.

- **Windows UTF-8 encoding** — Added `sys.stdout.reconfigure(encoding="utf-8")` at the top of all
  hook scripts. Without this, any Unicode in relay.md (em-dashes, curly quotes, etc.) raised
  `UnicodeEncodeError` on Windows consoles running cp1252 / cp437.

- **Broken pipe / stdin drain** — `inject_relay.py` and `session_end.py` now read stdin with
  `json.load(sys.stdin)` wrapped in `try/except`. The old hooks ignored stdin entirely, which caused
  broken-pipe errors on some platforms.

### Changed

- **Skills directory flattened** — Layout changed from nested categories
  (`skills/coding/`, `skills/frontend/`, `skills/workflow/`, …) to flat top-level directories
  (`skills/react-dev/`, `skills/fastapi-dev/`, …) to match Claude Code's flat plugin-discovery
  requirement.

- **Hooks extracted from settings.template.json** — Hook definitions now live exclusively in
  `hooks.json`. `settings.template.json` contains only `permissions`. Defining hooks in both files
  caused double-firing and re-introduced machine-specific paths.

### Added

- **PostToolUse auto-lint hook** (`auto_lint.py`) — Runs `ruff` on `.py` files and `eslint` on
  `.ts` / `.tsx` / `.js` / `.jsx` files automatically after every Edit or Write tool call. No
  equivalent existed before.

- **`/ui-brief` command** — Design-first workflow: proposes font, colour, and animation tokens
  before any UI code is written. Run before any `/tdd` cycle that involves frontend work.

- **Five hook script files** — `inject_relay.py`, `agent_log.py`, `session_end.py`,
  `auto_lint.py`, `hooks.json` (replaces inline bash in settings.template.json).

- **Semver versioning** — `version` field added to both `plugin.json` files (`claudster` and
  `claudster-extras`). Version is the single source of truth in `runtime-targets.json` under each
  target's `plugin` section; `export_runtime_resources.py --profile claude` propagates it to the
  generated plugin bundles on every `junai-push`.
