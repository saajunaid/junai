# Pipeline MCP Server

This server provides deterministic-routing support tools for the Orchestrator and all specialist agents.

## Tools (9)

- `pipeline_init(project, feature, type, confirm)`
  - Initializes `.github/pipeline-state.json` from template
  - Includes active-pipeline guard (requires explicit reset for restart)
- `pipeline_reset(project, feature, type, confirm)`
  - Explicit reset/restart flow for a new run
- `notify_orchestrator(stage_completed, result_status, artefact_path?, result_payload?)`
  - Persists completion result into `.github/pipeline-state.json`
  - Invokes deterministic routing transition logic
  - Writes routing decision into `_notes._routing_decision`
- `get_pipeline_status()`
  - Returns current stage/mode/gates summary
  - Returns latest `_routing_decision`
  - Returns `progress_line` for quick visual status
- `set_pipeline_mode(mode)`
  - Sets `supervised`, `assisted`, or `autopilot`
- `satisfy_gate(gate_name)`
  - Manually satisfies supervision gates
- `skip_stage(stage_to_skip, reason)`
  - Skips current stage when allowed by runner rules
  - Auto-carries applicable gates and advances deterministically
- `validate_deferred_paths(deferred_items)`
  - Validates deferred item file paths
  - Attempts filename-based path correction
- `run_command(command, timeout?, max_output_chars?)`
  - Executes shell commands in workspace context and returns structured output

## Configuration

The server reads `PIPELINE_STATE_PATH` from environment.

- Default: `.github/pipeline-state.json` (relative to workspace root)

## Run (manual)

```powershell
python tools/mcp-server/server.py
```

## Install dependencies

```powershell
.venv\Scripts\python -m pip install -r tools/mcp-server/requirements.txt
```
