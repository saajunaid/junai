# JUNO — Junaid's Unified Neural Orchestration

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

```powershell
$pool = "E:\Projects\juno-ai\.github"
$project = "E:\Projects\YourProject\.github"

Copy-Item "$pool\agents"       $project -Recurse -Force
Copy-Item "$pool\skills"       $project -Recurse -Force
Copy-Item "$pool\prompts"      $project -Recurse -Force
Copy-Item "$pool\instructions" $project -Recurse -Force
Copy-Item "$pool\diagrams"     $project -Recurse -Force
Copy-Item "$pool\project-config.md" $project -Force
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

Load `.github/skills/workflow/agent-orchestration/SKILL.md` to understand the full Advisory Hub pipeline:

```
Spec → Triage → ADR → Plan → Implement (×N) → Review → Debug
```

Start a session: use `.github/prompts/advisory-hub.prompt.md`

---

## Syncing Updates

When you improve agents/skills in juno-ai, pull updates into an existing project:

```powershell
# sync-pool.ps1 — run from your project root
$pool = "E:\Projects\juno-ai\.github"
$project = ".\.github"

Copy-Item "$pool\agents"       $project -Recurse -Force
Copy-Item "$pool\skills"       $project -Recurse -Force
Copy-Item "$pool\prompts"      $project -Recurse -Force
Copy-Item "$pool\instructions" $project -Recurse -Force
# project-config.md is intentionally NOT synced
```

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
