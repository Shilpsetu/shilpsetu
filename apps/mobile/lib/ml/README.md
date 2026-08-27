# On-device inference

**Owner: Flutter A, with ML**

TFLite interpreters running in isolates so the UI thread never blocks.

- `segmenter` — U-2-Net-lite, INT8. Target: under 1.5 s on the reference device.
- `classifier` — MobileNetV3 over the craft taxonomy (Bet 02).

Model assets live in `assets/models/` and are budgeted at **25 MB total**
(ADR-0003). Exceeding that budget is a release blocker. Benchmark on the
₹7,000 device in Phase 1, not Phase 4 — a model that is too slow is much
cheaper to discover in September than in December.
