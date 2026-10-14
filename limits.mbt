///|
/// Limits can tighten, never increase, the engine's hard resource ceilings.
pub struct Limits {
  priv focals : Int
  priv pairs : Int
  priv dense : Int
} derive(Debug, Eq)

///|
pub extend Limits with @debug.Debug::{to_repr}

///|
pub extend Limits with Eq::{equal, not_equal}

///|
pub fn limits(
  max_focals? : Int = 4096,
  max_pairs? : Int = 1000000,
  max_dense_cells? : Int = 65536,
) -> Limits raise BeliefError {
  if max_focals < 1 ||
    max_focals > 4096 ||
    max_pairs < 1 ||
    max_pairs > 1000000 ||
    max_dense_cells < 1 ||
    max_dense_cells > 65536 {
    raise Invalid("limits must be within positive hard ceilings")
  }
  { focals: max_focals, pairs: max_pairs, dense: max_dense_cells, }
}

///|
pub fn default_limits() -> Limits {
  { focals: 4096, pairs: 1000000, dense: 65536, }
}

///|
pub fn Limits::max_focals(self : Limits) -> Int {
  self.focals
}

///|
pub fn Limits::max_pairs(self : Limits) -> Int {
  self.pairs
}

///|
pub fn Limits::max_dense_cells(self : Limits) -> Int {
  self.dense
}

///|
fn Limits::check_dense(self : Limits, f : Frame) -> Unit raise BeliefError {
  if f.universe() + 1 > self.dense {
    raise Budget("dense powerset exceeds cell budget")
  }
}
