///|
test "subset lattice operations and deterministic enumeration" {
  let f = frame(["a", "b", "c"])
  assert_eq(f.cardinality(5), 2)
  assert_eq(f.complement(5), 2)
  assert_eq(f.intersection(3, 6), 2)
  assert_eq(f.union(3, 6), 7)
  assert_eq(f.difference(7, 3), 4)
  assert_true(f.is_subset(2, 6))
  assert_eq(f.subsets(5), [0, 1, 4, 5])
  assert_eq(f.subsets(0), [0])
  try f.subsets(7, max_results=7) catch {
    e => assert_true(e is Budget(_))
  } noraise {
    _ => fail("expected budget")
  }
}

///|
test "subset laws hold over all masks of a four-hypothesis frame" {
  let f = frame(["a", "b", "c", "d"])
  for a in 0..<=15 {
    assert_eq(f.complement(f.complement(a)), a)
    assert_eq(f.cardinality(a) + f.cardinality(f.complement(a)), 4)
    for b in 0..<=15 {
      assert_eq(f.union(a, b), f.union(b, a))
      assert_eq(f.intersection(a, b), f.intersection(b, a))
      assert_eq(f.difference(a, b) | (a & b), a)
    }
  }
}
