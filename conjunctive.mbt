///|
fn pair_budget(a : Mass, b : Mass, budget : Limits) -> Unit raise BeliefError {
  same_frame(a, b)
  budget.check_dense(a.domain)
  if a.focal_count() > budget.pairs / b.focal_count() {
    raise Budget("focal cross product exceeds pair budget")
  }
}

///|
/// Unnormalized conjunctive fusion: each pair transfers mass to intersection.
/// Empty intersections are preserved as conflict, never renormalized here.
pub fn conjunctive(
  a : Mass,
  b : Mass,
  budget~ : Limits = default_limits(),
) -> Mass raise BeliefError {
  pair_budget(a, b, budget)
  let bins = Array::make(a.domain.universe() + 1, 0.0)
  let corrections = Array::make(bins.length(), 0.0)
  for (left, x) in a.focals {
    for (right, y) in b.focals {
      let target = left & right
      let adjusted = x * y - corrections[target]
      let next = bins[target] + adjusted
      corrections[target] = next - bins[target] - adjusted
      bins[target] = next
    }
  }
  from_bins(a.domain, bins, budget)
}
