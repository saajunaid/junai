---
name: query-display
description: Add dev mode SQL query transparency to KPIs and charts. Use when adding new queries and need to show SQL details in developer mode with ðŸ”§ spanners.
---

# Query Display Skill

Add developer mode (ðŸ”§) SQL query transparency to KPIs and charts in Streamlit applications.

## When to Use

Invoke this skill when:
- Adding new KPIs that should show underlying SQL in dev mode
- Adding new charts that need query transparency
- Auditing for KPIs/charts missing dev mode integration
- User asks to "add spanners" or "show query details" for a feature

---

## âš ï¸ CRITICAL: Production Safety

**Dev mode indicators must NEVER appear in production.**

### Mandatory Guard Pattern

```python
# âœ… CORRECT - Always wrap dev mode code in guard
if DevMode.is_enabled():
    DevMode.render_kpi_popover("my_kpi")

# âŒ WRONG - Would show in production!
DevMode.render_kpi_popover("my_kpi")  # Missing guard!
```

### Environment Variable

```powershell
# Development - enables spanners
$env:STREAMLIT_DEV_MODE="true"

# Production - variable not set or false
# Spanners will NOT appear
```

### What's Safe in Production

| Component | Production Behavior |
|-----------|---------------------|
| SQL markers (`-- [KPI:id]`) | Harmless SQL comments |
| `kpi_definitions` metadata | Never loaded |
| `DevMode.render_*()` calls | Guarded by `is_enabled()` |

---

## Decision Tree: Which Pattern to Use

```
Is the KPI part of a combined multi-metric query?
â”‚
â”œâ”€ YES â†’ Pattern 1: Markers in Combined Query
â”‚         Use: -- [KPI:id] markers + kpi_definitions metadata
â”‚         Example: all_kpis query with 8 KPIs in one call
â”‚
â””â”€ NO â†’ Pattern 2: Standalone Query
          Use: get_query_info() directly
          Example: Individual chart queries, validation queries
```

| Situation | Pattern | Marker Needed? |
|-----------|---------|----------------|
| KPI from combined query (all_kpis) | Pattern 1 | Yes |
| KPI with own separate DB call | Pattern 2 | No |
| Chart query | Pattern 2 | No |
| Validation query | Pattern 2 | No |

---

## Pattern 1: Markers in Combined Query

Use when ONE query returns MULTIPLE KPIs (like `all_kpis`).

### Step 1: Add Markers in SQL

```yaml
# queries.yaml â†’ dashboard_kpis â†’ all_kpis
all_kpis:
  description: "Combined query returning ALL dashboard KPIs"
  sql: |
    -- [KPI:unique_customers]
    WITH customer_cte AS (
      SELECT DISTINCT customer_id FROM calls
      WHERE call_date >= '{start_date}'
    ),
    -- [/KPI:unique_customers]
    
    -- [KPI:open_cases]
    case_metrics AS (
      SELECT COUNT(*) AS open_cases
      FROM cases WHERE status = 'Open'
    )
    -- [/KPI:open_cases]
    
    SELECT * FROM customer_cte, case_metrics
```

**Marker Syntax:**
- Start: `-- [KPI:kpi_id]`
- End: `-- [/KPI:kpi_id]`
- These are valid SQL comments (safe in production)

### Step 2: Add Metadata to kpi_definitions

```yaml
# queries.yaml â†’ kpi_definitions
kpi_definitions:
  unique_customers:
    description: "Distinct customers who called"
    metric_name: "unique_calling_customers"

  open_cases:
    description: "Cases still open for calling customers"
    metric_name: "open_cases"
```

**Note:** No `sql:` field needed - SQL is extracted from markers.

### Step 3: Add UI Code with Guard

