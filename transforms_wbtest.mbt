///|
test "zeta Mobius roundtrips and all dense queries match sparse queries" {
  let f = frame(["a", "b", "c"])
  let m = mass(f, [(0, 0.1), (1, 0.2), (3, 0.3), (7, 0.4)])
  let dense = m.dense()
  let a = subset_mobius(f, subset_zeta(f, dense))
  let b = superset_mobius(f, superset_zeta(f, dense))
  let bel = m.belief_table()
  let q = m.commonality_table()
  let back = from_commonality(f, q)
  for i = 0; i < dense.length(); i = i + 1 {
    close(a[i], dense[i])
    close(b[i], dense[i])
    close(back.weight(i), dense[i])
    close(bel[i], m.belief(i))
    close(q[i], m.commonality(i))
  }
  rejects_invalid(() => subset_zeta(f, [1.0]))
  rejects_invalid(() => from_commonality(frame(["a"]), [1.0, 2.0]))
  rejects_invalid(() => subset_zeta(frame(["a"]), [1.0 / 0.0, 0.0]))
}
