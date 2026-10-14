///|
test "open world queries retain explicit conflict without counting it as belief" {
  let f = frame(["a", "b"])
  let m = mass(f, [(0, 0.1), (1, 0.2), (2, 0.3), (3, 0.4)])
  close(m.belief(1), 0.2)
  close(m.plausibility(1), 0.6)
  close(m.commonality(1), 0.6)
  close(m.commonality(0), 1.0)
  close(m.belief(0), 0.0)
  close(m.plausibility(0), 0.0)
  close(m.belief(3), 0.9)
  close(m.survival(), 0.9)
  close(m.nonspecific_mass(), 0.4)
  close(m.ignorance(), 0.4)
  assert_eq(m.interval(1), (m.belief(1), m.plausibility(1)))
  rejects_invalid(() => m.belief(4))
  rejects_invalid(() => m.plausibility(-1))
  rejects_invalid(() => m.commonality(9))
}