```python
from src.utils.dev_mode import DevMode

def render_kpi_card(label: str, value: str, kpi_id: str):
    st.markdown(f"**{label}**")
    st.markdown(f"<p style='font-size: 1.75rem;'>{value}</p>", 
                unsafe_allow_html=True)
    
    # âš ï¸ MANDATORY GUARD
    if DevMode.is_enabled():
        DevMode.render_kpi_popover(kpi_id)  # Extracts SQL from markers

# Usage
render_kpi_card("ðŸ‘¥ Unique Customers", "1,234", kpi_id="unique_customers")
```

### How Marker Extraction Works

```python
# In dev_mode.py - get_kpi_query() extracts SQL between markers
def get_kpi_query(cls, kpi_id: str) -> dict[str, Any] | None:
    all_kpis_sql = cls._get_all_kpis_sql()
    
    # Find SQL between markers
    start_marker = f"-- [KPI:{kpi_id}]"
    end_marker = f"-- [/KPI:{kpi_id}]"
    pattern = re.escape(start_marker) + r"(.*?)" + re.escape(end_marker)
    match = re.search(pattern, all_kpis_sql, re.DOTALL)
    
    if match:
        return {"sql": match.group(1).strip(), ...}
```

---

## Pattern 2: Standalone Query

Use when query is self-contained (charts, validation queries, separate KPIs).

### Step 1: Define Query in queries.yaml

```yaml
# queries.yaml â†’ home_charts
home_charts:
  workbasket_distribution:
    description: "Count cases by workbasket with date filter"
    entity: pega_cases
    sql: |
      SELECT WorkbasketHeading, COUNT(*) AS count
      FROM {table}
      WHERE [Created Date Time] >= ? AND [Created Date Time] < ?
      GROUP BY WorkbasketHeading
      ORDER BY count DESC
```

### Step 2: Add UI Code with Guard

```python
from src.utils.dev_mode import DevMode

def render_chart_section(title: str, chart_data: pd.DataFrame, 
                         section: str, query_name: str):
    # Title row with dev indicator
    title_col, dev_col = st.columns([0.95, 0.05])
    
    with title_col:
        st.markdown(f"##### {title}")
    
    with dev_col:
        # âš ï¸ MANDATORY GUARD
        if DevMode.is_enabled():
            query_info = DevMode.get_query_info(section, query_name)
            DevMode.render_sql_popover(query_info, title)
    
    # Chart rendering
    st.plotly_chart(create_chart(chart_data))

# Usage
render_chart_section(
    title="ðŸ“‹ Cases by Workbasket",
    chart_data=workbasket_df,
    section="home_charts",
    query_name="workbasket_distribution"
)
```

---

## Adding a New KPI: Complete Workflow

### Scenario A: KPI is Part of Combined Query

1. **Add markers in `all_kpis`:**
   ```yaml
   # In dashboard_kpis.all_kpis SQL
   -- [KPI:new_metric]
   new_metric_cte AS (
     SELECT COUNT(*) AS new_metric FROM table
   ),
   -- [/KPI:new_metric]
   ```

2. **Add metadata to `kpi_definitions`:**
   ```yaml
   kpi_definitions:
     new_metric:
       description: "What this metric measures"
       metric_name: "new_metric"
   ```

3. **Add UI with guard:**
   ```python
   if DevMode.is_enabled():
       DevMode.render_kpi_popover("new_metric")
   ```

### Scenario B: KPI Has Its Own Query

1. **Add query to appropriate section:**
   ```yaml
   dashboard_kpis:
     my_standalone_kpi:
       description: "Standalone KPI with own query"
       sql: |
         SELECT COUNT(*) AS value FROM my_table
   ```

2. **Add UI with guard:**
   ```python
   if DevMode.is_enabled():
       query_info = DevMode.get_query_info("dashboard_kpis", "my_standalone_kpi")
       DevMode.render_sql_popover(query_info, "My KPI")
   ```

### Scenario C: New Chart

1. **Add to `home_charts` or `analytics_charts`:**
   ```yaml
   home_charts:
     my_new_chart:
       description: "Chart description"
       entity: pega_cases
       sql: |
         SELECT category, COUNT(*) FROM {table} GROUP BY category
   ```

