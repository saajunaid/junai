# junai — Deterministic Agent Pipeline for VS Code Copilot

> 23 specialised AI agents. A 9-stage deterministic pipeline. No hallucinated routing.  
> Drop into any project. Run everything from the chat window.

---

## What It Is

junai is a portable agent framework for VS Code + GitHub Copilot. It gives you:

- **23 specialised agents** — Architect, Implement, Tester, Code Reviewer, Debug, Security Analyst, and more
- **A deterministic pipeline** — a Python state machine owns all routing logic; the LLM cannot hallucinate the wrong next step
- **Supervised and auto modes** — you control whether agents wait for your gate approval or run autonomously
- **70+ reusable skills, 30 prompts, 23 instruction files** — loaded dynamically by agents as needed
- **Chat-first UX** — init, reset, mode switch, gate approval all from the Copilot chat window

---

## Prerequisites

| Requirement | Notes |
|---|---|
| VS Code | Any recent version |
| GitHub Copilot | Agent mode must be enabled in Copilot Chat settings |
| Python 3.11+ | Must be on PATH |
| Git | For pipeline commits |
| PowerShell 5.1+ | Windows built-in; required for `sync.ps1` |

---

## Setup — Path A: New Project (Fastest)

1. Click **"Use this template"** → **"Create a new repository"** on this page
2. Clone your new repo, open it in VS Code
3. One-time venv setup (30 seconds):
   ```powershell
   python -m venv .venv
   .venv\Scripts\pip install -r tools/mcp-server/requirements.txt -r tools/pipeline-runner/requirements.txt
   ```
4. Reload VS Code — the 7 junai MCP tools appear in the Copilot Chat tools icon (⚙)
5. Edit `.github/project-config.md` — set your project name and stack
6. Create `.github/copilot-instructions.md` — add your architecture overview, DB names, key file paths
7. Open Copilot Chat, type `@Orchestrator` and describe what you want to build

---

## Setup — Path B: Existing Project

1. Clone junai anywhere on your machine:
   ```powershell
   git clone https://github.com/saajunaid/junai
   ```
2. Add to your PowerShell `$PROFILE` (once per machine):
   ```powershell
   . 'C:\Path\To\junai\sync.ps1'
   ```
3. From your existing project root:
   ```powershell
   junai-pull
   ```
   Deploys `.github/` (agents, skills, prompts, instructions, diagrams) and `tools/` (pipeline runner + MCP server) into your project.
4. Create venv (same as Path A step 3), reload VS Code
5. Configure `project-config.md` and `copilot-instructions.md`, then open Copilot Chat

---

## Your First Pipeline — Chat Commands

No terminal needed after setup. Everything runs from Copilot Chat:

| Say this | What happens |
|---|---|
| *"Start a new pipeline for feature: dark mode"* | `pipeline_init` creates state, Orchestrator classifies and routes |
| *"Switch to auto mode"* | Agents hand off without waiting for your click |
| *"Approve plan_approved"* | Satisfies a gate — gates are never bypassed in any mode |
| *"What stage are we at?"* | Returns current stage, mode, blocked_by |
| *"Reset pipeline for next feature: X"* | Wipes state and starts fresh |

### Pipeline stages

```
intent → prd → architect → plan → implement → tester → review → closed
```

Hotfix fast-track: `intent → implement → tester → closed`

---

## Supervised vs Auto Mode

- **Supervised (default):** Orchestrator presents a handoff button after each stage. You click to proceed. Gates require explicit approval.
- **Auto:** Orchestrator invokes the next agent immediately after completion. Gates still require your approval — they cannot be bypassed.

Switch at any time: *"Switch to auto mode"* or *"Switch to supervised mode"* in chat.

---

## Agents at a Glance

| Layer | Agents |
|---|---|
| Deep Reasoning | Architect, Plan, Debug, Security Analyst |
| Structured Thinking | PRD, Code Reviewer, Data Engineer, Tester, SQL Expert, UI/UX Designer, UX Designer, Prompt Engineer, Accessibility, Mentor |
| Execution | Implement, Streamlit Developer, Frontend Developer, DevOps, Janitor |
| Specialist | Mermaid Diagram, SVG Diagram, Project Manager |

---

## MCP Tools (7 total)

Available via natural language in Copilot Chat — or directly in the tools panel:

| Tool | Purpose |
|---|---|
| `pipeline_init` | Start a new pipeline (confirm=true required) |
| `pipeline_reset` | Reset for next feature (confirm=true required) |
| `set_pipeline_mode` | Switch supervised ↔ auto |
| `satisfy_gate` | Approve a supervision gate |
| `get_pipeline_status` | Current stage, mode, blocked_by, next transition |
| `notify_orchestrator` | Record stage completion + compute next transition |
| `validate_deferred_paths` | Verify deferred item file paths before pipeline close |

---

## Keeping Your Pool Updated

```powershell
junai-pull               # pull latest agents/skills/prompts → your project
junai-push               # push improvements from your project → junai pool
junai-export             # bundle to folder or .zip (offline/air-gapped)
junai-import <path>      # restore from export bundle
```

