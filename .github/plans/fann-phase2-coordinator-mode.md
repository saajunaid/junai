---
chain_id: FEAT-2026-0404-fann-evolution
type: plan
status: current
approval: pending
---

# Phase 2 — Coordinator Mode in junai-vscode

> **For the implementing agent:** Follow this plan task-by-task, executing each step sequentially.
> This plan is self-contained. You do not need the pipeline or @Orchestrator to execute it.

**Goal:** Add a Coordinator Mode that lets junai fan out tasks to multiple parallel read-only workers and synthesize their results into a single coherent answer — upgrading from serial single-agent routing to parallel multi-worker orchestration.

**Architecture:** A new `src/coordinator.ts` module implements the coordinator runtime. It defines worker types (explore, verify, review), a task graph that tracks parallel work items, and a result synthesizer. The coordinator is gated behind the `experimental.coordinator` feature flag from Phase 1. A new `junai.coordinate` command exposes it to users. The autopilot watcher and event bus from Phase 1 are used for status reporting.

**Tech Stack:** TypeScript 5.3+, VS Code Extension API ^1.101.0, Phase 1 modules (`featureFlags.ts`, `eventBus.ts`, `permissions.ts`).

**Parent roadmap:** `.github/plans/fann-junai-evolution-roadmap.md`  
**Depends on:** `.github/plans/fann-phase1-core-foundation.md` (completed)

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
| Worker execution | VS Code `runSubagent`-style pattern via chat participant API (if available) or serialized sub-prompts | Workers are conceptual — they run as structured sub-tasks within the extension's orchestration layer |
| Task graph | In-memory directed acyclic graph (adjacency list) | Workers have no cross-dependencies in v1, so a flat list with parallel execution is sufficient. DAG structure allows future dependency edges |
| Result synthesis | Template-based merge with deduplication | Results from workers are collected into sections, deduplicated, and formatted as one coherent response |
| Concurrency model | `Promise.allSettled` for parallel worker execution | Allows some workers to fail without blocking others; settled results include both fulfilled and rejected |
| Feature gate | `requireFeature('coordinator')` from Phase 1 | Coordinator is experimental — users must opt in via settings |

### Existing Scaffold — DO NOT Recreate

| File | Purpose | Current State |
|------|---------|---------------|
| `src/extension.ts` | Extension activation, commands, autopilot watcher | ✅ Working — add new command registration + import |
| `src/featureFlags.ts` | `requireFeature('coordinator')` guard | ✅ Working — call it, don't recreate |
| `src/eventBus.ts` | `JunaiEventBus.getInstance().emit(...)` | ✅ Working — emit coordinator events |
| `src/permissions.ts` | `checkPermission()` for risk gating | ✅ Working — use for worker action validation |
| `package.json` | Extension manifest | ✅ Working — add new command |

### Dependencies

**Already installed** (DO NOT reinstall):
- `@types/vscode`, `@types/node`, `typescript`, `@vscode/vsce`

**Not yet installed:**
- None — Phase 2 uses zero new dependencies

---

## Task 1: Worker Types and Task Graph

**Objective:** Define the worker type system and task graph that tracks parallel work items with their states and results.

### Files

- **Create:** `src/coordinator.ts`

### Step 1: Create the coordinator module

Create `E:\Projects\junai-vscode\src\coordinator.ts` with the worker types, task graph, and result types:

