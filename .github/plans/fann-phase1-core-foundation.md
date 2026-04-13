---
chain_id: FEAT-2026-0404-fann-evolution
type: plan
status: current
approval: pending
---

# Phase 1 — Core Foundation in junai-vscode

> **For the implementing agent:** Follow this plan task-by-task, executing each step sequentially.
> This plan is self-contained. You do not need the pipeline or @Orchestrator to execute it.

**Goal:** Add feature flags, risk-tiered permissions, and an event bus to junai-vscode — the three foundational runtime pieces that make Coordinator Mode, Dream Memory, Deep Plan, and KAIROS-lite safe to ship later.

**Architecture:** The current extension is a single ~1220-line `src/extension.ts` file. This phase introduces three new modules alongside it under `src/`. Each module exports a singleton or factory that `extension.ts` imports and wires into the activation lifecycle. No existing functionality is changed — this is purely additive.

**Tech Stack:** TypeScript 5.3+, VS Code Extension API ^1.101.0, Node.js built-in `EventEmitter`.

**Parent roadmap:** `.github/plans/fann-junai-evolution-roadmap.md`

---

## Manual Execution Protocol

For each task group below, follow this workflow:

1. **Open** a new chat session (any agent with code editing tools — `@Implement` recommended)
2. **Attach files** listed in the task's "Files" section
3. **Paste** the task description or reference this plan file
4. **Validate** using the task's acceptance criteria
5. **Commit** after each task group passes validation

**Drift rule:** If you find bugs introduced by Task N, fix them in the SAME session before starting Task N+1.

---

## Phase 0 — Context & Decisions

### Technology Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Event bus | Node.js `EventEmitter` wrapped in typed class | Zero dependencies, VS Code extensions already run on Node, type-safe wrapper prevents stringly-typed usage |
| Feature flags storage | VS Code `configuration` API (`package.json` contributes) | Standard extension pattern, users can override per-workspace in settings.json, survives reloads |
| Permissions model | Static risk classification + configurable protected paths | Keeps it simple — no runtime policy engine yet, just a lookup table and a guard function |
| Module pattern | Named exports from `src/*.ts`, imported in `extension.ts` | Avoids monolith growth, each concern is independently testable |

### Existing Scaffold — DO NOT Recreate

| File | Purpose | Current State |
|------|---------|---------------|
| `src/extension.ts` | Entire extension (1220 lines) — activation, commands, pool ops, autopilot watcher | ✅ Working — add imports at top, wire into `activate()` |
| `package.json` | Extension manifest — commands, configuration, scripts | ✅ Working — add new configuration properties |
| `tsconfig.json` | TypeScript config | ✅ Working — no changes needed |

### Dependencies

**Already installed** (DO NOT reinstall):
- `@types/vscode`, `@types/node`, `typescript`, `@vscode/vsce`

**Not yet installed:**
- None — Phase 1 uses zero new dependencies

---

## Task 1: Feature Flags Module

**Objective:** Add `experimental.*` boolean configuration settings that gate all future capabilities.

### Files

- **Create:** `src/featureFlags.ts`
- **Modify:** `package.json` (add configuration properties)
- **Modify:** `src/extension.ts` (import and initialize)

### Step 1: Add configuration properties to package.json

Open `E:\Projects\junai-vscode\package.json`. In the `contributes.configuration.properties` object, after the existing `junai.autoInitializeOnActivation` property, add the following four feature flag properties:

```jsonc
"junai.experimental.coordinator": {
  "type": "boolean",
  "default": false,
  "description": "Enable Coordinator Mode — fan out tasks to parallel workers and synthesize results. Experimental."
},
"junai.experimental.dream": {
  "type": "boolean",
  "default": false,
  "description": "Enable Dream Memory Consolidation — automatic background memory pruning and promotion after sessions. Experimental."
},
"junai.experimental.deepPlan": {
  "type": "boolean",
  "default": false,
  "description": "Enable Deep Plan Mode — long-think planning lane for complex features before implementation. Experimental."
},
"junai.experimental.proactive": {
  "type": "boolean",
  "default": false,
  "description": "Enable KAIROS-lite Proactive Assistant — opt-in low-noise notifications for meaningful pipeline events. Experimental."
}
```

