///|
test "Jousselme handles identical disjoint vacuous and empty focals" {
  let f = frame(["a", "b"])
  let a = simple_support(f, 1, 1.0)
  let b = simple_support(f, 2, 1.0)
  close(jousselme(a, a), 0.0)
  close(jousselme(a, b), 1.0)
  close(jousselme(a, vacuous(f)), 0.5.sqrt())
  close(jousselme(mass(f, [(0, 1.0)]), a), 1.0)
  close(focal_total_variation(a, b), 1.0)
  close(maximum_belief_difference(a, b).1, 1.0)
  try jousselme(a, b, budget=limits(max_pairs=3)) catch {
    e => assert_true(e is Budget(_))
  } noraise {
    _ => fail("expected distance budget")
  }
}
