# ADR-0001: Offline-first, device as UI source of truth

- **Status:** Accepted
- **Date:** 2026-08-27

## Context

Our users are artisans in craft clusters where 4G is intermittent. The core
activity -- photographing twenty products in a courtyard -- happens away from
reliable signal. An app that requires connectivity to record work is an app
that loses the work.

## Decision

The local Drift (SQLite) database backs every screen. The UI never reads from
the network directly. Writes append to an **outbox** table carrying an
idempotency key, a device timestamp and a monotonic sequence number; a sync
worker drains the outbox when connectivity returns and the server reconciles.

Server responses update the local store; they never block a render.

## Consequences

- Every write path needs an idempotency key, and the server must be safe to
  call twice with the same one.
- We owe real conflict-resolution work in Phase 2. Last-write-wins is
  acceptable for descriptions and prices; it is **not** acceptable for order
  and enquiry state, which is server-authoritative and never written offline.
- Local schema migrations become a real concern -- an artisan may skip several
  app versions. Drift migrations are tested, not assumed.
- **Cost accepted:** more code, and a class of bug (divergent local state)
  that does not exist in an online-only app. We take it because losing an
  afternoon of an artisan's work once is worse than all of it.