2. **Add UI with guard:**
   ```python
   if DevMode.is_enabled():
       query_info = DevMode.get_query_info("home_charts", "my_new_chart")
       DevMode.render_sql_popover(query_info, "My Chart")
   ```

---

## Core Architecture

```
queries.yaml              â†’ Single source of truth for SQL queries
     â”‚
     â”œâ”€â”€ dashboard_kpis.all_kpis  â†’ Combined query with [KPI:] markers
     â”‚         â”‚
     â”‚         â””â”€â”€ DevMode.get_kpi_query()  â†’ Extracts SQL between markers
     â”‚
     â”œâ”€â”€ kpi_definitions  â†’ Metadata only (description, metric_name)
     â”‚
     â””â”€â”€ home_charts, analytics_charts  â†’ Standalone queries
               â”‚
               â””â”€â”€ DevMode.get_query_info()  â†’ Loads full query
```

---

## DevMode Utility Implementation

```python
"""Dev Mode Utilities - Query transparency for KPIs and charts."""

import os
import re
from pathlib import Path
from typing import Any

import streamlit as st
import yaml


class DevMode:
    """Centralized dev mode utilities."""
    
    _queries_cache: dict[str, Any] | None = None
    _queries_mtime: float = 0

    @staticmethod
    def is_enabled() -> bool:
        """Check if dev mode is enabled via environment variable."""
        return os.getenv("STREAMLIT_DEV_MODE", "false").lower() == "true"

    @classmethod
    def _load_queries(cls) -> dict[str, Any]:
        """Load queries from YAML with file modification time caching."""
        queries_path = Path(__file__).parent.parent / "ingestion_config" / "queries.yaml"
        
        if queries_path.exists():
            current_mtime = queries_path.stat().st_mtime
            
            # Reload if file changed
            if cls._queries_cache is None or current_mtime > cls._queries_mtime:
                with open(queries_path, "r", encoding="utf-8") as f:
                    cls._queries_cache = yaml.safe_load(f) or {}
                cls._queries_mtime = current_mtime
        else:
            cls._queries_cache = {}
        
        return cls._queries_cache

    @classmethod
    def get_query_info(cls, section: str, query_name: str) -> dict[str, Any] | None:
        """Get query info from queries.yaml section.
        
        Args:
            section: Section name (e.g., 'home_charts', 'dashboard_kpis')
            query_name: Query name within section
            
        Returns:
            Dict with query_name, description, sql - or None
        """
        if not cls.is_enabled():
            return None
        
        queries = cls._load_queries()
        query_data = queries.get(section, {}).get(query_name)
        
        if not query_data:
            return None
        
        return {
            "query_name": query_name,
            "description": query_data.get("description", ""),
            "sql": query_data.get("sql", "-- Query not found"),
            "source": f"{section}.{query_name}",
        }

    @classmethod
    def get_kpi_query(cls, kpi_id: str) -> dict[str, Any] | None:
        """Get KPI query by extracting SQL from markers in all_kpis.
        
        Args:
            kpi_id: KPI identifier matching -- [KPI:kpi_id] marker
            
        Returns:
            Dict with sql, description from markers + kpi_definitions
        """
        if not cls.is_enabled():
            return None
        
        queries = cls._load_queries()
        
        # Get metadata from kpi_definitions
        kpi_meta = queries.get("kpi_definitions", {}).get(kpi_id, {})
        description = kpi_meta.get("description", "")
        metric_name = kpi_meta.get("metric_name", "")
        
        # Extract SQL from markers in all_kpis
        all_kpis = queries.get("dashboard_kpis", {}).get("all_kpis", {})
        all_kpis_sql = all_kpis.get("sql", "")
        
        # Find SQL between markers: -- [KPI:id] ... -- [/KPI:id]
        start_marker = f"-- [KPI:{kpi_id}]"
        end_marker = f"-- [/KPI:{kpi_id}]"
        pattern = re.escape(start_marker) + r"(.*?)" + re.escape(end_marker)
        match = re.search(pattern, all_kpis_sql, re.DOTALL)
        
        if match:
            extracted_sql = match.group(1).strip()
            return {
                "query_name": kpi_id,
                "description": description,
                "metric_name": metric_name,
                "sql": extracted_sql,
                "source": f"dashboard_kpis.all_kpis [KPI:{kpi_id}]",
            }
        
        return None

    @staticmethod
    def render_sql_popover(
        query_info: dict[str, Any] | None,
        label: str = "",
    ) -> None:
        """Render dev query popover with SQL details."""
        if not DevMode.is_enabled() or query_info is None:
            return
        
        with st.popover("ðŸ”§", use_container_width=False):
            st.caption(f"**Query:** `{query_info.get('query_name', 'Unknown')}`")
            if query_info.get("source"):
                st.caption(f"**Source:** `{query_info['source']}`")
            if query_info.get("description"):
                st.caption(f"_{query_info['description']}_")
            st.code(query_info.get("sql", "").strip(), language="sql")

    @staticmethod
    def render_kpi_popover(kpi_id: str) -> None:
        """Convenience method to render KPI popover by ID."""
        query_info = DevMode.get_kpi_query(kpi_id)
        DevMode.render_sql_popover(query_info, label=kpi_id)

    @staticmethod
    def render_banner() -> None:
        """Render dev mode banner at page top."""
        if not DevMode.is_enabled():
            return
        
        st.markdown(
            """<div style="background: #FEF3C7; border: 1px solid #F59E0B; 
            border-radius: 4px; padding: 8px 16px; margin-bottom: 16px;">
            ðŸ”§ <b>DEV MODE</b> - Query tooltips active
            </div>""",
            unsafe_allow_html=True,
        )
```

