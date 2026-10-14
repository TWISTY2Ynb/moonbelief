///|
/// mapping[i] is the target hypothesis index for source hypothesis i.
/// Surjectivity forbids introducing unsupported target categories.
pub fn Mass::coarsen(
  self : Mass,
  target : Frame,
  mapping : Array[Int],
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  if mapping.length() != self.domain.size() {
    raise Invalid("coarsening map must have one index per source hypothesis")
  }
  if target.size() > self.domain.size() {
    raise Invalid("coarsening cannot enlarge the hypothesis count")
  }
  let mut covered = 0
  for index in mapping {
    if index < 0 || index >= target.size() {
      raise Invalid("coarsening index outside target frame")
    }
    covered = covered | (1 << index)
  }
  if covered != target.universe() {
    raise Invalid("coarsening map must cover the target frame")
  }
  budget.check_dense(target)
  let bins = Array::make(target.universe() + 1, 0.0)
  let corrections = Array::make(bins.length(), 0.0)
  for (mask, value) in self.focals {
    let mut mapped = 0
    for i = 0; i < mapping.length(); i = i + 1 {
      if (mask & (1 << i)) != 0 {
        mapped = mapped | (1 << mapping[i])
      }
    }
    let adjusted = value - corrections[mapped]
    let next = bins[mapped] + adjusted
    corrections[mapped] = next - bins[mapped] - adjusted
    bins[mapped] = next
  }
  from_bins(target, bins, budget)
}

///|
/// Preimage event on the source frame for a category-level query.
pub fn Frame::coarse_preimage(
  self : Frame,
  target : Frame,
  mapping : Array[Int],
  event : Int,
) -> Int raise BeliefError {
  target.check_mask(event)
  // Reuse exactly the same coverage and index checks as mass projection.
  let _ = vacuous(self).coarsen(target, mapping)
  let mut result = 0
  for i = 0; i < mapping.length(); i = i + 1 {
    if (event & (1 << mapping[i])) != 0 {
      result = result | (1 << i)
    }
  }
  result
}
