---
chain_id: FEAT-2026-0404-fann-evolution
type: plan
status: current
approval: pending
---

# Phase 3 — Dream Memory Consolidation in junai-vscode

> **For the implementing agent:** Follow this plan task-by-task, executing each step sequentially.
> This plan is self-contained. You do not need the pipeline or @Orchestrator to execute it.

**Goal:** Add a Dream Memory Consolidation system that automatically reviews, prunes, and promotes durable knowledge after completed sessions — so yesterday's lessons are available in future sessions without re-explaining them from scratch.

**Architecture:** A new `src/dream.ts` module implements the memory consolidation engine. It works with a workspace-local memory store (`.github/dream-memory.json`) that holds memory entries with metadata (source, timestamp, confidence, access count, tags). The consolidation pass scans for stale, contradictory, or low-value entries and prunes them while promoting high-value entries. The system is gated behind the `experimental.dream` feature flag from Phase 1. A new `junai.dreamConsolidate` command exposes manual consolidation, and an automatic trigger fires after pipeline stage completions via the event bus.

**Key design constraints:**
- Memory entries are stored in a single JSON file (not scattered files) — simple, portable, git-friendly
- Consolidation is non-destructive: pruned entries move to an archive section, never deleted
- Automatic triggers are low-noise: consolidation runs at most once per stage completion, silently
- The dream system reads from `docs/gold-nuggets-log.md` and `.github/copilot-instructions.md` to seed itself, but NEVER writes to those files — it only manages its own store

**Tech Stack:** TypeScript 5.3+, VS Code Extension API ^1.101.0, Phase 1 modules (`featureFlags.ts`, `eventBus.ts`).

**Parent roadmap:** `.github/plans/fann-junai-evolution-roadmap.md`  
**Depends on:** Phase 1 (completed), Phase 2 (completed)

---

## Manual Execution Protocol

For each task group below, follow this workflow:

1. **Open** a new chat session
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
| Storage format | Single `.github/dream-memory.json` file | Git-friendly, portable, simple to parse; avoids scattered files |
| Pruning strategy | Archive-based — pruned entries move to `archived` array | Non-destructive; user can inspect and recover archived items |
| Staleness threshold | 30 days since last access OR 0 access count after 7 days | Conservative defaults; avoids pruning useful entries too early |
| Contradiction detection | Simple: same `subject` with conflicting `fact` text | Phase 3 scope — no NLP; string-level comparison is sufficient |
| Promotion criteria | Accessed 3+ times OR manually tagged `promoted` | Organic promotion based on actual reuse |
| Consolidation trigger | After `task-completed` events where `stage` matches a pipeline stage | Runs silently via event bus subscription |
| Feature gate | `requireFeature('dream')` from Phase 1 | Dream is experimental — users must opt in |

### Existing Scaffold — DO NOT Recreate

| File | Purpose | Current State |
|------|---------|---------------|
| `src/extension.ts` | Extension activation, commands, event bus wiring | ✅ Working — add new command + event subscription |
| `src/featureFlags.ts` | `requireFeature('dream')` and `isFeatureEnabled('dream')` | ✅ Working — use, don't recreate |
| `src/eventBus.ts` | `JunaiEventBus.getInstance()` | ✅ Working — subscribe to task-completed events |
| `src/permissions.ts` | Risk gating | ✅ Working — not needed for Dream (read/write own file only) |
| `src/coordinator.ts` | Coordinator mode | ✅ Working — not modified in Phase 3 |

### Dependencies

**Not yet installed:** None — Phase 3 uses zero new dependencies.

---

## Task 1: Memory Store Types and Persistence

**Objective:** Define the memory entry types and the persistence layer that reads/writes `.github/dream-memory.json`.

### Files

- **Create:** `src/dream.ts`

### Step 1: Create the dream module

Create `E:\Projects\junai-vscode\src\dream.ts` with the following content:

