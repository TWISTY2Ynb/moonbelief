///|
fn cardinality(mask : Int32) -> Int32 {
  let mut bits = mask
  let mut count = 0
  while bits != 0 {
    bits = bits & (bits - 1)
    count = count + 1
  }
  count
}

///|
pub fn Frame::cardinality(
  self : Frame,
  mask : Int32,
) -> Int32 raise BeliefError {
  self.check_mask(mask)
  cardinality(mask)
}

///|
pub fn Frame::complement(self : Frame, mask : Int32) -> Int32 raise BeliefError {
  self.check_mask(mask)
  self.universe() ^ mask
}

///|
pub fn Frame::intersection(
  self : Frame,
  left : Int32,
  right : Int32,
) -> Int32 raise BeliefError {
  self.check_mask(left)
  self.check_mask(right)
  left & right
}

///|
pub fn Frame::union(
  self : Frame,
  left : Int32,
  right : Int32,
) -> Int32 raise BeliefError {
  self.check_mask(left)
  self.check_mask(right)
  left | right
}

///|
pub fn Frame::difference(
  self : Frame,
  left : Int32,
  right : Int32,
) -> Int32 raise BeliefError {
  self.check_mask(left)
  self.check_mask(right)
  left & (self.universe() ^ right)
}

///|
pub fn Frame::is_subset(
  self : Frame,
  left : Int32,
  right : Int32,
) -> Bool raise BeliefError {
  self.check_mask(left)
  self.check_mask(right)
  (left & right) == left
}

///|
/// Enumerate subsets of a query, not of an implicitly unbounded universe.
pub fn Frame::subsets(
  self : Frame,
  mask : Int32,
  max_results~ : Int32 = 65536,
) -> Array[Int32] raise BeliefError {
  self.check_mask(mask)
  let count = 1 << cardinality(mask)
  if max_results < 1 || count > max_results {
    raise Budget("subset enumeration exceeds output budget")
  }
  let result : Array[Int32] = []
  let mut current = mask
  while true {
    result.push(current)
    if current == 0 {
      break
    }
    current = (current - 1) & mask
  }
  result.sort()
  result
}
