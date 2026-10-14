///|
fn check_survival_threshold(min_survival : Double) -> Unit raise BeliefError {
  if !finite(min_survival) || min_survival < 0.0 || min_survival >= 1.0 {
    raise Invalid("minimum survival must be finite and in [0,1)")
  }
}

///|
/// Removes explicit conflict by conditioning on nonempty mass.
/// Summing surviving focals directly avoids catastrophic 1-conflict cancellation.
pub fn Mass::normalize(
  self : Mass,
  min_survival? : Double = 1.0e-12,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  check_survival_threshold(min_survival)
  budget.check_dense(self.domain)
  let surviving = self.survival()
  if surviving <= min_survival {
    raise TotalConflict
  }
  let bins = Array::make(self.domain.universe() + 1, 0.0)
  for (mask, value) in self.focals {
    if mask != 0 {
      bins[mask] = value / surviving
    }
  }
  from_bins(self.domain, bins, budget)
}

///|
/// Dempster's normalized conjunctive rule, with an explicit instability gate.
pub fn dempster(
  a : Mass,
  b : Mass,
  min_survival? : Double = 1.0e-12,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  check_survival_threshold(min_survival)
  conjunctive(a, b, budget~).normalize(min_survival~, budget~)
}
