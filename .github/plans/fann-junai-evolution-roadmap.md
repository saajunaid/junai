# Fann Roadmap — junai Evolution + New Product Launch

> **Updated:** 2026-04-04
> **Status:** READY FOR EXECUTION
> **Execution model:** Staggered parallel — enhance `junai-vscode` first, then extract a shared core, then build `Fann` on top.

---

## Pre-Flight Scan

Phase 0 — Product Split Freeze: ~4 tasks, depends on none  
Phase 1 — Core Foundation in `junai-vscode`: ~6 tasks, depends on Phase 0  
Phase 2 — Coordinator Mode in `junai`: ~5 tasks, depends on Phase 1  
Phase 3 — Dream Memory Consolidation: ~5 tasks, depends on Phase 1  
Phase 4 — Deep Plan Mode: ~4 tasks, depends on Phases 1–3  
Phase 5 — KAIROS-lite Proactive Assistant: ~4 tasks, depends on Phases 1–3  
Phase 6 — Extract `fann-core`: ~6 tasks, depends on Phases 2–5  
Phase 7 — Scaffold `fann-vscode`: ~5 tasks, depends on Phase 6  
Phase 8 — Fann MVP Alpha: ~5 tasks, depends on Phase 7  
Phase 9 — Monetization + Polish: ~5 tasks, depends on Phase 8

---

## 0. Context & Decisions

### What this roadmap builds
This roadmap turns the existing `junai` work into a two-track product strategy. `junai-vscode` remains the advanced incubator and orchestration lab, while a new public extension named `Fann` becomes the cleaner, branded, monetizable product. A shared runtime package, `fann-core`, carries stable orchestration, memory, planning, and safety primitives used by both.

### Locked decisions

| Concern | Decision | Rationale |
|---------|----------|-----------|
| Public product name | `Fann` | Short, memorable, globally pronounceable, tied to craft/mastery |
| Advanced lab | `junai-vscode` | Already contains the full pipeline concepts and internal experimentation surface |
| Shared runtime | `fann-core` | Avoids duplicate implementations across the two extensions |
| Public extension repo | `fann-vscode` | Clean separation for branding, release cadence, and monetization |
| Execution strategy | Staggered parallel | Keeps momentum while minimizing duplicated work |
| Fann v1 UX | Narrow and product-first | The public product must expose only the smallest high-value surface, not the full `junai` internal model |

### Cross-cutting implementation refinements

These apply to **every remaining phase** of the roadmap:

1. **Define shared contracts early** — before `fann-core` is physically extracted, the interfaces and event shapes must be defined inside `junai-vscode` so later extraction is mechanical rather than exploratory.
2. **Attach dogfooding success metrics** — each phase must prove not only that the feature works technically, but that it improved the real daily workflow during use.
3. **Keep Fann product-first** — if a feature requires explaining pipeline state, specialist routing, or artefact contracts to the user, it likely belongs in `junai`, not `Fann` v1.

### Repo responsibility split

| Repo | Purpose | Status |
|------|---------|--------|
| `agent-sandbox` | Canonical source of truth for agents, prompts, skills, instructions, and roadmap docs | Keep |
| `junai-vscode` | Incubator / advanced extension / full orchestration experience | Keep and enhance |
| `fann-core` | Shared runtime for orchestration, memory, permissions, planning, notifications | Create |
| `fann-vscode` | Public-facing, simplified, branded extension built on the shared core | Create |
| `junai` | Public pool mirror of canonical AI resources | Keep |

### What stays in junai vs shared vs Fann-only

| Scope | Contents |
|------|----------|
| `junai`-only | full 25-agent pipeline surface, heavy orchestration, artefact contracts, advanced experimental workflows |
| Shared (`fann-core`) | coordinator runtime, background task runner, memory consolidation, prompt/skill loader, permissions engine, event bus |
| `Fann`-only | simplified UX, onboarding, branded commands, public docs, monetization hooks |

---

## 1. Recommended repo structure

```text
E:\Projects\
├── agent-sandbox/        # canonical source of truth for agents, prompts, skills, instructions
├── junai-vscode/         # advanced extension / incubator / full pipeline UX
├── fann-core/            # shared runtime engine used by both extensions
├── fann-vscode/          # public product extension with simplified UX
└── junai/                # public mirror of canonical pool resources
```

### Shared contracts to define before extraction

