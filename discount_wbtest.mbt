///|
test "discounting transfers missing reliability to ignorance even for open-world masses" {
  let f = frame(["a", "b", "c"])
  let m = mass(f, [(0, 0.1), (1, 0.2), (3, 0.4), (7, 0.3)])
  let d = m.discount(0.5)
  close(d.conflict(), 0.05)
  close(d.weight(1), 0.1)
  close(d.ignorance(), 0.65)
  assert_eq(m.discount(0.0), vacuous(f))
  assert_eq(m.discount(1.0), m)
  close(m.forget_detail().weight(7), 0.7)
  close(m.forget_detail().conflict(), 0.1)
  rejects_invalid(() => m.discount(-0.1))
  rejects_invalid(() => m.discount(0.0 / 0.0))
}
