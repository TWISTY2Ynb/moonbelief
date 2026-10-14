///|
fn main {
  let output = try {
    // Demonstration equipment categories, not medical diagnoses.
    let fine = @belief.frame(["power", "mechanical", "software"])
    let coarse = @belief.frame(["hardware", "software"])
    let input = @belief.mass(fine, [(1, 0.2), (2, 0.3), (7, 0.5)])
    let observed = input.discount(0.8).condition(3)
    let grouped = observed.coarsen(coarse, [0, 0, 1])
    let interval = observed.interval(1)
    Json::object({
      "workflow": Json::string("equipment-diagnostic"),
      "conditioned": observed.to_json(),
      "grouped": grouped.to_json(),
      "power_belief": Json::number(interval.0),
      "power_plausibility": Json::number(interval.1),
      "hardware_belief": Json::number(grouped.belief(1)),
    })
  } catch {
    _ => abort("diagnostic example failed")
  }
  println(output.stringify())
}
