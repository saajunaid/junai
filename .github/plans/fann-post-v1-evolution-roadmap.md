# Fann Post-v1 Evolution Roadmap — Shipping, Growth, Monetization, and VC Readiness

> **Updated:** 2026-04-06
> **Status:** READY FOR EXECUTION
> **Predecessor:** `fann-junai-evolution-roadmap.md` (Phases 0–9, all complete)
> **Execution model:** Sequential with parallel sub-tasks — ship preview first, learn from users, tighten commercial story, expand reach, earn the right to raise.

---

## Pre-Flight Scan

Phase 10 — Preview Release Preparation:            ~8 tasks, depends on completed v1 build (Phases 0–9)
Phase 11 — Closed Alpha + Feedback System:          ~7 tasks, depends on Phase 10
Phase 12 — Product Intelligence Layer:              ~8 tasks, depends on Phase 11
Phase 13 — Distribution Expansion:                  ~6 tasks, depends on Phases 10–12
Phase 14 — Monetization Validation:                 ~7 tasks, depends on Phases 11–13
Phase 15 — Visibility Engine / Build in Public:     ~8 tasks, depends on Phases 10–14
Phase 16 — VC Readiness / Fundraise Story:          ~6 tasks, depends on Phases 11–15

---

## 0. Context & Decisions

### What this roadmap builds

The v1 build roadmap (Phases 0–9) created the product: `junai-vscode` as the lab, `fann-core` as the shared runtime bridge, and `fann-vscode` as the public-facing product shell with 4 commands (`Ask`, `Deep Plan`, `Run in Background`, `Resume from Memory`), a calm onboarding flow, lightweight premium-boundary scaffolding, and a clear value proposition.

This roadmap takes that product from **internal dogfood** to **real users, real feedback, real revenue signal, and real visibility**. It is not another internal architecture cycle. It is shipment, learning, and traction.

### Locked decisions from v1

| Concern | Decision | Status |
|---------|----------|--------|
| Public product name | `Fann` | Locked |
| Three promises | think deeply, work asynchronously, resume intelligently | Locked |
| Command surface | 4 commands only | Locked for preview |
| One-line value proposition | "Turn rough coding intent into a clear next step now — and pick it back up later without losing context." | Locked |
| Editions scaffold | `free-alpha` / `pro-preview` via `entitlements.ts` | In place, no billing backend yet |
| Lab vs product boundary | `junai` = lab, `Fann` = product, `fann-core` = bridge | Locked |

### New decisions for this roadmap

| Concern | Decision | Rationale |
|---------|----------|-----------|
| Primary distribution | VS Code Marketplace | Native channel for a VS Code extension; covers Windows, macOS, Linux automatically |
| Secondary distribution | Open VSX Registry | Low-cost reach expansion to VSCodium and compatible editors |
| Discovery + trust | GitHub Releases + docs site | Changelogs, install docs, trust signals, feedback path |
| Docker distribution | Not now | Editor-first product; Docker adds packaging burden without PMF evidence |
| npm as consumer install | Selective — `fann-core` only later | npm is good for libraries, not the primary end-user install path |
| Electron desktop app | Not now | Premature packaging/support burden before PMF |
| Separate macOS/Linux/Win apps | Not now | Already covered by VS Code Marketplace cross-platform |
| Telemetry | Opt-in, lightweight, local-first data | Respect privacy; only collect what directly informs product decisions |
| Monetization timing | After closed alpha feedback proves value | Do not paywall before proving repeatable usefulness |
| Content cadence | Weekly proof, not one-shot hype | Compounding visibility beats single launch spikes |

### What stays in junai vs Fann during this roadmap

| Scope | Contents |
|-------|----------|
| `junai`-only | full 25-agent pipeline, heavy orchestration, artefact contracts, MCP tools, advanced experimental features |
| Shared (`fann-core`) | coordinator runtime, background task runner, memory consolidation, prompt/skill loader, permissions engine, event bus |
| `Fann`-only | simplified 4-command UX, onboarding, branded commands, public docs, monetization hooks, telemetry, feedback loops |

### Repo responsibilities during this roadmap

| Repo | Path | Role |
|------|------|------|
| `agent-sandbox` | `E:\Projects\agent-sandbox` | Canonical source — roadmaps, agents, prompts, skills, instructions, dogfooding logs |
| `junai-vscode` | `E:\Projects\junai-vscode` | Lab extension — stays internal, experimental features |
| `fann-core` | `E:\Projects\fann-core` | Shared runtime — orchestration, memory, planning, permissions, events |
| `fann-vscode` | `E:\Projects\fann-vscode` | Public product — 4 commands, onboarding, entitlements, distribution-ready |
| `junai` | `E:\Projects\junai` | Public pool mirror — canonical AI resources via GitHub |

### Current `fann-vscode` technical state (as of Phase 9 completion)

```text
fann-vscode/
├── src/
│   ├── extension.ts                    ← entry point, 4 command registrations, event bus wiring
│   ├── branding/
│   │   └── copy.ts                     ← product labels, tagline, value proposition
│   ├── commands/
│   │   ├── ask.ts                      ← Fann: Ask with follow-up quick-pick
│   │   ├── deepPlan.ts                 ← Fann: Deep Plan with approval CTA
│   │   ├── resumeFromMemory.ts         ← Fann: Resume from Memory with ranked context
│   │   └── runInBackground.ts          ← Fann: Run in Background with lifecycle states
│   ├── onboarding/
│   │   └── welcome.ts                  ← first-run welcome flow
│   ├── panels/
│   │   └── activityView.ts             ← output channel + status bar presence
│   └── services/
│       ├── config.ts                   ← workspace root + context utilities
│       ├── coreAdapter.ts              ← fann-core integration layer
│       ├── entitlements.ts             ← free-alpha / pro-preview capability gating
│       └── sessionState.ts             ← session persistence (asks, plans, background runs)
├── docs/
│   └── editions.md                     ← monetization boundary documentation
├── package.json                        ← 4 contributes.commands, fann-core file: dep
├── tsconfig.json
└── README.md                           ← 3-promise narrative, quick start, editions
```

### Current `fann-core` technical state

