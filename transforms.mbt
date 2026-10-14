///|
/// A copy of mass values in integer-mask order, including empty set at index 0.
pub fn Mass::dense(
  self : Mass,
  budget~ : Limits = default_limits(),
) -> Array[Double] raise BeliefError {
  budget.check_dense(self.domain)
  let result = Array::make(self.domain.universe() + 1, 0.0)
  for (mask, value) in self.focals {
    result[mask] = value
  }
  result
}

///|
fn lattice_transform(
  f : Frame,
  values : Array[Double],
  inverse : Bool,
  supersets : Bool,
  budget : Limits,
) -> Array[Double] raise BeliefError {
  budget.check_dense(f)
  if values.length() != f.universe() + 1 {
    raise Invalid("lattice vector shape must equal powerset size")
  }
  for value in values {
    if !finite(value) {
      raise Invalid("lattice transform requires finite values")
    }
  }
  let result = values.copy()
  for bit = 0; bit < f.size(); bit = bit + 1 {
    let flag = 1 << bit
    for mask = 0; mask < result.length(); mask = mask + 1 {
      let active = if supersets {
        (mask & flag) == 0
      } else {
        (mask & flag) != 0
      }
      if active {
        let other = if supersets { mask | flag } else { mask ^ flag }
        result[mask] = if inverse {
          result[mask] - result[other]
        } else {
          result[mask] + result[other]
        }
        if !finite(result[mask]) {
          raise Invalid("lattice transform overflow")
        }
      }
    }
  }
  result
}

///|
pub fn subset_zeta(
  f : Frame,
  values : Array[Double],
  budget~ : Limits = default_limits(),
) -> Array[Double] raise BeliefError {
  lattice_transform(f, values, false, false, budget)
}

///|
pub fn subset_mobius(
  f : Frame,
  values : Array[Double],
  budget~ : Limits = default_limits(),
) -> Array[Double] raise BeliefError {
  lattice_transform(f, values, true, false, budget)
}

///|
pub fn superset_zeta(
  f : Frame,
  values : Array[Double],
  budget~ : Limits = default_limits(),
) -> Array[Double] raise BeliefError {
  lattice_transform(f, values, false, true, budget)
}

///|
pub fn superset_mobius(
  f : Frame,
  values : Array[Double],
  budget~ : Limits = default_limits(),
) -> Array[Double] raise BeliefError {
  lattice_transform(f, values, true, true, budget)
}

///|
pub fn Mass::belief_table(
  self : Mass,
  budget~ : Limits = default_limits(),
) -> Array[Double] raise BeliefError {
  let result = subset_zeta(self.domain, self.dense(budget~), budget~)
  let conflict = self.conflict()
  for i = 0; i < result.length(); i = i + 1 {
    result[i] = result[i] - conflict
  }
  result
}

///|
pub fn Mass::commonality_table(
  self : Mass,
  budget~ : Limits = default_limits(),
) -> Array[Double] raise BeliefError {
  superset_zeta(self.domain, self.dense(budget~), budget~)
}

///|
/// Invert a normalized commonality vector; negative rounding noise <=1e-12
/// may be clamped, but inconsistent vectors are rejected, never renormalized.
pub fn from_commonality(
  f : Frame,
  values : Array[Double],
  budget~ : Limits = default_limits(),
) -> Mass raise BeliefError {
  let bins = superset_mobius(f, values, budget~)
  let entries : Array[(Int32, Double)] = []
  for mask = 0; mask < bins.length(); mask = mask + 1 {
    let value = bins[mask]
    if value < -1.0e-12 || value > 1.0 + 1.0e-12 {
      raise Invalid("commonality vector does not invert to a valid mass")
    }
    if value > 0.0 {
      entries.push((mask, if value > 1.0 { 1.0 } else { value }))
    }
  }
  mass(f, entries, budget~)
}
