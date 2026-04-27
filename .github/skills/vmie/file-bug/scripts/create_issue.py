"""
create_issue.py — VMIE Gitea issue filing helper for the file-bug skill.

Usage (CLI):
    python create_issue.py --repo vmie/nps-lens --title "[BUG] ..." --body "..." --flow auto-fix

Usage (Python import):
    from create_issue import create_issue
    url = create_issue(repo="vmie/nps-lens", title="...", body="...", flow="auto-fix")
"""

import argparse
import json
import os
import urllib.error
import urllib.request
from pathlib import Path

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

GITEA_BASE = os.environ.get("GITEA_BASE", "http://git.local:8090")

# Token resolution order: env var → .env file in project root
def _resolve_token() -> str:
    token = os.environ.get("GITEA_TOKEN") or os.environ.get("VMIE_BOT_TOKEN")
    if token:
        return token
    # Try .env files relative to nps-lens project root
    for candidate in [
        Path("config/.env.gitea"),
        Path("config/.env.api"),
        Path(".env"),
    ]:
        if candidate.exists():
            for line in candidate.read_text().splitlines():
                if line.startswith("GITEA_TOKEN=") or line.startswith("VMIE_BOT_TOKEN="):
                    return line.split("=", 1)[1].strip().strip('"').strip("'")
    # Fallback — hard-coded for local dev only (rotate regularly)
    return "***REDACTED-HASH***"


# Label IDs per repo — run list_labels.py to refresh if 422 errors appear
REPO_LABELS = {
    "vmie/nps-lens": {
        "bug": 11,
        "auto-fix": 13,
        "needs-triage": 31,
        "approved-change": 33,
        "fix-approved": 12,
    }
}

# Flow → label set mapping
FLOW_LABELS = {
    "auto-fix":       ["bug", "auto-fix", "needs-triage"],
    "supervised":     ["bug", "needs-triage"],
    "approved":       ["approved-change"],
}


# ---------------------------------------------------------------------------
# Core function
# ---------------------------------------------------------------------------

def create_issue(
    repo: str,
    title: str,
    body: str,
    flow: str = "auto-fix",
    gitea_base: str = GITEA_BASE,
    token: str | None = None,
) -> str:
    """
    Create a Gitea issue and return its HTML URL.

    Args:
        repo:        "owner/repo" e.g. "vmie/nps-lens"
        title:       Issue title (include [BUG] prefix)
        body:        Markdown body — symptoms only, no root cause
        flow:        "auto-fix" | "supervised" | "approved"
        gitea_base:  Base URL of Gitea instance
        token:       Gitea API token (resolved automatically if None)

    Returns:
        HTML URL of the created issue e.g. "http://git.local:8090/vmie/nps-lens/issues/26"

    Raises:
        ValueError:  Unknown repo or flow
        RuntimeError: API error
    """
    if repo not in REPO_LABELS:
        raise ValueError(
            f"Unknown repo '{repo}'. Known repos: {list(REPO_LABELS.keys())}. "
            "Add it to REPO_LABELS in create_issue.py."
        )
    if flow not in FLOW_LABELS:
        raise ValueError(f"Unknown flow '{flow}'. Choose from: {list(FLOW_LABELS.keys())}")

    token = token or _resolve_token()
    label_map = REPO_LABELS[repo]
    label_ids = [label_map[name] for name in FLOW_LABELS[flow] if name in label_map]

    payload = json.dumps({
        "title": title,
        "body": body,
        "labels": label_ids,
    }).encode()

    url = f"{gitea_base}/api/v1/repos/{repo}/issues"
    req = urllib.request.Request(
        url,
        data=payload,
        method="POST",
        headers={
            "Authorization": f"token {token}",
            "Content-Type": "application/json",
        },
    )

    try:
        with urllib.request.urlopen(req) as resp:
            issue = json.loads(resp.read())
    except urllib.error.HTTPError as exc:
        body_bytes = exc.read()
        raise RuntimeError(
            f"Gitea API error {exc.code}: {body_bytes.decode(errors='replace')}"
        ) from exc

    return issue["html_url"]


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def _build_body_interactively() -> str:
    """Minimal interactive prompt when --body is not provided."""
    print("Answer these questions (press Enter to skip optional ones):\n")
    page = input("Q1. Which page or feature is broken? ").strip()
    expected = input("Q2. What did you expect to happen? ").strip()
    actual = input("Q3. What actually happened? ").strip()
    pattern = input("Q4. Any pattern / conditions? (optional) ").strip()

    lines = ["## Bug Report", ""]
    if page:
        lines += [f"**Page / Feature:** {page}", ""]
    if expected:
        lines += ["**Expected:**", expected, ""]
    if actual:
        lines += ["**Actual:**", actual, ""]
    if pattern:
        lines += ["**Pattern / conditions:**", pattern, ""]
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="File a bug issue on Gitea")
    parser.add_argument("--repo", default="vmie/nps-lens", help="owner/repo")
    parser.add_argument("--title", required=True, help="Issue title")
    parser.add_argument("--body", default=None, help="Issue body (markdown). Prompts interactively if omitted.")
    parser.add_argument(
        "--flow",
        default="auto-fix",
        choices=list(FLOW_LABELS.keys()),
        help="Issue template flow",
    )
    parser.add_argument("--base", default=GITEA_BASE, help="Gitea base URL")
    args = parser.parse_args()

    body = args.body or _build_body_interactively()
    url = create_issue(
        repo=args.repo,
        title=args.title,
        body=body,
        flow=args.flow,
        gitea_base=args.base,
    )
    print(f"\nIssue filed: {url}")
    print("The debug pipeline will investigate and post a diagnosis comment shortly.")


if __name__ == "__main__":
    main()
