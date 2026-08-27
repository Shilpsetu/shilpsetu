# Seed data

## `crafts.json`

18 crafts across Bharat TULIP's four collections. Top-level grouping uses the
Ministry's own collection names so an export drops onto the shelf they already
run (see ADR notes and `docs/karigar-plan-v1.html`).

### Before this ships -- owner: Design + data

Every field below was assembled from public sources and **must be verified**
before it appears in the deck or in front of a judge:

1. **`gi_tagged`** -- check each against the GI Registry at
   <https://search.ipindia.gov.in/GIRPublic/>. Under-claim where uncertain.
   `kantha_stitch` is currently `false` pending verification.
2. **`material_cost_hint`** and **`typical_hours`** -- these are rough
   placeholders used to prompt the artisan, never to price on her behalf.
   Replace with cluster-surveyed figures. If we cannot survey a craft, the app
   asks and does not guess.
3. **`cluster`** -- cross-check against the cluster development programme
   lists so we name the cluster the Ministry names.
4. **`vocabulary`** -- have someone who knows the craft read this. Wrong
   technical vocabulary is worse than none: it makes a generated description
   confidently wrong, which a buyer will spot before we do.

## `wages.json`

State handloom / handicraft minimum wage basis for the price floor (Bet 03).
**Every row needs a `source_ref` pointing at the actual notification.** A wage
figure we cannot cite is a wage figure we cannot defend on stage.