### Step 2: Create the feature flags module

Create `E:\Projects\junai-vscode\src\featureFlags.ts`:

```typescript
import * as vscode from 'vscode';

/**
 * Experimental feature flag names.
 * Each maps to a `junai.experimental.<name>` boolean setting in package.json.
 */
export type FeatureFlag = 'coordinator' | 'dream' | 'deepPlan' | 'proactive';

const CONFIG_SECTION = 'junai.experimental';

/**
 * Check whether a specific experimental feature is enabled.
 * Reads from VS Code workspace configuration (user/workspace settings).
 */
export function isFeatureEnabled(flag: FeatureFlag): boolean {
    const config = vscode.workspace.getConfiguration(CONFIG_SECTION);
    return config.get<boolean>(flag, false);
}

/**
 * Get all feature flag states as a snapshot.
 * Useful for logging and status display.
 */
export function getAllFlags(): Record<FeatureFlag, boolean> {
    const config = vscode.workspace.getConfiguration(CONFIG_SECTION);
    return {
        coordinator: config.get<boolean>('coordinator', false),
        dream:       config.get<boolean>('dream', false),
        deepPlan:    config.get<boolean>('deepPlan', false),
        proactive:   config.get<boolean>('proactive', false),
    };
}

/**
 * Guard that throws if a feature is not enabled.
 * Use at the top of command handlers gated behind experimental flags.
 *
 * @example
 * ```ts
 * requireFeature('coordinator');
 * // ... coordinator logic — only reached if flag is on
 * ```
 */
export function requireFeature(flag: FeatureFlag): void {
    if (!isFeatureEnabled(flag)) {
        const msg = `This feature requires enabling "junai.experimental.${flag}" in settings.`;
        vscode.window.showWarningMessage(msg);
        throw new Error(msg);
    }
}
```

### Step 3: Wire feature flags into extension.ts

Open `E:\Projects\junai-vscode\src\extension.ts`. Add this import at the top of the file, after the existing imports:

```typescript
import { getAllFlags } from './featureFlags';
```

In the `cmdStatus()` function, after the existing status lines that print Mode/Initialized/Version, add feature flag display:

```typescript
const flags = getAllFlags();
channel.appendLine(`  Flags       : coordinator=${flags.coordinator} dream=${flags.dream} deepPlan=${flags.deepPlan} proactive=${flags.proactive}`);
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] Running `junai: Show Pipeline Status` displays the four feature flags with their boolean values
- [ ] Setting `"junai.experimental.coordinator": true` in workspace settings changes the displayed value
- [ ] All four flags default to `false`

### Commit

```bash
git add src/featureFlags.ts package.json src/extension.ts
git commit -m "feat(flags): add experimental feature flag infrastructure"
```

---

## Task 2: Risk-Tiered Permissions Module

**Objective:** Classify actions into Low/Medium/High risk tiers and provide a guard function that autopilot mode uses to decide whether to proceed, prompt, or block.

### Files

- **Create:** `src/permissions.ts`
- **Modify:** `src/extension.ts` (import for status display)

### Step 1: Create the permissions module

Create `E:\Projects\junai-vscode\src\permissions.ts`:

```typescript
import * as vscode from 'vscode';

// ─────────────────────────────────────────────────────────────
// Risk tiers
// ─────────────────────────────────────────────────────────────

export type RiskTier = 'low' | 'medium' | 'high';

export interface ActionClassification {
    action: string;
    tier: RiskTier;
    description: string;
}

/**
 * Static risk classification table.
 * Agents and the autopilot watcher use this to decide behaviour:
 *   low    → proceed silently
 *   medium → proceed but log prominently
 *   high   → require explicit user approval (even in autopilot)
 */
