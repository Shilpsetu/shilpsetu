# Capture & Studio

**Owner: Flutter A**

Camera, the pre-shutter quality gate, on-device segmentation, crop and
white-balance to listing spec (ADR-0003).

The quality gate refuses a blurred or backlit frame **before** the shutter
fires and says why aloud — fixing a bad photo is more expensive than not
taking one, and the spoken reason teaches the artisan.

Budget: segmentation returns in under `Timings.segmentationBudget` on the
reference device.

## Layout
- `domain/` — entities and use cases. No Flutter imports.
- `data/` — repositories, API + Drift access. Implements domain interfaces.
- `presentation/` — widgets and Riverpod controllers.

Nobody outside this feature edits these files without talking to the owner.
