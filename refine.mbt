///|
/// Each source hypothesis maps to a nonempty disjoint block of the target.
/// Blocks must partition the target. No probabilities are invented within a
/// block: every focal is extended to the union of its corresponding blocks.
pub fn Mass::refine(
  self : Mass,
  target : Frame,
  blocks : Array[Int],
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  if blocks.length() != self.domain.size() {
    raise Invalid("refinement requires one block per source hypothesis")
  }
  let mut covered = 0
  for block in blocks {
    target.check_mask(block)
    if block == 0 || (covered & block) != 0 {
      raise Invalid("refinement blocks must be nonempty and disjoint")
    }
    covered = covered | block
  }
  if covered != target.universe() {
    raise Invalid("refinement blocks must partition target frame")
  }
  budget.check_dense(target)
  let bins = Array::make(target.universe() + 1, 0.0)
  for (mask, value) in self.focals {
    let mut mapped = 0
    for i = 0; i < blocks.length(); i = i + 1 {
      if (mask & (1 << i)) != 0 {
        mapped = mapped | blocks[i]
      }
    }
    bins[mapped] = value
  }
  // A partition induces an injective focal mapping, so no merging is needed.
  from_bins(target, bins, budget)
}

///|
/// Derive the inverse category map from a valid refinement partition.
pub fn Frame::refinement_inverse(
  self : Frame,
  target : Frame,
  blocks : Array[Int],
) -> Array[Int] raise BeliefError {
  let _ = vacuous(self).refine(target, blocks)
  let result = Array::make(target.size(), 0)
  for coarse = 0; coarse < blocks.length(); coarse = coarse + 1 {
    for fine = 0; fine < target.size(); fine = fine + 1 {
      if (blocks[coarse] & (1 << fine)) != 0 {
        result[fine] = coarse
      }
    }
  }
  result
}