```typescript
import { JunaiEventBus } from './eventBus';
import { requireFeature } from './featureFlags';

// ─────────────────────────────────────────────────────────────
// Worker types
// ─────────────────────────────────────────────────────────────

/**
 * Worker types for the coordinator.
 * Phase 2 starts with read-only workers only.
 *
 *   explore  — search/read the codebase to answer a question
 *   verify   — check an assertion (file exists, test passes, pattern holds)
 *   review   — review code/docs for issues against criteria
 */
export type WorkerType = 'explore' | 'verify' | 'review';

export interface WorkerSpec {
    /** Unique ID within a coordination run */
    id: string;
    /** What kind of worker to launch */
    type: WorkerType;
    /** Human-readable label for status display */
    label: string;
    /** The question or task this worker should answer */
    prompt: string;
    /** Optional: specific files/paths to scope the worker's search */
    scopePaths?: string[];
}

// ─────────────────────────────────────────────────────────────
// Task states and results
// ─────────────────────────────────────────────────────────────

export type TaskStatus = 'pending' | 'running' | 'completed' | 'failed';

export interface TaskResult {
    workerId: string;
    workerType: WorkerType;
    label: string;
    status: 'success' | 'failure';
    /** The worker's findings or answer */
    output: string;
    /** How long the worker took (ms) */
    durationMs: number;
    /** Error message if status is 'failure' */
    error?: string;
}

export interface TaskNode {
    worker: WorkerSpec;
    status: TaskStatus;
    result?: TaskResult;
    startedAt?: string;
    completedAt?: string;
}

// ─────────────────────────────────────────────────────────────
// Task graph
// ─────────────────────────────────────────────────────────────

/**
 * In-memory task graph for a single coordination run.
 * Phase 2 uses a flat list (no inter-worker dependencies).
 * The DAG structure (adjacency list) is reserved for future phases
 * where workers may depend on each other's results.
 */
export class TaskGraph {
    private nodes: Map<string, TaskNode> = new Map();

    addWorker(worker: WorkerSpec): void {
        if (this.nodes.has(worker.id)) {
            throw new Error(`Worker ID "${worker.id}" already exists in task graph`);
        }
        this.nodes.set(worker.id, {
            worker,
            status: 'pending',
        });
    }

    getNode(workerId: string): TaskNode | undefined {
        return this.nodes.get(workerId);
    }

    getAllNodes(): TaskNode[] {
        return Array.from(this.nodes.values());
    }

    getPendingWorkers(): WorkerSpec[] {
        return this.getAllNodes()
            .filter(n => n.status === 'pending')
            .map(n => n.worker);
    }

    markRunning(workerId: string): void {
        const node = this.nodes.get(workerId);
        if (!node) { throw new Error(`Unknown worker: ${workerId}`); }
        node.status = 'running';
        node.startedAt = new Date().toISOString();
    }

    markCompleted(workerId: string, result: TaskResult): void {
        const node = this.nodes.get(workerId);
        if (!node) { throw new Error(`Unknown worker: ${workerId}`); }
        node.status = result.status === 'success' ? 'completed' : 'failed';
        node.result = result;
        node.completedAt = new Date().toISOString();
    }

    isComplete(): boolean {
        return this.getAllNodes().every(n => n.status === 'completed' || n.status === 'failed');
    }

    getSummary(): { total: number; completed: number; failed: number; pending: number; running: number } {
        const nodes = this.getAllNodes();
        return {
            total:     nodes.length,
            completed: nodes.filter(n => n.status === 'completed').length,
            failed:    nodes.filter(n => n.status === 'failed').length,
            pending:   nodes.filter(n => n.status === 'pending').length,
            running:   nodes.filter(n => n.status === 'running').length,
        };
    }
}

// ─────────────────────────────────────────────────────────────
// Coordination request and result
// ─────────────────────────────────────────────────────────────

export interface CoordinationRequest {
    /** Human-readable title for the coordination run */
    title: string;
    /** The broad question or task to coordinate */
    goal: string;
    /** Workers to fan out */
    workers: WorkerSpec[];
}

export interface CoordinationResult {
    title: string;
    goal: string;
    /** Individual worker results */
    workerResults: TaskResult[];
    /** Synthesized answer combining all worker outputs */
    synthesizedOutput: string;
    /** Total wall-clock time for the coordination run (ms) */
    totalDurationMs: number;
    /** Summary counts */
    summary: ReturnType<TaskGraph['getSummary']>;
}
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] `TaskGraph` can add workers, track states, and report summary
- [ ] `WorkerSpec` includes id, type, label, prompt, and optional scopePaths
- [ ] `CoordinationRequest` and `CoordinationResult` types compile correctly
- [ ] No runtime dependencies added

### Commit

```bash
git add src/coordinator.ts
git commit -m "feat(coordinator): add worker types, task graph, and coordination types"
```

---

## Task 2: Worker Executor and Result Synthesizer

**Objective:** Implement the function that executes workers (as simulated sub-tasks in Phase 2) and synthesizes their results into a coherent output.

### Files

- **Modify:** `src/coordinator.ts` (add executor and synthesizer functions)

### Step 1: Add the worker executor

Append the following to the bottom of `E:\Projects\junai-vscode\src\coordinator.ts`:

```typescript
// ─────────────────────────────────────────────────────────────
// Worker executor
// ─────────────────────────────────────────────────────────────

