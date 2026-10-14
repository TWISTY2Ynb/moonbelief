# Provenance and license boundaries

MoonBelief is an original MoonBit implementation licensed MIT (see LICENSE). Its only runtime/library dependency is MoonBit core. The independently authored integer-mask representation, compensated bins, resource accounting, JSON protocol, workflows and tests are part of this repository.

Mathematical reference terms include Dempster–Shafer belief/plausibility/commonality, the transferable-belief pignistic projection, Yager, Dubois–Prade, pairwise PCR5 and Jousselme distance. Naming an algorithm is not endorsement, calibration evidence or an assertion that competing fusion assumptions coincide.

Reference software: [Thomas Reineking, pyds](https://github.com/reineking/pyds), BSD-3-Clause (copyright 2012 Thomas Reineking). Its Python source and LICENSE were inspected outside this repository. No source, documentation prose or fixtures were copied, so this is not a port and the upstream license is not substituted for this project's MIT license. pyds README explicitly says it is no longer maintained and recommends considering probabilistic alternatives.

`scripts/differential.py` is self-authored. It constructs 12 source pairs from six small rational masses and checks six rules through the actual MoonBit CLI (72 cases). It optionally imports a user-supplied local pyds file with `--pyds-path`; it does not download or redistribute it. Only conjunctive, normalized conjunctive and disjunctive results are compared to upstream, 35 cases excluding normalized total conflict. Yager, Dubois–Prade and PCR5 are checked against the separately implemented Fraction/set oracle, not misrepresented as pyds-supported comparisons.

`reference_wbtest.mbt` generates its own quarter-grid masses and uses membership enumeration rather than the production intersection/bin helpers. Test inputs are synthetic, not copied datasets. Ecosystem comparison projects listed in the duplication report were inspected only as research and are not code dependencies or bundled sources.
