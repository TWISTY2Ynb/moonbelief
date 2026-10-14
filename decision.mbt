///|
pub struct DecisionPolicy {
  priv conflict_ceiling : Double
  priv nonspecific_ceiling : Double
  priv required_margin : Double
} derive(Debug, Eq)

///|
pub extend DecisionPolicy with @debug.Debug::{to_repr}

///|
pub extend DecisionPolicy with Eq::{equal, not_equal}

///|
pub fn decision_policy(
  max_conflict~ : Double = 0.5,
  max_nonspecific~ : Double = 0.8,
  min_margin~ : Double = 0.05,
) -> DecisionPolicy raise BeliefError {
  if !finite(max_conflict) ||
    max_conflict < 0.0 ||
    max_conflict > 1.0 ||
    !finite(max_nonspecific) ||
    max_nonspecific < 0.0 ||
    max_nonspecific > 1.0 ||
    !finite(min_margin) ||
    min_margin < 0.0 {
    raise Invalid(
      "decision thresholds must be finite, nonnegative, and masses at most one",
    )
  }
  {
    conflict_ceiling: max_conflict,
    nonspecific_ceiling: max_nonspecific,
    required_margin: min_margin,
  }
}

///|
pub struct ActionDecision {
  index : Int32
  label : String
  expected_score : Double
  margin : Double
  accepted : Bool
  reason : String
  conflict : Double
  nonspecific : Double
} derive(Debug, Eq)

///|
pub extend ActionDecision with @debug.Debug::{to_repr}

///|
pub extend ActionDecision with Eq::{equal, not_equal}

///|
/// Rows are actions; columns are hypotheses in frame order. Limited to 64
/// actions and finite magnitudes <=1e12. Returned expectations use BetP.
pub fn Mass::expected_utilities(
  self : Mass,
  utilities : Array[Array[Double]],
) -> Array[Double] raise BeliefError {
  if utilities.length() == 0 || utilities.length() > 64 {
    raise Invalid("utility matrix requires 1..64 actions")
  }
  let probabilities = self.pignistic()
  let result : Array[Double] = []
  for row in utilities {
    if row.length() != self.domain.size() {
      raise Invalid("utility row must match hypothesis count")
    }
    let terms : Array[Double] = []
    for i = 0; i < row.length(); i = i + 1 {
      let value = row[i]
      if !finite(value) || magnitude(value) > 1.0e12 {
        raise Invalid(
          "utility entries must be finite and magnitude at most 1e12",
        )
      }
      terms.push(value * probabilities[i])
    }
    result.push(stable_sum(terms))
  }
  result
}

///|
/// Loss rows have the same layout, but must be nonnegative.
pub fn Mass::expected_losses(
  self : Mass,
  losses : Array[Array[Double]],
) -> Array[Double] raise BeliefError {
  if losses.length() == 0 || losses.length() > 64 {
    raise Invalid("loss matrix requires 1..64 actions")
  }
  for row in losses {
    if row.length() != self.domain.size() {
      raise Invalid("loss row must match hypothesis count")
    }
    for value in row {
      if value < 0.0 {
        raise Invalid("loss entries must be nonnegative")
      }
    }
  }
  self.expected_utilities(losses)
}

///|
/// Explicit supplied policy; equal scores keep the first action.
/// If only one action exists its margin is defined as zero, not infinity.
/// Margins have utility units, so caller must calibrate the policy accordingly.
pub fn Mass::decide(
  self : Mass,
  actions : Array[String],
  utilities : Array[Array[Double]],
  policy : DecisionPolicy,
) -> ActionDecision raise BeliefError {
  let scores = self.expected_utilities(utilities)
  if actions.length() != scores.length() {
    raise Invalid("action labels and utility rows must have equal counts")
  }
  for i = 0; i < actions.length(); i = i + 1 {
    if actions[i].length() == 0 || actions[i].length() > 256 {
      raise Invalid("action labels must have 1..256 characters")
    }
    for j = 0; j < i; j = j + 1 {
      if actions[i] == actions[j] {
        raise Invalid("action labels must be unique")
      }
    }
  }
  let mut best = 0
  for i = 1; i < scores.length(); i = i + 1 {
    if scores[i] > scores[best] {
      best = i
    }
  }
  let mut runner_up = scores[best]
  let mut has_runner = false
  for i = 0; i < scores.length(); i = i + 1 {
    if i != best && (!has_runner || scores[i] > runner_up) {
      runner_up = scores[i]
      has_runner = true
    }
  }
  let margin = scores[best] - runner_up
  let conflict = self.conflict()
  let nonspecific = self.nonspecific_mass()
  let reason = if conflict > policy.conflict_ceiling {
    "conflict exceeds policy"
  } else if nonspecific > policy.nonspecific_ceiling {
    "nonspecificity exceeds policy"
  } else if margin < policy.required_margin {
    "utility margin below policy"
  } else {
    "accepted by supplied policy"
  }
  {
    index: best,
    label: actions[best],
    expected_score: scores[best],
    margin,
    accepted: conflict <= policy.conflict_ceiling &&
    nonspecific <= policy.nonspecific_ceiling &&
    margin >= policy.required_margin,
    reason,
    conflict,
    nonspecific,
  }
}
