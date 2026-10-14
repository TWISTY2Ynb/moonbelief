///|
test "pignistic projection distributes nonspecific masses and preserves stable ties" {
  let f = frame(["a", "b", "c"])
  let m = mass(f, [(0, 0.1), (1, 0.3), (6, 0.6)])
  let p = m.pignistic()
  for value in p {
    close(value, 1.0 / 3.0)
  }
  let ranks = vacuous(f).ranking()
  assert_eq(ranks[0].label, "a")
  assert_eq(ranks[1].label, "b")
  assert_eq(ranks[2].label, "c")
  close(m.ranking()[0].belief, 0.3)
  close(stable_sum(p), 1.0)
}