These contracts should be drafted **now** inside `junai-vscode`, even if the implementation still lives there until Phase 6:

```text
CoreEvent
- kind: task-complete | plan-ready | memory-updated | blocked | approval-needed
- source: coordinator | dream | deep-plan | proactive | permissions
- severity: info | warning | error
- title: string
- detail?: string

CoordinatorTaskSpec
- id, role, goal, dependencies, status, evidence

CoordinatorSynthesisResult
- summary, workerFindings[], nextAction, confidence

MemoryConsolidationResult
- factsAdded[], factsUpdated[], factsPruned[], conflicts[]

DeepPlanRequest / DeepPlanResult
- task summary, scope, constraints, risks, output plan path

RiskTier / ProtectedAction
- low | medium | high
- requires approval?: boolean
- protected paths / commands / rationale
```

> **Rule:** extraction to `fann-core` should mostly move code that already conforms to these contracts, not redesign it later.

### Proposed `fann-core` structure

```text
fann-core/
├── src/
│   ├── orchestration/
│   │   ├── coordinator.ts
│   │   ├── taskGraph.ts
│   │   └── workerRunner.ts
│   ├── memory/
│   │   ├── consolidator.ts
│   │   ├── recall.ts
│   │   └── policies.ts
│   ├── planning/
│   │   ├── deepPlan.ts
│   │   └── planContracts.ts
│   ├── permissions/
│   │   ├── riskTiers.ts
│   │   ├── protectedPaths.ts
│   │   └── approvalPolicy.ts
│   ├── background/
│   │   ├── taskRunner.ts
│   │   ├── notifications.ts
│   │   └── events.ts
│   ├── prompts/
│   │   ├── loader.ts
│   │   └── featureFlags.ts
│   ├── types/
│   └── index.ts
├── package.json
└── README.md
```

### Proposed `fann-vscode` structure

```text
fann-vscode/
├── src/
│   ├── extension.ts
│   ├── commands/
│   │   ├── ask.ts
│   │   ├── deepPlan.ts
│   │   ├── runInBackground.ts
│   │   └── resume.ts
│   ├── onboarding/
│   │   ├── welcome.ts
│   │   └── setupWizard.ts
│   ├── panels/
│   │   ├── activityView.ts
│   │   └── briefNotifications.ts
│   ├── services/
│   │   ├── coreAdapter.ts
│   │   ├── config.ts
│   │   └── sessionState.ts
│   └── branding/
├── package.json
└── README.md
```

---

## 2. Feature-by-feature build order

## Phase 0 — Product Split Freeze

**Objective:** Lock the naming, repo structure, and responsibility boundaries before new implementation begins.

### Tasks
1. Save this roadmap and treat it as the reference plan.
2. Freeze the public name as `Fann` and avoid reopening naming decisions during implementation.
3. Confirm `junai-vscode` as the incubator, `fann-core` as the shared runtime, and `fann-vscode` as the public product.
4. Create placeholder repo/folder notes or tickets for `fann-core` and `fann-vscode`.

### Exit gate
- `Fann` name accepted
- repo split documented
- roadmap file available for reference

---

## Phase 1 — Core Foundation in `junai-vscode`

**Objective:** Add the foundational runtime pieces that make all later features safe, controllable, composable, and ready for later extraction.

### Build in this order
1. **Feature flags**
   - `experimental.coordinator`
   - `experimental.dream`
   - `experimental.deepPlan`
   - `experimental.proactive`
2. **Risk-tiered permissions**
   - Low / Medium / High action classification
   - protected files and commands
   - stronger autopilot boundaries
3. **Event/notification bus**
   - task completed
   - blocked
   - approval needed
   - background result ready
4. **Shared contract draft (inside `junai-vscode`)**
   - `CoreEvent`
   - `CoordinatorTaskSpec` and `CoordinatorSynthesisResult`
   - `MemoryConsolidationResult`
   - `DeepPlanRequest` / `DeepPlanResult`
   - `RiskTier` / `ProtectedAction`

### Why first
These features provide rollout control, safer experimentation, and the notification primitives needed for Coordinator, Dream, Deep Plan, and KAIROS-lite. The shared contracts also reduce Phase 6 extraction risk.

### Exit gate
- feature flags work end-to-end
- risky operations can be classified and gated
- background events can be emitted and surfaced
- shared contract types are drafted and referenced by the Phase 2+ implementations

