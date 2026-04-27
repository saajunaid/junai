---
name: file-bug
description: File a bug issue against a VMIE project (nps-lens or any Gitea-hosted repo) by interviewing the user for symptoms and creating a correctly-labelled Gitea issue. Use this skill whenever the user mentions a bug, something broken, unexpected behaviour, or asks to "file an issue", "report a bug", or "raise a ticket" — even if they only give a one-line description. Never ask the user to fill in a Gitea form manually.
---

# file-bug — VMIE Issue Filing Skill

## Purpose

Turn a user's one-line observation ("the quotes aren't showing") into a properly-structured, symptom-only Gitea issue with the right template and labels — without the user ever opening a browser form.

**Critical constraint:** The issue body must contain **symptoms only**. Never include root-cause hypotheses, stack traces you've inferred, or fix suggestions. The debug pipeline does the investigation — contaminating the issue body pre-empts that and breaks the pipeline.

---

## Step 1 — Interview (3 questions max)

Ask only the questions whose answers you don't already have from context. If the user's initial message already answers some, skip those.

**Q1 — What page / feature is broken?**
> "Which part of the app — which page or feature?"

**Q2 — What did you expect vs. what did you see?**
> "What were you expecting to happen, and what actually happened instead?"

**Q3 — Any pattern? (optional — only ask if needed)**
> "Does it happen every time, or only under certain conditions (e.g., specific filter, data period, user)?"

Do not ask for a root cause, do not ask the user to inspect the code, do not ask for logs. If they volunteer that information, note it privately but do not include it in the issue body.

---

## Step 2 — Classify the flow

Determine which issue template to use based on the nature of the bug:

| Signal | Template | Labels |
|--------|----------|--------|
| Display/data issue, no config change needed | `bug_report_autofix.md` | `bug, auto-fix, needs-triage` |
| Requires a deliberate design or config decision | `bug_report.md` | `bug, needs-triage` |
| User explicitly says "just fix it, no review needed" | `approved_change.md` | `approved-change` |

Default to **auto-fix** for display/data bugs unless the user says otherwise.

---

## Step 3 — Compose the issue body

Use this exact structure. Keep it factual and symptom-focused:

```
## Bug Report

**What I see:**
[One paragraph — concrete description of the broken behaviour the user reported. First person. No technical jargon unless the user used it.]

**Steps to reproduce:**
1. [Step 1]
2. [Step 2]
3. ...

**Expected:**
[What should happen]

**Actual:**
[What is happening instead]

**Pattern / conditions:**
[Only include if known — e.g. "Monthly period only", "Broadband product only", "All periods affected"]

**Environment:**
[Dev / Prod / Both — infer from context or ask only if critical]
```

**Do not add:**
- Root cause theories ("probably because...")
- Code snippets or file names
- Fix suggestions
- Stack traces

---

## Step 4 — Create the issue

Call the helper script to file the issue:

```bash
python .github/skills/vmie/file-bug/scripts/create_issue.py \
  --repo vmie/nps-lens \
  --title "[BUG] <concise title>" \
  --body "<escaped body>" \
  --flow auto-fix
```

Or invoke the script as a Python module with the `create_issue()` function — see `scripts/create_issue.py` for the API.

The script returns the issue URL. Report it to the user as:
> "Issue filed: http://git.local:8090/vmie/nps-lens/issues/N — the debug pipeline will investigate and post a diagnosis shortly."

---

## Step 5 — Confirm and stop

After the issue URL is returned:
- Tell the user the issue number and URL
- Tell them the pipeline will post a diagnosis comment within a few minutes
- **Do not** start investigating the bug yourself
- **Do not** suggest a fix
- **Do not** open files or run queries to check the data

The pipeline owns what happens next.

---

## Repo → label mapping

| Repo | Gitea URL | Label IDs (auto-fix=13, bug=11, needs-triage=31, approved-change=33) |
|------|-----------|-----------------------------------------------------------------------|
| vmie/nps-lens | http://git.local:8090 | See above |

To add a new repo, update this table and the `REPOS` dict in `scripts/create_issue.py`.

---

## Error handling

| Problem | Action |
|---------|--------|
| Script returns HTTP 401 | Token expired — ask user to update `GITEA_TOKEN` in `.env` or `config/.env.gitea` |
| Script returns HTTP 422 | Label ID mismatch — run `scripts/list_labels.py` to get current IDs |
| User gives root cause | Accept it politely, exclude it from issue body, proceed with symptom-only filing |
| User gives one word ("broken") | Ask Q1, Q2, Q3 before filing |