---

## Audit: Finding Missing Dev Mode Integration

### Manual Audit Checklist

1. **Find all KPIs in queries.yaml:**
   ```yaml
   kpi_definitions:
     calls_offered: ...    # Check: has marker + UI spanner?
     limerick: ...         # Check: has marker + UI spanner?
   ```

2. **Check each has markers in all_kpis:**
   ```powershell
   Select-String -Path "src/ingestion_config/queries.yaml" -Pattern "-- \[KPI:"
   ```

3. **Search for KPI render calls missing guards:**
   ```powershell
   Select-String -Path "src/pages/*.py","src/Home.py" -Pattern "render_kpi" | 
     Where-Object { $_ -notmatch "if DevMode" }
   ```

### Automated Audit Script

```python
# scripts/audit_dev_mode.py
import yaml
import re
from pathlib import Path

def audit_kpi_markers():
    """Find KPIs missing markers or UI integration."""
    queries_path = Path("src/ingestion_config/queries.yaml")
    with open(queries_path) as f:
        queries = yaml.safe_load(f)
    
    # Get all kpi_definitions
    kpi_defs = queries.get("kpi_definitions", {}).keys()
    
    # Get all markers in all_kpis
    all_kpis_sql = queries.get("dashboard_kpis", {}).get("all_kpis", {}).get("sql", "")
    markers = set(re.findall(r"-- \[KPI:(\w+)\]", all_kpis_sql))
    
    # Find mismatches
    missing_markers = set(kpi_defs) - markers
    orphan_markers = markers - set(kpi_defs)
    
    print("=== KPI Dev Mode Audit ===")
    if missing_markers:
        print(f"âš ï¸ KPIs without markers: {missing_markers}")
    if orphan_markers:
        print(f"âš ï¸ Markers without metadata: {orphan_markers}")
    if not missing_markers and not orphan_markers:
        print("âœ… All KPIs have matching markers and metadata")
    
    return missing_markers, orphan_markers

if __name__ == "__main__":
    audit_kpi_markers()
```

---

## Validation Tooltips (Optional)

For KPIs with cross-validation from multiple sources (separate from dev spanners):