```text
fann-core/
├── src/
│   ├── index.ts                        ← barrel exports
│   ├── types/index.ts                  ← JsonPrimitive, JsonValue, JsonObject
│   ├── orchestration/
│   │   ├── coordinator.ts              ← parallel worker execution, finding synthesis
│   │   ├── taskGraph.ts                ← WorkerType, TaskSpec, TaskGraph
│   │   └── workerRunner.ts             ← explore/verify/review worker dispatch
│   ├── memory/
│   │   ├── types.ts                    ← MemorySignalKind, MemoryFactRecord, consolidation contracts
│   │   └── consolidator.ts             ← DreamMemoryEngine (543 lines) with debounced consolidation
│   ├── planning/
│   │   ├── planContracts.ts            ← DeepPlanRequest/Result/Phase/Confidence
│   │   └── deepPlan.ts                 ← plan generation, markdown rendering, persistence
│   ├── permissions/
│   │   ├── riskTiers.ts                ← RiskTier, ActionName, 18 classified actions
│   │   ├── protectedPaths.ts           ← glob-based path protection
│   │   └── approvalPolicy.ts           ← mode-based permission checking
│   ├── background/
│   │   ├── events.ts                   ← JunaiEventBus singleton, typed event system
│   │   ├── notifications.ts            ← proactive policy engine (dedupe + rate-limit)
│   │   └── taskRunner.ts               ← generic background task execution
│   └── prompts/
│       └── featureFlags.ts             ← ExperimentalFeatureDefinition manifest
├── package.json                        ← v0.1.0, no external deps
└── README.md
```

### Shared contracts (defined and stable)

```text
CoreEvent
- type: task-completed | task-blocked | approval-needed | background-result | memory-consolidated
- timestamp, source, severity (info | success | warning | error), title, detail?

CoordinatorTaskSpec
- id, role, goal, dependencies, status, evidence

CoordinatorSynthesisResult
- summary, workerFindings[], nextAction, confidence

MemoryConsolidationResult
- factsAdded[], factsUpdated[], factsPruned[], conflicts[]

DeepPlanRequest / DeepPlanResult
- taskSummary, scope[], constraints[], contextReferences?
- summary, assumptions[], risks[], phases[], nextAction, confidence

RiskTier / ProtectedAction
- low | medium | high
- 18 classified actions, 8 protected (high-risk)

FannPlan / FannPlanCapabilities
- free-alpha | pro-preview
- maxConcurrentBackgroundBriefs, resumeMemoryAnchors, allowCopyFullPlan

BackgroundRunRecord
- id, title, notePath?, status (queued | running | success | failure | interrupted), summary

FannSessionState
- lastAsk?, lastDeepPlanPath?, backgroundRuns[]
```

---

## 1. Distribution strategy

### Publish now (Phase 10)

| Channel | Action | Priority |
|---------|--------|----------|
| **VS Code Marketplace** | `npx vsce publish` under `junai-labs` publisher | Primary |
| **Open VSX** | `npx ovsx publish` for VSCodium/compatible ecosystems | Secondary, if packaging is smooth |
| **GitHub Releases** | Tag `v0.1.0-preview`, attach `.vsix`, write release notes | Essential for trust |
| **README + docs** | Public-facing quick-start, value statement, editions doc | Essential |

### Explicitly defer

| Channel | Why deferred |
|---------|--------------|
| Docker image | Editor-first product; Docker adds packaging burden without demand signal |
| npm consumer install | Good for `fann-core` library later; not the main user install |
| Electron desktop app | Premature before PMF; large support surface for minimal incremental reach |
| Separate macOS/Linux/Win apps | Already covered by VS Code Marketplace cross-platform distribution |

### Decision gate for deferred channels

Revisit Docker / Electron / standalone apps only when:
1. Real user feedback explicitly requests non-VS-Code distribution
2. Retention data shows meaningful demand beyond the VS Code ecosystem
3. The packaging cost is justified by projected reach expansion

---

## 2. Feature-by-feature build order

## Phase 10 — Preview Release Preparation

**Objective:** Make `fann-vscode` installable, understandable, and tryable by real external users with zero hand-holding.

### Pre-requisite: fann-core packaging fix

`fann-vscode` currently depends on `fann-core` via `file:../fann-core` local linking. This **must** be resolved before `npx vsce package` can produce a `.vsix` that works on any machine. Options (pick one):
- **Bundle into extension:** copy the compiled `fann-core` output into the extension's `dist/` and reference it as a local module
- **Publish to npm first:** `npm publish` fann-core as `@junai-labs/fann-core` (or scoped name), then reference as a normal dependency
- **Inline the dependency:** vendor the compiled output directly into the extension source tree

The chosen approach must be validated by: install the `.vsix` on a clean machine with no local `fann-core` checkout → all 4 commands work.

### Build in this order

1. **Marketplace listing polish**
   - Write a compelling marketplace description (short description already exists in `package.json`)
   - Create a detailed `description` field with markdown formatting for the VS Code Marketplace listing page
   - Add `galleryBanner`, `icon`, `badges` to `package.json`
   - Choose brand colors that reinforce calm, professional energy

2. **Visual assets**
   - Create `icon.png` (128×128 minimum, 256×256 recommended)
   - Create 3–5 marketplace screenshots showing each command in action:
     - `Fann: Ask` → input box + follow-up quick-pick
     - `Fann: Deep Plan` → plan output in activity panel
     - `Fann: Run in Background` → brief notification
     - `Fann: Resume from Memory` → ranked context output
   - Create one animated GIF or short video (~15 seconds) showing a complete ask → deep plan → resume loop

3. **README hardening**
   - Current README (`fann-vscode/README.md`) is solid for MVP
   - Add an architecture section explaining how `fann-core` powers the product
   - Add a "What Fann is NOT" section to set expectations for preview
   - Add a "Roadmap / Coming next" section with 3–5 upcoming improvements
   - Add badges: VS Code Marketplace version, installs, rating

4. **Changelog and release notes**
   - Create or update `CHANGELOG.md` in `fann-vscode` with release notes for `v0.1.0-preview`
   - Use conventional changelog format:
     - **Added:** 4 commands, onboarding, session state, background lifecycle, editions scaffold
     - **Built on:** `fann-core` shared runtime (orchestration, memory, planning, permissions)
     - **Known limits:** no billing backend, local-only editions, lightweight telemetry deferred

5. **Feedback intake path**
   - Add a `bugs` and `repository` field in `package.json` pointing to the public `fann-vscode` GitHub repo
   - Create issue templates:
     - Bug report (with environment details auto-fill)
     - Feature request (with "which promise does this serve?" prompt)
     - Feedback / impressions (open-ended)
   - Add a `Fann: Send Feedback` command (opens the GitHub issues page or a lightweight form URL)
   - Alternatively, set up a simple landing page with email capture + feedback form

