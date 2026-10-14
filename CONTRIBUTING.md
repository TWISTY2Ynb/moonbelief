# Contributing

Use MoonBit block style (`///|`); keep public contracts explicit and arrays non-aliasing. Add stable assertion tests for numerical behavior and budget/error boundaries. Never change a fusion rule simply to match one desired example; supply independent mathematical cases. New rules need assumptions, conflict behavior and associativity scope documented.

Run `moon info && moon fmt`, inspect `.mbti` changes, then `moon fmt --check`, strict check/test/build and example checks for each target. Run `python scripts/differential.py` and `python scripts/audit.py`. CI installs integrity-pinned official snapshots, not arbitrary latest binaries. No native result may be inferred from check-only output.

Keep credentials and private operational data out of issues, source, examples, history and package archives. Submit focused commits with a clear implementation/test purpose. Release changes must keep module version, Git tag and public source aligned.
