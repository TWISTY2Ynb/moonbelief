///|
/// Reorder to an exactly matching set of labels. Fusion never aligns silently.
pub fn Mass::align(
  self : Mass,
  target : Frame,
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  if target.size() != self.domain.size() {
    raise FrameMismatch
  }
  let mapping : Array[Int] = []
  for name in self.domain.names {
    let mut position = -1
    for i = 0; i < target.size(); i = i + 1 {
      if target.names[i] == name {
        position = i
        break
      }
    }
    if position < 0 {
      raise FrameMismatch
    }
    mapping.push(position)
  }
  self.coarsen(target, mapping, budget~)
}

///|
/// Rename positionally; caller asserts that the new labels mean the same
/// hypotheses. This is not semantic matching or automatic label inference.
pub fn Mass::relabel(
  self : Mass,
  names : Array[String],
  budget? : Limits = default_limits(),
) -> Mass raise BeliefError {
  let target = frame(names)
  if target.size() != self.domain.size() {
    raise Invalid("relabeling must preserve hypothesis count")
  }
  mass(target, self.entries(), budget~)
}
