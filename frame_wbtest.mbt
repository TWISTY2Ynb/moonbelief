///|
test "frame labels and masks are owned and ordered" {
  let labels = ["rain", "sun", "snow"]
  let f = frame(labels)
  labels[0] = "modified"
  assert_eq(f.labels(), ["rain", "sun", "snow"])
  assert_eq(f.subset(["snow", "rain"]), 5)
  assert_eq(f.members(5), ["rain", "snow"])
  assert_eq(f.universe(), 7)
  let exposed = f.labels()
  exposed[0] = "modified"
  assert_eq(f.labels()[0], "rain")
}

///|
test "frame validation rejects ambiguous and invalid inputs" {
  rejects_invalid(() => frame([]))
  rejects_invalid(() => frame(["a", "a"]))
  rejects_invalid(() => frame([""]))
  let f = frame(["a", "b"])
  rejects_invalid(() => f.members(-1))
  rejects_invalid(() => f.members(4))
  rejects_invalid(() => f.subset(["x"]))
  rejects_invalid(() => f.subset(["a", "a"]))
}

///|
fn[T] rejects_invalid(action : () -> T raise BeliefError) -> Unit raise {
  try action() catch {
    e => assert_true(e is Invalid(_))
  } noraise {
    _ => fail("expected invalid input error")
  }
}
