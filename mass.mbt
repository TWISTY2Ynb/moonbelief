///|
/// Sparse canonical mass assignment; empty-set mass is retained explicitly.
pub struct Mass {
  priv domain : Frame
  priv focals : Array[(Int32, Double)]
} derive(Debug, Eq)

///|
pub extend Mass with @debug.Debug::{to_repr}

///|
pub extend Mass with Eq::{equal, not_equal}

///|
fn finite(x : Double) -> Bool {
  !x.is_nan() && x != 1.0 / 0.0 && x != -1.0 / 0.0
}

///|
fn magnitude(x : Double) -> Double {
  if x < 0.0 {
    -x
  } else {
    x
  }
}

///|
fn stable_sum(values : Array[Double]) -> Double {
  let mut sum = 0.0
  let mut correction = 0.0
  for value in values {
    let y = value - correction
    let next = sum + y
    correction = next - sum - y
    sum = next
  }
  sum
}

///|
/// Duplicate subsets are merged; totals must be one within 1e-10.
/// Tiny positive focals are preserved, not pruned by a hidden threshold.
pub fn mass(
  f : Frame,
  entries : Array[(Int32, Double)],
  budget~ : Limits = default_limits(),
) -> Mass raise BeliefError {
  budget.check_dense(f)
  if entries.length() == 0 {
    raise Invalid("mass requires at least one entry")
  }
  if entries.length() > budget.focals {
    raise Budget("input focal budget exceeded")
  }
  let bins = Array::make(f.universe() + 1, 0.0)
  let corrections = Array::make(bins.length(), 0.0)
  for (mask, value) in entries {
    f.check_mask(mask)
    if !finite(value) || value < 0.0 || value > 1.0 {
      raise Invalid("mass weight must be finite and within [0,1]")
    }
    let y = value - corrections[mask]
    let next = bins[mask] + y
    corrections[mask] = next - bins[mask] - y
    bins[mask] = next
  }
  let total = stable_sum(bins)
  if magnitude(total - 1.0) > 1.0e-10 {
    raise Invalid("mass weights must sum to one")
  }
  from_bins(f, bins, budget)
}

///|
fn from_bins(
  f : Frame,
  bins : Array[Double],
  budget : Limits,
) -> Mass raise BeliefError {
  budget.check_dense(f)
  if bins.length() != f.universe() + 1 {
    raise Invalid("dense mass shape mismatch")
  }
  let total = stable_sum(bins)
  if !finite(total) || total <= 0.0 {
    raise Invalid("mass has no finite positive total")
  }
  let result : Array[(Int32, Double)] = []
  for mask = 0; mask < bins.length(); mask = mask + 1 {
    let value = bins[mask]
    if !finite(value) || value < 0.0 {
      raise Invalid("invalid computed mass weight")
    }
    if value > 0.0 {
      if result.length() >= budget.focals {
        raise Budget("output focal budget exceeded")
      }
      result.push((mask, value / total))
    }
  }
  { domain: f, focals: result, }
}

///|
pub fn Mass::frame(self : Mass) -> Frame {
  self.domain
}

///|
pub fn Mass::entries(self : Mass) -> Array[(Int32, Double)] {
  self.focals.copy()
}

///|
pub fn Mass::focal_count(self : Mass) -> Int32 {
  self.focals.length()
}

///|
pub fn Mass::weight(self : Mass, mask : Int32) -> Double raise BeliefError {
  self.domain.check_mask(mask)
  for (subset, value) in self.focals {
    if subset == mask {
      return value
    }
    if subset > mask {
      break
    }
  }
  0.0
}

///|
pub fn Mass::conflict(self : Mass) -> Double {
  if self.focals[0].0 == 0 {
    self.focals[0].1
  } else {
    0.0
  }
}
