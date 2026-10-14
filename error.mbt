///|
pub(all) suberror BeliefError {
  Invalid(String)
  Budget(String)
  FrameMismatch
  TotalConflict
} derive(Debug, Eq)

///|
pub extend BeliefError with @debug.Debug::{to_repr}

///|
pub extend BeliefError with Eq::{equal, not_equal}
