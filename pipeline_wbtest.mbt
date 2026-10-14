///|
test "pipeline preserves caller order source names and pre-normalization diagnostics" {
  let f = frame(["a", "b"])
  let a = simple_support(f, 1, 0.6)
  let b = simple_support(f, 2, 0.7)
  let sources = [source("sensor-a", a), source("sensor-b", b)]
  let r = pipeline(sources, Dempster)
  close(r.steps()[0].conjunctive_conflict, 0.42)
  close(r.steps()[0].output_conflict, 0.0)
  assert_eq(r.mass(), dempster(a, b))
  assert_eq(r.pair_work(), 8)
  assert_eq(
    pipeline([source("only", a, reliability=0.0)], Yager).mass(),
    vacuous(f),
  )
  rejects_invalid(() => pipeline([], Yager))
  rejects_invalid(() => pipeline([source("x", a), source("x", b)], Yager))
  try pipeline(sources, Yager, budget=limits(max_pairs=7)) catch {
    e => assert_true(e is Budget(_))
  } noraise {
    _ => fail("expected total pipeline pair budget")
  }
}
