///|
/// Sum of nonempty focal masses included in the event (unnormalized TBM).
pub fn Mass::belief(self : Mass, event : Int) -> Double raise BeliefError {
  self.domain.check_mask(event)
  let values : Array[Double] = []
  for (mask, value) in self.focals {
    if mask != 0 && (mask & event) == mask {
      values.push(value)
    }
  }
  stable_sum(values)
}

///|
/// Sum of masses intersecting the event; empty-set conflict contributes zero.
pub fn Mass::plausibility(self : Mass, event : Int) -> Double raise BeliefError {
  self.domain.check_mask(event)
  let values : Array[Double] = []
  for (mask, value) in self.focals {
    if (mask & event) != 0 {
      values.push(value)
    }
  }
  stable_sum(values)
}

///|
/// Commonality includes empty-set mass only when event is empty.
pub fn Mass::commonality(self : Mass, event : Int) -> Double raise BeliefError {
  self.domain.check_mask(event)
  let values : Array[Double] = []
  for (mask, value) in self.focals {
    if (mask & event) == event {
      values.push(value)
    }
  }
  stable_sum(values)
}

///|
pub fn Mass::interval(
  self : Mass,
  event : Int,
) -> (Double, Double) raise BeliefError {
  (self.belief(event), self.plausibility(event))
}

///|
/// Nonspecificity: total nonempty mass assigned to nonsingleton subsets.
/// This is not Shannon entropy and is distinct from mass on the full frame.
pub fn Mass::nonspecific_mass(self : Mass) -> Double {
  let values : Array[Double] = []
  for (mask, value) in self.focals {
    if cardinality(mask) > 1 {
      values.push(value)
    }
  }
  stable_sum(values)
}

///|
pub fn Mass::ignorance(self : Mass) -> Double raise BeliefError {
  self.weight(self.domain.universe())
}

///|
/// Surviving mass is summed directly to avoid cancellation of 1-conflict.
pub fn Mass::survival(self : Mass) -> Double {
  let values : Array[Double] = []
  for (mask, value) in self.focals {
    if mask != 0 {
      values.push(value)
    }
  }
  stable_sum(values)
}
