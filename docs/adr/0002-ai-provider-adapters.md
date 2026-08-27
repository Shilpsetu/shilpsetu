# ADR-0002: Every AI capability behind a provider adapter

- **Status:** Accepted
- **Date:** 2026-08-27

## Context

We depend on speech recognition, translation, text generation, image
processing and price estimation. Each has several possible implementations
(hosted government APIs, commercial LLMs, self-hosted open models, on-device
models) with very different cost, latency and availability profiles. We do not
yet know which combination we will ship, and a government deployment cannot be
locked to a single commercial vendor.

## Decision

One abstract interface per capability, in `app/providers/base.py`:

`SpeechTranscriber`, `Translator`, `DescriptionWriter`, `ImageEnhancer`,
`PriceEstimator`.

Every interface has at minimum a **Mock** implementation returning
deterministic fixtures. Selection is by configuration, per capability, so we
can run Bhashini ASR with a mock writer, or everything mocked, without a code
change. Business logic imports the interface and never a concrete provider.

## Consequences

- Swapping providers is a config change, which is what lets us answer "what
  does this cost the government to run?" with a real alternative rather than a
  shrug.
- **The mock provider is not a testing convenience -- it is our demo
  insurance.** `PROVIDER_PROFILE=mock` must run the entire listing flow with
  the network disabled, and this is rehearsed, not assumed.
- Interfaces must be defined in terms of our domain, not any vendor's payload
  shape. A leaked vendor field in an interface signature is a review blocker.
- **Cost accepted:** an indirection layer, and the discipline of keeping
  provider-specific behaviour behind it even when a direct call would be
  quicker.