```typescript
import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { isFeatureEnabled } from './featureFlags';
import { JunaiEventBus } from './eventBus';

// ─────────────────────────────────────────────────────────────
// Memory entry types
// ─────────────────────────────────────────────────────────────

export type MemoryCategory =
    | 'repo-fact'          // Durable codebase convention or structure fact
    | 'rejected-approach'  // Approach tried and explicitly ruled out
    | 'successful-command' // Command or workflow that worked
    | 'failure-mode'       // Known failure mode and how to avoid it
    | 'user-preference'    // User's stated preference or convention
    | 'general';           // Uncategorized knowledge

export interface MemoryEntry {
    /** Unique ID — generated as timestamp-based slug */
    id: string;
    /** Short subject line (what this is about) */
    subject: string;
    /** The actual knowledge or fact */
    fact: string;
    /** Where this knowledge came from */
    source: string;
    /** Category for filtering and consolidation */
    category: MemoryCategory;
    /** ISO 8601 timestamp when this entry was created */
    createdAt: string;
    /** ISO 8601 timestamp when this entry was last accessed/used */
    lastAccessedAt: string;
    /** How many times this entry has been accessed */
    accessCount: number;
    /** Confidence score: 0.0 to 1.0 */
    confidence: number;
    /** Optional tags for grouping */
    tags: string[];
    /** Whether this entry has been manually promoted */
    promoted: boolean;
}

export interface ArchivedEntry extends MemoryEntry {
    /** Why this entry was archived */
    archiveReason: string;
    /** When it was archived */
    archivedAt: string;
}

export interface DreamMemoryStore {
    /** Schema version for forward compatibility */
    version: number;
    /** Active memory entries */
    entries: MemoryEntry[];
    /** Archived (pruned) entries — kept for inspection/recovery */
    archived: ArchivedEntry[];
    /** Last consolidation run timestamp */
    lastConsolidationAt: string | null;
    /** Total consolidation runs */
    consolidationCount: number;
}

// ─────────────────────────────────────────────────────────────
// Persistence
// ─────────────────────────────────────────────────────────────

const STORE_FILENAME = 'dream-memory.json';
const CURRENT_VERSION = 1;

/**
 * Resolve the path to the dream memory store file.
 * Returns null if no workspace is open.
 */
function getStorePath(): string | null {
    const folders = vscode.workspace.workspaceFolders;
    if (!folders || folders.length === 0) { return null; }
    return path.join(folders[0].uri.fsPath, '.github', STORE_FILENAME);
}

/**
 * Create a new empty memory store.
 */
function createEmptyStore(): DreamMemoryStore {
    return {
        version: CURRENT_VERSION,
        entries: [],
        archived: [],
        lastConsolidationAt: null,
        consolidationCount: 0,
    };
}

/**
 * Load the memory store from disk.
 * Returns a fresh empty store if the file doesn't exist or is invalid.
 */
export function loadStore(): DreamMemoryStore {
    const storePath = getStorePath();
    if (!storePath) { return createEmptyStore(); }

    try {
        if (!fs.existsSync(storePath)) { return createEmptyStore(); }
        const raw = fs.readFileSync(storePath, 'utf8');
        const parsed = JSON.parse(raw) as DreamMemoryStore;

        // Basic validation
        if (typeof parsed.version !== 'number' || !Array.isArray(parsed.entries)) {
            return createEmptyStore();
        }

        return parsed;
    } catch {
        return createEmptyStore();
    }
}

/**
 * Save the memory store to disk.
 * Creates the .github directory if it doesn't exist.
 */
export function saveStore(store: DreamMemoryStore): void {
    const storePath = getStorePath();
    if (!storePath) { return; }

    const dir = path.dirname(storePath);
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }

    fs.writeFileSync(storePath, JSON.stringify(store, null, 2), 'utf8');
}

// ─────────────────────────────────────────────────────────────
// Memory operations
// ─────────────────────────────────────────────────────────────

/**
 * Generate a unique ID for a memory entry.
 */
function generateId(): string {
    const now = new Date();
    const ts = now.toISOString().replace(/[-:T]/g, '').slice(0, 14);
    const rand = Math.random().toString(36).slice(2, 6);
    return `dream-${ts}-${rand}`;
}

/**
 * Add a new memory entry to the store.
 */
export function addEntry(
    store: DreamMemoryStore,
    entry: Omit<MemoryEntry, 'id' | 'createdAt' | 'lastAccessedAt' | 'accessCount' | 'promoted'>,
): MemoryEntry {
    const now = new Date().toISOString();
    const newEntry: MemoryEntry = {
        ...entry,
        id: generateId(),
        createdAt: now,
        lastAccessedAt: now,
        accessCount: 0,
        promoted: false,
    };
    store.entries.push(newEntry);
    return newEntry;
}

/**
 * Record an access to a memory entry (increment count + update timestamp).
 */
export function touchEntry(store: DreamMemoryStore, entryId: string): void {
    const entry = store.entries.find(e => e.id === entryId);
    if (entry) {
        entry.accessCount += 1;
        entry.lastAccessedAt = new Date().toISOString();
    }
}

/**
 * Promote a memory entry (manually mark as high-value).
 */
export function promoteEntry(store: DreamMemoryStore, entryId: string): void {
    const entry = store.entries.find(e => e.id === entryId);
    if (entry) {
        entry.promoted = true;
        entry.confidence = Math.min(1.0, entry.confidence + 0.2);
    }
}

/**
 * Get entries matching a category filter.
 */
export function getEntriesByCategory(store: DreamMemoryStore, category: MemoryCategory): MemoryEntry[] {
    return store.entries.filter(e => e.category === category);
}

/**
 * Get entries matching a tag.
 */
export function getEntriesByTag(store: DreamMemoryStore, tag: string): MemoryEntry[] {
    return store.entries.filter(e => e.tags.includes(tag));
}

/**
 * Search entries by subject or fact text (case-insensitive substring match).
 */
export function searchEntries(store: DreamMemoryStore, query: string): MemoryEntry[] {
    const lower = query.toLowerCase();
    return store.entries.filter(e =>
        e.subject.toLowerCase().includes(lower) ||
        e.fact.toLowerCase().includes(lower)
    );
}
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] `DreamMemoryStore` type has `entries`, `archived`, `version`, `lastConsolidationAt`, `consolidationCount`
- [ ] `loadStore()` returns empty store if file doesn't exist or is invalid
- [ ] `saveStore()` creates `.github/` directory if needed
- [ ] `addEntry()` auto-generates ID and timestamps
- [ ] `touchEntry()` increments access count and updates timestamp
- [ ] `promoteEntry()` sets `promoted = true` and boosts confidence
- [ ] `searchEntries()` does case-insensitive substring matching
- [ ] No runtime dependencies added

### Commit

```bash
git add src/dream.ts
git commit -m "feat(dream): add memory store types and persistence layer"
```

---

## Task 2: Consolidation Engine — Staleness Detection and Pruning

**Objective:** Implement the consolidation logic that identifies stale, contradictory, and low-value entries, then archives them.

### Files

- **Modify:** `src/dream.ts` (append consolidation functions)

### Step 1: Add consolidation logic

Append the following to the bottom of `E:\Projects\junai-vscode\src\dream.ts`:

```typescript
// ─────────────────────────────────────────────────────────────
// Consolidation engine
// ─────────────────────────────────────────────────────────────

