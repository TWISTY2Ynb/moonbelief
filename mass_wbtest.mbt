///|
fn close(actual : Double, expected : Double) -> Unit raise {
  assert_true(magnitude(actual - expected) < 1.0e-9)
}

///|
test "canonical mass merges duplicates and preserves empty-set conflict" {
  let f = frame(["a", "b"])
  let input = [(3, 0.3), (1, 0.2), (0, 0.1), (1, 0.4)]
  let m = mass(f, input)
  input[0] = (2, 0.9)
  assert_eq(m.focal_count(), 3)
  close(m.weight(1), 0.6)
  close(m.conflict(), 0.1)
  close(m.weight(2), 0.0)
  let copy = m.entries()
  copy[0] = (3, 1.0)
  close(m.conflict(), 0.1)
}

///|
test "invalid mass totals and resource ceilings are explicit errors" {
  let f = frame(["a", "b"])
  rejects_invalid(() => mass(f, []))
  rejects_invalid(() => mass(f, [(4, 1.0)]))
  rejects_invalid(() => mass(f, [(1, -0.1), (3, 1.0)]))
  rejects_invalid(() => mass(f, [(1, 0.2)]))
  rejects_invalid(() => mass(f, [(1, 0.0 / 0.0)]))
  rejects_invalid(() => mass(f, [(1, 1.0 / 0.0)]))
  rejects_invalid(() => limits(max_pairs=0))
  let small = limits(max_dense_cells=2)
  try mass(f, [(1, 1.0)], budget=small) catch {
    e => assert_true(e is Budget(_))
  } noraise {
    _ => fail("expected budget")
  }
}

///|
test "tiny positive focals survive canonicalization" {
  let f = frame(["a", "b"])
  let m = mass(f, [(1, 1.0e-15), (3, 1.0 - 1.0e-15)])
  assert_true(m.weight(1) > 0.0)
  assert_eq(default_limits().max_focals(), 4096)
  assert_eq(default_limits().max_pairs(), 1000000)
  assert_eq(default_limits().max_dense_cells(), 65536)
}