### Dogfooding success metric
- during normal development work, at least one experimental feature can be toggled on/off without code changes or brittle behavior
- permission prompts and background events feel predictable enough to trust during daily use

---

## Phase 2 — Coordinator Mode in `junai`

**Objective:** Upgrade `@Orchestrator` from stage router to true multi-worker coordinator.

### First implementation slice
1. Start with **parallel read-only workers** for repo exploration, investigation, and verification.
2. Add result aggregation so Orchestrator can synthesize one coherent answer.
3. Bind the implementation to the shared coordinator contracts drafted in Phase 1.
4. Only after stable read-only execution, expand to implementation/test/review worker patterns.

### User-visible behavior
A single broad request can now fan out to multiple workers in parallel instead of forcing manual or serial routing.

### Exit gate
- one orchestration flow can launch 2–3 workers and merge the results coherently
- coordinator output follows a stable result shape that can later move into `fann-core`

### Dogfooding success metric
- used successfully on at least 3 real tasks
- saved at least one manual routing or investigation cycle compared with serial agent use
- synthesis quality felt better than “ask one agent, then ask another”

---

## Phase 3 — Dream Memory Consolidation

**Objective:** Make `junai` improve across sessions by consolidating durable memory automatically.

### Build
1. Run a memory pass after completed stages or after significant sessions.
2. Consolidate:
   - durable repo facts
   - rejected approaches
   - successful commands and workflows
   - known failure modes
3. Use the Phase 1 memory result contract so the output is structured for later extraction.
4. Prune stale or contradictory items to avoid drift.

### User-visible behavior
Yesterday’s debugging or implementation lessons are available in future sessions without re-explaining them from scratch.

### Exit gate
- repeated explanations decrease
- memory stays concise and useful instead of bloated

### Dogfooding success metric
- at least 2 future sessions benefited from prior memory without manual recap
- memory added signal more often than noise
- stale or contradictory memory was visibly pruned instead of accumulating

---

## Phase 4 — Deep Plan Mode

**Objective:** Add a long-think planning lane for large tasks before implementation begins.

### Build
1. One entrypoint for deep planning: PRD → Architecture → phased implementation plan.
2. Clear approval gate before execution starts.
3. Route large, ambiguous, or risky tasks into Deep Plan instead of rushed implementation.
4. Bind the plan request/response flow to the Phase 1 shared planning contracts.

### User-visible behavior
Commands like “Deep Plan this feature” return a reusable phased plan with risks, dependencies, and validation steps.

### Exit gate
- complex tasks consistently produce usable plan documents
- fewer large tasks start with unclear scope

### Dogfooding success metric
- at least one real feature was planned through Deep Plan and then executed with less mid-stream scope confusion
- the plan output was good enough to reuse rather than rewrite manually

---

## Phase 5 — KAIROS-lite Proactive Assistant

**Objective:** Add a low-noise proactive layer that helps without interrupting.

### Build
1. Opt-in only.
2. Brief mode by default.
3. Surface only meaningful events:
   - background task finished
   - plan drift detected
   - review ready
   - blocked waiting for user input
4. Emit proactive notifications through the same shared event contract defined earlier.
5. Absorb the deferred event-taxonomy follow-up from the contract audit:
   - add `severity`, `title`, and `detail` consistently where proactive surfacing depends on them
   - keep the model small and useful rather than over-designing a full event ontology

### User-visible behavior
`junai` becomes lightly proactive instead of purely reactive, but remains calm and non-spammy.

### Exit gate
- notifications help more than they annoy
- users can leave it on without fatigue

### Dogfooding success metric
- the feature stays enabled for several days of normal use
- the majority of surfaced events are useful enough to act on immediately
- no noticeable notification fatigue builds up

---

## Phase 6 — Extract `fann-core`

**Objective:** Move stable runtime primitives into a shared package used by both extensions.

### Extract
- orchestration runtime
- background task runner
- memory service
- permissions engine
- prompt/flag loader
- notification primitives

### Deferred follow-ups to absorb during extraction hardening
- evolve coordinator synthesis from markdown-heavy output toward structured findings (`finding`, `severity`, `evidence`, `file`, `confidence`, `recommended_action`)
- add dedupe / ranking so repeated worker observations collapse into one clearer conclusion
- tighten action-name typing further only where it improves extraction safety without creating churn

