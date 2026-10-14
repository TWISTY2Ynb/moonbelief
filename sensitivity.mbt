///|
pub struct SourceSensitivity {
  omitted : String
  conflict_without : Double
  conflict_change : Double
  pignistic_variation : Double
  winner_without : String
  winner_changed : Bool
} derive(Debug, Eq)

///|
pub extend SourceSensitivity with @debug.Debug::{to_repr}

///|
pub extend SourceSensitivity with Eq::{equal, not_equal}

///|
fn maximum_index(values : Array[Double]) -> Int32 {
  let mut best = 0
  for i = 1; i < values.length(); i = i + 1 {
    if values[i] > values[best] {
      best = i
    }
  }
  best
}

///|
/// Leave-one-out is a sensitivity diagnostic, not source-reliability learning.
/// Limited to 2..16 sources. The pair budget is shared across baseline and
/// all reruns; no per-source failures are hidden. Total conflict raises an error.
pub fn leave_one_out(
  sources : Array[Source],
  rule : Rule,
  budget~ : Limits = default_limits(),
) -> Array[SourceSensitivity] raise BeliefError {
  if sources.length() < 2 || sources.length() > 16 {
    raise Invalid("leave-one-out requires 2..16 sources")
  }
  let baseline = pipeline(sources, rule, budget~)
  let probabilities = baseline.mass().pignistic()
  let winner = maximum_index(probabilities)
  let labels = baseline.mass().frame().labels()
  let result : Array[SourceSensitivity] = []
  let mut work = baseline.pair_work()
  for omitted = 0; omitted < sources.length(); omitted = omitted + 1 {
    let remaining : Array[Source] = []
    for i = 0; i < sources.length(); i = i + 1 {
      if i != omitted {
        remaining.push(sources[i])
      }
    }
    if work >= budget.pairs {
      raise Budget("sensitivity aggregate pair budget exhausted")
    }
    let local_budget = limits(
      max_focals=budget.focals,
      max_pairs=budget.pairs - work,
      max_dense_cells=budget.dense,
    )
    let rerun = pipeline(remaining, rule, budget=local_budget)
    work = work + rerun.pair_work()
    let alternate = rerun.mass().pignistic()
    let terms : Array[Double] = []
    for i = 0; i < probabilities.length(); i = i + 1 {
      terms.push(magnitude(probabilities[i] - alternate[i]))
    }
    let alternate_winner = maximum_index(alternate)
    result.push({
      omitted: sources[omitted].name,
      conflict_without: rerun.mass().conflict(),
      conflict_change: rerun.mass().conflict() - baseline.mass().conflict(),
      pignistic_variation: stable_sum(terms) * 0.5,
      winner_without: labels[alternate_winner],
      winner_changed: alternate_winner != winner,
    })
  }
  result
}
