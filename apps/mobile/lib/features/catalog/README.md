# Catalog

**Owner: Flutter B**

The artisan's product list, backed by Drift (ADR-0001).

Products are identified **by their own photograph**, never by a typed name.
There is no text-entry search box in this feature.

## Layout
- `domain/` — entities and use cases. No Flutter imports.
- `data/` — repositories, API + Drift access. Implements domain interfaces.
- `presentation/` — widgets and Riverpod controllers.

Nobody outside this feature edits these files without talking to the owner.
