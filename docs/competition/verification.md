# Reproducible verification inventory

Audit date: 2026-10-14. This file records method and locally observed results; actual clean-runner outcomes are the repository Actions runs, not a promise inferred from this text.

## Counting

`python scripts/audit.py` counts only root production `.mbt`, excluding test suffixes, generated interfaces, examples and the thin command. Measured implementation: **2062 physical / 1700 nonblank noncomment lines**. Scripts, docs and data do not contribute. The same script inventories reachable commits touching real implementation/tests/scripts/CI; the initial documentation-only setup is conservatively excluded. It emits SHA, purpose and paths so line count is not confused with engineering value.

## Test scope

- 35 MoonBit test declarations (not a coverage percentage).
- Closed-world: 35 quarter-grid masses, 1225 ordered pairs × six rules = 7350 outcomes.
- Open-world: 35 quarter-grid masses, 1225 ordered pairs × five applicable rules = 6125 outcomes.
- Total: **13,475 enumerated rule outcomes**, including explicit total-conflict errors. Independent oracle enumerates label membership rather than calling production lattice helpers.
- Other tests exercise input mutation isolation, mask/frame errors, sparse/dense transforms and inversion, utility decisions, alignment, refinement/coarsening, JSON round trips, aggregate budgets, complete/tiny survival and nonassociative fold order.
- Actual command differential: **72** Fraction/set cases over six rules, all eight event queries and pignistic rankings, with **two explicit conflict responses**.
- Optional locally inspected BSD pyds reference: **35** rule comparisons, passed. Not all six rules exist in that upstream; see provenance. This optional dependency is deliberately not downloaded in CI.
- Three runnable examples have separate objective JSON assertions in `scripts/check_examples.py`. No benchmark speed or coverage-rate claim is made.

## Target evidence

Windows: strict check/test/build passed wasm-gc, wasm and js; all 35 tests passed each. Native strict check passed; local test/build could not execute because cc/gcc/clang is absent. Linux CI independently executes all four targets, including native with the runner C compiler. Use public Actions evidence to determine actual native execution.

`moon info && moon fmt` regenerates interfaces, and CI rejects resulting diffs. Toolchain archives are SHA-256 pinned and ETag constrained in `scripts/install-ci-toolchain.sh`; pin changes fail closed rather than fetching silently changed latest binaries.

## Release acceptance

Release acceptance also requires real green CI at the exact public commit, same-account metadata, archive/privacy inspection, matching tag and a credential-free empty-cache consumer installing the exact published version. Those external facts are recorded at delivery, not fabricated by unit tests. Private participant material is intentionally not part of this source tree.