6. **Pre-publish build validation**
   - Run `npm run compile` and verify clean output
   - Run `npx vsce package --no-dependencies` and verify `.vsix` is produced
   - Install the `.vsix` in a clean VS Code instance and run all 4 commands
   - Verify onboarding flow fires correctly on first activation
   - Verify `fann-core` dependency resolves correctly when packaged

7. **Publish to VS Code Marketplace**
   - Ensure `junai-labs` publisher account is set up and PAT is valid
   - Run `npx vsce publish --no-dependencies` (or use CI when ready)
   - Verify the listing page renders correctly (description, screenshots, badges, links)

8. **GitHub Release**
   - Tag `v0.1.0-preview` in `fann-vscode` repo
   - Attach the `.vsix` file to the GitHub release
   - Write release notes linking to marketplace, README, and feedback path

### User-visible behavior
A developer searching "Fann" or "coding companion" on the VS Code Marketplace can install `Fann` in one click, read a clear value proposition, run through onboarding, and try all 4 commands within 5 minutes.

### Exit gate
- `fann-vscode` is publicly listed on the VS Code Marketplace
- a new external user can install and try `Fann` without any hand-held support or private instructions
- listing and docs feel coherent enough for a credible preview release
- `.vsix` can also be installed manually from GitHub Releases for offline / corporate environments

### Dogfooding success metric
- first 25–100 preview installs happen without confusion-heavy support overhead
- at least 3 of the first 10 external users complete the full ask → plan → resume loop without asking how

### Agent-executable prompt

