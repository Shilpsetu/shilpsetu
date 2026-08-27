# Pricing

**Owner: Flutter B**

Show floor, suggested and stretch — never one number (Bet 03).

The floor is spoken aloud with its reasoning. The UI must make 'below this you
are losing money' unmistakable without relying on reading: use
`Palette.belowFloor`, an icon, and speech together.

## Layout
- `domain/` — entities and use cases. No Flutter imports.
- `data/` — repositories, API + Drift access. Implements domain interfaces.
- `presentation/` — widgets and Riverpod controllers.

Nobody outside this feature edits these files without talking to the owner.
