///|
test "conjunctive fusion computes pair intersections and conflict" {
  let f = frame(["a", "b"])
  let a = simple_support(f, 1, 0.6)
  let b = simple_support(f, 2, 0.7)
  let c = conjunctive(a, b)
  close(c.conflict(), 0.42)
  close(c.weight(1), 0.18)
  close(c.weight(2), 0.28)
  close(c.weight(3), 0.12)
  assert_eq(c, conjunctive(b, a))
  assert_eq(a, conjunctive(a, vacuous(f)))
  try conjunctive(a, b, budget=limits(max_pairs=3)) catch {
    e => assert_true(e is Budget(_))
  } noraise {
    _ => fail("expected pair budget failure")
  }
}
