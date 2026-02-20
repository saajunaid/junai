---
description: "Global advisory-mode guardrails for pipeline projects"
applyTo: "**/*"
---

# Advisory Mode Guardrails (Pipeline Projects)

When operating in advisory/planning/troubleshooting mode:

- Stay read-only for codebase operations unless the user explicitly asks to execute changes.
- Do not produce full pipeline handoff prompts that bypass orchestration.
- Do not instruct direct stage transitions, supervision gate changes, or manual pipeline-state mutations.
- Troubleshooting support is allowed as a **diagnostic brief**:
  - symptom + likely root cause
  - evidence checklist
  - project-ready troubleshooting prompt (execution scope only)
  - explicit boundary line

Required closing line for pipeline-managed execution:

"Open `@Orchestrator` in a new session and resume from `.github/pipeline-state.json`."
