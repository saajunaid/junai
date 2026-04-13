# Checkpoint — Fann / junai evolution

> **Updated:** 2026-04-06
> **Status:** Phase 1 through Phase 9 complete
> **Purpose:** Short working notes to support later extraction into `fann-core`

---

## Current status

- **Phase 1 complete** — feature flags, risk-tiered permissions, and event/notification groundwork are in place in `junai-vscode`.
- **Phase 2 complete** — Coordinator Mode MVP is implemented and compile-verified.
- **Phase 3 complete** — Dream Memory Consolidation is implemented with quiet consolidation, dedupe, pruning, and structured result contracts.
- **Phase 4 complete** — Deep Plan Mode is implemented with an approval-aware command entrypoint and reusable phased planning output.
- **Phase 5 complete** — KAIROS-lite Proactive Assistant is implemented with opt-in low-noise popup/status/log surfacing, dedupe, cooldown, and shared-event-based routing.
- **Phase 6 complete** — `fann-core` is extracted as the shared runtime package, while `junai-vscode` remains stable through thin adapters and re-export boundaries.
- **Phase 7 complete** — `fann-vscode` is scaffolded as the public-facing shell with a narrow product-first command surface on top of `fann-core`.
- **Phase 8 complete** — `fann-vscode` is now a narrow MVP Alpha with stronger daily usability for deep thinking, async work, and intelligent resumption.
- **Phase 9 complete** — `fann-vscode` now presents as a credible preview product with stronger onboarding, value messaging, marketplace-facing polish, and lightweight premium-boundary scaffolding.
- **Shared-contract audit completed** — core contract shapes were normalized with minimal, compatibility-safe edits.

## Contract audit summary

### Stable already
- Feature flags are clear and stable
- `RiskTier` usage is consistent
- Event bus mechanics are stable
- Coordinator execution flow is behaviorally stable

### Minimal fixes applied
- Explicit `CoreEvent` contract added
- `CoordinatorTaskSpec` aligned to current worker spec
- `CoordinatorSynthesisResult` added as an extraction-ready synthesis shape
- `ProtectedAction` model introduced
- `ApprovalNeededEvent.riskTier` normalized to `RiskTier`

### Intentionally deferred
- richer event taxonomy (`severity`, `title`, `detail` everywhere)
- richer structured synthesis beyond markdown output
- strict `ActionName` enforcement at every call boundary

**Decision:** These deferred items are follow-up refinements, not blockers for Phase 3.

## Cross-cutting validation hardening reminder

- before naming a file path in a prompt or attachment list, **verify the actual path** with `Get-ChildItem -Recurse`, `file_search`, or `Test-Path`
- do **not** infer nested paths from a summary, scaffold description, or filename list alone
- treat file paths the same way we treat other validation questions: use the **primary signal** from the workspace tree before stating them as fact

---

## Dogfooding notes

### Coordinator dogfood — prompt 1 result
- `coordinator`, `dream`, and `deepPlan` are now live end-to-end under experimental flags
- `proactive` remains scaffolded but not yet implemented
- Experimental surface is clearer: live features are distinguished from roadmap-only features

### Recommended small cleanup before Phase 3
Create a single experimental feature manifest that defines:
- `flag`
- `implemented`
- `commandId` (optional)
- `statusLabel`
- `comingSoon` text (optional)

This keeps settings, status output, and docs honest without broad refactoring.

### Coordinator dogfood — prompt 2 result
- **Verdict:** `READY FOR PHASE 3 WITH MINOR FOLLOW-UP`
- Dream should start now, but with one small guardrail first: a quiet consolidation service using structured payloads plus dedupe state
- This confirms Phase 3 is practical, not premature

### Coordinator dogfood — prompt 3 result
#### What worked well
- parallel review angles gave faster first-pass coverage
- the architecture, maintainability, and UX lenses converged on the same key conclusions
- coordinator is already useful for bounded investigation / audit / review work

#### What still feels weak
- repeated file overlap created redundancy
- outputs were too markdown/report-like and still needed manual cleanup
- synthesis quality is still modest because worker output is not yet strongly structured

#### Follow-up implication
- **Phase 5** should absorb the deferred event-taxonomy work needed for cleaner proactive surfacing
- **Phase 6** should absorb structured finding contracts and dedupe/ranking in coordinator synthesis during extraction hardening
- Best current use case: review / audit / investigation tasks
- Not yet strongest for: high-polish final conclusions without manual cleanup

### Phase 1 foundation / contract follow-ups to revisit
- keep the **shared experimental feature manifest** acting as the single source of truth across settings, status output, and future shells
- continue tightening the **event contract** only where it improves clarity (`severity`, `title`, `detail`) without over-designing the taxonomy
- keep **`RiskTier` / `ProtectedAction`** semantics stable as shared infrastructure and avoid drift between `junai-vscode`, `fann-core`, and later `fann-vscode`
- revisit stricter **`ActionName` typing** only where it meaningfully improves safety without creating churn at every boundary

### Phase 2 coordinator follow-ups to revisit
- evolve coordinator output from markdown-heavy synthesis toward a compact **structured findings** model (`finding`, `severity`, `evidence`, `file`, `confidence`, `recommended_action`)
- add **dedupe / ranking** so repeated worker observations collapse into one clearer conclusion instead of overlapping report text
- reduce repeated file overlap and manual cleanup burden in multi-worker runs
- keep using Coordinator primarily for **review / audit / investigation** work until higher-polish final synthesis is proven