/** Consolidation configuration — conservative defaults */
const CONSOLIDATION_CONFIG = {
    /** Days since last access before an entry is considered stale */
    staleDays: 30,
    /** Days after creation with 0 accesses before pruning */
    unusedGraceDays: 7,
    /** Minimum access count to auto-promote */
    autoPromoteThreshold: 3,
    /** Maximum entries before consolidation is recommended */
    maxEntries: 200,
};

export interface ConsolidationReport {
    /** Entries archived due to staleness */
    staleArchived: string[];
    /** Entries archived due to no usage */
    unusedArchived: string[];
    /** Entries archived due to contradiction */
    contradictionArchived: string[];
    /** Entries auto-promoted due to high access count */
    autoPromoted: string[];
    /** Total active entries after consolidation */
    remainingEntries: number;
    /** Total archived entries (cumulative) */
    totalArchived: number;
}

/**
 * Run a full consolidation pass on the memory store.
 *
 * Steps:
 * 1. Detect and archive stale entries (no access for `staleDays` days)
 * 2. Detect and archive unused entries (0 accesses after `unusedGraceDays` days)
 * 3. Detect and archive contradictions (same subject, conflicting facts)
 * 4. Auto-promote high-access entries
 * 5. Update consolidation metadata
 *
 * Non-destructive: pruned entries move to `store.archived`, never deleted.
 * Promoted entries are never pruned by staleness.
 */
