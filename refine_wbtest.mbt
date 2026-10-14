///|
test "vacuous extension refines and coarsens without inventing singleton weights" {
  let coarse = frame(["warm", "cool"])
  let fine = frame(["red", "blue", "green"])
  let m = mass(coarse, [(0, 0.1), (1, 0.2), (2, 0.3), (3, 0.4)])
  let blocks = [1, 6]
  let r = m.refine(fine, blocks)
  close(r.weight(6), 0.3)
  close(r.weight(2), 0.0)
  assert_eq(r.coarsen(coarse, coarse.refinement_inverse(fine, blocks)), m)
  rejects_invalid(() => m.refine(fine, [1, 3]))
  rejects_invalid(() => m.refine(fine, [1, 2]))
  rejects_invalid(() => m.refine(fine, [0, 7]))
}
