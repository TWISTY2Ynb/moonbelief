# Security and safe use

This is a bounded numeric library, not a safety-certified decision system. Do not deploy the demonstration policy as a clinical, transport, financial or industrial safety authority. Validate frame completeness, source dependence, reliability provenance, rule assumptions and utility units independently.

All numeric inputs must be finite. Frame, focal, pair, dense, source, action and text-depth limits reject excessive work rather than silently truncate evidence. These bounds do not make arbitrary surrounding application code safe. The library has no runtime network, filesystem or credential access; the optional CLI reads one command argument, which may be visible in process listings. Do not place private evidence in CLI arguments on shared hosts; use the pure API inside your own controlled process instead.

JSON duplicate keys use core's last-key-wins behavior. Reject duplicates before this interface when ambiguity is security-relevant. CLI domain failures return an error JSON with process exit status zero; inspect schema/kind. Full conflict has no pignistic decision and is an explicit failure in the report facade.

Report suspected defects through the repository's GitHub issues using a minimal synthetic example. Do not include real sensitive evidence, tokens or private operational data. No private disclosure channel or response-time guarantee is advertised. CI installers fail closed on snapshot integrity mismatch; updating toolchain pins requires obtaining and checking both official archives again and rerunning all targets.