> **Phase 10 Prompt (for @Implement or standalone coding agent):**
>
> Repo: `E:\Projects\fann-vscode`
> Attach: `package.json`, `README.md`, `docs/editions.md`, `src/extension.ts`, `src/branding/copy.ts`, `src/onboarding/welcome.ts`
>
> Tasks:
> 1. In `package.json`: add `galleryBanner` (theme: dark, color: #1a1a2e), `icon` pointing to `icon.png`, `bugs.url` and `repository.url` pointing to the public GitHub repo, and `badges` for marketplace version/installs.
> 2. Create `CHANGELOG.md` at the repo root with v0.1.0-preview release notes listing all 4 commands, fann-core shared runtime, editions scaffold, and known limits.
> 3. In `README.md`: add a "What Fann is NOT" section after the editions section. Add a "Coming Next" section listing: feedback system, opt-in usage insights, expanded distribution, monetization validation.
> 4. Create `.github/ISSUE_TEMPLATE/bug_report.md` and `.github/ISSUE_TEMPLATE/feature_request.md` with standard templates.
> 5. Add a `fann.sendFeedback` command in `package.json` contributes.commands. Create `src/commands/sendFeedback.ts` that opens the GitHub issues page via `vscode.env.openExternal`. Register the command in `extension.ts`.
> 6. Validate: `npm run compile` succeeds, `npx vsce package --no-dependencies` produces a `.vsix`.
>
> Do not modify `fann-core`. Do not modify product messaging in `copy.ts`. Do not add telemetry in this phase.

---

## Phase 11 — Closed Alpha + Feedback System

**Objective:** Build a tight learning loop with real users so the next product iterations are driven by evidence, not internal opinion.

### Build in this order

1. **Design partner recruitment**
   - Identify 10–25 initial alpha users from:
     - personal developer network
     - X / LinkedIn followers who engage with dev-tools content
     - communities where async developer workflows are valued (e.g., indie hackers, solo devs, remote teams)
   - Send a short invite:
     - what Fann does (one sentence)
     - what you want from them (install → use daily for 1 week → 15-minute interview)
     - what they get (direct influence on the product direction + early access to premium features)

2. **Feedback intake infrastructure**
   - Set up a structured feedback form (Tally, Typeform, Google Form, or GitHub Discussions)
   - Fields:
     - Which command(s) did you use?
     - What were you working on?
     - Did Fann help you resume faster, plan better, or work async more easily?
     - What was confusing or missing?
     - Would you use this daily? Why or why not?
   - Add a `Fann: Send Feedback` command that opens this form (or link it from the welcome panel)

3. **Lightweight in-product feedback hooks**
   - After the 5th `Fann: Resume from Memory` use, show a non-blocking info message:
     "You've resumed 5 times. How is it working? [Send Feedback] [Not Now]"
   - After the first `Deep Plan` is completed:
     "Your first plan is ready. Was this useful? [Send Feedback] [Not Now]"
   - **Day-2 return moment:** After the user's first `Ask` or `Deep Plan`, show a one-time non-blocking message the next day (or next activation):
     "Welcome back. Your last session context is ready. [Resume from Memory] [Start Fresh]"
     This engineers the "aha" moment — the value of Fann compounds on day 2, not day 1. The goal is to make the user *experience* resume, not just know it exists.
   - Limit to one feedback prompt per session maximum; do not chain or spam

3A. **Codebase-aware Deep Plan** *(implemented pre-alpha — fixes the "plans feel generic" gap)*
   - **Problem:** `Deep Plan` currently produces generic phased plans from user text alone. Internal feedback confirms plans feel templated and lack project-specific context.
   - **Fix:** Wire a lightweight workspace scan into the Deep Plan pipeline so plans reflect the user's actual codebase.
   - **Architecture:**
     - fann-core: new `scanWorkspace()` function runs explore/verify workers against auto-detected project signals (`package.json`, `pyproject.toml`, `src/` structure, test files, CI config, `dream-memory.json`)
     - fann-core: `createDeepPlanResult()` uses scan output in `contextReferences` to produce context-specific phases (real file paths, real tech stack, test-aware steps)
     - Extension layer (junai-vscode / fann-vscode): optionally enriches the plan via `vscode.lm` API if any language model is available — no API key configuration, no separate auth; uses whatever model the user has (Copilot, local, Azure, etc.). Falls back to improved algorithmic path if no model available.
   - **Contract:** `DeepPlanRequest/DeepPlanResult` unchanged — downstream consumers (rendering, persistence, dreamMemory) work without modification.
   - **fann-core stays dependency-free** — no LLM SDK. The LLM call is the extension's responsibility.
   - **Validation:** generate a plan for an existing project with tests and CI → verify phase tasks reference real paths and real tech stack signals.

4. **Core product metrics tracking**
   - **North star metric:** D2 retention on `Resume from Memory` — does the user come back the day after their first session and resume? This single metric proves the product thesis. If D2 resume retention is strong, Fann has product-market fit signal. If users only try `Ask` once and leave, the positioning isn't landing. Track and report this metric explicitly.
   - Track locally (in session state or a lightweight `.fann/metrics.json`):
     - activation: did the user run at least one command after install?
     - repeated use: did the user run a command on at least 3 different days?
     - most-used command: which of the 4 commands is used most?
     - return behavior: did the user use `Resume from Memory` at least twice?
     - **D2 resume rate:** did the user use `Resume from Memory` within 48 hours of their first command?
   - Do NOT send telemetry externally without explicit opt-in
   - Display a summary in `Fann: Status` or the activity panel for the user's own awareness

5. **Weekly review ritual**
   - Schedule a recurring review (weekly, 30 minutes):
     - Read all feedback submissions
     - Categorize by the 3 promises (think deeply / work async / resume intelligently)
     - Identify top-3 pain points and top-3 praised behaviors
     - Update a `dogfooding/alpha-feedback-log.md` in `agent-sandbox` with each week's synthesis
   - Create a public-facing "what we heard / what we changed" log (short Markdown or blog post)

6. **User interview script**
   - Prepare a 15-minute semi-structured interview:
     1. What do you do? What does your typical coding day look like?
     2. Walk me through how you used Fann last week.
     3. Which command was most valuable? Why?
     4. What was confusing or felt wrong?
     5. If Fann disappeared tomorrow, what would you miss most?
     6. Would you pay for this? What would you pay for?
   - Run at least 5–10 interviews during the alpha period

7. **Triage and prioritization**
   - Tag feedback issues as:
     - `promise:think-deeply`
     - `promise:work-async`
     - `promise:resume-intelligently`
     - `ux:confusion`
     - `ux:delight`
     - `request:new-feature`
     - `bug`
   - Use this tagging to decide the next iteration priorities

### User-visible behavior
Alpha users feel heard and influential. They see their feedback turn into real product changes. The product improves measurably each week.

### Exit gate
- feedback is coming from real users, not only internal opinion
- at least 5–10 users use the product more than once and can clearly articulate what is valuable or missing
- a structured feedback loop is running weekly

### Dogfooding success metric
- at least 5 user interviews completed with actionable insights
- top-3 pain points are identified and have a clear fix plan
- at least one product change in the next iteration is directly traceable to user feedback

### Agent-executable prompt

> **Phase 11 Prompt (for @Implement or standalone coding agent):**
>
> Repo: `E:\Projects\fann-vscode`
> Attach: `src/extension.ts`, `src/services/sessionState.ts`, `src/commands/resumeFromMemory.ts`, `src/commands/deepPlan.ts`, `src/commands/sendFeedback.ts` (from Phase 10), `package.json`
>
> Tasks:
> 1. Create `src/services/metrics.ts`: a lightweight local metrics tracker that records command usage counts, session dates, and resume-from-memory usage count in `.fann/metrics.json`. Export `recordCommandUsage(commandId: string)` and `getMetricsSummary()`.
> 2. Wire `recordCommandUsage()` calls into each command handler in `src/commands/ask.ts`, `deepPlan.ts`, `runInBackground.ts`, and `resumeFromMemory.ts`.
> 3. In `resumeFromMemory.ts`: after the 5th resume (check metrics), show a one-time feedback prompt: "You've resumed 5 times. How is it working? [Send Feedback] [Not Now]". Track whether the prompt was already shown in metrics state.
> 4. In `deepPlan.ts`: after the first plan is created (check metrics), show a one-time feedback prompt: "Your first plan is ready. Was this useful? [Send Feedback] [Not Now]". Same one-time guard.
> 5. Add a `Fann: Usage Summary` command that reads `.fann/metrics.json` and shows a formatted summary in the output channel (activation date, total commands, most-used command, resume count, days-used count).
> 6. Validate: `npm run compile` succeeds. Do not add external telemetry. All data stays in `.fann/metrics.json` on the user's machine.
>
> Do not modify `fann-core`. Keep feedback prompts non-blocking (use `showInformationMessage`, not modal dialogs).

---

## Phase 12 — Product Intelligence Layer

**Objective:** Add opt-in, privacy-respecting instrumentation so product decisions are grounded in real usage data, not guesses.

### Build in this order

1. **Opt-in telemetry framework**
   - Create `src/services/telemetry.ts` in `fann-vscode`
   - Respect the VS Code global telemetry setting (`telemetry.telemetryLevel`)
   - Add a Fann-specific setting: `fann.telemetry.enabled` (default: `false` — opt-in only)
   - Show a single non-blocking prompt on first activation after install:
     "Fann can share anonymous usage stats to improve the product. No code or prompts are ever sent. [Enable] [No Thanks]"

2. **Event schema design**
   - Define a minimal telemetry event set:

     ```text
     TelemetryEvent
     - event: command-used | session-resumed | plan-created | background-brief-completed | feedback-sent
     - timestamp: ISO 8601
     - commandId: fann.ask | fann.deepPlan | fann.runInBackground | fann.resumeFromMemory
     - sessionId: anonymized session hash (no PII)
     - edition: free-alpha | pro-preview
     - outcome: completed | cancelled | error
     ```

   - Explicitly exclude:
     - any user input text (asks, task summaries, plan content)
     - file paths or workspace content
     - any personal identifiers

3. **Local-first data collection**
   - Write events to `.fann/telemetry-events.json` (local, not sent anywhere by default)
   - Aggregate daily summaries: command counts, session resumption rate, error counts
   - Make the local data viewable via the existing `Fann: Usage Summary` command or the activity panel

4. **Remote telemetry backend (lightweight)**
   - When ready, add a minimal ingestion endpoint:
     - Azure Functions / Cloudflare Workers / Vercel Edge Function
     - Accept POST with the telemetry event batch
     - Store in a simple time-series store (e.g., Azure Table Storage, Supabase, or a Postgres table)
   - The extension sends batched events (daily, not real-time) only when opt-in is enabled
   - Include a `telemetry.endpointUrl` setting for transparency

5. **Product metrics dashboard**
   - Build a minimal internal dashboard (Streamlit, Retool, or a simple HTML page):
     - Daily / weekly active users (DAU, WAU)
     - Command usage breakdown
     - Session resumption rate (% of sessions starting with `Resume from Memory`)
     - Retention curves: D1, D7, D30
     - Error rate by command
     - Edition distribution (free-alpha vs pro-preview)

6. **Conversion funnel**
   - Track the onboarding funnel:
     1. Extension installed → activated → first command run → second command run → day-2 return → day-7 return
   - Track the premium boundary funnel:
     1. Hit a premium boundary → saw upgrade hint → changed plan → continued using

7. **A/B testing foundation**
   - Add a simple A/B assignment mechanism:
     - Generate a stable hash from the anonymized session ID
     - Use the hash to assign to experiment groups
     - Support at most 2 concurrent experiments to avoid combinatorial complexity
   - First experiment candidate: "does showing a suggested next action in the status bar increase `Resume from Memory` usage?"

8. **Privacy documentation**
   - Write a clear privacy statement for the marketplace listing and README:
     - What is collected (anonymous usage events only)
     - What is NOT collected (no code, no prompts, no PII)
     - How to opt out (setting toggle)
     - Where data goes (endpoint URL, retention policy)
   - Include the privacy commitment in the onboarding flow

### User-visible behavior
Users who opt in are told exactly what is collected and can see their own usage summary. Users who do not opt in experience zero behavioral difference.

### Exit gate
- telemetry is opt-in with a clear privacy commitment
- at least one product decision is informed by real telemetry data
- local usage data is viewable by the user

### Dogfooding success metric
- DAU/WAU/retention metrics are visible in a dashboard within 2 weeks of closing the alpha period
- at least one product iteration is explicitly justified by a telemetry insight (e.g., "80% of users never try Deep Plan — we should improve discoverability")

### Agent-executable prompt

> **Phase 12 Prompt (for @Implement or standalone coding agent):**
>
> Repo: `E:\Projects\fann-vscode`
> Attach: `src/services/metrics.ts` (from Phase 11), `src/services/entitlements.ts`, `src/extension.ts`, `package.json`
>
> Tasks:
> 1. Create `src/services/telemetry.ts`:
>    - Define `TelemetryEvent` interface: `{ event, timestamp, commandId, sessionId, edition, outcome }`.
>    - Create `TelemetryService` class with: `isEnabled()` (checks `fann.telemetry.enabled` AND `telemetry.telemetryLevel`), `recordEvent(event)` (writes to `.fann/telemetry-events.json`), `getLocalSummary()` (aggregates events by day/command).
>    - Generate `sessionId` as a SHA-256 hash of `vscode.env.machineId + install-date`, never raw machine ID.
>    - Include ZERO user-input text in any event. Only command IDs and outcomes.
> 2. In `package.json`: add `fann.telemetry.enabled` configuration property (boolean, default false, with markdown description explaining what is collected and what is not).
> 3. In `extension.ts`: after activation, if telemetry has never been prompted (check `.fann/telemetry-prompted` flag file), show a one-time prompt: "Fann can share anonymous usage stats to improve the product. No code or prompts are ever sent. [Enable] [No Thanks]". Write the flag file regardless of choice.
> 4. Wire `telemetryService.recordEvent()` calls into each command handler alongside the existing `recordCommandUsage()` calls. Only record if `isEnabled()` returns true.
> 5. Update the `Fann: Usage Summary` command to include telemetry status and local event summary if telemetry is enabled.
> 6. Create `PRIVACY.md` at repo root documenting exactly what is collected, what is excluded, and how to opt out.
> 7. Validate: `npm run compile` succeeds. No external HTTP calls yet — all telemetry stays local in this phase.
>
> Do not modify `fann-core`. Do not add a remote endpoint yet.

---

## Phase 13 — Distribution Expansion

**Objective:** Expand reach rationally without exploding operational complexity or splitting focus.

### Build in this order

1. **Open VSX publication**
   - Install `ovsx` CLI: `npm install -g ovsx`
   - Publish: `npx ovsx publish <fann-vscode>.vsix -p <token>`
   - Verify listing renders correctly on open-vsx.org
   - Add Open VSX badge to README

2. **GitHub Pages docs site (optional, if warranted by feedback)**
   - Create a minimal static site at `fann-vscode` repo root (or a `docs/` folder with GitHub Pages)
   - Pages:
     - Home / landing with the 3 promises
     - Quick-start guide
     - Detailed command reference
     - FAQ
     - Privacy policy
     - Changelog
   - Use a lightweight static site generator (VitePress, Starlight, or plain HTML + Tailwind)

3. **Auto-update and version communication**
   - Ensure `vsce publish` increments the version correctly
   - Add a "What's new" notification after extension update:
     - Show once per version, non-blocking
     - Link to changelog or release notes

4. **Corporate / air-gapped install path**
   - Ensure `.vsix` is always attached to GitHub Releases
   - Document manual install instructions: `code --install-extension fann-vscode-X.Y.Z.vsix`
   - This covers corporate environments that block the VS Code Marketplace

5. **CI/CD pipeline for releases**
   - Set up a GitHub Actions workflow in `fann-vscode`:
     - Trigger on `v*` tag push
     - Run compile, package, publish to VS Code Marketplace + Open VSX
     - Create GitHub Release with `.vsix` attached
     - Update version badge

6. **fann-core npm publication (when ready)**
   - Publish `fann-core` to npm when the API surface is stable enough for external consumption
   - This enables others to build tools on the shared runtime
   - Defer this until there is clear demand or a strategic reason to open the runtime

### User-visible behavior
Developers find `Fann` through more channels, updates happen seamlessly, and corporate users can install from `.vsix`.

### Exit gate
- `Fann` is available on both VS Code Marketplace and Open VSX
- updates are published through a CI/CD pipeline with no manual steps
- install friction is low for all user types (public, corporate, offline)

### Dogfooding success metric
- distribution expansion increases installs without materially increasing support burden
- at least one install comes from a channel that was not available before (e.g., Open VSX, direct `.vsix`)

### Agent-executable prompt

> **Phase 13 Prompt (for @DevOps or standalone coding agent):**
>
> Repo: `E:\Projects\fann-vscode`
> Attach: `package.json`, `.github/` directory (if it exists)
>
> Tasks:
> 1. Create `.github/workflows/release.yml`:
>    - Trigger: push tags matching `v*`
>    - Jobs: checkout → setup Node 20 → `npm ci` → `npm run compile` → `npx vsce package --no-dependencies` → publish to VS Code Marketplace using `VSCE_PAT` secret → publish to Open VSX using `OVSX_PAT` secret → create GitHub Release with `.vsix` attached
>    - Use `actions/create-release@v1` and `actions/upload-release-asset@v1` (or equivalent)
> 2. Add a "What's new" notification in `src/extension.ts`:
>    - On activation, compare `context.globalState.get('lastSeenVersion')` with `context.extension.packageJSON.version`
>    - If different, show one-time info message: "Fann updated to vX.Y.Z. [See What's New]" linking to CHANGELOG.md
>    - Update `lastSeenVersion` in global state
> 3. Update `README.md`: add Open VSX badge, manual `.vsix` install instructions
> 4. Validate: `npm run compile` succeeds. The workflow file is valid YAML.
>
> Do not modify `fann-core`.

---

## Phase 14 — Monetization Validation

**Objective:** Validate whether users value `Fann` enough to pay, and where the premium boundary should actually sit, grounded in real usage data.

### Build in this order

1. **Pricing hypothesis documentation**
   - Document the initial hypothesis:
     - **Who pays:** Developers who use `Fann` daily and want more concurrency / recall / planning power
     - **What they pay for:** Expanded background briefs, wider resume memory window, full-plan copy, future team features
     - **Price point hypothesis:** $5–12/month for individual; team pricing deferred
     - **Why they pay repeatedly:** The value compounds with usage (memory grows, plans accumulate, async briefs build context)

2. **Premium boundary validation**
   - Use telemetry data from Phase 12 to answer:
     - How many users hit the background-brief concurrency limit?
     - How many users hit the resume memory window limit?
     - Do users actually use the full-plan copy action when available?
   - If users rarely hit the boundary → the boundary is too generous or the feature is not compelling enough
   - If users frequently hit the boundary and complain → the boundary is well-placed

3. **Upgrade pathway implementation**
   - Current state: local `fann.account.plan` setting in `entitlements.ts`
   - Next step: add a `Fann: Upgrade` command that:
     - Shows the current plan and capabilities
     - Describes what `pro-preview` adds
     - Links to a payment page / waitlist / email signup
   - Keep the upgrade path light and non-intrusive at first

4. **Payment infrastructure (when validated)**
   - Choose a payment provider:
     - Stripe for subscription billing (standard)
     - Paddle for VAT/tax handling (international)
     - Gumroad for simplicity (solo developer)
     - LemonSqueezy for digital product licensing
   - Wire the payment flow:
     - User clicks upgrade → redirected to payment page → receives license key → enters key in extension settings
     - `entitlements.ts` validates the key against a lightweight backend
   - Keep billing logic out of `fann-core` — it belongs in the shell layer only

5. **License key validation backend**
   - Build a minimal backend:
     - Receives license key → validates against payment provider → returns plan + capabilities
     - Host on Azure Functions / Cloudflare Workers / Vercel Edge
     - Cache validation results locally to avoid blocking workflows during network issues
   - Keep the backend stateless and simple

6. **Pricing page / landing**
   - Create a public pricing comparison:
     - Free Alpha: 1 background brief, 3 memory anchors, first-step Deep Plan actions
     - Pro: 3 background briefs, 6 memory anchors, full-plan copy, priority support
     - Team (future): shared memory, team-wide plans, admin controls
   - Host on the docs site or a standalone landing page

7. **Refund and cancellation policy**
   - Define a clear policy before accepting money:
     - 30-day money-back guarantee for annual plans
     - Cancel anytime for monthly plans (no refund for partial months)
     - Downgrade to Free Alpha retains all saved data (plans, briefs, memory)
   - Communicate this on the pricing page and in the extension

### User-visible behavior
Users who hit premium boundaries are shown a clear, non-intrusive upgrade path. Users who upgrade get immediate capability expansion. Users who don't upgrade experience no degradation of the free tier.

### Exit gate
- there is a defensible monetization hypothesis grounded in real usage data
- at least a few preview users express concrete willingness to pay
- the upgrade path works end-to-end (from extension to payment to license validation)

### Dogfooding success metric
- the conversion funnel from free → premium-interest → actual upgrade is measurable
- at least one real transaction (even if $1 test price) has been completed end-to-end
- premium boundaries feel additive, not hostile — validated by user feedback

### Agent-executable prompt

> **Phase 14 Prompt (for @Implement or standalone coding agent):**
>
> Repo: `E:\Projects\fann-vscode`
> Attach: `src/services/entitlements.ts`, `src/extension.ts`, `package.json`, `docs/editions.md`
>
> Tasks:
> 1. Add a `fann.upgrade` command in `package.json` contributes.commands.
> 2. Create `src/commands/upgrade.ts`:
>    - Show a quick-pick with current plan info and capability comparison
>    - Include an "Open Pricing Page" option that opens a configurable URL via `vscode.env.openExternal`
>    - Include a "Enter License Key" option that prompts for a key and saves it to `fann.account.licenseKey` setting
>    - Register the command in `extension.ts`
> 3. In `entitlements.ts`:
>    - Add a `fann.account.licenseKey` setting (string, default empty)
>    - Add a `validateLicenseKey(key: string): FannPlan` function that:
>      - For now, accepts any non-empty string and returns `'pro-preview'` (placeholder validation)
>      - Includes a `// TODO: replace with backend validation` comment
>    - Update `resolveFannPlan()` to check for a valid license key first, then fall back to the `fann.account.plan` setting
> 4. In `package.json`: add the `fann.account.licenseKey` configuration property (string, default empty, description explaining this is for pro validation)
> 5. Update `docs/editions.md` with the upgrade pathway documentation
> 6. Validate: `npm run compile` succeeds. The upgrade flow works locally with a placeholder key.
>
> Do not modify `fann-core`. Do not build the remote validation backend yet. Keep billing logic in the shell layer only.

---

## Phase 15 — Visibility Engine / Build in Public

**Objective:** Build repeated credible visibility in the developer ecosystem so that `Fann` becomes known, not just listed.

### Build in this order

1. **Launch narrative**
   - Craft a one-paragraph story that answers:
     - What is `Fann`?
     - Why does it exist?
     - How is it different from plain AI chat?
     - What can you do with it in 5 minutes?
   - This paragraph is the foundation for every public post, pitch, and listing

2. **Story angles**
   - Prepare 5–7 distinct content angles:
     - "Why AI chat is not enough for daily coding work"
     - "I built a coding companion that remembers what you were doing yesterday"
     - "How I made AI async — and why it matters for solo developers"
     - "The 3 promises of calm AI: think deeply, work async, resume intelligently"
     - "From 25-agent pipeline lab to 4-command product: the Fann origin story"
     - "Why your coding intent shouldn't disappear when you close the editor"
     - "I dogfooded my own AI product for 60 days — here's what I learned"
   - Each angle can power multiple posts across different channels

3. **Channel plan**

   | Channel | Content type | Cadence | Priority |
   |---------|-------------|---------|----------|
   | X (Twitter) | Short-form: demos, insights, build updates | 3–4x/week | High |
   | LinkedIn | Professional narrative: origin story, product thinking, dev-tools perspective | 1–2x/week | High |
   | dev.to / Hashnode | Long-form: technical deep-dives, case studies | 1x/2 weeks | Medium |
   | Reddit (r/vscode, r/programming, r/devtools) | Discussion: "I built X, feedback welcome" | 1x every 2 weeks | Medium |
   | Hacker News | Launch post + follow-up | 1–2 strategic posts, not spammed | High (timing matters) |
   | Product Hunt | Full launch page with demo, screenshots, call-to-action | 1x, when listing and demo are strong | High |
   | YouTube | Short demo video (2–3 min) | 1x for launch, then monthly | Medium |
   | Newsletter / blog | Personal dev-tools newsletter or blog series | 1x/week | Low–Medium |

4. **Demo assets**
   - Create 2–3 polished demo artifacts:
     - 30-second GIF: ask → deep plan → resume loop
     - 2-minute narrated video: full workflow demo with voiceover
     - Interactive playground page (if warranted): try Fann concepts in a browser sandbox
   - All demos must show the product in real use, not hypothetical screenshots

5. **Hacker News launch plan**
   - Title format: "Show HN: Fann – A calm coding companion that helps you resume where you left off"
   - Post timing: Tuesday–Thursday, 8–10am ET
   - Prepare for questions:
     - "How is this different from Copilot Chat?"
     - "Why not just use session history?"
     - "What about privacy?"
     - "Will this work with X editor?"
   - Do NOT over-explain in the initial post. Keep it tight. Let the demo speak.

6. **Product Hunt launch plan**
   - Landing page with:
     - Tagline (one sentence)
     - 3 screenshots
     - 1 demo video
     - "Try it free" button linking to Marketplace listing
   - Recruit 3–5 early users to leave reviews on launch day
   - Schedule for a Tuesday or Wednesday for best visibility
   - Follow up with a "thank you + what we learned" post

7. **Build-in-public cadence**
   - Weekly rhythm:
     - Monday: share a metric or insight from the previous week
     - Wednesday: share a product decision or technical detail
     - Friday: share a user quote, feedback, or lesson learned
   - Monthly rhythm:
     - End-of-month: publish a "monthly report" with installs, retention, feedback themes, next plans
   - This cadence builds compounding visibility vs one-shot hype

8. **Community / ambassador seeding**
   - Identify 5–10 dev influencers or content creators who:
     - Talk about developer productivity
     - Care about async workflows, intent management, or AI tools
     - Have audiences of 1K–50K developers
   - Reach out with a personalized message + demo access
   - Do NOT pay for reviews. Offer genuine early access and ask for honest impressions.

### User-visible behavior
Developers encounter `Fann` naturally through content they already read, watch, or follow. The product has a recognizable positioning: "calm coding companion that helps you resume where you left off."

### Exit gate
- the product has a visible, consistent public narrative with recognizable positioning
- at least one content piece has generated meaningful external traffic or install conversions
- the launch cadence is running weekly without burning out

### Dogfooding success metric
- installs and feedback conversations rise from repeated credible exposure, not just one announcement
- at least 3 different content channels have driven installs
- the "I built X" story generates genuine engagement (comments, shares, questions) rather than silence

### Agent-executable prompt

> **Phase 15 Prompt (for @Prompt-Engineer or standalone content agent):**
>
> Context: Fann is a VS Code extension with 4 commands (Ask, Deep Plan, Run in Background, Resume from Memory). Value proposition: "Turn rough coding intent into a clear next step now — and pick it back up later without losing context." Three promises: think deeply, work asynchronously, resume intelligently.
>
> Tasks:
> 1. Write the one-paragraph launch narrative (4–5 sentences, compelling, non-technical, clear differentiation from plain AI chat).
> 2. For each of the 7 story angles listed above, write a 2–3 sentence pitch that could open a blog post, Twitter thread, or LinkedIn post.
> 3. Write the Hacker News "Show HN" post (title + 4–5 paragraph body — keep it tight, link to demo/install).
> 4. Write a Product Hunt tagline (one sentence), maker comment (3 paragraphs: what, why, who), and first-day reply template for common questions.
> 5. Draft the Monday/Wednesday/Friday build-in-public post templates with fill-in-the-blank sections for metrics, decisions, and user quotes.
>
> Output: a single markdown file at `.github/plans/fann-launch-content-kit.md` containing all of the above in labeled sections.

---

## Phase 16 — VC Readiness / Fundraise Story

**Objective:** Earn the right to raise by showing traction, clarity, and a believable market story — not by raising on concept hype.

### Build in this order

1. **Founder / product narrative**
   - Write a 1-page narrative memo:
     - **Why now:** AI coding tools are commoditized into one-shot chat. The next layer is persistent intent, async execution, and cross-session memory.
     - **What pain:** Developers lose momentum between sessions. Context evaporates. Starting over is the norm.
     - **What Fann does:** Turns rough intent into structured next steps that persist and resume.
     - **Why this becomes a platform:** Start with a VS Code companion → grow into a developer workflow layer that spans editors, teams, and toolchains.
     - **Why us:** Built the `junai` 25-agent pipeline lab; extracted the product from real daily use; shipped without external validation dependency.

2. **Traction dashboard**
   - Build a live or weekly-updated dashboard showing:
     - Total installs (Marketplace + Open VSX + direct `.vsix`)
     - Weekly active users (WAU)
     - D7 / D30 retention rates
     - Usage by command (which promise is most used?)
     - Premium-interest signals (upgrade prompt interactions, plan changes)
     - Feedback volume and sentiment
   - This dashboard is your primary fundraise artifact — investors want to see curves, not concepts

3. **Investor memo / deck (5–7 slides)**
   - Slide 1: **The problem** — AI chat is ephemeral; developers lose context between sessions
   - Slide 2: **The product** — Fann: 4 commands, 3 promises, daily workflow companion
   - Slide 3: **Traction** — installs, WAU, retention, user quotes
   - Slide 4: **Market** — $X billion developer tools market; positioned in the "developer workflow layer" between chat and full CI
   - Slide 5: **Business model** — freemium with individual pro → team enterprise → platform licensing
   - Slide 6: **Roadmap** — product evolution toward a developer workflow platform
   - Slide 7: **Ask** — amount, use of funds (hire + growth + infrastructure)

4. **Category positioning**
   - Position `Fann` clearly in the market landscape:
     - NOT "another Copilot" (not code generation)
     - NOT "another CI tool" (not deployment automation)
     - IS "developer workflow companion" — the layer between intent and execution that persists across sessions
   - Create a competitive landscape map showing where `Fann` sits relative to:
     - GitHub Copilot Chat (one-shot, ephemeral)
     - Cursor (editor-integrated AI, but still session-bound)
     - Linear / Notion (task management, but not intent-driven execution)
     - Fann: persistent intent → structured execution → cross-session resume

5. **Decision gate for fundraising conversations**
   - Only start VC conversations when at least 3 of these 5 are true:
     1. ≥ 500 installs with > 10% WAU/install ratio
     2. D7 retention ≥ 25%
     3. At least 10 users express concrete willingness to pay
     4. The conversion funnel from free → paid is measurable (even if small)
     5. The product story generates repeated organic interest (not paid or incentivized)
   - If fewer than 3 are true, focus on product and growth, not fundraising

6. **Warm intro pipeline**
   - Build a list of 20–30 potential investors:
     - Developer tools VCs (e.g., Heavybit, Greylock, Redpoint, a16z infra, Sequoia scout)
     - Angel investors from the dev-tools ecosystem
     - Solo GPs who back early-stage developer infrastructure
   - Reach out through warm intros, not cold emails
   - Lead with the traction dashboard, not the product concept

### User-visible behavior
None — this phase is founder-facing, not user-facing. Users continue to experience the product as is.

### Exit gate
- there is enough real usage signal to support external fundraising conversations
- the traction dashboard shows a believable growth curve
- the investor memo/deck is ready and concise
- the category positioning is crisp enough to explain in one sentence

### Dogfooding success metric
- VC conversations, if started, are anchored in real traction data
- investor feedback is treated as another learning signal, not validation dependency
- the fundraise story is grounded in demonstrated usage, not hypothetical feature lists

### Agent-executable prompt

> **Phase 16 Prompt (for @Prompt-Engineer or content agent):**
>
> Context: Fann is a VS Code coding companion with 4 commands. Value prop: "Turn rough coding intent into a clear next step now — and pick it back up later without losing context." Origin: built from `junai`, a 25-agent pipeline lab.
>
> Tasks:
> 1. Write a 1-page founder narrative memo covering: why now, what pain, what Fann does, why this becomes a platform, why us.
> 2. Draft a 7-slide investor deck outline (title + 3–5 bullet points per slide, no design — just the content skeleton).
> 3. Write a competitive positioning statement (one paragraph) explaining where Fann sits relative to Copilot Chat, Cursor, Linear, and Notion.
> 4. Write the decision gate criteria as a checklist with threshold values.
>
> Output: `.github/plans/fann-investor-content-kit.md`

---

## 3. Milestones and timeline

| Milestone | Duration | Outcome |
|-----------|----------|---------|
| `M10` | 1–2 weeks | Preview release live on VS Code Marketplace |
| `M11` | 2–3 weeks | 10–25 alpha users onboarded, feedback loop running |
| `M12` | 1–2 weeks | Opt-in telemetry + local usage summary live |
| `M13` | 1 week | Open VSX published, CI/CD pipeline live |
| `M14` | 2–3 weeks | Monetization hypothesis validated or invalidated |
| `M15` | Ongoing (weekly cadence) | Build-in-public rhythm established, first external traffic |
| `M16` | When traction warrants | Investor memo ready, decision gate evaluated |

**Estimated total to first meaningful traction signal:** 8–12 weeks from Phase 10 start.

---

## 4. Immediate next steps (current checkpoint: all v1 build phases complete)

1. **Start Phase 10 — Preview Release Preparation**
   - Create visual assets (icon, screenshots, demo GIF)
   - Harden the README and marketplace listing
   - Validate the `.vsix` package in a clean VS Code instance
   - Publish to VS Code Marketplace

2. **Prepare Phase 11 recruitment**
   - Identify 10–25 design partner candidates from personal network and dev communities
   - Draft the invite message
   - Set up the feedback form

3. **Do not build monetization infrastructure before Phase 11 feedback validates value**

---

## 5. Strategic rules for this roadmap

> **The first roadmap built the product. This roadmap earns the audience, the revenue signal, and the right to scale it.**

> **Optimize for distribution + retention + quotable positioning, not one-off hype.**

> **Do not build Electron, Docker, or multi-platform apps before VS Code Marketplace + Open VSX prove demand.**

> **Every product decision from here forward should be traceable to feedback, usage data, or a validated hypothesis — not to internal assumptions.**

> **`junai` is the lab. `Fann` is the product. `fann-core` is the bridge. This rule holds through shipping, monetization, and beyond.**

---

## 6. Manual execution protocol

This section matches the original roadmap's execution model for consistency.

### How to execute each phase

1. **Read the phase section fully** before starting any work.
2. **Execute tasks in the listed order** — dependencies are encoded in the sequence.
3. **Use the agent-executable prompt** when delegating to a coding/content agent. Attach the listed files.
4. **Verify exit gates** before marking the phase complete. Use primary signals (grep, test output, live marketplace listing) rather than assumptions.
5. **Log dogfooding results** in `dogfooding/dogfooding-tests.md` under a `## Phase N — [Name]` heading.
6. **Update `checkpoint.md`** with: phase status, follow-ups discovered, and next steps.

### Phase completion checklist (every phase)

- [ ] All listed tasks completed
- [ ] Exit gate conditions met (verified with primary signals)
- [ ] Dogfooding metric evaluated and recorded
- [ ] Phase follow-ups logged in checkpoint
- [ ] Git commit includes all changed files
- [ ] Next phase is ready to start

### Rules inherited from v1 roadmap

- **Build in order.** Do not skip ahead. Each phase's build list is sequenced to minimize wasted work.
- **Dogfood before shipping.** Every phase must be dogfooded before marking complete.
- **Do not over-build.** If a phase can be completed with less than listed, that is fine. Do not add scope.
- **Follow-ups go in checkpoint, not in the roadmap.** The roadmap is the plan. The checkpoint is the living record.
- **When in doubt, ship and learn.** Perfection is the enemy of traction.
