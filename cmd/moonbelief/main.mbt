///|
#cfg(target="js")
fn argument_offset() -> Int {
  2
}

///|
#cfg(not(target="js"))
fn argument_offset() -> Int {
  1
}

///|
fn main {
  let args = @env.args()
  let offset = argument_offset()
  if args.length() != offset + 1 {
    println(
      "{\"schema\":\"moonbelief.error.v1\",\"error\":\"usage: moonbelief JSON_REQUEST\"}",
    )
    return
  }
  let report = @belief.execute_json(args[offset]) catch {
    error => {
      let (kind, message) = match error {
        Invalid(message) => ("invalid", message)
        Budget(message) => ("budget", message)
        FrameMismatch => ("frame-mismatch", "ordered frames differ")
        TotalConflict =>
          (
            "total-conflict", "insufficient nonempty mass for decision projection",
          )
      }
      println(
        Json::object({
          "schema": Json::string("moonbelief.error.v1"),
          "kind": Json::string(kind),
          "error": Json::string(message),
        }).stringify(),
      )
      return
    }
  }
  println(report)
}
