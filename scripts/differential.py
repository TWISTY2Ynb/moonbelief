#!/usr/bin/env python3
"""Self-authored exact-rational oracle; optional separately obtained pyds reference."""
import argparse
import importlib.util
import itertools
import json
import subprocess
from fractions import Fraction as Q
from pathlib import Path

LABELS = ["a", "b", "c"]
RULES = ["conjunctive", "dempster", "disjunctive", "yager", "dubois-prade", "pairwise-pcr5"]

def members(mask):
    return frozenset(i for i in range(3) if mask // (2 ** i) % 2)

def mask_of(subset):
    return sum(2 ** i for i in subset)

def oracle(a, b, rule):
    result = [Q(0) for _ in range(8)]
    for left, x in a.items():
        for right, y in b.items():
            common = mask_of(members(left) & members(right))
            union = mask_of(members(left) | members(right))
            product = x * y
            if rule == "disjunctive":
                result[union] += product
            elif rule == "dubois-prade":
                result[common if common else union] += product
            elif rule == "pairwise-pcr5" and not common:
                result[left] += x * x * y / (x + y)
                result[right] += y * y * x / (x + y)
            else:
                result[common] += product
    if rule == "yager":
        result[7] += result[0]
        result[0] = Q(0)
    if rule == "dempster":
        surviving = sum(result[1:])
        if not surviving:
            return None
        result = [Q(0)] + [v / surviving for v in result[1:]]
    return result

def rows(weights):
    return [{"subset": [LABELS[i] for i in members(k)], "mass": float(v)} for k, v in weights.items()]

def check_close(a, b):
    if abs(float(a) - float(b)) > 1e-9:
        raise AssertionError("numeric differential mismatch")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--pyds-path", type=Path, help="optional local BSD reference, never downloaded by this script")
    args = parser.parse_args()
    upstream = None
    if args.pyds_path:
        spec = importlib.util.spec_from_file_location("pyds_reference", str(args.pyds_path))
        upstream = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(upstream)
    root = Path(__file__).resolve().parents[1]
    cases = [{1: Q(3, 4), 7: Q(1, 4)}, {2: Q(1, 2), 7: Q(1, 2)},
             {3: Q(2, 3), 7: Q(1, 3)}, {1: Q(1)}, {2: Q(1)}, {4: Q(1, 3), 7: Q(2, 3)}]
    pairs = [(cases[i], cases[(i + shift) % 6]) for i in range(6) for shift in (1, 3)]
    comparisons = 0
    upstream_checks = 0
    conflict_cases = 0
    for a, b in pairs:
        for rule in RULES:
            expected = oracle(a, b, rule)
            request = {"schema": "moonbelief.request.v1", "frame": LABELS, "rule": rule,
                       "sources": [{"name": "left", "masses": rows(a)}, {"name": "right", "masses": rows(b)}],
                       "queries": [[LABELS[i] for i in members(k)] for k in range(8)]}
            run = subprocess.run(["moon", "-C", str(root), "run", "cmd/moonbelief", "--target", "wasm-gc", "--quiet", "--", json.dumps(request)],
                                 capture_output=True, text=True, encoding="utf-8", timeout=120)
            if run.returncode:
                raise RuntimeError("differential command failed")
            actual = json.loads(run.stdout)
            if expected is None or sum(expected[1:]) == 0:
                if actual.get("kind") != "total-conflict":
                    raise AssertionError("total conflict was not explicit")
                conflict_cases += 1
            else:
                dense = [0.0] * 8
                for row in actual["mass"]["masses"]:
                    mask = sum(2 ** LABELS.index(name) for name in row["subset"])
                    dense[mask] = row["mass"]
                for x, y in zip(dense, expected):
                    check_close(x, y)
                for k, query in enumerate(actual["queries"]):
                    bel = sum(expected[j] for j in range(1, 8) if members(j) <= members(k))
                    pl = sum(expected[j] for j in range(8) if members(j) & members(k))
                    check_close(query["belief"], bel)
                    check_close(query["plausibility"], pl)
                survival = sum(expected[1:])
                for item in actual["ranking"]:
                    i = LABELS.index(item["label"])
                    probability = sum(expected[k] / len(members(k)) for k in range(1, 8) if i in members(k)) / survival
                    check_close(item["pignistic"], probability)
            if upstream and rule in ("conjunctive", "dempster", "disjunctive") and expected is not None:
                left = upstream.MassFunction({frozenset(LABELS[i] for i in members(k)): float(v) for k, v in a.items()})
                right = upstream.MassFunction({frozenset(LABELS[i] for i in members(k)): float(v) for k, v in b.items()})
                ref = left.combine_disjunctive(right) if rule == "disjunctive" else left.combine_conjunctive(right, normalization=rule == "dempster")
                for k in range(8):
                    check_close(ref[frozenset(LABELS[i] for i in members(k))], expected[k])
                upstream_checks += 1
            comparisons += 1
    print(json.dumps({"rational_rule_cases": comparisons, "explicit_conflict_cases": conflict_cases,
                      "pyds_rule_comparisons": upstream_checks, "status": "passed"}, sort_keys=True))

if __name__ == "__main__":
    main()