const ACTION_CLASSIFICATIONS: ActionClassification[] = [
    // Low — read-only, reversible, or minimal impact
    { action: 'read_file',           tier: 'low',    description: 'Read a file' },
    { action: 'search_workspace',    tier: 'low',    description: 'Search workspace content' },
    { action: 'git_status',          tier: 'low',    description: 'Check git status' },
    { action: 'run_tests',           tier: 'low',    description: 'Execute test suite' },
    { action: 'lint_check',          tier: 'low',    description: 'Run linter' },

    // Medium — modifies files but is recoverable
    { action: 'edit_file',           tier: 'medium', description: 'Edit a file' },
    { action: 'create_file',         tier: 'medium', description: 'Create a new file' },
    { action: 'git_commit',          tier: 'medium', description: 'Commit staged changes' },
    { action: 'install_dependency',  tier: 'medium', description: 'Install a package dependency' },
    { action: 'run_build',           tier: 'medium', description: 'Run build command' },

    // High — destructive, external, or hard to reverse
    { action: 'delete_file',         tier: 'high',   description: 'Delete a file' },
    { action: 'git_push',            tier: 'high',   description: 'Push commits to remote' },
    { action: 'git_force_push',      tier: 'high',   description: 'Force-push to remote' },
    { action: 'git_reset_hard',      tier: 'high',   description: 'Hard reset git history' },
    { action: 'drop_table',          tier: 'high',   description: 'Drop a database table' },
    { action: 'run_destructive_cmd', tier: 'high',   description: 'Run a potentially destructive shell command' },
    { action: 'publish_package',     tier: 'high',   description: 'Publish a package to registry' },
    { action: 'send_external_msg',   tier: 'high',   description: 'Send message to external service (PR comment, Slack, etc.)' },
];

const classificationMap = new Map(ACTION_CLASSIFICATIONS.map(c => [c.action, c]));

// ─────────────────────────────────────────────────────────────
// Protected paths
// ─────────────────────────────────────────────────────────────

/**
 * Glob patterns for files that should always require explicit approval
 * before modification, regardless of the action's base risk tier.
 * Matched against workspace-relative paths.
 */
const PROTECTED_PATH_PATTERNS: string[] = [
    '.github/pipeline-state.json',
    '.env',
    '.env.*',
    '**/secrets/**',
    '**/credentials/**',
    'package.json',
    'package-lock.json',
    'tsconfig.json',
    '.github/project-config.md',
];

/**
 * Check if a file path matches any protected pattern.
 * Uses simple glob matching (VS Code's minimatch is available via the API).
 */
export function isProtectedPath(relativePath: string): boolean {
    // Normalize separators
    const normalized = relativePath.replace(/\\/g, '/');
    for (const pattern of PROTECTED_PATH_PATTERNS) {
        if (matchGlob(normalized, pattern)) {
            return true;
        }
    }
    return false;
}

/**
 * Simple glob matcher supporting * and ** patterns.
 * For production use, consider importing minimatch — but for the initial
 * set of patterns (no complex negations), this covers the cases.
 */
function matchGlob(filePath: string, pattern: string): boolean {
    // Exact match
    if (filePath === pattern) { return true; }

    // Convert glob to regex
    const regexStr = pattern
        .replace(/\./g, '\\.')
        .replace(/\*\*/g, '⦿')       // placeholder for **
        .replace(/\*/g, '[^/]*')      // * = anything except /
        .replace(/⦿/g, '.*');         // ** = anything including /
    return new RegExp(`^${regexStr}$`).test(filePath);
}

// ─────────────────────────────────────────────────────────────
// Permission checks
// ─────────────────────────────────────────────────────────────

export interface PermissionResult {
    allowed: boolean;
    tier: RiskTier;
    reason: string;
    requiresApproval: boolean;
}

/**
 * Evaluate whether an action should be allowed in the current pipeline mode.
 *
 * @param action    - The action identifier (must match a key in ACTION_CLASSIFICATIONS)
 * @param mode      - Current pipeline mode ('supervised' | 'assisted' | 'autopilot')
 * @param filePath  - Optional workspace-relative path for file operations
 *
 * Behaviour by mode:
 *   supervised → everything requires approval (medium + high block, low proceeds)
 *   assisted   → low + medium proceed, high requires approval
 *   autopilot  → low + medium proceed, high requires approval
 *
 * Protected paths escalate any action to high tier.
 */