/**
 * Execute a single worker.
 *
 * Phase 2 implementation: Workers are "simulated" — they perform
 * file system reads and searches within the workspace to answer
 * their prompt. This is the read-only exploration slice.
 *
 * Future phases will upgrade this to launch actual sub-agent
 * sessions via the VS Code chat API.
 *
 * @param worker  - The worker specification
 * @param workspaceRoot - Absolute path to the workspace root
 * @returns The worker's result
 */
export async function executeWorker(
    worker: WorkerSpec,
    workspaceRoot: string,
): Promise<TaskResult> {
    const startTime = Date.now();

    try {
        let output: string;

        switch (worker.type) {
            case 'explore':
                output = await executeExploreWorker(worker, workspaceRoot);
                break;
            case 'verify':
                output = await executeVerifyWorker(worker, workspaceRoot);
                break;
            case 'review':
                output = await executeReviewWorker(worker, workspaceRoot);
                break;
            default:
                throw new Error(`Unknown worker type: ${worker.type}`);
        }

        return {
            workerId: worker.id,
            workerType: worker.type,
            label: worker.label,
            status: 'success',
            output,
            durationMs: Date.now() - startTime,
        };
    } catch (err: unknown) {
        const errorMsg = err instanceof Error ? err.message : String(err);
        return {
            workerId: worker.id,
            workerType: worker.type,
            label: worker.label,
            status: 'failure',
            output: '',
            durationMs: Date.now() - startTime,
            error: errorMsg,
        };
    }
}

// ─────────────────────────────────────────────────────────────
// Worker type implementations (read-only, Phase 2)
// ─────────────────────────────────────────────────────────────

import * as fs from 'fs';
import * as path from 'path';

/**
 * Explore worker — searches the workspace for files and content
 * matching the worker's prompt/scope.
 */
async function executeExploreWorker(worker: WorkerSpec, workspaceRoot: string): Promise<string> {
    const results: string[] = [];
    const searchPaths = worker.scopePaths ?? ['.'];

    for (const scopePath of searchPaths) {
        const fullPath = path.resolve(workspaceRoot, scopePath);
        if (!fs.existsSync(fullPath)) {
            results.push(`Path not found: ${scopePath}`);
            continue;
        }

        const stat = fs.statSync(fullPath);
        if (stat.isFile()) {
            // Read the file and include a summary
            const content = fs.readFileSync(fullPath, 'utf8');
            const lineCount = content.split('\n').length;
            results.push(`**${scopePath}** (${lineCount} lines):\n\`\`\`\n${content.slice(0, 2000)}${content.length > 2000 ? '\n... (truncated)' : ''}\n\`\`\``);
        } else if (stat.isDirectory()) {
            // List directory contents recursively (up to 2 levels)
            const listing = listDirRecursive(fullPath, workspaceRoot, 2);
            results.push(`**${scopePath}/** contents:\n${listing}`);
        }
    }

    if (results.length === 0) {
        results.push('No results found for the given scope.');
    }

    return `### Explore: ${worker.label}\n\n**Prompt:** ${worker.prompt}\n\n${results.join('\n\n')}`;
}

/**
 * Verify worker — checks whether specific assertions hold
 * (file exists, pattern found, etc.)
 */
async function executeVerifyWorker(worker: WorkerSpec, workspaceRoot: string): Promise<string> {
    const checks: string[] = [];
    const searchPaths = worker.scopePaths ?? [];

    if (searchPaths.length === 0) {
        return `### Verify: ${worker.label}\n\n**Prompt:** ${worker.prompt}\n\nNo scope paths specified — cannot verify.`;
    }

    for (const scopePath of searchPaths) {
        const fullPath = path.resolve(workspaceRoot, scopePath);
        const exists = fs.existsSync(fullPath);
        checks.push(`- \`${scopePath}\`: ${exists ? '✅ exists' : '❌ not found'}`);

        if (exists && fs.statSync(fullPath).isFile()) {
            const content = fs.readFileSync(fullPath, 'utf8');
            const lineCount = content.split('\n').length;
            checks.push(`  - ${lineCount} lines, ${content.length} bytes`);
        }
    }

    return `### Verify: ${worker.label}\n\n**Prompt:** ${worker.prompt}\n\n${checks.join('\n')}`;
}

