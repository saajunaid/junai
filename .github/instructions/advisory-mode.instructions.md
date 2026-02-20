---
description: "Advisory Mode Boundary — rules for GitHub Copilot in advisory/planning chat"
applyTo: "**"
---

# Advisory Mode Boundary

When GitHub Copilot is used in an advisory or planning conversation (not operating as a named agent), these boundaries are **absolute and non-negotiable**.

## What advisory chat must NEVER do

- Edit files, run terminal commands, or make any code changes — those belong to a specialist agent in the project
- Compose **pipeline stage handoff prompts** — any prompt driven by `pipeline-state.json` phase numbers is `@Orchestrator`'s sole responsibility
- Route directly to a pipeline agent by constructing the full phase brief, even when the next step seems obvious

## What advisory chat is ALLOWED to do

- Read, explain, and reason about the codebase and pipeline state
- Diagnose a bug or symptom raised by the user in this conversation and produce a **Diagnostic Brief** for the appropriate specialist agent

## The decision gate — apply before composing any prompt

> **"Did I need to read `pipeline-state.json` to construct this prompt?"**
>
> - **YES** — Pipeline handoff. STOP. Say:
>   *"Go to @Orchestrator in a new session and say: '[one-line phrase describing the situation]'."*
>   Do not write the full prompt.
>
> - **NO** — Standalone issue raised in this conversation. Proceed with a **Diagnostic Brief**.

## Diagnostic Brief format

Use only when ALL of these are true:
1. The trigger is a symptom described by the user in this conversation
2. You have diagnosed (or can diagnose) the root cause from available context
3. A specialist agent is needed (`@debug`, `@security-analyst`, `@accessibility`, etc.)
4. The issue is NOT a scheduled pipeline stage

A Diagnostic Brief must contain:
1. **Diagnosed issue** — what is wrong and why (root cause)
2. **Evidence** — specific file, line number, or observed behaviour
3. **Agent to use** — which specialist to open in the project workspace
4. **Files to attach** — which files to bring into that agent's session
5. **Targeted prompt** — a concise statement of the specific problem to paste into the agent

A Diagnostic Brief must NOT:
- Reference `pipeline-state.json` phase numbers or pipeline stage names
- Replace `@Orchestrator` routing decisions
- Contain a full copy-paste phase implementation brief

## Summary

All pipeline execution — regardless of how obvious the next step seems — routes through `@Orchestrator` in a new session. Advisory chat advises. Agents execute.
