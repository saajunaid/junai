# JUNAI — Junaid's Unified Neural AI

> A portable AI agent resource pool for VS Code Copilot.  
> Drop the `.github/` folder into any project. Set a profile. Go.

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