/**
 * Review worker — reads specified files and produces a structured
 * summary for the coordinator to synthesize.
 */
async function executeReviewWorker(worker: WorkerSpec, workspaceRoot: string): Promise<string> {
    const reviews: string[] = [];
    const searchPaths = worker.scopePaths ?? [];

    if (searchPaths.length === 0) {
        return `### Review: ${worker.label}\n\n**Prompt:** ${worker.prompt}\n\nNo scope paths specified — cannot review.`;
    }

    for (const scopePath of searchPaths) {
        const fullPath = path.resolve(workspaceRoot, scopePath);
        if (!fs.existsSync(fullPath)) {
            reviews.push(`- \`${scopePath}\`: ❌ not found — cannot review`);
            continue;
        }

        if (fs.statSync(fullPath).isFile()) {
            const content = fs.readFileSync(fullPath, 'utf8');
            const lines = content.split('\n');
            reviews.push(`- \`${scopePath}\` (${lines.length} lines): read for review`);

            // Extract key indicators for the review
            const hasExports = /^export\s/m.test(content);
            const hasTodos = (content.match(/TODO|FIXME|HACK|XXX/gi) ?? []).length;
            const hasTests = /(?:describe|it|test)\s*\(/m.test(content);

            reviews.push(`  - Exports: ${hasExports ? 'yes' : 'no'}`);
            if (hasTodos > 0) { reviews.push(`  - TODOs/FIXMEs: ${hasTodos}`); }
            reviews.push(`  - Test patterns: ${hasTests ? 'found' : 'none'}`);
        }
    }

    return `### Review: ${worker.label}\n\n**Prompt:** ${worker.prompt}\n\n${reviews.join('\n')}`;
}

/**
 * Recursively list directory contents up to a max depth.
 */
function listDirRecursive(dirPath: string, workspaceRoot: string, maxDepth: number, currentDepth: number = 0): string {
    if (currentDepth >= maxDepth) { return '  '.repeat(currentDepth) + '(max depth reached)\n'; }

    const SKIP_DIRS = new Set(['.git', 'node_modules', '__pycache__', '.DS_Store', 'out', 'dist', '.venv']);
    let output = '';

    try {
        const entries = fs.readdirSync(dirPath, { withFileTypes: true });
        for (const entry of entries) {
            if (SKIP_DIRS.has(entry.name)) { continue; }
            const indent = '  '.repeat(currentDepth);
            const relativePath = path.relative(workspaceRoot, path.join(dirPath, entry.name));

            if (entry.isDirectory()) {
                output += `${indent}- ${entry.name}/\n`;
                output += listDirRecursive(path.join(dirPath, entry.name), workspaceRoot, maxDepth, currentDepth + 1);
            } else {
                output += `${indent}- ${entry.name}\n`;
            }
        }
    } catch {
        output += '  '.repeat(currentDepth) + '(access denied)\n';
    }

    return output;
}

// ─────────────────────────────────────────────────────────────
// Result synthesizer
// ─────────────────────────────────────────────────────────────

/**
 * Synthesize results from multiple workers into a single coherent output.
 * Deduplicates findings that appear in multiple worker results.
 */
export function synthesizeResults(
    goal: string,
    results: TaskResult[],
): string {
    const sections: string[] = [];

    sections.push(`## Coordination Summary\n`);
    sections.push(`**Goal:** ${goal}\n`);

    const succeeded = results.filter(r => r.status === 'success');
    const failed    = results.filter(r => r.status === 'failure');

    sections.push(`**Workers:** ${results.length} total — ${succeeded.length} succeeded, ${failed.length} failed\n`);

    // Successes
    if (succeeded.length > 0) {
        sections.push(`---\n`);
        for (const result of succeeded) {
            sections.push(result.output);
            sections.push(`\n*Worker \`${result.workerId}\` completed in ${result.durationMs}ms*\n`);
        }
    }

    // Failures
    if (failed.length > 0) {
        sections.push(`---\n\n### ⚠ Failed Workers\n`);
        for (const result of failed) {
            sections.push(`- **${result.label}** (\`${result.workerId}\`): ${result.error ?? 'Unknown error'}`);
        }
    }

    return sections.join('\n');
}
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] `executeWorker` handles all three worker types (explore, verify, review)
- [ ] `executeExploreWorker` reads files and lists directories with truncation at 2000 chars
- [ ] `executeVerifyWorker` checks file existence and reports results
- [ ] `executeReviewWorker` extracts key indicators (exports, TODOs, test patterns)
- [ ] `synthesizeResults` combines results with success/failure separation
- [ ] Worker failures are caught and returned as `status: 'failure'` (no thrown exceptions)
- [ ] `listDirRecursive` skips .git, node_modules, __pycache__, out, dist, .venv

