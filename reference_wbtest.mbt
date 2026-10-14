///|
// Independent test oracle uses explicit per-hypothesis membership rather than
// the production pair-target helpers or production lattice transforms.
fn reference_target(a : Int32, b : Int32, intersection : Bool) -> Int32 {
  let mut result = 0
  for hypothesis = 0; hypothesis < 3; hypothesis = hypothesis + 1 {
    let flag = 1 << hypothesis
    let left = a / flag % 2 == 1
    let right = b / flag % 2 == 1
    if (intersection && left && right) || (!intersection && (left || right)) {
      result = result + flag
    }
  }
  result
}

///|
fn reference_rule(a : Mass, b : Mass, rule : Rule) -> Array[Double] {
  let bins = Array::make(8, 0.0)
  for (left, x) in a.entries() {
    for (right, y) in b.entries() {
      let common = reference_target(left, right, true)
      let union = reference_target(left, right, false)
      let product = x * y
      match rule {
        Disjunctive => bins[union] = bins[union] + product
        DuboisPrade => {
          let target = if common == 0 { union } else { common }
          bins[target] = bins[target] + product
        }
        PairwisePCR5 =>
          if common == 0 {
            bins[left] = bins[left] + x * x * y / (x + y)
            bins[right] = bins[right] + y * y * x / (x + y)
          } else {
            bins[common] = bins[common] + product
          }
        _ => bins[common] = bins[common] + product
      }
    }
  }
  if rule == Yager {
    bins[7] = bins[7] + bins[0]
    bins[0] = 0.0
  }
  if rule == Dempster {
    let mut surviving = 0.0
    for i = 1; i < 8; i = i + 1 {
      surviving = surviving + bins[i]
    }
    bins[0] = 0.0
    if surviving > 0.0 {
      for i = 1; i < 8; i = i + 1 {
        bins[i] = bins[i] / surviving
      }
    }
  }
  bins
}

///|
fn quarter_masses(
  f : Frame,
  masks : Array[Int32],
) -> Array[Mass] raise BeliefError {
  let result : Array[Mass] = []
  for a = 0; a <= 4; a = a + 1 {
    for b = 0; b <= 4 - a; b = b + 1 {
      for c = 0; c <= 4 - a - b; c = c + 1 {
        let d = 4 - a - b - c
        result.push(
          mass(f, [
            (masks[0], a.to_double() / 4.0),
            (masks[1], b.to_double() / 4.0),
            (masks[2], c.to_double() / 4.0),
            (masks[3], d.to_double() / 4.0),
          ]),
        )
      }
    }
  }
  result
}

///|
test "exhaustive 1225 closed-world source pairs agree with six-rule membership oracle" {
  let f = frame(["a", "b", "c"])
  let cases = quarter_masses(f, [1, 2, 3, 7])
  assert_eq(cases.length(), 35)
  let mut pairs = 0
  for a in cases {
    for b in cases {
      pairs = pairs + 1
      for
        rule in [
          Conjunctive,
          Dempster,
          Disjunctive,
          Yager,
          DuboisPrade,
          PairwisePCR5,
        ] {
        let expected = reference_rule(a, b, rule)
        if rule == Dempster &&
          expected[1] + expected[2] + expected[3] + expected[7] == 0.0 {
          try fuse(a, b, rule) catch {
            e => assert_true(e is TotalConflict)
          } noraise {
            _ => fail("oracle predicted complete conflict")
          }
        } else {
          let actual = fuse(a, b, rule).dense()
          for i = 0; i < 8; i = i + 1 {
            close(actual[i], expected[i])
          }
        }
      }
    }
  }
  assert_eq(pairs, 1225)
}

///|
test "1225 open-world pairs validate empty-set propagation across five rules" {
  let f = frame(["a", "b", "c"])
  let cases = quarter_masses(f, [0, 1, 3, 7])
  let mut comparisons = 0
  for a in cases {
    for b in cases {
      for rule in [Conjunctive, Dempster, Disjunctive, Yager, DuboisPrade] {
        let expected = reference_rule(a, b, rule)
        let mut total = 0.0
        for value in expected {
          total = total + value
        }
        if rule == Dempster && total == 0.0 {
          try fuse(a, b, rule) catch {
            e => assert_true(e is TotalConflict)
          } noraise {
            _ => fail("oracle predicted complete conflict")
          }
        } else {
          let actual = fuse(a, b, rule).dense()
          for i = 0; i < 8; i = i + 1 {
            close(actual[i], expected[i])
          }
        }
        comparisons = comparisons + 1
      }
    }
  }
  assert_eq(comparisons, 6125)
}

///|
test "every quarter-mass query obeys monotonicity bounds and transform inversion" {
  let f = frame(["a", "b", "c"])
  for m in quarter_masses(f, [0, 1, 3, 7]) {
    let dense = m.dense()
    let zeta = subset_zeta(f, dense)
    let mobius = subset_mobius(f, zeta)
    let commonality = m.commonality_table()
    let inverse = from_commonality(f, commonality)
    for event = 0; event < 8; event = event + 1 {
      close(mobius[event], dense[event])
      close(inverse.weight(event), dense[event])
      close(commonality[event], m.commonality(event))
      assert_true(m.belief(event) <= m.plausibility(event) + 1.0e-12)
      for superset = 0; superset < 8; superset = superset + 1 {
        if reference_target(event, superset, true) == event {
          assert_true(m.belief(event) <= m.belief(superset) + 1.0e-12)
          assert_true(
            m.plausibility(event) <= m.plausibility(superset) + 1.0e-12,
          )
        }
      }
    }
  }
}
