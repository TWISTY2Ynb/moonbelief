///|
pub(all) enum Rule {
  Conjunctive
  Dempster
  Disjunctive
  Yager
  DuboisPrade
  PairwisePCR5
} derive(Debug, Eq)

///|
pub extend Rule with @debug.Debug::{to_repr}

///|
pub extend Rule with Eq::{equal, not_equal}

///|
pub fn fuse(
  a : Mass,
  b : Mass,
  rule : Rule,
  budget~ : Limits = default_limits(),
) -> Mass raise BeliefError {
  match rule {
    Conjunctive => conjunctive(a, b, budget~)
    Dempster => dempster(a, b, budget~)
    Disjunctive => disjunctive(a, b, budget~)
    Yager => yager(a, b, budget~)
    DuboisPrade => dubois_prade(a, b, budget~)
    PairwisePCR5 => pcr5(a, b, budget~)
  }
}

///|
pub struct Source {
  priv name : String
  priv evidence : Mass
  priv reliability : Double
} derive(Debug, Eq)

///|
pub extend Source with @debug.Debug::{to_repr}

///|
pub extend Source with Eq::{equal, not_equal}

///|
pub fn source(
  name : String,
  evidence : Mass,
  reliability~ : Double = 1.0,
) -> Source raise BeliefError {
  if name.length() == 0 || name.length() > 256 {
    raise Invalid("source name must have 1..256 characters")
  }
  if !finite(reliability) || reliability < 0.0 || reliability > 1.0 {
    raise Invalid("source reliability must be finite and in [0,1]")
  }
  { name, evidence, reliability, }
}

///|
pub fn Source::name(self : Source) -> String {
  self.name
}

///|
pub fn Source::mass(self : Source) -> Mass {
  self.evidence
}

///|
pub struct FusionStep {
  source : String
  input_conflict : Double
  previous_conflict : Double
  conjunctive_conflict : Double
  output_conflict : Double
  output_ignorance : Double
  output_focals : Int32
} derive(Debug, Eq)

///|
pub extend FusionStep with @debug.Debug::{to_repr}

///|
pub extend FusionStep with Eq::{equal, not_equal}

///|
pub struct PipelineResult {
  priv evidence : Mass
  priv trace : Array[FusionStep]
  priv pair_work : Int32
} derive(Debug, Eq)

///|
pub extend PipelineResult with @debug.Debug::{to_repr}

///|
pub extend PipelineResult with Eq::{equal, not_equal}

///|
pub fn PipelineResult::mass(self : PipelineResult) -> Mass {
  self.evidence
}

///|
pub fn PipelineResult::steps(self : PipelineResult) -> Array[FusionStep] {
  self.trace.copy()
}

///|
pub fn PipelineResult::pair_work(self : PipelineResult) -> Int32 {
  self.pair_work
}

///|
fn validate_sources(sources : Array[Source]) -> Unit raise BeliefError {
  if sources.length() == 0 || sources.length() > 32 {
    raise Invalid("pipeline requires 1..32 sources")
  }
  for i = 0; i < sources.length(); i = i + 1 {
    same_frame(sources[0].evidence, sources[i].evidence)
    for j = 0; j < i; j = j + 1 {
      if sources[i].name == sources[j].name {
        raise Invalid("pipeline source names must be unique")
      }
    }
  }
}

///|
/// Deterministic left fold in caller order. Not a generalized multisource
/// PCR5 or associativity guarantee. One source yields its discounted mass.
/// Pair budget covers BOTH diagnostic and fusion cross products globally.
pub fn pipeline(
  sources : Array[Source],
  rule : Rule,
  budget~ : Limits = default_limits(),
) -> PipelineResult raise BeliefError {
  validate_sources(sources)
  let mut current = sources[0].evidence.discount(
    sources[0].reliability,
    budget~,
  )
  let trace : Array[FusionStep] = []
  let mut work = 0
  for i = 1; i < sources.length(); i = i + 1 {
    let incoming = sources[i].evidence.discount(sources[i].reliability, budget~)
    let pairs = current.focal_count() * incoming.focal_count()
    if pairs > (budget.pairs - work) / 2 {
      raise Budget(
        "pipeline aggregate diagnostic and fusion pair budget exceeded",
      )
    }
    work = work + pairs * 2
    let raw = conjunctive(current, incoming, budget~)
    let next = fuse(current, incoming, rule, budget~)
    trace.push({
      source: sources[i].name,
      input_conflict: incoming.conflict(),
      previous_conflict: current.conflict(),
      conjunctive_conflict: raw.conflict(),
      output_conflict: next.conflict(),
      output_ignorance: next.ignorance(),
      output_focals: next.focal_count(),
    })
    current = next
  }
  { evidence: current, trace, pair_work: work, }
}