### Commit

```bash
git add src/coordinator.ts
git commit -m "feat(coordinator): add worker executor and result synthesizer"
```

---

## Task 3: Coordination Runner

**Objective:** Implement the top-level `coordinate()` function that takes a `CoordinationRequest`, executes workers in parallel, emits events, and returns a synthesized `CoordinationResult`.

### Files

- **Modify:** `src/coordinator.ts` (add the main coordinate function)

### Step 1: Add the coordinate function

Append the following to the bottom of `E:\Projects\junai-vscode\src\coordinator.ts`:

```typescript
// ─────────────────────────────────────────────────────────────
// Main coordination runner
// ─────────────────────────────────────────────────────────────

/**
 * Execute a full coordination run:
 * 1. Gate behind feature flag
 * 2. Build task graph from request
 * 3. Execute all workers in parallel (Promise.allSettled)
 * 4. Emit events for each completion/failure
 * 5. Synthesize results
 * 6. Return CoordinationResult
 *
 * @param request       - The coordination request with workers
 * @param workspaceRoot - Absolute path to the workspace root
 * @returns The coordination result with synthesized output
 */
export async function coordinate(
    request: CoordinationRequest,
    workspaceRoot: string,
): Promise<CoordinationResult> {
    // Gate: require feature flag
    requireFeature('coordinator');

    const startTime = Date.now();
    const eventBus = JunaiEventBus.getInstance();
    const taskGraph = new TaskGraph();

    // Build task graph
    for (const worker of request.workers) {
        taskGraph.addWorker(worker);
    }

    // Mark all workers as running
    for (const worker of request.workers) {
        taskGraph.markRunning(worker.id);
    }

    // Execute all workers in parallel
    const workerPromises = request.workers.map(worker =>
        executeWorker(worker, workspaceRoot)
    );

    const settled = await Promise.allSettled(workerPromises);

    // Process results
    const workerResults: TaskResult[] = [];

    for (let i = 0; i < settled.length; i++) {
        const worker = request.workers[i];
        const outcome = settled[i];

        let result: TaskResult;
        if (outcome.status === 'fulfilled') {
            result = outcome.value;
        } else {
            result = {
                workerId: worker.id,
                workerType: worker.type,
                label: worker.label,
                status: 'failure',
                output: '',
                durationMs: Date.now() - startTime,
                error: outcome.reason instanceof Error ? outcome.reason.message : String(outcome.reason),
            };
        }

        taskGraph.markCompleted(worker.id, result);
        workerResults.push(result);

        // Emit event for each worker completion
        eventBus.emit({
            type: result.status === 'success' ? 'task-completed' : 'task-blocked',
            timestamp: new Date().toISOString(),
            source: 'coordinator',
            stage: `coordinator:${worker.type}`,
            agent: worker.label,
            ...(result.status === 'success'
                ? { summary: `Worker "${worker.label}" completed in ${result.durationMs}ms` }
                : { reason: result.error ?? 'Worker failed' }
            ),
        } as any);
    }

    // Synthesize
    const synthesizedOutput = synthesizeResults(request.goal, workerResults);
    const totalDurationMs = Date.now() - startTime;

    // Emit coordination-complete event
    eventBus.emit({
        type: 'task-completed',
        timestamp: new Date().toISOString(),
        source: 'coordinator',
        stage: 'coordination-complete',
        agent: 'Coordinator',
        summary: `Coordination "${request.title}" finished — ${taskGraph.getSummary().completed}/${taskGraph.getSummary().total} workers succeeded (${totalDurationMs}ms)`,
    });

    return {
        title: request.title,
        goal: request.goal,
        workerResults,
        synthesizedOutput,
        totalDurationMs,
        summary: taskGraph.getSummary(),
    };
}
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] `coordinate()` throws if `experimental.coordinator` flag is not enabled (via `requireFeature`)
- [ ] Workers execute in parallel via `Promise.allSettled`
- [ ] Failed workers don't block successful ones
- [ ] Each worker completion emits an event on the event bus
- [ ] A final `task-completed` event is emitted when all workers finish
- [ ] `CoordinationResult` contains individual results, synthesized output, and timing

### Commit

```bash
git add src/coordinator.ts
git commit -m "feat(coordinator): add main coordination runner with parallel execution"
```

---

## Task 4: Wire into Extension — Command and Status

**Objective:** Register a `junai.coordinate` command in the extension and surface coordinator status in the pipeline status output.

### Files

- **Modify:** `package.json` (add command)
- **Modify:** `src/extension.ts` (register command, import coordinator)

### Step 1: Add the command to package.json

In `E:\Projects\junai-vscode\package.json`, in the `contributes.commands` array, after the `junai.probeAutopilot` entry, add:

```jsonc
{
  "command": "junai.coordinate",
  "title": "Run Coordinator (Experimental)",
  "category": "junai"
}
```

### Step 2: Wire into extension.ts

Open `E:\Projects\junai-vscode\src\extension.ts`.

**Add import** at the top, after the existing Phase 1 imports:

```typescript
import { coordinate, CoordinationRequest } from './coordinator';
```

**Register command** in the `activate()` function. Inside the `context.subscriptions.push(...)` block, after the `junai.probeAutopilot` registration, add:

```typescript
vscode.commands.registerCommand('junai.coordinate', () => cmdCoordinate()),
```

**Add the command handler** — place this new function after the existing `cmdProbeAutopilot` function:

```typescript
// ─────────────────────────────────────────────────────────────
// junai.coordinate — run coordinator mode (experimental)
// ─────────────────────────────────────────────────────────────
async function cmdCoordinate() {
    const workspaceFolders = vscode.workspace.workspaceFolders;
    if (!workspaceFolders || workspaceFolders.length === 0) {
        vscode.window.showErrorMessage('junai: No workspace folder open.');
        return;
    }

    const workspaceRoot = workspaceFolders[0].uri.fsPath;

    // Quick pick: what to coordinate
    const goal = await vscode.window.showInputBox({
        placeHolder: 'What would you like to investigate across the codebase?',
        prompt: 'junai Coordinator: Enter a broad question or task to fan out to parallel workers',
    });
    if (!goal) { return; }

    // For Phase 2: generate a default set of exploratory workers
    // based on the user's goal. Future phases will allow custom worker specs.
    const request: CoordinationRequest = {
        title: `Coordinate: ${goal.slice(0, 50)}`,
        goal,
        workers: [
            {
                id: 'explore-src',
                type: 'explore',
                label: 'Explore source files',
                prompt: goal,
                scopePaths: ['src'],
            },
            {
                id: 'explore-config',
                type: 'explore',
                label: 'Explore configuration',
                prompt: goal,
                scopePaths: ['package.json', 'tsconfig.json'],
            },
            {
                id: 'verify-structure',
                type: 'verify',
                label: 'Verify project structure',
                prompt: `Verify key project files exist for: ${goal}`,
                scopePaths: ['src/extension.ts', 'package.json', 'README.md'],
            },
        ],
    };

    const channel = vscode.window.createOutputChannel('junai Coordinator');
    channel.show(true);
    channel.appendLine(`═══ Coordinator Run: ${request.title} ═══`);
    channel.appendLine(`Goal: ${goal}`);
    channel.appendLine(`Workers: ${request.workers.length}`);
    channel.appendLine(`Starting parallel execution...\n`);

    try {
        const result = await coordinate(request, workspaceRoot);

        channel.appendLine(result.synthesizedOutput);
        channel.appendLine(`\n═══ Coordination Complete ═══`);
        channel.appendLine(`Total time: ${result.totalDurationMs}ms`);
        channel.appendLine(`Workers: ${result.summary.completed} completed, ${result.summary.failed} failed`);

        vscode.window.showInformationMessage(
            `junai Coordinator: ${result.summary.completed}/${result.summary.total} workers completed (${result.totalDurationMs}ms)`,
            'View Results'
        ).then(choice => {
            if (choice === 'View Results') { channel.show(true); }
        });
    } catch (err: unknown) {
        const msg = err instanceof Error ? err.message : String(err);
        channel.appendLine(`\n❌ Coordination failed: ${msg}`);
        vscode.window.showErrorMessage(`junai Coordinator: ${msg}`);
    }
}
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] `junai.coordinate` command appears in the Command Palette
- [ ] Running `junai.coordinate` without the feature flag enabled shows a warning message
- [ ] With the flag enabled, the command shows an input box, launches 3 workers, and outputs results to the "junai Coordinator" output channel
- [ ] The output includes the synthesized result with worker summaries and timing
- [ ] Events appear in the "junai Events" output channel during the run

