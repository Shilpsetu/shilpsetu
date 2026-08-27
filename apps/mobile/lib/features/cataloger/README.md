# Voice Cataloger

**Owner: Flutter B**

Record a voice note in any supported language, send for transcription and
extraction, then read the generated description back aloud for approval.

The read-back is not a nicety. An artisan who cannot read has no other way to
check what was written about her own product, and it is what keeps her the
author rather than the subject. Do not make it skippable.

## Layout
- `domain/` — entities and use cases. No Flutter imports.
- `data/` — repositories, API + Drift access. Implements domain interfaces.
- `presentation/` — widgets and Riverpod controllers.

Nobody outside this feature edits these files without talking to the owner.
