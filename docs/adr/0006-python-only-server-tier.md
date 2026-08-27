# ADR-0006: One language per tier -- Python everywhere on the server

- **Status:** Accepted
- **Date:** 2026-08-27

## Context

The ML work is unavoidably Python. The API tier could reasonably be
TypeScript, which would suit the buyer portal and give us a stronger web
ecosystem. That would mean two server languages, two dependency managers, two
test runners and a serialisation boundary between them.

## Decision

The entire server tier is Python: FastAPI for the API, ARQ for async work,
the same `uv` project for both, and a server-rendered buyer portal rather than
a separate JS application.

## Consequences

- One mental model for six students under deadline. The ML and API developers
  share tooling instead of negotiating an interface between runtimes.
- The domain layer (`app/domain`) imports nothing from FastAPI, so the
  framework stays replaceable and the use cases stay unit-testable.
- **Cost accepted:** the buyer portal is deliberately plain -- server-rendered
  HTML with minimal JavaScript. It is a demonstration surface for the linkage
  story, not a product we are judged on. If it ever needs to be a real SPA,
  that is a new ADR.
