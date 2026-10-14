///|
test "JSON mass boundary roundtrips empty-set conflict and rejects malformed schemas" {
  let f = frame(["a", "b"])
  let m = mass(f, [(0, 0.1), (1, 0.2), (3, 0.7)])
  assert_eq(parse_mass(m.json_text()), m)
  rejects_invalid(() => parse_mass("{}"))
  rejects_invalid(() => parse_mass("not json"))
  rejects_invalid(() => {
    mass_from_json(Json::object({ "unexpected": Json::null() }))
  })
  rejects_invalid(() => json_number(Json::number(1.0 / 0.0)))
  rejects_invalid(() => {
    mass_from_json(
      Json::object({
        "schema": Json::string("other"),
        "frame": encode_strings(["a"]),
        "masses": Json::array([]),
      }),
    )
  })
  rejects_invalid(() => {
    decode_rows(
      f,
      Json::array([
        Json::object({
          "subset": encode_strings(["c"]),
          "mass": Json::number(1.0),
        }),
      ]),
      default_limits(),
    )
  })
}
