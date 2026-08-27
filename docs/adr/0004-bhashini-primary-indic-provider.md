# ADR-0004: Bhashini as primary Indic language provider

- **Status:** Accepted
- **Date:** 2026-08-27

## Context

The application must accept voice input across Indian regional languages and
speak back to users who cannot read. Options: commercial ASR/MT APIs,
self-hosted open models (Whisper, IndicTrans2, IndicTTS), or Bhashini -- the
Government of India's national language platform, run by the Digital India
Bhashini Division, covering the 22 scheduled languages via the ULCA APIs.

## Decision

Bhashini is the **default** implementation of `SpeechTranscriber`,
`Translator` and the TTS capability. Self-hosted Whisper + IndicTrans2 is the
**fallback** implementation behind the same interfaces (ADR-0002), proven
working in Phase 3 rather than assumed.

## Consequences

- On a Ministry problem statement, "built on the government's own language
  stack" is a materially stronger answer than "we call a commercial US API" --
  on sovereignty, on recurring cost, and on the ministry's own strategy.
- Bhashini onboarding takes time. Registration starts in Phase 0, well before
  the code needs it.
- We inherit Bhashini's language coverage and latency characteristics. Where
  its quality is weak for a dialect we care about, we degrade to guided
  spoken questions -- never to garbled output presented as a description.
- **Cost accepted:** a dependency on a platform whose rate limits and uptime
  we do not control, mitigated by the fallback path and cached demo assets.
