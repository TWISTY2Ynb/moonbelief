///|
fn json_object(
  value : Json,
  allowed : Array[String],
) -> Map[String, Json] raise BeliefError {
  let object = match value {
    Object(object) => object
    _ => raise Invalid("expected JSON object")
  }
  for key in object.keys() {
    let mut known = false
    for candidate in allowed {
      if key == candidate {
        known = true
        break
      }
    }
    if !known {
      raise Invalid("unknown JSON field")
    }
  }
  object
}

///|
fn required(object : Map[String, Json], key : String) -> Json raise BeliefError {
  match object.get(key) {
    Some(value) => value
    None => raise Invalid("missing required JSON field")
  }
}

///|
fn json_string(value : Json) -> String raise BeliefError {
  match value {
    String(text) => text
    _ => raise Invalid("expected JSON string")
  }
}

///|
fn json_number(value : Json) -> Double raise BeliefError {
  match value {
    Number(number, ..) => {
      if !finite(number) {
        raise Invalid("JSON number must be finite")
      }
      number
    }
    _ => raise Invalid("expected JSON number")
  }
}

///|
fn json_array(value : Json, maximum : Int32) -> Array[Json] raise BeliefError {
  match value {
    Array(values) => {
      if values.length() > maximum {
        raise Budget("JSON array exceeds shape budget")
      }
      values
    }
    _ => raise Invalid("expected JSON array")
  }
}

///|
fn json_strings(
  value : Json,
  maximum : Int32,
) -> Array[String] raise BeliefError {
  let values = json_array(value, maximum)
  let result : Array[String] = []
  for item in values {
    result.push(json_string(item))
  }
  result
}

///|
fn bounded_parse(text : String) -> Json raise BeliefError {
  if text.length() > 262144 {
    raise Budget("JSON text exceeds 262144 code units")
  }
  // Bound nesting before the standard parser can allocate a recursive tree.
  // Brackets inside quoted strings, including escaped quotes, do not count.
  let mut depth = 0
  let mut quoted = false
  let mut escaped = false
  for character in text {
    if quoted {
      if escaped {
        escaped = false
      } else if character == '\\' {
        escaped = true
      } else if character == '"' {
        quoted = false
      }
    } else if character == '"' {
      quoted = true
    } else if character == '{' || character == '[' {
      depth = depth + 1
      if depth > 12 {
        raise Budget("JSON nesting exceeds twelve containers")
      }
    } else if character == '}' || character == ']' {
      depth = depth - 1
      if depth < 0 {
        raise Invalid("unbalanced JSON containers")
      }
    }
  }
  @json.parse(text) catch {
    _ => raise Invalid("invalid JSON text or nesting depth")
  }
}

///|
fn decode_rows(
  f : Frame,
  value : Json,
  budget : Limits,
) -> Mass raise BeliefError {
  let rows = json_array(value, budget.focals)
  let entries : Array[(Int32, Double)] = []
  for row in rows {
    let object = json_object(row, ["subset", "mass"])
    let labels = json_strings(required(object, "subset"), 16)
    let mask = f.subset(labels)
    let weight = json_number(required(object, "mass"))
    entries.push((mask, weight))
  }
  mass(f, entries, budget~)
}

///|
fn encode_strings(values : Array[String]) -> Json {
  Json::array(values.map(value => Json::string(value)))
}

///|
fn encode_rows(m : Mass) -> Json raise BeliefError {
  let rows : Array[Json] = []
  for (mask, weight) in m.focals {
    rows.push(
      Json::object({
        "subset": encode_strings(m.domain.members(mask)),
        "mass": Json::number(weight),
      }),
    )
  }
  Json::array(rows)
}

///|
pub fn mass_from_json(
  value : Json,
  budget~ : Limits = default_limits(),
) -> Mass raise BeliefError {
  let object = json_object(value, ["schema", "frame", "masses"])
  if json_string(required(object, "schema")) != "moonbelief.mass.v1" {
    raise Invalid("unsupported mass schema")
  }
  let f = frame(json_strings(required(object, "frame"), 16))
  decode_rows(f, required(object, "masses"), budget)
}

///|
pub fn parse_mass(
  text : String,
  budget~ : Limits = default_limits(),
) -> Mass raise BeliefError {
  mass_from_json(bounded_parse(text), budget~)
}

///|
pub fn Mass::to_json(self : Mass) -> Json raise BeliefError {
  Json::object({
    "schema": Json::string("moonbelief.mass.v1"),
    "frame": encode_strings(self.domain.labels()),
    "masses": encode_rows(self),
  })
}

///|
pub fn Mass::json_text(self : Mass) -> String raise BeliefError {
  self.to_json().stringify()
}
