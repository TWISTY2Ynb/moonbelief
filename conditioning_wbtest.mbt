///|
test "conditioning exposes rejected evidence before optional normalization" {
  let f = frame(["a", "b", "c"])
  let m = mass(f, [(1, 0.2), (2, 0.3), (7, 0.5)])
  let o = m.condition_open(5)
  close(o.conflict(), 0.3)
  close(o.weight(5), 0.5)
  let c = m.condition(5)
  close(c.weight(1), 2.0 / 7.0)
  close(c.weight(5), 5.0 / 7.0)
  close(m.conditional_interval(1, 5).0, 2.0 / 7.0)
  rejects_invalid(() => m.condition(0))
  try simple_support(f, 2, 1.0).condition(1) catch {
    e => assert_true(e is TotalConflict)
  } noraise {
    _ => fail("impossible evidence must fail")
  }
}
