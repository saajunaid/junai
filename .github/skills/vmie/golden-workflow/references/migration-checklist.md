# Golden Workflow Reference

Use this checklist when migrating an existing app or scaffolding a new repo on the VMIE local infra model.

## Runner Contract

- Shared `dev` runner for CI jobs
- Shared `prod` runner on `iegbcoppoc02`
- No app repo changes runner registration or labels
- Prod deploys serialize with a repo-specific concurrency lock

## Canonical Job Graph

1. `lint_and_test`
2. `frontend_checks`
3. `deploy_prod`
4. `release_metadata`
5. `notify`

Support workflows stay separate:

- `debug-pipeline.yml`
- `implement-fix.yml`
- `pr-scope-guard.yml`

## Deploy Contract

- Deploy the pushed SHA, not a pre-deploy version string
- Stop services, fetch, checkout, reset hard, clean, verify SHA
- Install deps, migrate, build, restart in `finally`, health-check
- Re-verify SHA after deploy

## Release Contract

- Git CalVer tag only
- Post-deploy only
- Runs on `dev`
- Never blocks service recovery

## Existing Repo Defaults

| Repo | Action |
|------|--------|
| `app-sight` | Full migration to canonical `ci.yml` |
| `appointment-assist` | Full migration to canonical `ci.yml` and deploy script cleanup |
| `nps-lens` | Normalize to the same release contract |
| `rev-sight` | Migrate last or keep manual until ready |

## New Repo Defaults

- Scaffold canonical `.gitea/workflows/ci.yml`
- Do not scaffold live `deploy-prod.yml` by default
- Include hardened `deploy.ps1`
- Keep support workflows independent

## First-Run Validation

Do not close the task until:

- the primary workflow runs
- prod converges to the pushed SHA
- health succeeds
- post-deploy tag succeeds
- support workflows remain independent

