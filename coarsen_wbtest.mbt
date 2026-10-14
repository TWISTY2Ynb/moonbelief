///|
test "coarsening merges categories while preserving query preimages" {
  let fine = frame(["red", "blue", "green"])
  let coarse = frame(["warm", "cool"])
  let m = mass(fine, [(1, 0.2), (2, 0.3), (4, 0.1), (7, 0.4)])
  let mapping = [0, 1, 1]
  let c = m.coarsen(coarse, mapping)
  close(c.weight(2), 0.4)
  close(c.belief(2), m.belief(fine.coarse_preimage(coarse, mapping, 2)))
  close(c.plausibility(2), m.plausibility(6))
  rejects_invalid(() => m.coarsen(coarse, [0, 0, 0]))
  rejects_invalid(() => m.coarsen(coarse, [0, 1, 2]))
  rejects_invalid(() => m.coarsen(coarse, [0]))
}