export function consolidate(store: DreamMemoryStore): ConsolidationReport {
    const now = new Date();
    const report: ConsolidationReport = {
        staleArchived: [],
        unusedArchived: [],
        contradictionArchived: [],
        autoPromoted: [],
        remainingEntries: 0,
        totalArchived: 0,
    };

    // Step 1: Detect stale entries
    const staleCutoff = new Date(now.getTime() - CONSOLIDATION_CONFIG.staleDays * 24 * 60 * 60 * 1000);
    for (const entry of store.entries) {
        if (entry.promoted) { continue; } // Never prune promoted entries
        const lastAccess = new Date(entry.lastAccessedAt);
        if (lastAccess < staleCutoff) {
            archiveEntry(store, entry, 'stale: no access for 30+ days');
            report.staleArchived.push(entry.id);
        }
    }
    // Remove archived entries from active list
    store.entries = store.entries.filter(e => !report.staleArchived.includes(e.id));

    // Step 2: Detect unused entries past grace period
    const unusedCutoff = new Date(now.getTime() - CONSOLIDATION_CONFIG.unusedGraceDays * 24 * 60 * 60 * 1000);
    for (const entry of store.entries) {
        if (entry.promoted) { continue; }
        const created = new Date(entry.createdAt);
        if (entry.accessCount === 0 && created < unusedCutoff) {
            archiveEntry(store, entry, 'unused: 0 accesses after 7-day grace period');
            report.unusedArchived.push(entry.id);
        }
    }
    store.entries = store.entries.filter(e => !report.unusedArchived.includes(e.id));

    // Step 3: Detect contradictions (same subject, different facts)
    const subjectGroups = new Map<string, MemoryEntry[]>();
    for (const entry of store.entries) {
        const key = entry.subject.toLowerCase().trim();
        const group = subjectGroups.get(key) ?? [];
        group.push(entry);
        subjectGroups.set(key, group);
    }

    for (const [, group] of subjectGroups) {
        if (group.length <= 1) { continue; }

        // Sort by confidence desc, then by createdAt desc (newest first)
        group.sort((a, b) => {
            if (b.confidence !== a.confidence) { return b.confidence - a.confidence; }
            return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
        });

        // Keep the highest-confidence entry, archive the rest
        const keeper = group[0];
        for (let i = 1; i < group.length; i++) {
            const duplicate = group[i];
            if (duplicate.fact.toLowerCase().trim() !== keeper.fact.toLowerCase().trim()) {
                archiveEntry(store, duplicate, `contradiction: conflicts with "${keeper.id}" (higher confidence)`);
                report.contradictionArchived.push(duplicate.id);
            }
        }
    }
    store.entries = store.entries.filter(e => !report.contradictionArchived.includes(e.id));

    // Step 4: Auto-promote high-access entries
    for (const entry of store.entries) {
        if (!entry.promoted && entry.accessCount >= CONSOLIDATION_CONFIG.autoPromoteThreshold) {
            entry.promoted = true;
            entry.confidence = Math.min(1.0, entry.confidence + 0.1);
            report.autoPromoted.push(entry.id);
        }
    }

    // Step 5: Update metadata
    store.lastConsolidationAt = now.toISOString();
    store.consolidationCount += 1;
    report.remainingEntries = store.entries.length;
    report.totalArchived = store.archived.length;

    return report;
}

/**
 * Move an entry to the archive with a reason.
 */
function archiveEntry(store: DreamMemoryStore, entry: MemoryEntry, reason: string): void {
    const archived: ArchivedEntry = {
        ...entry,
        archiveReason: reason,
        archivedAt: new Date().toISOString(),
    };
    store.archived.push(archived);
}

/**
 * Get a summary of the memory store's health.
 */
