///|
/// Singleton decision projection. This is pignistic probability, not belief.
/// Conflict is removed by conditioning on directly summed nonempty mass.
pub fn Mass::pignistic(
  self : Mass,
  min_survival? : Double = 1.0e-12,
) -> Array[Double] raise BeliefError {
  check_survival_threshold(min_survival)
  let surviving = self.survival()
  if surviving <= min_survival {
    raise TotalConflict
  }
  let result = Array::make(self.domain.size(), 0.0)
  let corrections = Array::make(result.length(), 0.0)
  for (mask, value) in self.focals {
    if mask != 0 {
      let share = value / surviving / cardinality(mask).to_double()
      for i = 0; i < result.length(); i = i + 1 {
        if (mask & (1 << i)) != 0 {
          let adjusted = share - corrections[i]
          let next = result[i] + adjusted
          corrections[i] = next - result[i] - adjusted
          result[i] = next
        }
      }
    }
  }
  result
}

///|
pub struct HypothesisScore {
  index : Int
  label : String
  belief : Double
  plausibility : Double
  pignistic : Double
} derive(Debug, Eq)

///|
pub extend HypothesisScore with @debug.Debug::{to_repr}

///|
pub extend HypothesisScore with Eq::{equal, not_equal}

///|
/// Stable descending pignistic ranking: ties retain original frame order.
/// Belief and plausibility columns remain unnormalized open-world bounds.
pub fn Mass::ranking(
  self : Mass,
  min_survival? : Double = 1.0e-12,
) -> Array[HypothesisScore] raise BeliefError {
  let probabilities = self.pignistic(min_survival~)
  let result : Array[HypothesisScore] = []
  for index = 0; index < self.domain.size(); index = index + 1 {
    let mask = 1 << index
    result.push({
      index,
      label: self.domain.names[index],
      belief: self.belief(mask),
      plausibility: self.plausibility(mask),
      pignistic: probabilities[index],
    })
  }
  for i = 1; i < result.length(); i = i + 1 {
    let item = result[i]
    let mut j = i
    while j > 0 && result[j - 1].pignistic < item.pignistic {
      result[j] = result[j - 1]
      j = j - 1
    }
    result[j] = item
  }
  result
}