export function checkPermission(
    action: string,
    mode: string,
    filePath?: string,
): PermissionResult {
    const classification = classificationMap.get(action);
    let tier: RiskTier = classification?.tier ?? 'medium';

    // Escalate if targeting a protected path
    if (filePath && isProtectedPath(filePath)) {
        tier = 'high';
    }

    switch (mode) {
        case 'supervised':
            return {
                allowed: tier === 'low',
                tier,
                reason: tier === 'low'
                    ? 'Low-risk action — proceeding'
                    : `Supervised mode — ${tier}-risk action requires manual approval`,
                requiresApproval: tier !== 'low',
            };

        case 'assisted':
        case 'autopilot':
            return {
                allowed: tier !== 'high',
                tier,
                reason: tier === 'high'
                    ? `High-risk action requires explicit approval even in ${mode} mode`
                    : `${tier}-risk action — proceeding in ${mode} mode`,
                requiresApproval: tier === 'high',
            };

        default:
            // Unknown mode — treat as supervised (safest default)
            return {
                allowed: tier === 'low',
                tier,
                reason: `Unknown mode "${mode}" — defaulting to supervised behaviour`,
                requiresApproval: tier !== 'low',
            };
    }
}

/**
 * Get the classification for a specific action.
 * Returns undefined if the action is not in the static table.
 */
export function getActionClassification(action: string): ActionClassification | undefined {
    return classificationMap.get(action);
}

/**
 * Get all action classifications — useful for status display / documentation.
 */
export function getAllClassifications(): readonly ActionClassification[] {
    return ACTION_CLASSIFICATIONS;
}
```

### Step 2: Wire permissions into extension.ts status display

Open `E:\Projects\junai-vscode\src\extension.ts`. Add this import at the top, near the other new import:

```typescript
import { getAllClassifications } from './permissions';
```

In `cmdStatus()`, after the feature flags line added in Task 1, add:

```typescript
const classifications = getAllClassifications();
const highCount = classifications.filter(c => c.tier === 'high').length;
const medCount  = classifications.filter(c => c.tier === 'medium').length;
const lowCount  = classifications.filter(c => c.tier === 'low').length;
channel.appendLine(`  Permissions : ${lowCount} low / ${medCount} medium / ${highCount} high risk actions classified`);
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] `checkPermission('read_file', 'autopilot')` returns `{ allowed: true, tier: 'low', requiresApproval: false, ... }`
- [ ] `checkPermission('git_push', 'autopilot')` returns `{ allowed: false, tier: 'high', requiresApproval: true, ... }`
- [ ] `checkPermission('edit_file', 'autopilot', '.env')` escalates to high tier due to protected path
- [ ] `checkPermission('edit_file', 'supervised')` returns `{ allowed: false, requiresApproval: true }` (medium in supervised = blocked)
- [ ] `junai: Show Pipeline Status` displays the permission counts
- [ ] `isProtectedPath('src/main.ts')` returns `false`
- [ ] `isProtectedPath('.github/pipeline-state.json')` returns `true`

### Commit

```bash
git add src/permissions.ts src/extension.ts
git commit -m "feat(permissions): add risk-tiered action classification and protected paths"
```

---

## Task 3: Event Bus Module

**Objective:** Create a typed pub/sub event bus that pipeline components can use to emit and listen for events — task completion, approval requests, background results, and blocked states.

### Files

- **Create:** `src/eventBus.ts`
- **Modify:** `src/extension.ts` (import, initialize, wire into autopilot watcher)

### Step 1: Create the event bus module

Create `E:\Projects\junai-vscode\src\eventBus.ts`:

