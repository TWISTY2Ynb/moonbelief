///|
test "utility decisions abstain on ignorance or inadequate margins" {
  let f = frame(["a", "b"])
  let utilities = [[1.0, 0.0], [0.0, 1.0]]
  let policy = decision_policy()
  let d = bayesian(f, [0.8, 0.2]).decide(
    ["choose-a", "choose-b"],
    utilities,
    policy,
  )
  assert_true(d.accepted)
  assert_eq(d.label, "choose-a")
  close(d.margin, 0.6)
  let abstain = vacuous(f).decide(["choose-a", "choose-b"], utilities, policy)
  assert_true(!abstain.accepted)
  assert_eq(abstain.reason, "nonspecificity exceeds policy")
  assert_true(
    !bayesian(f, [0.5, 0.5]).decide(["a", "b"], utilities, policy).accepted,
  )
  close(bayesian(f, [0.8, 0.2]).expected_losses([[0.0, 5.0]])[0], 1.0)
  rejects_invalid(() => vacuous(f).expected_utilities([[1.0]]))
  rejects_invalid(() => vacuous(f).expected_losses([[-1.0, 0.0]]))
  rejects_invalid(() => decision_policy(max_conflict=1.1))
  rejects_invalid(() => vacuous(f).decide(["x", "x"], utilities, policy))
}
