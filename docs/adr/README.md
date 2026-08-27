# Architecture Decision Records

Every decision that would be expensive to reverse lives here, so that nobody
relitigates it in week four and so that we can answer "why?" on stage.

**Format:** context, decision, consequences. Consequences must include the
cost we accepted, not just the benefit. A decision with no stated cost has
not been thought about.

**Process:** open a PR that adds the next-numbered file. One reviewer.
Superseded records are never deleted -- add `Superseded by ADR-XXXX` to the
status line and leave the history intact.

| # | Decision | Status |
|---|----------|--------|
| [0001](0001-offline-first-device-source-of-truth.md) | Offline-first, device as UI source of truth | Accepted |
| [0002](0002-ai-provider-adapters.md) | Every AI capability behind a provider adapter | Accepted |
| [0003](0003-split-image-pipeline.md) | Split the image pipeline across the network boundary | Accepted |
| [0004](0004-bhashini-primary-indic-provider.md) | Bhashini as primary Indic language provider | Accepted |
| [0005](0005-contract-first-openapi.md) | Contract-first: OpenAPI generates the Dart client | Accepted |
| [0006](0006-python-only-server-tier.md) | One language per tier -- Python everywhere on the server | Accepted |
