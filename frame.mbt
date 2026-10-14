///|
/// Ordered, exhaustive, mutually exclusive hypotheses. Order is semantic.
pub struct Frame {
  priv names : Array[String]
} derive(Debug, Eq)

///|
/// A finite powerset is deliberately bounded to at most sixteen hypotheses.
pub fn frame(names : Array[String]) -> Frame raise BeliefError {
  if names.length() == 0 || names.length() > 16 {
    raise Invalid("frame must contain 1..16 hypotheses")
  }
  for i = 0; i < names.length(); i = i + 1 {
    if names[i].length() == 0 || names[i].length() > 256 {
      raise Invalid("hypothesis label length must be 1..256")
    }
    for j = 0; j < i; j = j + 1 {
      if names[i] == names[j] {
        raise Invalid("duplicate hypothesis label")
      }
    }
  }
  { names: names.copy(), }
}

///|
pub fn Frame::labels(self : Frame) -> Array[String] {
  self.names.copy()
}

///|
pub fn Frame::size(self : Frame) -> Int32 {
  self.names.length()
}

///|
pub fn Frame::universe(self : Frame) -> Int32 {
  (1 << self.names.length()) - 1
}

///|
pub fn Frame::subset(
  self : Frame,
  labels : Array[String],
) -> Int32 raise BeliefError {
  let mut mask = 0
  for label in labels {
    let mut found = false
    for i = 0; i < self.names.length(); i = i + 1 {
      if self.names[i] == label {
        let bit = 1 << i
        if (mask & bit) != 0 {
          raise Invalid("duplicate subset label")
        }
        mask = mask | bit
        found = true
        break
      }
    }
    if !found {
      raise Invalid("unknown subset label")
    }
  }
  mask
}

///|
pub fn Frame::members(
  self : Frame,
  mask : Int32,
) -> Array[String] raise BeliefError {
  self.check_mask(mask)
  let result : Array[String] = []
  for i = 0; i < self.names.length(); i = i + 1 {
    if (mask & (1 << i)) != 0 {
      result.push(self.names[i])
    }
  }
  result
}

///|
fn Frame::check_mask(self : Frame, mask : Int32) -> Unit raise BeliefError {
  if mask < 0 || mask > self.universe() {
    raise Invalid("subset outside frame")
  }
}

///|
pub extend Frame with @debug.Debug::{to_repr}

///|
pub extend Frame with Eq::{equal, not_equal}
