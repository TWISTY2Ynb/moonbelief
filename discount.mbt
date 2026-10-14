///|
/// Shafer reliability discounting: alpha scales every focal, including empty,
/// then 1-alpha is transferred to the full frame. Reliability is supplied,
/// never inferred from agreement. This is not a source-dependence correction.
pub fn Mass::discount(
  self : Mass,
  reliability : Double,
  budget~ : Limits = default_limits(),
) -> Mass raise BeliefError {
  if !finite(reliability) || reliability < 0.0 || reliability > 1.0 {
    raise Invalid("reliability must be finite and in [0,1]")
  }
  budget.check_dense(self.domain)
  let bins = Array::make(self.domain.universe() + 1, 0.0)
  for (mask, value) in self.focals {
    bins[mask] = reliability * value
  }
  let universe = self.domain.universe()
  bins[universe] = bins[universe] + (1.0 - reliability)
  from_bins(self.domain, bins, budget)
}

///|
/// Explicitly move all nonsingleton nonempty masses to the full frame.
/// Conflict and singleton commitments are retained; no hidden pruning occurs.
pub fn Mass::forget_detail(
  self : Mass,
  budget~ : Limits = default_limits(),
) -> Mass raise BeliefError {
  budget.check_dense(self.domain)
  let bins = Array::make(self.domain.universe() + 1, 0.0)
  let universe = self.domain.universe()
  for (mask, value) in self.focals {
    let target = if cardinality(mask) > 1 { universe } else { mask }
    bins[target] = bins[target] + value
  }
  from_bins(self.domain, bins, budget)
}