export function getStoreHealth(store: DreamMemoryStore): {
    totalEntries: number;
    totalArchived: number;
    promotedCount: number;
    staleCount: number;
    avgConfidence: number;
    categoryCounts: Record<string, number>;
    lastConsolidation: string | null;
    consolidationCount: number;
    needsConsolidation: boolean;
} {
    const now = new Date();
    const staleCutoff = new Date(now.getTime() - CONSOLIDATION_CONFIG.staleDays * 24 * 60 * 60 * 1000);

    const staleCount = store.entries.filter(e =>
        !e.promoted && new Date(e.lastAccessedAt) < staleCutoff
    ).length;

    const avgConfidence = store.entries.length > 0
        ? store.entries.reduce((sum, e) => sum + e.confidence, 0) / store.entries.length
        : 0;

    const categoryCounts: Record<string, number> = {};
    for (const entry of store.entries) {
        categoryCounts[entry.category] = (categoryCounts[entry.category] ?? 0) + 1;
    }

    return {
        totalEntries: store.entries.length,
        totalArchived: store.archived.length,
        promotedCount: store.entries.filter(e => e.promoted).length,
        staleCount,
        avgConfidence: Math.round(avgConfidence * 100) / 100,
        categoryCounts,
        lastConsolidation: store.lastConsolidationAt,
        consolidationCount: store.consolidationCount,
        needsConsolidation: staleCount > 0 || store.entries.length > CONSOLIDATION_CONFIG.maxEntries,
    };
}
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] `consolidate()` archives stale entries (30+ days since last access)
- [ ] `consolidate()` archives unused entries (0 accesses after 7-day grace)
- [ ] `consolidate()` detects contradictions and keeps higher-confidence entry
- [ ] `consolidate()` auto-promotes entries with 3+ accesses
- [ ] Promoted entries are NEVER pruned by staleness or unused checks
- [ ] `archiveEntry()` preserves the full entry with reason and timestamp
- [ ] `getStoreHealth()` reports entry counts, avg confidence, stale count, and needsConsolidation flag
- [ ] `ConsolidationReport` includes counts for each pruning category

### Commit

```bash
git add src/dream.ts
git commit -m "feat(dream): add consolidation engine with staleness detection and pruning"
```

---

## Task 3: Ingestion — Seed from Gold Nuggets Log

**Objective:** Add the ability to ingest durable knowledge from `docs/gold-nuggets-log.md` into the dream memory store, avoiding duplicates.

### Files

- **Modify:** `src/dream.ts` (append ingestion function)

### Step 1: Add the ingestion function

Append the following to the bottom of `E:\Projects\junai-vscode\src\dream.ts`:

```typescript
// ─────────────────────────────────────────────────────────────
// Ingestion — seed from gold nuggets log
// ─────────────────────────────────────────────────────────────

/**
 * Ingest entries from `docs/gold-nuggets-log.md` into the dream memory store.
 *
 * The gold nuggets log uses a structured markdown format with entries like:
 * ```
 * ### <subject>
 * <fact text across one or more lines>
 * ```
 *
 * This function parses the file, extracts entries, and adds them to the store
 * if they don't already exist (deduplication by subject match).
 *
 * The dream system READS from gold-nuggets-log.md but NEVER writes to it.
 *
 * @returns Number of new entries ingested
 */
export function ingestFromGoldNuggets(store: DreamMemoryStore): number {
    const folders = vscode.workspace.workspaceFolders;
    if (!folders || folders.length === 0) { return 0; }

    const nuggetPath = path.join(folders[0].uri.fsPath, 'docs', 'gold-nuggets-log.md');
    if (!fs.existsSync(nuggetPath)) { return 0; }

    const content = fs.readFileSync(nuggetPath, 'utf8');
    const parsed = parseGoldNuggets(content);

    let ingested = 0;
    const existingSubjects = new Set(store.entries.map(e => e.subject.toLowerCase().trim()));

    for (const nugget of parsed) {
        const normalizedSubject = nugget.subject.toLowerCase().trim();
        if (existingSubjects.has(normalizedSubject)) { continue; }

        addEntry(store, {
            subject: nugget.subject,
            fact: nugget.fact,
            source: 'gold-nuggets-log.md',
            category: categorizeNugget(nugget.fact),
            confidence: 0.8, // Gold nuggets have high baseline confidence
            tags: ['ingested', 'gold-nugget'],
        });

        existingSubjects.add(normalizedSubject);
        ingested++;
    }

    return ingested;
}

interface ParsedNugget {
    subject: string;
    fact: string;
}

/**
 * Parse a gold nuggets log file into structured entries.
 * Handles the `### subject` + body format.
 */
