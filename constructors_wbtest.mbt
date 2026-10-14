///|
test "constructors and convex pooling preserve frame semantics" {
  let f = frame(["a", "b"])
  close(vacuous(f).ignorance(), 1.0)
  close(simple_support(f, 1, 0.7).weight(1), 0.7)
  close(simple_support(f, 3, 0.7).weight(3), 1.0)
  let a = bayesian(f, [0.7, 0.3])
  let b = bayesian(f, [0.1, 0.9])
  close(mixture(a, b, 0.5).weight(1), 0.4)
  rejects_invalid(() => simple_support(f, 0, 0.3))
  rejects_invalid(() => bayesian(f, [1.0]))
  rejects_invalid(() => mixture(a, b, 1.1))
  try mixture(a, vacuous(frame(["b", "a"])), 0.5) catch {
    e => assert_true(e is FrameMismatch)
  } noraise {
    _ => fail("expected frame mismatch")
  }
}
