---
name: golden-workflow
description: Standardize VMIE Gitea workflows onto the Golden VMIE Workflow for the local shared-runner infra model. Use whenever an existing app has brittle tag-first deploy logic, split CI and deploy files, manual deploy drift, or runner-safe workflow issues, and also whenever a new repo must inherit the correct default CI/CD flow. Covers runner contract, canonical ci.yml, SHA-driven prod deploy on iegbcoppoc02, post-deploy CalVer tagging, bootstrap alignment, repo migration, and mandatory first-run execution plus validation.
---

# Golden Workflow Skill

Use this skill to migrate, repair, or bootstrap VMIE app workflows so they conform to the local Gitea + shared-runner deployment model.

## When To Use

Use this skill when requests include any of:

- "move this app to the golden workflow"
- "fix the VMIE workflow"
- "standardize CI/CD across repos"
- "make this new repo inherit the right flow"
- "our deploy-prod workflow keeps breaking"
- "fix brittle tag-first deploy logic"
- "align app-sight / appointment-assist / nps-lens / rev-sight"
- "update platform-infra and project-template"

## What This Skill Covers

This skill is for the deploy-critical path only:

- `.gitea/workflows/ci.yml`
- `.gitea/workflows/deploy-prod.yml` as a legacy migration target
- `.gitea/scripts/deploy.ps1`
- post-deploy Git CalVer tag push
- bootstrap changes in `platform-infra` and `project-template`
- first-run execution and validation after migration

## Explicitly Out Of Scope Unless The User Asks

- `.gitea/workflows/debug-pipeline.yml`
- `.gitea/workflows/implement-fix.yml`
- `.gitea/workflows/pr-scope-guard.yml`
- Gitea issue or PR labels
- shared runner registration, service creation, or relabeling

## Required Companion Skills

Load these first when they exist:

- `.github/skills/devops/ci-cd-pipeline/SKILL.md`
- `.github/skills/vmie/windows-deployment/SKILL.md`
- `.github/skills/workflow/verification-loop/SKILL.md`

Optional:

- `.github/skills/devops/git-commit/SKILL.md` when commits are part of the task

## Golden VMIE Workflow Defaults

Treat these as the default contract unless the repo has an explicit, justified exception:

1. One canonical `.gitea/workflows/ci.yml` owns PR checks, push checks, deploy, release metadata, and notify.
2. Prod deploy runs on the shared `prod` runner on `iegbcoppoc02`.
3. Deploy identity is the pushed commit SHA, not a pre-deploy version tag.
4. Prod pulls and builds on-box.
5. CalVer is the runtime release id and Git release tag; the tag is pushed only after deploy succeeds.
6. `debug` and `implement` remain separate support workflows.
7. The shared runner contract is not changed from inside app repos.
8. Runtime version display remains CalVer. The deploy identity is the pushed SHA, but `src/_version.json`, `frontend/public/version.json`, `dist/version.json`, and `APP_VERSION` must use the CalVer returned by `compute-version.ps1`, never `sha-<shortsha>`.

## Phase 1: Inventory The Repo

Read these first:

- `.gitea/workflows/ci.yml` if present
- `.gitea/workflows/deploy-prod.yml` if present
- `.gitea/workflows/debug-pipeline.yml` if present
- `.gitea/workflows/implement-fix.yml` if present
- `.gitea/scripts/deploy.ps1`
- `.gitea/scripts/compute-version.ps1` if present
- local runbooks or bootstrap docs if they exist

Then classify the repo:

| Pattern | Meaning | Migration mode |
|---------|---------|----------------|
| `golden-ready` | Already close to SHA-driven single-workflow deploy | Normalize only |
| `tag-first-split` | Uses tag/version job before deploy or split `deploy-prod.yml` | Full migration |
| `manual-deploy` | Deploy is manual or incomplete | Controlled migration |

## Phase 2: Check For Golden Workflow Violations

Look for these problems:

- deploy depends on a pre-deploy CalVer tag push
- deploy depends on `GITHUB_OUTPUT` version plumbing
- `git pull` is the only prod sync operation
- deploy script mutates release metadata in the critical path
- deploy script writes `sha-<shortsha>` into runtime version files or `APP_VERSION`
- workflow self-heals its own source file at runtime
- support workflows are coupled to the main deploy flow
- prod jobs lack a deployment concurrency lock
- prod deploy does not verify `HEAD == expected SHA`
- PowerShell Git commands pipe stderr/stdout into control-flow variables or `Write-Host` without preserving a numeric exit code

If you find any of these, treat the repo as non-golden even if it appears to work sometimes.

## Phase 3: Apply The Golden Workflow

### Canonical workflow shape

Use this job graph:

1. `lint_and_test` on `dev`
2. `frontend_checks` on `dev` when a frontend exists
3. `deploy_prod` on `prod` for `push` to `main`
4. `release_metadata` on `dev` only after successful deploy
5. `notify` on `dev`

