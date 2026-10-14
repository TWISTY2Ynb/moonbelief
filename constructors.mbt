///|
pub fn vacuous(
  f : Frame,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  mass(f, [(f.universe(), 1.0)], budget~)
}

///|
/// Simple support does not silently create empty-set conflict.
pub fn simple_support(
  f : Frame,
  event : Int,
  support : Double,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  f.check_mask(event)
  if event == 0 || !finite(support) || support < 0.0 || support > 1.0 {
    raise Invalid(
      "simple support requires a nonempty event and support in [0,1]",
    )
  }
  mass(f, [(event, support), (f.universe(), 1.0 - support)], budget~)
}

///|
/// Bayesian mass: one explicit probability for each hypothesis in frame order.
pub fn bayesian(
  f : Frame,
  probabilities : Array[Double],
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  if probabilities.length() != f.size() {
    raise Invalid("probability vector must match frame size")
  }
  let entries : Array[(Int, Double)] = []
  for i = 0; i < probabilities.length(); i = i + 1 {
    entries.push((1 << i, probabilities[i]))
  }
  mass(f, entries, budget~)
}

///|
fn same_frame(a : Mass, b : Mass) -> Unit raise BeliefError {
  if a.domain != b.domain {
    raise FrameMismatch
  }
}

///|
/// Convex pooling is an alternative to independent-evidence fusion.
/// alpha is the weight of the first source, not a reliability estimate.
pub fn mixture(
  a : Mass,
  b : Mass,
  alpha : Double,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  same_frame(a, b)
  if !finite(alpha) || alpha < 0.0 || alpha > 1.0 {
    raise Invalid("mixture weight must be finite and in [0,1]")
  }
  budget.check_dense(a.domain)
  let bins = Array::make(a.domain.universe() + 1, 0.0)
  for (mask, value) in a.focals {
    bins[mask] = value * alpha
  }
  for (mask, value) in b.focals {
    bins[mask] = bins[mask] + value * (1.0 - alpha)
  }
  from_bins(a.domain, bins, budget)
}