function parseGoldNuggets(content: string): ParsedNugget[] {
    const nuggets: ParsedNugget[] = [];
    const lines = content.split('\n');

    let currentSubject: string | null = null;
    let currentLines: string[] = [];

    for (const line of lines) {
        const h3Match = line.match(/^###\s+(.+)$/);
        if (h3Match) {
            // Save previous entry
            if (currentSubject && currentLines.length > 0) {
                nuggets.push({
                    subject: currentSubject.trim(),
                    fact: currentLines.join('\n').trim(),
                });
            }
            currentSubject = h3Match[1];
            currentLines = [];
        } else if (currentSubject) {
            // Skip empty lines at the start
            if (currentLines.length === 0 && line.trim() === '') { continue; }
            // Stop at next heading (any level)
            if (/^#{1,2}\s/.test(line)) {
                nuggets.push({
                    subject: currentSubject.trim(),
                    fact: currentLines.join('\n').trim(),
                });
                currentSubject = null;
                currentLines = [];
            } else {
                currentLines.push(line);
            }
        }
    }

    // Don't forget the last entry
    if (currentSubject && currentLines.length > 0) {
        nuggets.push({
            subject: currentSubject.trim(),
            fact: currentLines.join('\n').trim(),
        });
    }

    return nuggets;
}

/**
 * Auto-categorize a nugget based on keywords in the fact text.
 */
function categorizeNugget(fact: string): MemoryCategory {
    const lower = fact.toLowerCase();
    if (lower.includes('rejected') || lower.includes('ruled out') || lower.includes('do not use')) {
        return 'rejected-approach';
    }
    if (lower.includes('command') || lower.includes('workflow') || lower.includes('run ')) {
        return 'successful-command';
    }
    if (lower.includes('fail') || lower.includes('error') || lower.includes('bug') || lower.includes('crash')) {
        return 'failure-mode';
    }
    if (lower.includes('prefer') || lower.includes('convention') || lower.includes('always ')) {
        return 'user-preference';
    }
    return 'repo-fact';
}
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] `ingestFromGoldNuggets()` returns 0 if file doesn't exist (no crash)
- [ ] `ingestFromGoldNuggets()` parses `### heading` + body format correctly
- [ ] Duplicate subjects are skipped (case-insensitive deduplication)
- [ ] Ingested entries get `confidence: 0.8` and tags `['ingested', 'gold-nugget']`
- [ ] `categorizeNugget()` maps keywords to appropriate categories
- [ ] `parseGoldNuggets()` handles multiple entries and the last entry in the file
- [ ] The dream system NEVER writes to `gold-nuggets-log.md`

### Commit

```bash
git add src/dream.ts
git commit -m "feat(dream): add gold nuggets ingestion with deduplication"
```

---

## Task 4: Wire into Extension — Command, Event Subscription, Status

**Objective:** Register a `junai.dreamConsolidate` command, subscribe to task-completed events for automatic consolidation, and surface dream status in the pipeline status output.

### Files

- **Modify:** `package.json` (add command)
- **Modify:** `src/extension.ts` (register command, add event subscription, update status display)

### Step 1: Add the command to package.json

In `E:\Projects\junai-vscode\package.json`, in the `contributes.commands` array, after the `junai.coordinate` entry, add:

```jsonc
{
  "command": "junai.dreamConsolidate",
  "title": "Run Dream Memory Consolidation (Experimental)",
  "category": "junai"
}
```

### Step 2: Wire into extension.ts

Open `E:\Projects\junai-vscode\src\extension.ts`.

**Add import** at the top, after the coordinator import:

```typescript
import { loadStore, saveStore, consolidate, ingestFromGoldNuggets, getStoreHealth } from './dream';
```

**Register command** in the `activate()` function. Inside the `context.subscriptions.push(...)` block, after the `junai.coordinate` registration, add:

```typescript
vscode.commands.registerCommand('junai.dreamConsolidate', () => cmdDreamConsolidate()),
```

**Add automatic consolidation trigger** — after the event bus `onAny` subscription block in `activate()`, add:

