///|
test "alternative conflict policies yield distinct inspectable assignments" {
  let f = frame(["a", "b", "c"])
  let a = simple_support(f, 1, 1.0)
  let b = simple_support(f, 2, 1.0)
  close(disjunctive(a, b).weight(3), 1.0)
  close(yager(a, b).weight(7), 1.0)
  close(dubois_prade(a, b).weight(3), 1.0)
  let c = simple_support(f, 3, 1.0)
  close(dubois_prade(a, c).weight(1), 1.0)
  close(disjunctive(a, c).weight(3), 1.0)
  let empty = mass(f, [(0, 1.0)])
  close(dubois_prade(empty, empty).conflict(), 1.0)
  close(yager(empty, empty).ignorance(), 1.0)
}
