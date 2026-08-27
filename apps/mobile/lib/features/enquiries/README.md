# Enquiries & Orders

**Owner: Flutter A**

Incoming buyer enquiries, arriving as a spoken alert in the artisan's
language — this is the return edge that makes the whole system a sales channel
rather than a catalog.

Order and enquiry state is server-authoritative and never written offline
(ADR-0001).

## Layout
- `domain/` — entities and use cases. No Flutter imports.
- `data/` — repositories, API + Drift access. Implements domain interfaces.
- `presentation/` — widgets and Riverpod controllers.

Nobody outside this feature edits these files without talking to the owner.