```typescript
    // Dream: auto-consolidate after pipeline stage completions (silent, opt-in via flag)
    eventBus.on('task-completed', (event) => {
        if (!isFeatureEnabled('dream')) { return; }
        // Only consolidate after meaningful pipeline stages, not every sub-event
        const pipelineStages = new Set([
            'implement', 'test', 'review', 'architecture', 'plan',
            'security', 'coordination-complete',
        ]);
        if (!pipelineStages.has(event.stage)) { return; }

        try {
            const store = loadStore();
            ingestFromGoldNuggets(store);
            consolidate(store);
            saveStore(store);
        } catch {
            // Silent failure — dream consolidation should never break the pipeline
        }
    });
```

Note: This requires importing `isFeatureEnabled` — update the featureFlags import:

```typescript
import { getAllFlags, isFeatureEnabled } from './featureFlags';
```

**Add the command handler** — place this new function after the `cmdCoordinate` function:

```typescript
// ─────────────────────────────────────────────────────────────
// junai.dreamConsolidate — run dream memory consolidation (experimental)
// ─────────────────────────────────────────────────────────────
async function cmdDreamConsolidate() {
    const { requireFeature } = await import('./featureFlags');
    try {
        requireFeature('dream');
    } catch {
        return; // Warning already shown by requireFeature
    }

    const channel = vscode.window.createOutputChannel('junai Dream');
    channel.show(true);
    channel.appendLine('═══ Dream Memory Consolidation ═══');

    const store = loadStore();

    // Ingest from gold nuggets first
    const ingested = ingestFromGoldNuggets(store);
    channel.appendLine(`Ingested ${ingested} new entries from gold-nuggets-log.md`);

    // Run consolidation
    const report = consolidate(store);
    channel.appendLine('');
    channel.appendLine('Consolidation Report:');
    channel.appendLine(`  Stale archived:         ${report.staleArchived.length}`);
    channel.appendLine(`  Unused archived:         ${report.unusedArchived.length}`);
    channel.appendLine(`  Contradictions archived: ${report.contradictionArchived.length}`);
    channel.appendLine(`  Auto-promoted:           ${report.autoPromoted.length}`);
    channel.appendLine(`  Remaining entries:       ${report.remainingEntries}`);
    channel.appendLine(`  Total archived:          ${report.totalArchived}`);

    // Save
    saveStore(store);
    channel.appendLine('');
    channel.appendLine('Store saved to .github/dream-memory.json');

    // Health check
    const health = getStoreHealth(store);
    channel.appendLine('');
    channel.appendLine('Store Health:');
    channel.appendLine(`  Total entries:     ${health.totalEntries}`);
    channel.appendLine(`  Promoted:          ${health.promotedCount}`);
    channel.appendLine(`  Avg confidence:    ${health.avgConfidence}`);
    channel.appendLine(`  Needs consolidation: ${health.needsConsolidation}`);
    channel.appendLine(`  Consolidation #:   ${health.consolidationCount}`);
    channel.appendLine('═══════════════════════════════════');

    vscode.window.showInformationMessage(
        `junai Dream: consolidated — ${report.remainingEntries} entries active, ${report.staleArchived.length + report.unusedArchived.length + report.contradictionArchived.length} archived`,
    );
}
```

**Update `cmdStatus()`** — find the existing event log display section in `cmdStatus()` and add dream status after it. After the line that shows recent events, add:

```typescript
    // Dream memory status
    if (isFeatureEnabled('dream')) {
        const dreamStore = loadStore();
        const dreamHealth = getStoreHealth(dreamStore);
        channel.appendLine(`  Dream       : ${dreamHealth.totalEntries} entries (${dreamHealth.promotedCount} promoted, ${dreamHealth.staleCount} stale) | consolidations: ${dreamHealth.consolidationCount}`);
    }
