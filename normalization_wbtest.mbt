///|
test "Dempster normalization and explicit complete conflict" {
  let f = frame(["a", "b"])
  let d = dempster(simple_support(f, 1, 0.6), simple_support(f, 2, 0.7))
  close(d.weight(1), 0.18 / 0.58)
  close(d.weight(2), 0.28 / 0.58)
  close(d.conflict(), 0.0)
  try dempster(simple_support(f, 1, 1.0), simple_support(f, 2, 1.0)) catch {
    e => assert_true(e is TotalConflict)
  } noraise {
    _ => fail("total conflict must be explicit")
  }
  rejects_invalid(() => d.normalize(min_survival=1.0))
}

///|
test "direct survival handles conflict rounded to one without dividing by zero" {
  let f = frame(["a", "b"])
  let tiny = mass(f, [(0, 1.0), (1, 1.0e-17)])
  try tiny.normalize() catch {
    e => assert_true(e is TotalConflict)
  } noraise {
    _ => fail("near total conflict must use default threshold")
  }
  close(tiny.normalize(min_survival=0.0).weight(1), 1.0)
}