```python
def render_kpi_with_validation(
    label: str,
    value: str,
    kpi_id: str,
    validation_info: dict | None = None,
):
    """Render KPI with validation tooltip and dev mode spanner."""
    st.markdown(f"**{label}**")
    
    # Validation indicator (always visible if provided)
    validation_html = ""
    if validation_info:
        variance = validation_info.get('variance_pct', 0)
        validation_html = (
            f'<span class="kpi-tooltip-container">'
            f'<span class="kpi-info-icon">?</span>'
            f'<span class="kpi-tooltip-text">'
            f'<b>Cross-Validation</b><br>'
            f'{validation_info["source_a"]}: {validation_info["value_a"]:,}<br>'
            f'{validation_info["source_b"]}: {validation_info["value_b"]:,}<br>'
            f'Variance: {variance:.1f}%'
            f'</span></span>'
        )
    
    st.markdown(
        f"<p style='font-size: 1.75rem;'>{value}{validation_html}</p>",
        unsafe_allow_html=True
    )
    
    # Dev mode spanner (GUARDED)
    if DevMode.is_enabled() and kpi_id:
        DevMode.render_kpi_popover(kpi_id)
```

---

## Color Palette Reference

| Purpose | bg_color | text_color |
|---------|----------|------------|
| Neutral/default | `#F3F4F6` | `#374151` |
| Success/positive | `#D1FAE5` | `#065F46` |
| Info/blue | `#DBEAFE` | `#1E40AF` |
| Purple | `#EDE9FE` | `#5B21B6` |
| Warning/orange | `#FFF7ED` | `#9A3412` |
| Error/red | `#FEE2E2` | `#991B1B` |
| Amber | `#FEF3C7` | `#92400E` |

---

## Testing Checklist

1. **Enable dev mode:**
   ```powershell
   $env:STREAMLIT_DEV_MODE="true"
   streamlit run src/Home.py
   ```

2. **Verify spanners appear:**
   - [ ] ðŸ”§ icon next to KPIs
   - [ ] ðŸ”§ icon next to charts
   - [ ] Click shows SQL with highlighting

3. **Verify SQL correctness:**
   - [ ] SQL matches queries.yaml
   - [ ] Markers extract correct portions

4. **Test auto-propagation:**
   - [ ] Change SQL in queries.yaml
   - [ ] Refresh page
   - [ ] Verify updated SQL appears

5. **Verify production safety:**
   ```powershell
   Remove-Item Env:STREAMLIT_DEV_MODE
   streamlit run src/Home.py
   ```
   - [ ] No ðŸ”§ icons visible
   - [ ] No dev banner

---

## Anti-Patterns to Avoid

```python
# âŒ BAD: Missing guard - shows in production!
DevMode.render_kpi_popover("my_kpi")

# âœ… GOOD: Guarded
if DevMode.is_enabled():
    DevMode.render_kpi_popover("my_kpi")
```

```python
# âŒ BAD: Hardcoded SQL duplicates queries.yaml
KPI_SQL = {"my_kpi": "SELECT COUNT(*) FROM users"}

# âœ… GOOD: Dynamic loading from queries.yaml
if DevMode.is_enabled():
    DevMode.render_kpi_popover("my_kpi")
```

```yaml
# âŒ BAD: SQL in kpi_definitions (duplicates all_kpis)
kpi_definitions:
  my_kpi:
    sql: SELECT COUNT(*) FROM users  # Duplication!

# âœ… GOOD: Metadata only, SQL from markers
kpi_definitions:
  my_kpi:
    description: "User count"
    metric_name: "user_count"
```

---

## Summary

| Task | What to Do |
|------|------------|
| **New KPI in combined query** | Add markers in `all_kpis` + metadata in `kpi_definitions` + guarded UI call |
| **New standalone KPI** | Add query to section + guarded `get_query_info()` call |
| **New chart** | Add query to charts section + guarded `get_query_info()` call |
| **Audit for gaps** | Compare `kpi_definitions` keys to markers in `all_kpis` |
| **ALWAYS** | Wrap dev mode calls in `if DevMode.is_enabled():` |
