///|
test "request to report closes the sensor query and action workflow" {
  let request = Json::object({
    "schema": Json::string("moonbelief.request.v1"),
    "frame": encode_strings(["a", "b"]),
    "rule": Json::string("yager"),
    "sources": Json::array([
      Json::object({
        "name": Json::string("s1"),
        "masses": encode_rows(simple_support(frame(["a", "b"]), 1, 0.8)),
      }),
      Json::object({
        "name": Json::string("s2"),
        "masses": encode_rows(simple_support(frame(["a", "b"]), 1, 0.7)),
      }),
    ]),
    "queries": Json::array([encode_strings(["a"])]),
    "decision": Json::object({
      "actions": encode_strings(["a", "b"]),
      "utilities": Json::array([
        Json::array([Json::number(1.0), Json::number(0.0)]),
        Json::array([Json::number(0.0), Json::number(1.0)]),
      ]),
    }),
  })
  let result = execute_request(request)
  let object = json_object(result, [
    "schema", "mass", "conflict", "nonspecific", "ranking", "steps", "pair_work",
    "queries", "decision",
  ])
  close(mass_from_json(required(object, "mass")).weight(1), 0.94)
  let decision = json_object(required(object, "decision"), [
    "action", "index", "accepted", "expected_utility", "margin", "reason", "conflict",
    "nonspecific",
  ])
  assert_eq(required(decision, "accepted"), Json::boolean(true))
  assert_eq(execute_json(request.stringify()), result.stringify())
  rejects_invalid(() => rule_from_string("pcr6"))
}
