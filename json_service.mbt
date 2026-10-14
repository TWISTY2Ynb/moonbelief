///|
pub fn rule_from_string(name : String) -> Rule raise BeliefError {
  match name {
    "conjunctive" => Conjunctive
    "dempster" => Dempster
    "disjunctive" => Disjunctive
    "yager" => Yager
    "dubois-prade" => DuboisPrade
    "pairwise-pcr5" => PairwisePCR5
    _ => raise Invalid("unsupported fusion rule")
  }
}

///|
fn optional_number(
  object : Map[String, Json],
  name : String,
  default : Double,
) -> Double raise BeliefError {
  match object.get(name) {
    None => default
    Some(value) => json_number(value)
  }
}

///|
fn decode_sources(
  f : Frame,
  value : Json,
  budget : Limits,
) -> Array[Source] raise BeliefError {
  let rows = json_array(value, 32)
  let result : Array[Source] = []
  for row in rows {
    let object = json_object(row, ["name", "reliability", "masses"])
    result.push(
      source(
        json_string(required(object, "name")),
        decode_rows(f, required(object, "masses"), budget),
        reliability=optional_number(object, "reliability", 1.0),
      ),
    )
  }
  result
}

///|
fn encode_step(step : FusionStep) -> Json {
  Json::object({
    "source": Json::string(step.source),
    "input_conflict": Json::number(step.input_conflict),
    "previous_conflict": Json::number(step.previous_conflict),
    "conjunctive_conflict": Json::number(step.conjunctive_conflict),
    "output_conflict": Json::number(step.output_conflict),
    "output_ignorance": Json::number(step.output_ignorance),
    "output_focals": Json::number(step.output_focals.to_double()),
  })
}

///|
fn encode_ranking(m : Mass) -> Json raise BeliefError {
  let result : Array[Json] = []
  for score in m.ranking() {
    result.push(
      Json::object({
        "label": Json::string(score.label),
        "belief": Json::number(score.belief),
        "plausibility": Json::number(score.plausibility),
        "pignistic": Json::number(score.pignistic),
      }),
    )
  }
  Json::array(result)
}

///|
fn encode_queries(m : Mass, value : Json) -> Json raise BeliefError {
  let queries = json_array(value, 256)
  let result : Array[Json] = []
  for query in queries {
    let labels = json_strings(query, 16)
    let mask = m.domain.subset(labels)
    let (belief, plausibility) = m.interval(mask)
    result.push(
      Json::object({
        "subset": encode_strings(m.domain.members(mask)),
        "belief": Json::number(belief),
        "plausibility": Json::number(plausibility),
      }),
    )
  }
  Json::array(result)
}

///|
fn decode_utilities(value : Json) -> Array[Array[Double]] raise BeliefError {
  let rows = json_array(value, 64)
  let result : Array[Array[Double]] = []
  for row in rows {
    let cells = json_array(row, 16)
    let values : Array[Double] = []
    for cell in cells {
      values.push(json_number(cell))
    }
    result.push(values)
  }
  result
}

///|
fn encode_decision(m : Mass, value : Json) -> Json raise BeliefError {
  let object = json_object(value, ["actions", "utilities", "policy"])
  let policy_object = match object.get("policy") {
    None => Map([])
    Some(value) =>
      json_object(value, ["max_conflict", "max_nonspecific", "min_margin"])
  }
  let policy = decision_policy(
    max_conflict=optional_number(policy_object, "max_conflict", 0.5),
    max_nonspecific=optional_number(policy_object, "max_nonspecific", 0.8),
    min_margin=optional_number(policy_object, "min_margin", 0.05),
  )
  let report = m.decide(
    json_strings(required(object, "actions"), 64),
    decode_utilities(required(object, "utilities")),
    policy,
  )
  Json::object({
    "action": Json::string(report.label),
    "index": Json::number(report.index.to_double()),
    "accepted": Json::boolean(report.accepted),
    "expected_utility": Json::number(report.expected_score),
    "margin": Json::number(report.margin),
    "reason": Json::string(report.reason),
    "conflict": Json::number(report.conflict),
    "nonspecific": Json::number(report.nonspecific),
  })
}

///|
/// Pure request/report facade: no I/O, credentials, training or network.
/// Total conflict produces a domain error instead of invalid ranking numbers.
pub fn execute_request(
  value : Json,
  budget? : Limits = default_limits(),
) -> Json raise BeliefError {
  let object = json_object(value, [
    "schema", "frame", "rule", "sources", "queries", "decision",
  ])
  if json_string(required(object, "schema")) != "moonbelief.request.v1" {
    raise Invalid("unsupported request schema")
  }
  let f = frame(json_strings(required(object, "frame"), 16))
  let rule = rule_from_string(json_string(required(object, "rule")))
  let sources = decode_sources(f, required(object, "sources"), budget)
  let result = pipeline(sources, rule, budget~)
  let m = result.mass()
  let output : Map[String, Json] = {
    "schema": Json::string("moonbelief.report.v1"),
    "mass": m.to_json(),
    "conflict": Json::number(m.conflict()),
    "nonspecific": Json::number(m.nonspecific_mass()),
    "ranking": encode_ranking(m),
    "steps": Json::array(result.steps().map(encode_step)),
    "pair_work": Json::number(result.pair_work().to_double()),
  }
  match object.get("queries") {
    Some(queries) => output["queries"] = encode_queries(m, queries)
    None => ()
  }
  match object.get("decision") {
    Some(decision) => output["decision"] = encode_decision(m, decision)
    None => ()
  }
  Json::object(output)
}

///|
pub fn execute_json(
  text : String,
  budget? : Limits = default_limits(),
) -> String raise BeliefError {
  execute_request(bounded_parse(text), budget~).stringify()
}
