# ADR-0005: Contract-first -- OpenAPI generates the Dart client

- **Status:** Accepted
- **Date:** 2026-08-27

## Context

Six people, two tiers, four months. The default failure mode of a split team
is the app developers idle while waiting for an endpoint, then a day lost to a
field that was renamed without telling anyone.

## Decision

The FastAPI application is the single source of truth for the API contract. It
emits OpenAPI; CI regenerates `packages/api_client_dart` from that schema and
**fails the build if the committed client differs from the generated one**.
The generated client is committed but never hand-edited.

Mobile developers work against the generated client and a mock server from day
one; they are never blocked on a backend implementation.

## Consequences

- Endpoint shapes are designed before they are implemented, which is the point.
- A breaking API change cannot be merged without the regenerated client in the
  same PR, so the break is visible at review time rather than at integration
  time.
- **Cost accepted:** a generation step in CI, and the rule that nobody edits
  generated files -- which will be violated at least once and must be caught
  in review.
