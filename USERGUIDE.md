# junai — User Guide

> A deterministic agent pipeline for VS Code + GitHub Copilot.
> Agents are routed by a state machine, not LLM inference. Every transition is auditable and git-blameable.

---

## Contents

1. [What It Is](#1-what-it-is)
2. [Prerequisites](#2-prerequisites)
3. [Installation](#3-installation)
4. [After Install — Venv + MCP Setup](#4-after-install--venv--mcp-setup)
5. [Starting a Pipeline](#5-starting-a-pipeline)
6. [Pipeline Modes](#6-pipeline-modes)
7. [Stages and Agents](#7-stages-and-agents)
8. [Gates — Approval Checkpoints](#8-gates--approval-checkpoints)
9. [MCP Tools Reference](#9-mcp-tools-reference)
10. [CLI Reference](#10-cli-reference)
11. [Adding a Pipeline-Integrated Agent](#11-adding-a-pipeline-integrated-agent)
12. [Adding an Ad-Hoc Agent](#12-adding-an-ad-hoc-agent)
13. [Adding Skills, Prompts, Instructions](#13-adding-skills-prompts-instructions)
14. [Hotfix Workflow](#14-hotfix-workflow)
15. [Blocked State and Recovery](#15-blocked-state-and-recovery)
16. [Deferred Items and Re-entry](#16-deferred-items-and-re-entry)
17. [pipeline-state.json Schema](#17-pipeline-statejson-schema)
18. [Project Config](#18-project-config)
19. [Troubleshooting](#19-troubleshooting)
20. [VS Code Extension](#20-vs-code-extension)
21. [MCP Server](#21-mcp-server)

---

## 1. What It Is

junai is an agent pipeline infrastructure for VS Code + GitHub Copilot. It routes work between specialised AI agents in a deterministic, auditable way.

**What makes it different from raw Copilot chat:**

| Raw Copilot | junai |
|---|---|
| LLM decides what to do next | Python state machine decides |
| No persistent state | State survives session reloads |
| No approval checkpoints | Gates require explicit human sign-off |
| No artefact tracking | Every stage produces a tracked artefact |
| One model, one context | 23 specialised agents with scoped contexts |

The pipeline covers the full development lifecycle: intent → PRD → architecture → security → planning → UX → implementation → testing → review → devops → janitor → closed.

---

## 2. Prerequisites

| Requirement | Notes |
|---|---|
| VS Code | 1.95+ recommended |
| GitHub Copilot extension | Agent/tool support must be enabled |
| Python 3.11+ | On PATH |
| Git | Required for `junai-pull` and `junai-push` |
| `uv` (optional) | Required only for `uvx junai-mcp` MCP path — install with `pip install uv` |

---

## 3. Installation

There are three ways to get the junai pool into your project.

### Path A — VS Code Extension (recommended for new users)

No PowerShell, no cloning required.

1. Open VS Code → Extensions panel → search `junai`
2. Install **junai — Agentic Pipeline** by `junai-labs`
   or run: `code --install-extension junai-labs.junai`
3. Open your project in VS Code
4. Open Command Palette (`Ctrl+Shift+P`) → **junai: Initialize Agent Pipeline**

The extension copies 23 agents, 203 skills, 30 prompts, 23 instructions, diagrams, and tools into `.github/` and scaffolds `pipeline-state.json` with mode `supervised`. It also writes `.vscode/mcp.json` automatically (see §21).

> **Requires:** `uv` on PATH for the MCP server transport written by the extension to work. If you prefer the local venv path instead, edit `.vscode/mcp.json` after init (see §21).

### Path B — `junai-pull` (for existing junai users)

One-time PowerShell profile setup (run once per machine):

```powershell
# Clone the junai repo
git clone https://github.com/saajunaid/junai E:\Projects\junai

# Add to PowerShell profile
Add-Content $PROFILE "`n. 'E:\Projects\junai\sync.ps1'"

# Reload profile
. $PROFILE
```

Then from any project root:

```powershell
junai-pull
```

This copies `.github/` (agents, skills, prompts, instructions, diagrams, tools) from the junai repo into your workspace. To update the pool later: `junai-pull` again.

### Path C — junai-export / junai-import (air-gapped)

From a machine with access to the junai repo:

```powershell
junai-export C:\Temp\junai-pool.zip
```

On the air-gapped machine, from your project root:

```powershell
junai-import C:\Temp\junai-pool.zip
```

---

## 4. After Install — Venv + MCP Setup

Regardless of which install path you used, you need to create a Python virtual environment so the MCP server and CLI run locally.

**From your project root:**

```powershell
# Create venv
python -m venv .venv

# Install dependencies (Windows)
.venv\Scripts\pip install -r .github\tools\mcp-server\requirements.txt -r .github\tools\pipeline-runner\requirements.txt

# Mac/Linux
.venv/bin/pip install -r .github/tools/mcp-server/requirements.txt -r .github/tools/pipeline-runner/requirements.txt
```

Then **reload VS Code** (`Ctrl+Shift+P` → Reload Window).

**Verify MCP tools are active:** Open Copilot Chat → click the tools icon (🔧). You should see 8 junai tools listed.

**`.vscode/mcp.json` — what should be there:**

If you used the extension, `.vscode/mcp.json` already exists with a `junai` entry (uvx transport). If you used `junai-pull`, create or edit `.vscode/mcp.json`:

```json
{
  "servers": {
    "junai-pipeline": {
      "type": "stdio",
      "command": "${workspaceFolder}/.venv/Scripts/python.exe",
      "args": ["${workspaceFolder}/.github/tools/mcp-server/server.py"],
      "env": {
        "PIPELINE_STATE_PATH": "${workspaceFolder}/.github/pipeline-state.json"
      }
    }
  }
}
```

> On Mac/Linux replace `Scripts/python.exe` with `bin/python`.

---

## 5. Starting a Pipeline

### Initialise pipeline state

```powershell
# Windows (via wrapper at project root)
junai pipeline init --project "MyApp" --feature "user-auth" --type feature

# Mac/Linux
./junai.sh pipeline init --project "MyApp" --feature "user-auth" --type feature

# Or direct Python invocation
.venv\Scripts\python .github\tools\pipeline-runner\junai.py pipeline init --project "MyApp" --feature "user-auth" --type feature
```

`--type` accepts `feature` (default) or `hotfix`.

This writes `.github/pipeline-state.json` with `pipeline_mode: supervised` and `current_stage: intent`.

> `init` is CLI-only by design — see §17 for why it's not an MCP tool.

### Edit project context

Before your first pipeline run, fill in two files:

- `.github/project-config.md` — project name, tech stack, conventions agents should follow
- `copilot-instructions.md` — workspace-level Copilot instructions (loaded by all agents automatically)

### Open the Orchestrator

In Copilot Chat, select the `@Orchestrator` agent, then describe your feature:

```
Read .github/pipeline-state.json and .github/project-config.md.

New feature: [describe what you want to build]

Start in supervised mode.
```

The Orchestrator reads pipeline state, identifies the current stage, invokes the right agent, and presents a handoff button when complete.

---

## 6. Pipeline Modes

Pipeline mode controls how agent handoffs are triggered.

| Mode | Handoffs | Gates |
|---|---|---|
| `supervised` (default) | User clicks handoff button each time | Always require human approval |
| `assisted` | Orchestrator fires next agent automatically | Always require human approval |
| `autopilot` | Orchestrator auto-routes all transitions | Most gates auto-satisfied; `intent_approved` exception |

> Default is always `supervised`. Change mode only when you trust the pipeline to route correctly.

**Switch mode:**

```powershell
# CLI
junai pipeline mode --value supervised
junai pipeline mode --value assisted
junai pipeline mode --value autopilot

# Or in Copilot Chat (calls set_pipeline_mode MCP tool)
"Switch pipeline to assisted mode"
```

Blocked states and escalations always surface to the user regardless of mode.

---

## 7. Stages and Agents

The pipeline has 15 stages (plus a `BLOCKED` state for escalations). Each stage is handled by a dedicated agent.

| Stage | Agent | Description |
|---|---|---|
| `intent` | Orchestrator | Parse and validate the feature intent |
| `intake` | Orchestrator | Route to correct pipeline type (feature/hotfix) |
| `prd` | PRD | Write Product Requirements Document |
| `architect` | Architect | Produce Architecture Decision Record |
| `security` | Security Analyst | Security review and threat modelling |
| `plan` | Plan | Write detailed implementation plan |
| `ux_research` | UX Designer | UX research and user flow mapping |
| `ui_design` | UI/UX Designer | UI design and component specifications |
| `implement` | Implement | Write the code |
| `tester` | Tester | Write and run tests |
| `review` | Code Reviewer | Code review, flag issues |
| `debug` | Debug | Debug failures from tester or review |
| `devops` | DevOps | CI/CD and deployment setup |
| `janitor` | Janitor | Cleanup, dead code, final checks |
| `closed` | — | Pipeline complete |
| `BLOCKED` | — | Escalation requiring human resolution |

Agent files live at `.github/agents/<name>.agent.md`. The registry is at `.github/tools/pipeline-runner/agents.registry.json`.

---

## 8. Gates — Approval Checkpoints

Gates are mandatory human approval checkpoints. They are **never auto-bypassed** regardless of pipeline mode.

| Gate | Sits between |
|---|---|
| `intent_approved` | `intent` → `prd` |
| `adr_approved` | `architect` → `security` |
| `plan_approved` | `plan` → `ux_research` / `implement` |
| `review_approved` | `review` → `devops` |

**Satisfy a gate — three options:**

```powershell
# CLI
junai pipeline gate --name intent_approved

# Copilot Chat (calls satisfy_gate MCP tool)
"Approve intent_approved"

# Direct JSON edit (fallback)
# In .github/pipeline-state.json → supervision_gates → set "intent_approved": true
```

---

## 9. MCP Tools Reference

All 8 tools are accessible via the tools panel in Copilot Chat. You can invoke them through natural language — the model translates intent to tool calls.

### `get_pipeline_status`
Returns current stage, pipeline mode, project name, and last updated timestamp.
```
"What's the pipeline status?"
```

### `notify_orchestrator`
Called by agents at the end of every stage. Parameters: `stage_completed`, `result_status`, `artefact_path` (optional), `result_payload` (optional). Returns the next transition, next stage, and any gate or blocking reason.

### `validate_deferred_paths`
Checks whether deferred artefact paths now exist on disk. Parameter: `deferred_items` (list). Use before closing a pipeline when deferred items were recorded.

### `set_pipeline_mode`
Switches pipeline mode. Parameter: `mode` (`supervised` | `assisted` | `autopilot`).
```
"Switch to assisted mode"
```

### `satisfy_gate`
Marks a supervision gate as satisfied. Parameter: `gate_name`.
```
"Approve plan_approved"
```

### `pipeline_init`
Initialises or resets pipeline state from the template. Equivalent to the CLI `init` command. Guard: will not overwrite existing state without `force: true`.

### `pipeline_reset`
Resets pipeline state to initial values without reinitialising the full template.

### `run_command`
Executes a shell command from within an agent context. Used by Tester and DevOps agents to run tests and build commands.

---

## 10. CLI Reference

Invoke via the wrapper at your project root, or directly via Python.

```powershell
# Windows wrapper (deployed to project root)
junai pipeline <subcommand>

# Mac/Linux wrapper
./junai.sh pipeline <subcommand>

# Direct Python invocation (always works)
.venv\Scripts\python .github\tools\pipeline-runner\junai.py pipeline <subcommand>
```

| Subcommand | What it does |
|---|---|
| `status` | Print current stage, mode, last updated |
| `init --project <n> --feature <s> [--type feature\|hotfix] [--force]` | Initialise or reset pipeline state |
| `mode --value supervised\|assisted\|autopilot` | Switch pipeline mode |
| `gate --name <gate_name>` | Mark a supervision gate as satisfied |
| `next [--event <event>]` | Compute next transition (dry-run, no state write) |
| `advance --event <event> [--stage <stage>]` | Compute and write next transition |
| `preflight --target-stage <stage>` | Run preflight checks before a stage |
| `transitions` | Print all transitions as a table |

The `junai agent` subcommand is for agent management (scaffold, validate, onboard, diff, list, inspect, remove) — see [Adding a Pipeline-Integrated Agent](#11-adding-a-pipeline-integrated-agent).

---

## 11. Adding a Pipeline-Integrated Agent

junai is designed to be extended without touching Python.

**Steps:**

1. **Register the stage** in `agents.registry.json` → `stages` section:
   ```json
   "data_engineer": {
     "agent": "Data Engineer",
     "description": "Data pipeline design and schema specification"
   }
   ```

2. **Register transitions** in `agents.registry.json` → `transitions` section (add T-nn entries for entering and exiting the new stage).

3. **Scaffold the agent file:**
   ```powershell
   junai agent make --name data-engineer --role executing
   ```
   This creates `.github/agents/data-engineer.agent.md` from the canonical template, pre-populated with the §8 Completion Reporting Protocol and HARD STOP.

4. **Edit the agent file** — fill in the agent's responsibilities, skills to load, and outputs.

5. **Validate:**
   ```powershell
   junai agent validate --name data-engineer
   ```

No Python changes. No restart. The new stage is active immediately.

---

## 12. Adding an Ad-Hoc Agent

Ad-hoc agents are called directly by humans on demand — not routed by the Orchestrator.

Just create `.github/agents/<name>.agent.md`. No registry entry needed.

```powershell
junai agent make --name sql-auditor --role advisory
```

Edit the file and call it in Copilot Chat: `@sql-auditor Review the schema in src/db/`.

---

## 13. Adding Skills, Prompts, Instructions

All three are plug-and-play with no code changes.

**Skills** — reusable capability bundles loaded by agents:
1. Create `.github/skills/<category>/<name>/SKILL.md`
2. Add an entry to `.github/skills/_registry.md`
3. Reference in an agent's `load:` block: `load: skills/<category>/<name>/SKILL.md`

**Prompts** — slash-command prompts for Copilot Chat:
1. Create `.github/prompts/<name>.prompt.md`
2. Available immediately as `/name` in Copilot Chat

**Instructions** — contextual instructions loaded per file type or agent:
1. Create `.github/instructions/<name>.instructions.md`
2. Specify `applyTo:` in the frontmatter to scope by glob pattern

---

## 14. Hotfix Workflow

Hotfix pipelines skip the PRD, Architect, Plan, and UX stages.

```powershell
junai pipeline init --project "MyApp" --feature "fix-null-crash" --type hotfix
```

Hotfix flow: `intake` → `debug` → `implement` → `tester` → `review` (if security deferrals) → `closed`.

`hotfix_id` is set automatically in `pipeline-state.json`.

---

## 15. Blocked State and Recovery

A `BLOCKED` state is triggered when an agent raises an escalation with `severity: blocking`.

Escalation files are written to `.github/agent-docs/escalations/`.

**To recover:**
1. Open the escalation file in `.github/agent-docs/escalations/`
2. Resolve the underlying issue it describes
3. Set `"status": "resolved"` in the escalation file
4. Clear `"blocked_by"` in `pipeline-state.json`
5. Run the Orchestrator — it will compute the recovery transition (T-27: BLOCKED → resolved)

---

## 16. Deferred Items and Re-entry

Deferred items are pieces of work intentionally skipped during a pipeline run (e.g., a secondary feature, a non-critical refactor).

They are recorded in `pipeline-state.json` → `deferred[]`.

**To re-enter for deferred work:**
- The pipeline transitions from `closed` → `implement` via T-23

**Check if deferred artefacts now exist:**
```
"Validate deferred paths"
```
This calls `validate_deferred_paths` with the current `deferred[]` list and reports which items are ready to pick up.

---

## 17. `pipeline-state.json` Schema

The state file lives at `.github/pipeline-state.json`. Template: `.github/pipeline-state.template.json`.

Key fields:

| Field | Description |
|---|---|
| `pipeline_mode` | `supervised` \| `assisted` \| `autopilot` |
| `type` | `feature` \| `hotfix` |
| `hotfix_id` | Set for hotfix pipelines |
| `current_stage` | Current stage ID (e.g. `implement`) |
| `status` | `in_progress` \| `blocked` \| `closed` |
| `supervision_gates` | Boolean map of gate satisfaction |
| `stages` | Per-stage object — artefact path, result, timestamps |
| `deferred[]` | List of deferred item objects |
| `_notes.handoff_payload` | Last handoff context between agents |
| `_notes._routing_decision` | Last routing decision from `notify_orchestrator` |

> `init` is CLI-only by design: it destroys and recreates this file. An accidental natural-language trigger mid-pipeline would wipe live state. See §19 for the `pipeline_init` MCP tool guard.

---

## 18. Project Config

Two files provide workspace-level context that agents load at the start of every session:

**`.github/project-config.md`**
Describes the project: name, tech stack, repo structure, coding conventions, and any project-specific agent behaviour overrides. Edit this before your first pipeline run.

**`copilot-instructions.md`** (workspace root)
Standard VS Code Copilot instructions file. All agents inherit these automatically. Use it for global preferences: language, style, output format.

---

## 19. Troubleshooting

| Problem | Fix |
|---|---|
| MCP tools don't appear in Copilot Chat | Venv not created or VS Code not reloaded after creating it. Run `python -m venv .venv`, install deps, then `Ctrl+Shift+P` → Reload Window. |
| `get_pipeline_status` returns empty | `PIPELINE_STATE_PATH` env var in `.vscode/mcp.json` must be an absolute path to `pipeline-state.json`. `${workspaceFolder}` is resolved by VS Code — confirm VS Code has the right workspace root open. |
| Transition computes wrong stage | Run `junai pipeline next --event <event>` to dry-run the transition without writing state. |
| Agent ignores HARD STOP | The §8 Completion Reporting Protocol block is missing from the agent file. Run `junai agent validate --name <name>` to check and `junai agent onboard --name <name>` to patch. |
| Gate never satisfied | In `supervised` and `assisted` modes, gates always require manual approval. Run `junai pipeline gate --name <gate_name>` or say *"Approve `<gate_name>`"* in Copilot Chat. |
| `junai` command not found | `junai.bat` / `junai.sh` must be at your workspace root. Pull the wrappers from the junai pool. Alternatively, invoke directly: `.venv\Scripts\python .github\tools\pipeline-runner\junai.py pipeline <cmd>`. |
| Pipeline state looks wrong after direct agent work | Run the Orchestrator — it automatically runs a §9.2 drift resync to reconcile state with actual artefacts on disk. |

---

## 20. VS Code Extension

The extension is the zero-friction install path. No PowerShell, no cloning.

**Install:**
- VS Code Extensions panel → search `junai` → install **junai — Agentic Pipeline** by `junai-labs`
- Or: `code --install-extension junai-labs.junai`
- Marketplace: https://marketplace.visualstudio.com/items?itemName=junai-labs.junai

**Extension ID:** `junai-labs.junai` · **Source:** https://github.com/saajunaid/junai-vscode

**Commands:**

| Command | What it does |
|---|---|
| `junai: Initialize Agent Pipeline` | Deploy pool into `.github/`, scaffold `pipeline-state.json`, write `.vscode/mcp.json` |
| `junai: Show Pipeline Status` | Output panel: mode, version, init date |
| `junai: Set Pipeline Mode` | Quick-pick: supervised / assisted / autopilot |

**When to use extension vs `junai-pull`:**

| Scenario | Recommended |
|---|---|
| New developer, first time | Extension — no PowerShell required |
| Already have junai cloned | `junai-pull` — pool stays in sync with upstream |
| Air-gapped machine | `junai-export` + `junai-import` |

The extension does **not** create the Python venv. After init, still run the venv setup from §4.

---

## 21. MCP Server

The junai MCP server is published as a standalone package for users who want to add it to any project without the full extension.

- **Registry:** `io.github.saajunaid/junai-mcp` at `registry.modelcontextprotocol.io`
- **PyPI:** https://pypi.org/project/junai-mcp/0.1.1/
- **Source:** `.github/tools/mcp-server/server.py`

### Manual `.vscode/mcp.json` setup (uvx transport)

```json
{
  "servers": {
    "junai": {
      "type": "stdio",
      "command": "uvx",
      "args": ["junai-mcp"]
    }
  }
}
```

**Prerequisite:** `uv` on PATH — `pip install uv` or https://docs.astral.sh/uv/

### Local venv transport (recommended for active development)

```json
{
  "servers": {
    "junai-pipeline": {
      "type": "stdio",
      "command": "${workspaceFolder}/.venv/Scripts/python.exe",
      "args": ["${workspaceFolder}/.github/tools/mcp-server/server.py"],
      "env": {
        "PIPELINE_STATE_PATH": "${workspaceFolder}/.github/pipeline-state.json"
      }
    }
  }
}
```

The local venv path always runs your workspace pool version. The `uvx` path runs the published PyPI package. Use local venv if you customise the server.

### Automatic setup via extension

The VS Code extension (§20) writes the `junai` (uvx) entry automatically on init. If a `junai` key already exists, it is left untouched.
