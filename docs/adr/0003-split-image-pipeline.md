# ADR-0003: Split the image pipeline across the network boundary

- **Status:** Accepted
- **Date:** 2026-08-27

## Context

Turning a phone snapshot into a listing-grade product image involves cheap
steps (segment, crop, white-balance) and expensive ones (super-resolution,
relighting). Doing all of it server-side means the artisan stares at a spinner
over a 3G uplink. Doing all of it on-device means a slow, hot phone and a
larger APK than a low-end device can carry.

## Decision

**On-device, synchronous:** pre-shutter quality gate, segmentation
(U-2-Net-lite, INT8 TFLite), auto-crop to the target listing aspect,
white-balance and exposure normalisation, craft classification.
Budget: under 1.5 s end-to-end on the reference device.

**Server-side, queued:** super-resolution, relighting, contact-shadow
compositing, generation of marketplace-specific variants.

The on-device result is immediately usable and immediately shown. The server
pass replaces it later; the UI treats the upgrade as an update, never as a
blocking step.

## Consequences

- Two rendering paths for the same product image, and a state where local and
  server versions differ. `product_media` stores both, keyed by variant.
- The original capture is immutable and always retained, so any processing
  step can be re-run later without asking the artisan to re-photograph.
- Bundled model assets are budgeted at 25 MB total. Exceeding it is a release
  blocker, not a discussion.
- **Cost accepted:** duplicated image logic in Dart and Python, kept in sync
  by golden-image tests over a shared fixture set.