```typescript
import { EventEmitter } from 'events';

// ─────────────────────────────────────────────────────────────
// Event types
// ─────────────────────────────────────────────────────────────

export interface PipelineEvent {
    /** ISO 8601 timestamp */
    timestamp: string;
    /** Source component that emitted the event */
    source: string;
}

export interface TaskCompletedEvent extends PipelineEvent {
    type: 'task-completed';
    stage: string;
    agent: string;
    summary: string;
}

export interface TaskBlockedEvent extends PipelineEvent {
    type: 'task-blocked';
    stage: string;
    agent: string;
    reason: string;
}

export interface ApprovalNeededEvent extends PipelineEvent {
    type: 'approval-needed';
    stage: string;
    agent: string;
    action: string;
    riskTier: string;
}

export interface BackgroundResultEvent extends PipelineEvent {
    type: 'background-result';
    taskId: string;
    status: 'success' | 'failure';
    summary: string;
}

export interface MemoryConsolidatedEvent extends PipelineEvent {
    type: 'memory-consolidated';
    itemsPruned: number;
    itemsPromoted: number;
}

export type JunaiEvent =
    | TaskCompletedEvent
    | TaskBlockedEvent
    | ApprovalNeededEvent
    | BackgroundResultEvent
    | MemoryConsolidatedEvent;

export type JunaiEventType = JunaiEvent['type'];

// ─────────────────────────────────────────────────────────────
// Typed event bus
// ─────────────────────────────────────────────────────────────

type EventHandler<T extends JunaiEvent> = (event: T) => void;

// Map event type strings to their corresponding event interfaces
type EventTypeMap = {
    'task-completed':       TaskCompletedEvent;
    'task-blocked':         TaskBlockedEvent;
    'approval-needed':      ApprovalNeededEvent;
    'background-result':    BackgroundResultEvent;
    'memory-consolidated':  MemoryConsolidatedEvent;
};

/**
 * Typed event bus for junai pipeline events.
 *
 * Usage:
 * ```ts
 * const bus = JunaiEventBus.getInstance();
 *
 * // Subscribe
 * bus.on('task-completed', (event) => {
 *     console.log(`${event.agent} finished ${event.stage}`);
 * });
 *
 * // Emit
 * bus.emit({
 *     type: 'task-completed',
 *     timestamp: new Date().toISOString(),
 *     source: 'autopilot-watcher',
 *     stage: 'implement',
 *     agent: 'Implement',
 *     summary: 'Feature X implemented',
 * });
 * ```
 */
export class JunaiEventBus {
    private static instance: JunaiEventBus | null = null;
    private emitter = new EventEmitter();
    private eventLog: JunaiEvent[] = [];
    private maxLogSize = 100;

    private constructor() {
        // Increase max listeners — multiple consumers per event type is expected
        this.emitter.setMaxListeners(50);
    }

    static getInstance(): JunaiEventBus {
        if (!JunaiEventBus.instance) {
            JunaiEventBus.instance = new JunaiEventBus();
        }
        return JunaiEventBus.instance;
    }

    /**
     * Subscribe to a specific event type.
     * Returns a disposable function to unsubscribe.
     */
    on<K extends JunaiEventType>(
        eventType: K,
        handler: EventHandler<EventTypeMap[K]>,
    ): () => void {
        this.emitter.on(eventType, handler as (...args: unknown[]) => void);
        return () => {
            this.emitter.off(eventType, handler as (...args: unknown[]) => void);
        };
    }

    /**
     * Subscribe to ALL event types (useful for logging / status display).
     * Returns a disposable function to unsubscribe.
     */
    onAny(handler: (event: JunaiEvent) => void): () => void {
        const wrapper = (event: JunaiEvent) => handler(event);
        this.emitter.on('*', wrapper);
        return () => { this.emitter.off('*', wrapper); };
    }

    /**
     * Emit an event. Dispatches to type-specific listeners AND the wildcard '*' listener.
     */
    emit(event: JunaiEvent): void {
        // Add to rolling log
        this.eventLog.push(event);
        if (this.eventLog.length > this.maxLogSize) {
            this.eventLog.shift();
        }

        // Type-specific dispatch
        this.emitter.emit(event.type, event);
        // Wildcard dispatch
        this.emitter.emit('*', event);
    }

    /**
     * Get recent events (most recent first).
     */
    getRecentEvents(count: number = 10): readonly JunaiEvent[] {
        return this.eventLog.slice(-count).reverse();
    }

    /**
     * Clear all listeners and the event log.
     * Call during extension deactivation.
     */
    dispose(): void {
        this.emitter.removeAllListeners();
        this.eventLog = [];
        JunaiEventBus.instance = null;
    }
}
```

