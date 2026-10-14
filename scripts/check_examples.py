#!/usr/bin/env python3
"""Run actual workflows and assert objective JSON results, not just exit status."""
import argparse
import json
import math
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def run(package, target, *args):
    result = subprocess.run(["moon", "-C", str(ROOT), "run", package, "--target", target,
                             "--quiet", *args], capture_output=True, text=True, encoding="utf-8", timeout=180)
    if result.returncode:
        raise RuntimeError("workflow process failed: " + package + "\n" + result.stderr)
    return json.loads(result.stdout)

def close(actual, expected):
    if not math.isclose(actual, expected, abs_tol=1e-10, rel_tol=1e-10):
        raise AssertionError((actual, expected))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", default="wasm-gc", choices=["wasm-gc", "wasm", "js", "native"])
    target = parser.parse_args().target
    sensors = run("examples/sensors", target)
    assert sensors["workflow"] == "sensor-fusion"
    close(sensors["raw_pair_conflict"], 0.3456)
    close(sensors["conflict"], 0)
    close(sensors["ignorance"], 0.4912)
    close(sensors["clear_plausibility"], 0.8656)
    diagnostic = run("examples/diagnostics", target)
    close(diagnostic["power_belief"], 0.16)
    close(diagnostic["power_plausibility"], 0.76)
    close(diagnostic["hardware_belief"], 1)
    ensemble = run("examples/ensemble", target)
    assert ensemble["action"] == "accept" and ensemble["accepted"] is True
    close(ensemble["expected_utility"], 0.31)
    assert ensemble["winner_changes"] == [False, False, False]
    request = (ROOT / "examples/request.json").read_text(encoding="utf-8")
    report = run("cmd/moonbelief", target, "--", request)
    assert report["schema"] == "moonbelief.report.v1"
    close(report["queries"][0]["belief"], 0.7)
    close(report["queries"][0]["plausibility"], 1)
    error = run("cmd/moonbelief", target, "--", "{}")
    assert error["schema"] == "moonbelief.error.v1" and error["kind"] == "invalid"
    print(json.dumps({"target": target, "workflows": 3, "protocol_checks": 2, "status": "passed"}))

if __name__ == "__main__":
    main()
