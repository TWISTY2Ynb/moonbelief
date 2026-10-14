///|
fn main {
  let output = try {
    let f = @belief.frame(["clear", "blocked"])
    let optical = @belief.simple_support(f, 1, 0.8)
    let sonar = @belief.simple_support(f, 2, 0.6)
    let result = @belief.pipeline(
      [
        @belief.source("optical", optical, reliability=0.9),
        @belief.source("sonar", sonar, reliability=0.8),
      ],
      Yager,
    )
    Json::object({
      "workflow": Json::string("sensor-fusion"),
      "mass": result.mass().to_json(),
      "raw_pair_conflict": Json::number(result.steps()[0].conjunctive_conflict),
      "conflict": Json::number(result.mass().conflict()),
      "ignorance": Json::number(result.mass().ignorance()),
      "clear_plausibility": Json::number(result.mass().plausibility(1)),
    })
  } catch {
    _ => abort("sensor example failed")
  }
  println(output.stringify())
}
