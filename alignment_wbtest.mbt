///|
test "explicit alignment changes masks without changing labels or evidence" {
  let f = frame(["a", "b", "c"])
  let g = frame(["c", "a", "b"])
  let m = mass(f, [(1, 0.2), (6, 0.8)])
  let aligned = m.align(g)
  close(aligned.weight(2), 0.2)
  close(aligned.weight(5), 0.8)
  assert_eq(aligned.align(f), m)
  assert_eq(m.relabel(["x", "y", "z"]).entries(), m.entries())
  rejects_invalid(() => m.relabel(["x"]))
  try m.align(frame(["a", "b", "d"])) catch {
    e => assert_true(e is FrameMismatch)
  } noraise {
    _ => fail("label set mismatch must be explicit")
  }
}
