///|
fn main {
  let output = try {
    let f = @belief.frame(["accept", "reject"])
    let inputs = [
      @belief.source("classifier-a", @belief.simple_support(f, 1, 0.8)),
      @belief.source("classifier-b", @belief.simple_support(f, 1, 0.7)),
      @belief.source("classifier-c", @belief.simple_support(f, 2, 0.4)),
    ]
    let result = @belief.pipeline(inputs, Yager)
    let decision = result
      .mass()
      .decide(
        ["accept", "reject"],
        [[1.0, -2.0], [-0.2, 0.8]],
        @belief.decision_policy(),
      )
    let sensitivity = @belief.leave_one_out(inputs, Yager)
    Json::object({
      "workflow": Json::string("ensemble-decision"),
      "action": Json::string(decision.label),
      "accepted": Json::boolean(decision.accepted),
      "reason": Json::string(decision.reason),
      "expected_utility": Json::number(decision.expected_score),
      "omitted": Json::array(
        sensitivity.map(item => Json::string(item.omitted)),
      ),
      "winner_changes": Json::array(
        sensitivity.map(item => Json::boolean(item.winner_changed)),
      ),
    })
  } catch {
    _ => abort("ensemble example failed")
  }
  println(output.stringify())
}