### Step 2: Wire event bus into extension.ts

Open `E:\Projects\junai-vscode\src\extension.ts`. Add this import at the top:

```typescript
import { JunaiEventBus } from './eventBus';
```

In the `activate()` function, after `startAutopilotWatcher(context);`, add:

```typescript
// Initialize event bus — consumers can subscribe via JunaiEventBus.getInstance()
const eventBus = JunaiEventBus.getInstance();

// Log all events to the output channel for debugging
const outputChannel = vscode.window.createOutputChannel('junai Events');
context.subscriptions.push({ dispose: () => { eventBus.dispose(); outputChannel.dispose(); } });

eventBus.onAny((event) => {
    outputChannel.appendLine(`[${event.timestamp}] ${event.type} from ${event.source}: ${JSON.stringify(event)}`);
});
```

In the `deactivate()` function, add cleanup:

```typescript
export function deactivate() {
    JunaiEventBus.getInstance().dispose();
}
```

### Step 3: Emit events from the autopilot watcher

In `extension.ts`, inside the `startAutopilotWatcher` function, find the section where a successful routing is logged (the line containing `✓ Opened @${targetAgent}`). After that `channel.appendLine` call, add an event emission:

```typescript
JunaiEventBus.getInstance().emit({
    type: 'task-completed',
    timestamp: new Date().toISOString(),
    source: 'autopilot-watcher',
    stage,
    agent: targetAgent,
    summary: `Routed to @${targetAgent} for stage: ${stage}`,
});
```

Also find where the pipeline reaches closed state (the line containing `Pipeline reached closed state`). After that `channel.appendLine`, add:

```typescript
JunaiEventBus.getInstance().emit({
    type: 'task-completed',
    timestamp: new Date().toISOString(),
    source: 'autopilot-watcher',
    stage: 'pipeline-closed',
    agent: 'none',
    summary: `Pipeline closed — ${state.feature ?? 'feature'} complete`,
});
```

### Step 4: Add event count to status display

In `cmdStatus()`, after the permissions line added in Task 2, add:

```typescript
const recentEvents = JunaiEventBus.getInstance().getRecentEvents(5);
channel.appendLine(`  Events      : ${recentEvents.length} recent events in log`);
if (recentEvents.length > 0) {
    for (const evt of recentEvents) {
        channel.appendLine(`    • [${evt.type}] ${evt.source} — ${evt.timestamp}`);
    }
}
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] `JunaiEventBus.getInstance()` returns the same instance on repeated calls (singleton)
- [ ] Subscribing to `'task-completed'` and emitting a `TaskCompletedEvent` triggers the handler
- [ ] The `onAny` wildcard handler receives events of all types
- [ ] `getRecentEvents()` returns events in most-recent-first order
- [ ] The rolling log never exceeds 100 entries (oldest are evicted)
- [ ] `dispose()` clears all listeners and resets the singleton
- [ ] `junai: Show Pipeline Status` displays recent event count and list
- [ ] The "junai Events" output channel shows events when the autopilot watcher fires
- [ ] `deactivate()` properly cleans up the event bus

### Commit

```bash
git add src/eventBus.ts src/extension.ts
git commit -m "feat(events): add typed event bus with rolling log and autopilot integration"
```

---

## Task 4: Integration Verification & Final Commit

**Objective:** Verify all three modules work together and the extension compiles, loads, and runs correctly.

### Files

- **Verify:** `src/extension.ts`, `src/featureFlags.ts`, `src/permissions.ts`, `src/eventBus.ts`
- **Verify:** `package.json`

### Step 1: Full compile check

```bash
cd E:\Projects\junai-vscode
npm run compile
```

Expected: zero errors, zero warnings.

### Step 2: Verify module structure

After Task 1-3, the `src/` directory should contain:

```
src/
├── extension.ts      # Modified — imports from the three new modules
├── featureFlags.ts   # NEW — experimental flag checks
├── permissions.ts    # NEW — risk tiers + protected paths
└── eventBus.ts       # NEW — typed pub/sub
```

### Step 3: Verify extension.ts imports

The top of `extension.ts` should now include these three new imports (order doesn't matter):

```typescript
import { getAllFlags } from './featureFlags';
import { getAllClassifications } from './permissions';
import { JunaiEventBus } from './eventBus';
```

### Step 4: Verify cmdStatus output format

Running `junai: Show Pipeline Status` should produce output like:

```
─── junai Pipeline Status ───────────────────
  Mode        : supervised
  Initialized : 2026-04-01T...
  Version     : 1.0.0
  Flags       : coordinator=false dream=false deepPlan=false proactive=false
  Permissions : 5 low / 5 medium / 8 high risk actions classified
  Events      : 0 recent events in log