### Phase 3 dogfood follow-ups to revisit
- add a **resume-oriented retrieval layer** so Dream helps future sessions resume intelligently, not just record activity
- preserve **rejection rationale** (`we rejected X because Y`) more explicitly instead of mostly event-style memory
- reduce promotion of low-value structural trivia from repo-fact extraction
- improve near-duplicate merging so slightly different wording reinforces one fact instead of creating fragmented memory entries
- revisit pruning rules for important single-hit insights that may otherwise age out too early

### Phase 4 dogfood follow-ups to revisit
- keep improving **task-specific nextAction quality** so plans point to a concrete engineering move, not a generic checkpoint
- keep approval wording product-facing (`Use This Plan` / `Copy Next Step`) rather than ceremonial
- improve discoverability in docs and command surfaces so Deep Plan feels intentional, not hidden
- over time, reduce reliance on templated heuristics so plans become less generic and more execution-ready
- preserve the current compact `DeepPlanRequest` / `DeepPlanResult` contract as the base for later `fann-core` extraction

### Phase 5 dogfood follow-ups to revisit
- reduce **status-bar churn** in bursty success flows by bundling or aggregating rapid low-stakes notices instead of rotating them too quickly
- keep notification wording more **product-natural** (`Plan approved`, `Next step ready`) and less ceremonial or extension-internal
- preserve the current **quiet-by-default** policy during extraction: popup only for truly blocking or approval-needed moments
- keep the **policy engine host-agnostic** and the VS Code display layer thin so `fann-core` owns decisions while the extension shell only renders them
- normalize the slightly **junai-shaped event mappings** during Phase 6 extraction so the shared event taxonomy stays compact, reusable, and product-facing

### Phase 6 stability follow-ups to revisit
- keep **`fann-core` packaging and version sync** reliable so the shared package can be bundled/published cleanly beyond the local `file:../fann-core` setup
- keep the **shared manifest and VS Code command metadata** in sync so features do not feel missing or mislabeled across shells
- watch a few mildly awkward **file placements / naming leftovers** inside `fann-core` and clean them up only when it improves clarity without causing churn
- keep adapter boundaries disciplined: **`fann-core` owns decisions, shells own rendering and host integration**
- treat remaining Phase 6 issues as **operational hardening**, not a reason to redesign before product-shell work

### Phase 7 shell / product follow-ups to revisit
- replace note-based background prep with richer **real async job orchestration** only when it improves the product surface without exposing lab complexity
- add a more polished **activity panel / webview** when the product needs stronger in-app visibility beyond output-channel-style surfaces
- strengthen **resume intelligence** so `Resume from Memory` ranks relevance better than a latest-only snapshot
- evolve `Fann: Ask` into a richer in-product conversation surface only after the simple shell proves its value
- harden **`fann-core` packaging / release flow** so `fann-vscode` is not dependent on local-only linking
- add targeted tests around **command handlers and core-adapter boundaries** as the shell stabilizes toward MVP

### Phase 8 MVP follow-ups to revisit
- replace remaining internal helper naming like **`BackgroundPrep*`** so shell internals stay consistent with public-product language
- add a tiny **recent outcomes read model** for Resume (for example, last successful first step / latest successful brief) to improve re-entry further
- add lightweight targeted unit tests for:
  - session state transitions (`running -> success/failure/interrupted`)
  - resume ranking logic
  - deep-plan next-step extraction parser
- consider a compact **open latest brief/plan alias** later only if real usage proves it valuable, without widening the core command surface prematurely
- keep product wording guardrails in place so internal terms (`pipeline`, `specialist`, `orchestration`, `lab-only`, raw `confidence` framing) do not drift back into the public shell
- keep making **`Run in Background`** feel richer and more obviously valuable over time, but without widening scope beyond the narrow MVP
- soften any last bits of **alpha/dev-tool wording** in README and UI copy as Phase 9 polish work

### Phase 9 polish / monetization follow-ups to revisit
- add real **account-backed entitlement resolution** later to replace local setting-based edition selection when monetization is ready
- prepare richer **marketplace assets** (icon, screenshots, listing narrative, demo visuals) once brand assets are finalized
- add lightweight **telemetry / usage instrumentation** only when needed for conversion-safe premium boundary tuning and feedback loops
- consider a subtle **compare editions** touchpoint only if monetization turns on, without harming the calm product feel
- treat the next work as **shipping + feedback + iteration**, not another internal architecture phase

---

## Next steps

1. Treat the original build roadmap as **effectively complete for v1 preview** and move into the **post-v1 shipping / feedback / iteration roadmap**
2. Focus next on preview release preparation, marketplace/listing assets, external feedback loops, and monetization validation
3. Keep the product narrow and calm while learning from real users rather than reopening the internal build phases

---

## Phase meanings in plain words

- **Phase 1** = build the plumbing and safety rails
- **Phase 2** = make `junai` coordinate multiple workers in parallel
- **Phase 3 (Dream)** = make `junai` remember useful things across sessions without getting bloated or stale
- **Phase 4 (Deep Plan)** = add a structured long-think planning lane before implementation
- **Phase 5 (KAIROS-lite)** = make `junai` lightly proactive in a calm, low-noise, opt-in way
- **Phase 6 (`fann-core`)** = extract the stable shared runtime so both `junai` and `Fann` can build on the same core
- **Phase 7 (`fann-vscode`)** = create the first simple public product shell on top of the shared core
- **Phase 8 (MVP Alpha)** = make that shell genuinely useful in daily use for deep thinking, async work, and intelligent resumption
- **Phase 9 (Monetization + Polish)** = turn the MVP into a credible external-facing preview product with clear value and light premium boundaries

---

## Strategic reminder

> `junai` is the lab. `Fann` is the product. `fann-core` is the bridge.
