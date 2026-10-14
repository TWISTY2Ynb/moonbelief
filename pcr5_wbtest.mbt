///|
test "pairwise PCR5 redistributes only conflicting products to participating focals" {
  let f = frame(["a", "b"])
  let a = simple_support(f, 1, 0.6)
  let b = simple_support(f, 2, 0.7)
  let c = pcr5(a, b)
  close(c.weight(1), 0.18 + 0.42 * 0.6 / 1.3)
  close(c.weight(2), 0.28 + 0.42 * 0.7 / 1.3)
  close(c.weight(3), 0.12)
  close(c.conflict(), 0.0)
  close(pcr5(b, a).weight(1), c.weight(1))
  rejects_invalid(() => pcr5(a, mass(f, [(0, 0.1), (1, 0.9)])))
}