─────────────────────────────────────────────
```

### Step 5: Smoke test feature flag toggle

1. Open VS Code Settings (Ctrl+,)
2. Search for `junai.experimental`
3. Toggle `coordinator` to `true`
4. Run `junai: Show Pipeline Status`
5. Verify output shows `coordinator=true`

### Step 6: Package test

```bash
npm run package
```

Expected: produces a `.vsix` file without errors.

### Acceptance Criteria — Phase 1 complete when ALL pass

- [ ] `npm run compile` → zero errors
- [ ] `npm run package` → produces .vsix successfully
- [ ] `src/` contains exactly 4 `.ts` files (extension + 3 new modules)
- [ ] `package.json` has 4 new `junai.experimental.*` boolean configurations
- [ ] Feature flags display correctly in status output
- [ ] Permission counts display correctly in status output
- [ ] Event log displays correctly in status output
- [ ] Toggling a feature flag in settings changes the status output
- [ ] No existing commands or functionality are broken
- [ ] Extension activates without errors in the Extension Host

### Final Commit

```bash
git add -A
git commit -m "feat(phase1): complete core foundation — feature flags, permissions, event bus"
```

---

## Source Document Traceability

| Requirement | Source | Plan Task | Status |
|-------------|--------|-----------|--------|
| Feature flags for coordinator/dream/deepPlan/proactive | Roadmap Phase 1, item 1 | Task 1 | ✅ Covered |
| Risk-tiered permissions (Low/Medium/High) | Roadmap Phase 1, item 2 | Task 2 | ✅ Covered |
| Protected files and commands | Roadmap Phase 1, item 2 | Task 2 (PROTECTED_PATH_PATTERNS) | ✅ Covered |
| Stronger autopilot boundaries | Roadmap Phase 1, item 2 | Task 2 (checkPermission with mode) | ✅ Covered |
| Event bus: task-completed | Roadmap Phase 1, item 3 | Task 3 (TaskCompletedEvent) | ✅ Covered |
| Event bus: blocked | Roadmap Phase 1, item 3 | Task 3 (TaskBlockedEvent) | ✅ Covered |
| Event bus: approval-needed | Roadmap Phase 1, item 3 | Task 3 (ApprovalNeededEvent) | ✅ Covered |
| Event bus: background-result-ready | Roadmap Phase 1, item 3 | Task 3 (BackgroundResultEvent) | ✅ Covered |
| Exit gate: flags work end-to-end | Roadmap Phase 1 exit gate | Task 4 Step 5 | ✅ Covered |
| Exit gate: risky ops can be classified and gated | Roadmap Phase 1 exit gate | Task 2 acceptance criteria | ✅ Covered |
| Exit gate: background events emitted and surfaced | Roadmap Phase 1 exit gate | Task 3 Step 3 + Task 4 | ✅ Covered |
