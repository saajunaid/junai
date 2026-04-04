# Phased Execution Plans

This directory contains **phased execution plans** for multi-session work.

## Purpose

When work is too large for a single session, create a plan document here that breaks it into phases. Each phase is sized to complete in one session.

## Creating Plans

Use the `/plan` prompt:
```
/plan add customer search feature
/plan refactor data services
```

Or manually create: `plans/{feature-name}.md`

## Using Plans

**Start implementation:**
```
Read plans/{feature-name}.md and implement Phase 1.
```

**Continue work:**
```
Read plans/{feature-name}.md and implement Phase 2. Phase 1 is complete.
```

## Plan Lifecycle

```
📝 Created     → /plan prompt generates document
⏳ In Progress → Phases being implemented
✅ Completed   → All phases done, move to archive/
🗑️ Archived    → Move to plans/archive/
```

## File Naming

- `{feature-name}.md` - Use kebab-case
- Examples: `customer-search.md`, `interaction-linking.md`, `analytics-dashboard.md`

## Why Here (Not docs/)

AI workflow artifacts are kept in `` to separate them from:
- `docs/` - Project documentation for users/developers
- `enhancements/` - Feature specifications and PRDs

This keeps the repository organized:
```
├── plans/      ← Phased execution plans (AI workflow)
├── handoffs/   ← Emergency context handoffs (AI workflow)
├── agents/     ← Agent definitions
├── prompts/    ← Prompt commands
├── skills/     ← Loadable skills
└── instructions/ ← Coding guidelines
```