```

### Acceptance Criteria

- [ ] `npm run compile` succeeds with zero errors
- [ ] `junai.dreamConsolidate` command appears in the Command Palette
- [ ] Running `junai.dreamConsolidate` without the feature flag enabled shows a warning
- [ ] With the flag enabled: ingests from gold nuggets, runs consolidation, saves store, shows report
- [ ] Auto-consolidation fires after task-completed events for pipeline stages (only when flag is on)
- [ ] Auto-consolidation failures are silently caught (never breaks pipeline)
- [ ] `cmdStatus()` shows dream status when the flag is enabled
- [ ] `package.json` has the new command entry

### Commit

```bash
git add src/extension.ts src/dream.ts package.json
git commit -m "feat(dream): wire consolidation command, auto-trigger, and status display"
```

---

## Task 5: Integration Verification & Final Commit

**Objective:** Verify the complete dream system works end-to-end.

### Files

- **Verify:** `src/dream.ts`, `src/extension.ts`, `package.json`

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
├── coordinator.ts   # Phase 2 — coordinator mode
├── dream.ts         # NEW — dream memory consolidation
├── eventBus.ts      # Phase 1 — typed event bus
├── extension.ts     # Modified — new command + event subscription + status
├── featureFlags.ts  # Phase 1 — feature flags
└── permissions.ts   # Phase 1 — risk tiers
```

### Step 3: Verify extension.ts imports

The top of `extension.ts` should include these imports (Phase 1 + 2 + 3):

```typescript
import { getAllFlags, isFeatureEnabled } from './featureFlags';
import { getAllClassifications } from './permissions';
import { JunaiEventBus } from './eventBus';
import { coordinate, CoordinationRequest } from './coordinator';
import { loadStore, saveStore, consolidate, ingestFromGoldNuggets, getStoreHealth } from './dream';
```

### Step 4: Verify package.json commands

The `contributes.commands` array should now have 9 commands:
1. `junai.init`
2. `junai.selectProfile`
3. `junai.status`
4. `junai.setMode`
5. `junai.remove`
6. `junai.update`
7. `junai.probeAutopilot`
8. `junai.coordinate`
9. `junai.dreamConsolidate` ← NEW

### Step 5: Package smoke test

```bash
npm run package
```

Expected: produces a `.vsix` file without errors.

### Acceptance Criteria — Phase 3 complete when ALL pass

- [ ] `npm run compile` → zero errors
- [ ] `npm run package` → produces .vsix successfully
- [ ] `src/` contains exactly 6 `.ts` files (5 from Phases 1-2 + dream)
- [ ] `package.json` has 9 commands including `junai.dreamConsolidate`
- [ ] Feature flag gate works — dream blocked when `experimental.dream` is false
- [ ] Manual consolidation: ingests, prunes stale/unused/contradictions, auto-promotes, saves
- [ ] Auto-trigger fires silently after pipeline stage completions (only when flag is on)
- [ ] `cmdStatus()` shows dream health when flag is enabled
- [ ] No existing commands or functionality are broken

### Final Commit

```bash
git add -A
git commit -m "feat(phase3): complete dream memory consolidation — store, consolidation, ingestion, auto-trigger"
```

---

## Source Document Traceability

| Requirement | Source | Plan Task | Status |
|-------------|--------|-----------|--------|
| Run memory pass after completed stages | Roadmap Phase 3, item 1 | Task 4 (event subscription auto-trigger) | ✅ Covered |
| Consolidate durable repo facts | Roadmap Phase 3, item 2a | Task 1 (MemoryCategory: repo-fact) + Task 3 (ingestion) | ✅ Covered |
| Consolidate rejected approaches | Roadmap Phase 3, item 2b | Task 1 (MemoryCategory: rejected-approach) + Task 3 (categorize) | ✅ Covered |
| Consolidate successful commands/workflows | Roadmap Phase 3, item 2c | Task 1 (MemoryCategory: successful-command) | ✅ Covered |
| Consolidate known failure modes | Roadmap Phase 3, item 2d | Task 1 (MemoryCategory: failure-mode) | ✅ Covered |
| Prune stale or contradictory items | Roadmap Phase 3, item 3 | Task 2 (consolidate: staleness, unused, contradictions) | ✅ Covered |
| Feature flag gating | Phase 1 dependency | Task 4 (requireFeature + isFeatureEnabled checks) | ✅ Covered |
| Event bus integration | Phase 1 dependency | Task 4 (subscribe to task-completed) | ✅ Covered |
| Memory stays concise and useful | Roadmap Phase 3 exit gate | Task 2 (auto-promote + archive, not delete) | ✅ Covered |