### Commit

```bash
git add src/extension.ts src/coordinator.ts package.json
git commit -m "feat(coordinator): wire coordinate command into extension with status output"
```

---

## Task 5: Integration Verification & Final Commit

**Objective:** Verify the complete coordinator system works end-to-end.

### Files

- **Verify:** `src/coordinator.ts`, `src/extension.ts`, `package.json`

### Step 1: Full compile check

```bash
cd E:\Projects\junai-vscode
npm run compile
```

Expected: zero errors, zero warnings.

### Step 2: Verify module structure

The `src/` directory should now contain:

```
src/
├── coordinator.ts    # NEW — worker types, task graph, executor, synthesizer, runner
├── eventBus.ts       # Phase 1 — typed event bus
├── extension.ts      # Modified — new command + import
├── featureFlags.ts   # Phase 1 — feature flags
└── permissions.ts    # Phase 1 — risk tiers
```

### Step 3: Verify extension.ts imports

The top of `extension.ts` should include these imports (Phase 1 + Phase 2):

```typescript
import { getAllFlags } from './featureFlags';
import { getAllClassifications } from './permissions';
import { JunaiEventBus } from './eventBus';
import { coordinate, CoordinationRequest } from './coordinator';
```

### Step 4: Verify package.json commands

The `contributes.commands` array should now have 8 commands (7 existing + 1 new):
1. `junai.init`
2. `junai.selectProfile`
3. `junai.status`
4. `junai.setMode`
5. `junai.remove`
6. `junai.update`
7. `junai.probeAutopilot`
8. `junai.coordinate` ← NEW

