///|
test "leave-one-out exposes decision changes without inferring credibility" {
  let f = frame(["a", "b"])
  let a = simple_support(f, 1, 0.9)
  let b = simple_support(f, 2, 0.5)
  let sources = [source("strong-a", a), source("weak-b", b)]
  let report = leave_one_out(sources, Yager)
  assert_eq(report.length(), 2)
  assert_eq(report[0].omitted, "strong-a")
  assert_true(report[0].winner_changed)
  assert_true(!report[1].winner_changed)
  close(report[0].conflict_without, 0.0)
  assert_true(report[0].pignistic_variation > 0.0)
  rejects_invalid(() => leave_one_out([source("only", a)], Yager))
}

///|
test "leave-one-out accepts exact pair budgets and still rejects aggregate overruns" {
  let f = frame(["a", "b"])
  let a = simple_support(f, 1, 1.0)
  let two = [source("one", a), source("two", a)]
  let exact = leave_one_out(two, Yager, budget=limits(max_pairs=2))
  assert_eq(exact.length(), 2)
  for row in exact {
    close(row.pignistic_variation, 0.0)
    assert_true(!row.winner_changed)
  }
  rejects_budget(() => leave_one_out(two, Yager, budget=limits(max_pairs=1)))
  let three = [source("one", a), source("two", a), source("three", a)]
  assert_eq(
    leave_one_out(three, Yager, budget=limits(max_pairs=10)).length(),
    3,
  )
  rejects_budget(() => leave_one_out(three, Yager, budget=limits(max_pairs=9)))
}
