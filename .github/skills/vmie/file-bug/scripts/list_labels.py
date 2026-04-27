"""
list_labels.py — Print current Gitea label IDs for a repo.
Run this when create_issue.py returns HTTP 422 to refresh the IDs in REPO_LABELS.

Usage:
    python list_labels.py
    python list_labels.py --repo vmie/nps-lens --base http://git.local:8090
"""

import argparse
import json
import os
import urllib.request
from pathlib import Path


GITEA_BASE = os.environ.get("GITEA_BASE", "http://git.local:8090")


def _resolve_token() -> str:
    token = os.environ.get("GITEA_TOKEN") or os.environ.get("VMIE_BOT_TOKEN")
    if token:
        return token
    for candidate in [Path("config/.env.gitea"), Path("config/.env.api"), Path(".env")]:
        if candidate.exists():
            for line in candidate.read_text().splitlines():
                if line.startswith("GITEA_TOKEN=") or line.startswith("VMIE_BOT_TOKEN="):
                    return line.split("=", 1)[1].strip().strip('"').strip("'")
    return "***REDACTED-HASH***"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", default="vmie/nps-lens")
    parser.add_argument("--base", default=GITEA_BASE)
    args = parser.parse_args()

    token = _resolve_token()
    url = f"{args.base}/api/v1/repos/{args.repo}/labels"
    req = urllib.request.Request(url, headers={"Authorization": f"token {token}"})
    with urllib.request.urlopen(req) as resp:
        labels = json.loads(resp.read())

    print(f"Labels for {args.repo}:")
    for label in sorted(labels, key=lambda l: l["id"]):
        print(f"  {label['id']:3d}  {label['name']}")

    print("\nUpdate REPO_LABELS in create_issue.py with these IDs if they differ.")


if __name__ == "__main__":
    main()