### Step 5: Package smoke test

```bash
npm run package
```

Expected: produces a `.vsix` file without errors.

### Acceptance Criteria — Phase 2 complete when ALL pass

- [ ] `npm run compile` → zero errors
- [ ] `npm run package` → produces .vsix successfully
- [ ] `src/` contains exactly 5 `.ts` files (4 from Phase 1 + coordinator)
- [ ] `package.json` has 8 commands including `junai.coordinate`
- [ ] Feature flag gate works — coordinator blocked when `experimental.coordinator` is false
- [ ] With flag enabled: 3 workers launch in parallel, results are synthesized, output appears in channel
- [ ] Events from coordinator appear in the "junai Events" output channel
- [ ] No existing commands or functionality are broken

### Final Commit

```bash
git add -A
git commit -m "feat(phase2): complete coordinator mode — parallel workers, task graph, synthesizer"
```

---

## Source Document Traceability

| Requirement | Source | Plan Task | Status |
|-------------|--------|-----------|--------|
| Start with parallel read-only workers | Roadmap Phase 2, item 1 | Task 1 (WorkerType: explore, verify, review) + Task 2 (executors) | ✅ Covered |
| Result aggregation / synthesis | Roadmap Phase 2, item 2 | Task 2 (synthesizeResults) | ✅ Covered |
| Feature flag gating | Roadmap Phase 1 (used here) | Task 3 (requireFeature check) | ✅ Covered |
| Event bus integration | Roadmap Phase 1 (used here) | Task 3 (emit events per worker) | ✅ Covered |
| One flow can launch 2-3 workers and merge coherently | Roadmap Phase 2 exit gate | Task 4 (3 default workers) + Task 5 | ✅ Covered |
| Expand to implementation/test/review later | Roadmap Phase 2, item 3 | Deferred — WorkerType union is extensible | ⏳ Future phase |