### Canonical deploy behavior

The deploy script must:

1. log the expected SHA
2. stop services
3. fetch origin
4. checkout target branch
5. reset hard to `origin/<branch>`
6. clean untracked files
7. verify `HEAD == expected SHA`
8. install dependencies
9. run migrations if enabled
10. build frontend if enabled
11. restart services in a `finally` block
12. health-check
13. verify `HEAD == expected SHA` again

Runtime version stamping is allowed in the deploy path only to make the running UI/API show CalVer. Use `compute-version.ps1 -Env prod -RepoRoot <repo>` immediately after SHA convergence, validate `^vYYYY.MM.DD.N$`, export that value as `APP_VERSION` before the frontend build, and roll back any unpushed local tag if health-check fails. Do not stamp `sha-<shortsha>` as the runtime version.

PowerShell Git handling is part of the deploy contract:

- use a helper that logs Git stdout/stderr but returns only `[int]$LASTEXITCODE`
- never let harmless Git output such as `Already on 'main'` become the value of an exit-code variable
- avoid `git ... 2>&1 | Write-Host` under `$ErrorActionPreference = 'Stop'` unless the helper isolates streams from control flow

### Canonical release behavior

The release job must:

1. run only after deploy success
2. resolve or create the Git CalVer tag for the deployed SHA
3. push that tag
4. write a useful run summary
5. never block production health recovery

## Phase 4: Preserve Support Workflows

Do not rewrite `debug-pipeline.yml`, `implement-fix.yml`, or `pr-scope-guard.yml` just because the main CI/CD flow changed.

Only touch them if one of these is true:

- they call the old deploy-critical jobs directly
- they reference deleted scripts or workflow outputs
- the first-run validation proves they broke after the migration

## Phase 5: Repo-Specific Migration Defaults

Use these defaults unless the user directs otherwise:

| Repo | Default action |
|------|----------------|
| `app-sight` | Migrate from split tag-first deploy flow to canonical `ci.yml` |
| `appointment-assist` | Remove tag-first release dependency and self-heal deploy behavior |
| `nps-lens` | Keep as reference, normalize to the same release contract |
| `rev-sight` | Migrate last unless there is an urgent production reason |
| `platform-infra` | Make it the source of truth for the golden workflow |
| `project-template` | Ship the canonical workflow and every script it calls by default |

For any new repo in the same local infra:

1. scaffold the canonical `ci.yml`
2. keep support workflows separate
3. include the hardened `deploy.ps1`
4. include NSSM helper scripts when `deploy_prod` invokes NSSM
5. add release metadata only after deploy succeeds

## Phase 6: Execute The First Real Run

Do not stop after editing files. The skill must carry the migration through the first real run.

### First-run execution steps

1. Run local checks that mirror the repo gates.
2. Commit and push if the user asked for a live migration.
3. Watch the primary workflow end-to-end.
4. Record the commit SHA used for the run.
5. Record whether the repo used PR flow or push-to-main deploy flow.

### First-run validation checklist

The migration is not complete until all applicable checks pass:

- workflow picked up on the correct runner labels
- backend checks ran for real code reasons only
- frontend checks ran for real code reasons only
- deploy triggered only after gates passed
- prod `HEAD` matched the pushed SHA
- health endpoint returned success
- Git CalVer tag was pushed only after deploy success
- `notify` reported the real final state
- shared prod runner service remained untouched
- support workflows still existed and were not unintentionally coupled into the deploy path

### If the first run fails

Classify before patching:

| Failure | Response |
|---------|----------|
| Lint / test / build failure | Fix source code first |
| Workflow syntax or runtime issue | Fix workflow or script directly |
| Runner queue / label issue | Verify runner health, do not relabel ad hoc |
| Prod environment drift | Fix environment or repo config, not the runner contract |
| Post-deploy release failure | Fix release job separately; do not revert the deploy model |

## Phase 7: Report Back Clearly

Always report:

- repo classification
- files changed
- whether support workflows were touched
- first-run result
- deployed SHA
- release tag result
- remaining follow-ups

Use this template:

```markdown
## Golden Workflow Migration Report
- Repo:
- Classification:
- Files changed:
- Support workflows touched:
- First run:
- Commit SHA:
- Deploy result:
- Release tag:
- Remaining follow-ups:
```

## Anti-Patterns

- Treating a working `debug` workflow as evidence that the deploy-critical path is healthy
- Keeping both a canonical `ci.yml` and a live `deploy-prod.yml` without a clear reason
- Pushing CalVer tags before deploy succeeds
- Using `git pull` alone on prod
- Showing `sha-<shortsha>` in the UI footer instead of the CalVer runtime version
- Changing shared runner labels from inside an app repo
- Declaring a migration done before the first real run is validated
- Treating PowerShell/Git stderr or status text as a deploy failure instead of relying on numeric exit codes

## Reference

Read `references/migration-checklist.md` in this skill for the golden contract and repo migration matrix before making changes.