### Why now
At this point, the concepts are validated inside `junai-vscode` and worth formalizing as reusable infrastructure. Because the contracts were defined earlier, this phase should be primarily extraction and cleanup rather than redesign.

### Exit gate
- `junai-vscode` and `fann-vscode` can depend on the same package without copy-paste

### Dogfooding success metric
- after extraction, `junai-vscode` still behaves the same in normal use
- shared code reduced duplication instead of introducing regressions or conceptual drift

---

## Phase 7 — Scaffold `fann-vscode`

**Objective:** Create the public product shell on top of the shared core.

### Initial command surface
- `Fann: Ask`
- `Fann: Deep Plan`
- `Fann: Run in Background`
- `Fann: Resume from Memory`

### Fann v1 UX rule
If a feature requires teaching the user about pipeline state, agent routing graphs, artefact contracts, or specialist handoff discipline, it does **not** belong in the initial `Fann` surface. Keep those concepts in `junai`.

### Deliberately exclude from v1 UX
- full pipeline vocabulary
- specialist agent overload
- internal orchestration terminology
- settings and modes that are only meaningful to power users

### Exit gate
- a new user can understand the product quickly and complete a first-run flow with minimal explanation

### Dogfooding success metric
- a fresh user experience can be explained in one sentence
- first-run flow feels simpler than `junai-vscode`, not like a renamed copy

---

## Phase 8 — Fann MVP Alpha

**Objective:** Produce the first usable public-facing version.

### MVP promise
`Fann` helps developers:
1. think deeply
2. work asynchronously
3. resume intelligently

### Scope control
Keep the MVP narrow. Do not attempt to expose all `junai` complexity in the first public release.

### Exit gate
- daily dogfooding is possible
- at least one or two workflows clearly feel better than plain chat-based assistance

### Dogfooding success metric
- the MVP is good enough for real daily use for at least one repeated workflow
- the value proposition remains understandable without explaining `junai` internals

---

## Phase 9 — Monetization + Polish

**Objective:** Turn `Fann` from a promising tool into a credible product.

### Add
- onboarding flow
- stronger value messaging
- pricing or premium capability gating
- private alpha / waitlist / feedback collection
- marketplace-ready screenshots and docs

### Exit gate
- one-sentence value proposition is crisp
- first external users can understand why they would install and pay for `Fann`

### Dogfooding success metric
- external-facing messaging matches the workflows that proved valuable during internal dogfooding
- monetization discussions are grounded in demonstrated usage, not hypothetical feature lists

---

## 3. Milestones and timeline

| Milestone | Duration | Outcome |
|-----------|----------|---------|
| `M0` | 2–3 days | Product split and roadmap frozen |
| `M1` | 1 week | Feature flags + permissions + event bus |
| `M2` | 1 week | Coordinator mode prototype |
| `M3` | 1 week | Dream memory prototype |
| `M4` | 1 week | Deep Plan mode |
| `M5` | 1 week | KAIROS-lite |
| `M6` | 1–2 weeks | `fann-core` extracted |
| `M7` | 1 week | `fann-vscode` shell |
| `M8` | 1–2 weeks | Fann alpha-ready MVP |

**Estimated total:** 8–10 weeks for a solid first pass.

---

## 4. Immediate next steps (current checkpoint: Phase 1 through Phase 4 complete)

1. **Run focused Dream dogfooding validation**
   - run 2–3 sessions with `junai.experimental.dream=true`
   - inspect `dream-memory.json` signal quality (added/updated/pruned/conflicts) and verify noise stays low
   - capture concrete examples where prior-session memory reduced repeated explanations
2. **Run focused Deep Plan dogfooding validation**
   - run `junai.deepPlan` on 2–3 large/ambiguous tasks
   - evaluate whether scope, assumptions, risks, phases, and next action are reusable without major rewrite
   - capture where confidence scoring or phase granularity needs tuning
3. **Then start Phase 5 — KAIROS-lite Proactive Assistant**
   - keep proactive notifications opt-in and brief by default
   - reuse the shared event direction and absorb deferred `severity/title/detail` event taxonomy refinements
   - prioritize usefulness-over-volume to avoid notification fatigue

---

## 5. Strategic rule

> **`junai` is the lab. `Fann` is the product. `fann-core` is the bridge.**

That rule should guide scope decisions whenever overlap appears between the two extensions.
