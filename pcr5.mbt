///|
/// Two-source PCR5 only. Incompatible pair products are redistributed to
/// those same two focals in proportion to their original masses.
/// Inputs must have zero empty-set mass; sequential use is order-sensitive.
pub fn pcr5(
  a : Mass,
  b : Mass,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  pair_budget(a, b, budget)
  if a.conflict() > 0.0 || b.conflict() > 0.0 {
    raise Invalid("pairwise PCR5 requires closed-world inputs")
  }
  let bins = Array::make(a.domain.universe() + 1, 0.0)
  let corrections = Array::make(bins.length(), 0.0)
  for (left, x) in a.focals {
    for (right, y) in b.focals {
      let product = x * y
      let intersection = left & right
      if intersection != 0 {
        let adjusted = product - corrections[intersection]
        let next = bins[intersection] + adjusted
        corrections[intersection] = next - bins[intersection] - adjusted
        bins[intersection] = next
      } else {
        // Positive focal weights make the denominator strictly positive.
        // Avoid x*x*y: multiplying product by a ratio is less underflow-prone.
        let denominator = x + y
        let share_left = product * (x / denominator)
        let share_right = product * (y / denominator)
        let adjusted_left = share_left - corrections[left]
        let next_left = bins[left] + adjusted_left
        corrections[left] = next_left - bins[left] - adjusted_left
        bins[left] = next_left
        let adjusted_right = share_right - corrections[right]
        let next_right = bins[right] + adjusted_right
        corrections[right] = next_right - bins[right] - adjusted_right
        bins[right] = next_right
      }
    }
  }
  from_bins(a.domain, bins, budget)
}
