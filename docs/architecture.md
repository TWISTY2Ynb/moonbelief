# Architecture and semantic contracts

`Frame` fixes an ordered, finite set of mutually exclusive exhaustive labels. `Int` masks are safe up to 16 bits; masks are validated before enumeration or allocation. `Mass` stores copied sparse positive entries in deterministic mask order, including empty-set conflict. Constructors validate totals; computational `from_bins` validates and normalizes accumulated nonnegative mass. Limits are immutable and can only narrow hard ceilings.

## Layers

1. **Domain**: error/frame/subsets/limits/mass. Kahan-style compensated accumulation is used where many focal contributions converge; outward arrays are copies.
2. **Calculus**: queries/constructors/normalization/discount/conditioning. Belief excludes empty support; plausibility uses nonempty intersection. Commonality of the empty set is total mass, including conflict.
3. **Fusion**: conjunctive, alternative_rules and pcr5 implement separate explicit conflict policies. Dempster normalizes conjunctive output; pairwise PCR5 requires zero input conflict. Rules encode assumptions, not interchangeable approximations.
4. **Lattices and representation**: transforms use bounded subset/superset sweeps; coarsen maps each fine atom onto a coarse atom, refine requires disjoint nonempty covering blocks. Alignment is explicit because label order is semantic.
5. **Decisions**: pignistic divides nonempty mass uniformly within each focal subset, then by nonempty survival. Utilities use supplied units. Policy rejection still returns the leading candidate and reason; accepted is a separate field, not a guarantee of correctness.
6. **Audit workflows**: pipeline discounts sources, performs deterministic left folds and records conjunctive diagnostic conflict before each rule. Both diagnostic and actual rule pair work count. Sensitivity reruns share the supplied global work allowance. They are not causal explanations or automated trust estimation.
7. **Boundary**: JSON validates shapes and unknown fields; the bounded text prescan counts container depth outside escaped strings. Core JSON resolves duplicate keys last-value-wins. Pure request functions perform no I/O; CLI handles one JSON argument and emits one JSON response.

## Complexity and guarantees

Sparse fusion work is O(f₁·f₂), checked before looping. Dense transforms use O(2^n) memory and O(n·2^n) work, n≤16. Jousselme operates on the union of differing focals with a pair budget; it is not promised cheap for all sparse inputs. No timing, calibration, hard-real-time or concurrent-source guarantees are made.

Floating point uses Double. Input sum tolerance is 1e-10, inverse residual tolerance 1e-12, default minimum normalization survival 1e-12. These are separate contracts. Conservative threshold errors are preferable to NaN rankings. Defaults can be tightened; survival thresholds can be supplied in [0,1). See generated interface for exact optional labels.

Mass query methods do not mutate input; transformations return independent values. No cancellation or streaming API exists. The 262144-code-unit cap bounds text, not arbitrary in-memory caller-created Json nodes; object/array counts still undergo schema checks. Applications must bound any data before constructing external Json values.
