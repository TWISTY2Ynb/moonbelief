///|
fn[T] rejects_budget(action : () -> T raise BeliefError) -> Unit raise {
  try action() catch {
    e => assert_true(e is Budget(_))
  } noraise {
    _ => fail("expected resource budget rejection")
  }
}

///|
test "hard frame limits include the maximum mask but reject frame expansion" {
  let labels : Array[String] = []
  for i = 0; i < 16; i = i + 1 {
    labels.push("h\{i}")
  }
  let f = frame(labels)
  assert_eq(f.universe(), 65535)
  assert_eq(f.cardinality(65535), 16)
  let m = vacuous(f)
  assert_eq(m.dense().length(), 65536)
  rejects_budget(() => m.dense(budget=limits(max_dense_cells=65535)))
  labels.push("too-many")
  rejects_invalid(() => frame(labels))
  rejects_invalid(() => frame([""]))
  rejects_invalid(() => frame(["a", "a"]))
}

///|
test "output focal and input row budgets are distinct and deterministic" {
  let f = frame(["a", "b"])
  let a = simple_support(f, 1, 0.6)
  let b = simple_support(f, 2, 0.7)
  rejects_budget(() => conjunctive(a, b, budget=limits(max_focals=3)))
  rejects_budget(() => {
    mass(f, [(1, 0.5), (1, 0.5)], budget=limits(max_focals=1))
  })
  rejects_budget(() => f.subsets(3, max_results=3))
  rejects_invalid(() => limits(max_dense_cells=65537))
  rejects_invalid(() => limits(max_focals=4097))
}

///|
test "JSON nesting guard ignores brackets and escaped quotes inside strings" {
  assert_eq(bounded_parse("\"[[[\\\"{{{\""), Json::string("[[[\"{{{"))
  rejects_budget(() => bounded_parse("[[[[[[[[[[[[[0]]]]]]]]]]]]]"))
  rejects_invalid(() => bounded_parse("}"))
  rejects_invalid(() => parse_mass("[]"))
  rejects_invalid(() => {
    decode_rows(
      frame(["a"]),
      Json::array([
        Json::object({
          "subset": encode_strings(["a", "a"]),
          "mass": Json::number(1.0),
        }),
      ]),
      default_limits(),
    )
  })
}

///|
test "nonassociative rules remain order-sensitive and are never advertised as multisource PCR5" {
  let f = frame(["a", "b"])
  let a = simple_support(f, 1, 0.9)
  let b = simple_support(f, 2, 0.6)
  let c = simple_support(f, 2, 0.5)
  let left = pcr5(pcr5(a, b), c)
  let right = pcr5(a, pcr5(b, c))
  assert_true(magnitude(left.weight(1) - right.weight(1)) > 0.001)
  let yl = yager(yager(a, b), c)
  let yr = yager(a, yager(b, c))
  assert_true(magnitude(yl.weight(2) - yr.weight(2)) > 0.001)
}

///|
test "decision matrices reject invalid shapes magnitudes and NaNs before evaluation" {
  let m = bayesian(frame(["a", "b"]), [0.5, 0.5])
  rejects_invalid(() => m.expected_losses([]))
  rejects_invalid(() => m.expected_losses([[1.0]]))
  rejects_invalid(() => m.expected_utilities([[1.0e13, 0.0]]))
  rejects_invalid(() => m.expected_utilities([[0.0 / 0.0, 0.0]]))
  rejects_invalid(() => {
    m.decide(["x"], [[1.0, 0.0]], decision_policy(min_margin=-0.1))
  })
}
