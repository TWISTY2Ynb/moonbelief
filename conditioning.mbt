///|
/// Conditioning by certain event evidence. Incompatible mass stays empty.
/// An impossible/empty observation is rejected rather than fabricated.
pub fn Mass::condition_open(
  self : Mass,
  event : Int,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  self.domain.check_mask(event)
  if event == 0 {
    raise Invalid("conditioning event must be nonempty")
  }
  budget.check_dense(self.domain)
  let bins = Array::make(self.domain.universe() + 1, 0.0)
  let corrections = Array::make(bins.length(), 0.0)
  for (mask, value) in self.focals {
    let target = mask & event
    let adjusted = value - corrections[target]
    let next = bins[target] + adjusted
    corrections[target] = next - bins[target] - adjusted
    bins[target] = next
  }
  from_bins(self.domain, bins, budget)
}

///|
/// Closed-world conditioning uses the same near-total-conflict gate as Dempster.
pub fn Mass::condition(
  self : Mass,
  event : Int,
  min_survival? : Double = 1.0e-12,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  check_survival_threshold(min_survival)
  self.condition_open(event, budget~).normalize(min_survival~, budget~)
}

///|
/// Conditional belief/plausibility bounds, not a posterior probability vector.
pub fn Mass::conditional_interval(
  self : Mass,
  query : Int,
  given : Int,
  min_survival? : Double = 1.0e-12,
  budget? : Limits = default_limits(),
) -> (Double, Double) raise BeliefError {
  self.domain.check_mask(query)
  self.condition(given, min_survival~, budget~).interval(query)
}
