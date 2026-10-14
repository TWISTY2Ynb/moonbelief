#!/usr/bin/env python3
"""Reproducible LOC, test-declaration and conservative commit inventory."""
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args]).decode("utf-8").strip()

def main():
    inventory = []
    test_count = 0
    for path in sorted(ROOT.rglob("*.mbt")):
        relative = path.relative_to(ROOT)
        if any(part in ("_build", ".mooncakes", "target") for part in relative.parts):
            continue
        lines = path.read_text(encoding="utf-8").splitlines()
        if path.name.endswith(("_test.mbt", "_wbtest.mbt")):
            test_count += sum(bool(re.match(r'^test(?: |$)', line)) for line in lines)
            continue
        if len(relative.parts) != 1:
            continue  # Excludes examples, fixtures, generated artifacts and thin CLI.
        code = sum(bool(line.strip()) and not line.lstrip().startswith("//") for line in lines)
        inventory.append({"path": relative.as_posix(), "physical": len(lines), "nonblank_noncomment": code})
    commits = []
    for sha in git("rev-list", "--reverse", "HEAD").splitlines():
        paths = git("diff-tree", "--root", "--no-commit-id", "--name-only", "-r", sha).splitlines()
        meaningful = [p for p in paths if p.endswith(".mbt") or p.startswith("scripts/") or p.startswith(".github/workflows/")]
        if meaningful:
            commits.append({"sha": sha, "purpose": git("show", "-s", "--format=%s", sha), "paths": meaningful})
    physical = sum(item["physical"] for item in inventory)
    code = sum(item["nonblank_noncomment"] for item in inventory)
    if physical < 1500 or code < 1500 or len(commits) < 20:
        raise SystemExit("engineering threshold not met")
    print(json.dumps({"production_physical": physical, "production_nonblank_noncomment": code,
                      "test_declarations": test_count, "conservative_engineering_commits": len(commits),
                      "files": inventory, "commits": commits}, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
