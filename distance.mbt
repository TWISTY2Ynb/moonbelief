///|
fn jaccard_kernel(a : Int, b : Int) -> Double {
  let union = a | b
  if union == 0 {
    1.0
  } else {
    cardinality(a & b).to_double() / cardinality(union).to_double()
  }
}

///|
/// Jousselme distance with D(empty,empty)=1. Different frames are rejected.
/// Work is quadratic in the union of nonzero difference focals, not powerset.
pub fn jousselme(
  a : Mass,
  b : Mass,
  budget? : Limits = default_limits(),
) -> Double raise BeliefError {
  same_frame(a, b)
  let left = a.dense(budget~)
  let right = b.dense(budget~)
  let differences : Array[(Int, Double)] = []
  for mask = 0; mask < left.length(); mask = mask + 1 {
    let delta = left[mask] - right[mask]
    if delta != 0.0 {
      differences.push((mask, delta))
    }
  }
  let count = differences.length()
  if count == 0 {
    return 0.0
  }
  if count > budget.pairs / count {
    raise Budget("distance kernel exceeds pair budget")
  }
  let row_sums : Array[Double] = []
  for (mask, delta) in differences {
    let terms : Array[Double] = []
    for (other, other_delta) in differences {
      terms.push(delta * other_delta * jaccard_kernel(mask, other))
    }
    row_sums.push(stable_sum(terms))
  }
  let squared = stable_sum(row_sums) * 0.5
  if squared < -1.0e-12 {
    raise Invalid("distance numerical failure")
  }
  if squared <= 0.0 {
    0.0
  } else {
    squared.sqrt()
  }
}

///|
/// Total variation of focal-mass vectors (not a belief metric).
pub fn focal_total_variation(
  a : Mass,
  b : Mass,
  budget? : Limits = default_limits(),
) -> Double raise BeliefError {
  same_frame(a, b)
  let left = a.dense(budget~)
  let right = b.dense(budget~)
  let terms : Array[Double] = []
  for mask = 0; mask < left.length(); mask = mask + 1 {
    terms.push(magnitude(left[mask] - right[mask]))
  }
  stable_sum(terms) * 0.5
}

///|
/// Largest difference over all belief queries, using bounded zeta transforms.
pub fn maximum_belief_difference(
  a : Mass,
  b : Mass,
  budget? : Limits = default_limits(),
) -> (Int, Double) raise BeliefError {
  same_frame(a, b)
  let left = a.belief_table(budget~)
  let right = b.belief_table(budget~)
  let mut event = 0
  let mut difference = 0.0
  for mask = 0; mask < left.length(); mask = mask + 1 {
    let candidate = magnitude(left[mask] - right[mask])
    if candidate > difference {
      event = mask
      difference = candidate
    }
  }
  (event, difference)
}