> `project-config.md`, `copilot-instructions.md`, `pipeline-state.json`, and `agent-docs/` are **never synced** — project-specific.

---

## Pipeline CLI (terminal / scripting)

```powershell
python tools/pipeline-runner/pipeline_runner.py status
python tools/pipeline-runner/pipeline_runner.py init --project <name> --feature <slug> --type feature|hotfix --force
python tools/pipeline-runner/pipeline_runner.py mode --value supervised|auto
python tools/pipeline-runner/pipeline_runner.py gate --name <gate_name>
python tools/pipeline-runner/pipeline_runner.py next
python tools/pipeline-runner/pipeline_runner.py transitions
```

See `.github/pipeline/cheatsheet.md` for the full reference.

---

*Built by Junaid — because AI agents that hallucinate their own routing were getting old.*

---

## What's Inside

```
.github/
├── agents/          22 specialised AI agents (Architect, Implement, Debug, etc.)
├── skills/          70+ reusable skills (coding, data, frontend, workflow, devops)
├── prompts/         28 prompt templates (advisory-hub, plan, code-review, etc.)
├── instructions/    22 instruction files (python, fastapi, streamlit, security, etc.)
├── diagrams/        Agent workflow reference cards and design docs
└── project-config.md  ← The only file you edit per project
```

## Quick Start

### 1. Copy the pool into your project

Dot-source `sync.ps1` in your PowerShell profile (once):

```powershell
# In $PROFILE:
. 'E:\Projects\junai\sync.ps1'
```

Then run from any project root:

```powershell
junai-pull          # copies agents, skills, prompts, instructions, diagrams into .github/
```

### 2. Configure your project

Edit `.github/project-config.md` — either set the `profile` field to a named profile, or fill in Step 2 with your project values.

### 3. Add your project's `copilot-instructions.md`

This is **not** in the pool — it's project-specific. Create `.github/copilot-instructions.md` with your project's:

- Architecture overview
- Stack details
- DB connection info
- Data source tables
- Key file paths

Agents read `project-config.md` for brand/stack config and `copilot-instructions.md` for project architecture context.

---

## Agent Overview

| Layer | Agents | Model |
|-------|--------|-------|
| Deep Reasoning | Architect, Security Analyst, Plan, Debug | Claude Opus 4.6 |
| Structured Thinking | PRD, Code Reviewer, Data Engineer, Tester, SQL Expert, UI/UX Designer, UX Designer, Prompt Engineer, Accessibility, Mentor, Mermaid, SVG | Claude Sonnet 4.6 |
| Execution | Implement, Streamlit Developer, Frontend Developer, DevOps, Janitor | GPT-5.3-Codex |

---

## Pipeline Methodology

JUNAI uses a **deterministic 9-stage pipeline** with a state machine runner:

```
intent → prd → architect → plan → implement → tester → review → deploy → closed
```

Hotfix fast-track: `intent → implement → tester → closed`

### junai CLI (agent-sandbox projects)

```powershell
junai pipeline status                        # current stage, mode, blocked_by
junai pipeline next                          # dry-run: what would advance?
junai pipeline advance --event <stage>_complete
junai pipeline mode --value supervised|auto  # supervised = gated, auto = autonomous
junai pipeline gate  --name <gate_name>      # satisfy a supervision gate

junai agent list                             # compliance table for all agents
junai agent make     --name <xyz> [--role executing|advisory]
junai agent validate --name <xyz>
junai agent onboard  --name <xyz> [--yes]
```

See `.github/pipeline/cheatsheet.md` for the full reference.

For the Advisory Hub flow (non-pipeline projects), load `.github/skills/workflow/agent-orchestration/SKILL.md` and start with `.github/prompts/advisory-hub.prompt.md`.

---

## Syncing Updates

All sync operations are handled by `sync.ps1`. Dot-source it once in your `$PROFILE`:

```powershell
. 'E:\Projects\junai\sync.ps1'
```

| Command | What it does |
|---|---|
| `junai-pull` | Pool → project: copies agents, skills, prompts, instructions, diagrams into `.github/` |
| `junai-push` | Project → pool: commits improvements from a project back into this repo |
| `junai-export` | Creates a self-contained folder or `.zip` for offline/air-gapped machines |
| `junai-import` | Restores a pool from an export folder or zip on a machine without GitHub access |

> `project-config.md` and `copilot-instructions.md` are intentionally **never** synced — they are project-specific.

---

## What Stays in Your Project (Not in This Pool)

| File/Folder | Why It Stays |
|-------------|-------------|
| `.github/copilot-instructions.md` | Project architecture, DB names, stack details |
| `.github/project-config.md` | Your filled-in profile and project values |
| `.github/plans/` | Phased execution plans for active features |
| `.github/handoffs/` | Emergency context handoffs |
| `.github/agent-docs/` | PRDs, architecture docs, artefact manifests |

---

*Built by Junaid — because copy-pasting agent prompts between projects was getting old.*
