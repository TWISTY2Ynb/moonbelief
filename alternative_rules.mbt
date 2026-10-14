///|
/// Disjunctive fusion transfers each focal pair to its union.
/// This is an alternative source model, not interchangeable with conjunction.
pub fn disjunctive(
  a : Mass,
  b : Mass,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  pair_budget(a, b, budget)
  let bins = Array::make(a.domain.universe() + 1, 0.0)
  let corrections = Array::make(bins.length(), 0.0)
  for (left, x) in a.focals {
    for (right, y) in b.focals {
      let target = left | right
      let adjusted = x * y - corrections[target]
      let next = bins[target] + adjusted
      corrections[target] = next - bins[target] - adjusted
      bins[target] = next
    }
  }
  from_bins(a.domain, bins, budget)
}

///|
/// Yager transfers all conjunctive conflict to the full frame.
pub fn yager(
  a : Mass,
  b : Mass,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  let c = conjunctive(a, b, budget~)
  let bins = Array::make(a.domain.universe() + 1, 0.0)
  for (mask, value) in c.focals {
    if mask == 0 {
      bins[a.domain.universe()] = bins[a.domain.universe()] + value
    } else {
      bins[mask] = bins[mask] + value
    }
  }
  from_bins(a.domain, bins, budget)
}

///|
/// Dubois-Prade transfers each incompatible pair to its union.
/// Both-empty pairs stay empty; open-world inputs are not silently normalized.
pub fn dubois_prade(
  a : Mass,
  b : Mass,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  pair_budget(a, b, budget)
  let bins = Array::make(a.domain.universe() + 1, 0.0)
  let corrections = Array::make(bins.length(), 0.0)
  for (left, x) in a.focals {
    for (right, y) in b.focals {
      let intersection = left & right
      let target = if intersection == 0 { left | right } else { intersection }
      let adjusted = x * y - corrections[target]
      let next = bins[target] + adjusted
      corrections[target] = next - bins[target] - adjusted
      bins[target] = next
    }
  }
  from_bins(a.domain, bins, budget)
}
