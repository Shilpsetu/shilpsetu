#!/usr/bin/env bash
# Create every Phase 0 and Phase 1 issue, labelled, milestoned and assigned.
# Run once, by the lead, after the repo exists and handles are filled in below.
#
#   ./tools/seed_issues.sh            # create everything
#   ./tools/seed_issues.sh --dry-run  # print what it would create
#
# Requires the GitHub CLI: https://cli.github.com  then `gh auth login`.
set -euo pipefail

# ---------------------------------------------------------------------------
# FILL THESE IN. GitHub usernames, no @.
LEAD="${LEAD:-}"
APPDEV_A="${APPDEV_A:-}"
APPDEV_B="${APPDEV_B:-}"
BACKEND="${BACKEND:-}"
MLDEV="${MLDEV:-}"
DESIGNDATA="${DESIGNDATA:-}"
# ---------------------------------------------------------------------------

DRY=0
[[ "${1:-}" == "--dry-run" ]] && DRY=1

command -v gh >/dev/null || { echo "gh not found: https://cli.github.com"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Run 'gh auth login' first."; exit 1; }

run() { if [[ $DRY == 1 ]]; then echo "  would: $*"; else "$@" >/dev/null; fi; }

echo "==> labels"
add_label() { run gh label create "$1" --color "$2" --description "$3" --force; }
add_label "phase-0"          "0E8A16" "Foundations, by 2 Sep"
add_label "phase-1"          "1D76DB" "Walking skeleton, by 14 Sep"
add_label "area:mobile"      "5319E7" "Flutter app"
add_label "area:backend"     "B60205" "FastAPI"
add_label "area:ml"          "D93F0B" "Models and providers"
add_label "area:design-data" "FBCA04" "Design system and seed data"
add_label "area:infra"       "C2E0C6" "CI, docker, tooling"
add_label "blocks-demo"      "E99695" "On the critical path for the demo"

echo "==> milestones"
for m in "Phase 0 — foundations:2026-09-02" "Phase 1 — walking skeleton:2026-09-14"; do
  title="${m%%:*}"; due="${m##*:}"
  if [[ $DRY == 1 ]]; then echo "  would: milestone '$title' due $due"; else
    gh api "repos/{owner}/{repo}/milestones" -f title="$title" \
      -f due_on="${due}T23:59:59Z" >/dev/null 2>&1 || true
  fi
done

# issue <assignee> <milestone> <labels> <title> <body>
issue() {
  local who="$1" ms="$2" labels="$3" title="$4" body="$5"
  local args=(--title "$title" --body "$body" --label "$labels" --milestone "$ms")
  [[ -n "$who" ]] && args+=(--assignee "$who")
  if [[ $DRY == 1 ]]; then echo "  [$ms] ${who:-unassigned}: $title"; else
    gh issue create "${args[@]}" >/dev/null
  fi
}

P0="Phase 0 — foundations"
P1="Phase 1 — walking skeleton"

echo "==> issues"

# --- Lead
issue "$LEAD" "$P0" "phase-0" \
 "Confirm the SIH roster and register the team" \
 "Six members from one institution, minimum one female member, 1-2 mentors named.

**Blocks the internal-round entry, so this goes first.** Teams have been disqualified on the composition rule."
issue "$LEAD" "$P0" "phase-0,blocks-demo" \
 "Buy the reference device (2 GB RAM Android)" \
 "Every performance claim in the plan is unverifiable until this is on a desk.

Done looks like: the phone exists, \`flutter run\` works on it, and the segmentation latency number in issue *TFLite plumbing* was measured on it."
issue "$LEAD" "$P0" "phase-0" \
 "Register for Bhashini API access" \
 "https://bhashini.gitbook.io/bhashini-apis — government onboarding queue. Start now; ML needs credentials in Phase 1, not in November."
issue "$LEAD" "$P0" "phase-0,area:infra" \
 "Fill in CODEOWNERS and the START_HERE table" \
 "Replace the placeholder handles in \`.github/CODEOWNERS\` with real usernames, and put names in the routing table in \`START_HERE.md\`.

Until this is done CODEOWNERS silently does nothing. Verify with \`./tools/check_setup.sh\`."
issue "$LEAD" "$P1" "phase-1,blocks-demo" \
 "Write and rehearse the demo script" \
 "Ninety seconds: photo, voice, price, published. Screen mirrored.

Rehearse it **with the network switched off** (\`PROVIDER_PROFILE=mock\`), and rehearse being interrupted mid-flow."

# --- App dev A
issue "$APPDEV_A" "$P0" "phase-0,area:mobile,blocks-demo" \
 "Camera preview running on the reference device" \
 "Respect \`Sizes.minTouchTarget\` (64dp) from \`lib/core/theme/tokens.dart\`.

Done looks like: shutter button reachable one-handed, preview stable, no jank on the reference device."
issue "$APPDEV_A" "$P0" "phase-0,area:mobile,blocks-demo" \
 "TFLite segmentation plumbing in an isolate + latency baseline" \
 "Use **any** U-2-Net-lite checkpoint. Do not wait for ML's tuned model.

Done looks like: a measured millisecond number on the reference device, posted in this issue. Budget is \`Timings.segmentationBudget\` (1.5 s). If it is unreachable, we need to know in September."
issue "$APPDEV_A" "$P1" "phase-1,area:mobile,blocks-demo" \
 "Pre-shutter quality gate" \
 "Refuse a blurred or backlit frame **before** the shutter fires, and say why aloud in the artisan's language.

Fixing a bad photo costs more than not taking one, and the spoken reason teaches her."
issue "$APPDEV_A" "$P1" "phase-1,area:mobile,blocks-demo" \
 "Segment, auto-crop and white-balance to listing spec" \
 "On-device, under 1.5 s (ADR-0003). Output must satisfy the Amazon listing spec that Bharat TULIP's storefront enforces.

Hand the processed image to the cataloger flow."
issue "$APPDEV_A" "$P1" "phase-1,area:mobile" \
 "Enquiry inbox with spoken alerts" \
 "Incoming buyer enquiries arrive as audio in her language.

Order and enquiry state is server-authoritative and never written offline (ADR-0001)."

# --- App dev B
issue "$APPDEV_B" "$P0" "phase-0,area:mobile,blocks-demo" \
 "Audio capture, playback and Hindi TTS on device" \
 "\`record\` for capture, \`flutter_tts\` for playback. Verify Hindi actually speaks on a real device — emulator TTS lies."
issue "$APPDEV_B" "$P0" "phase-0,area:mobile" \
 "Set up ARB files for hi-IN and en-IN" \
 "The analyzer fails the build on a missing string. That is deliberate: an unlocalised string is a bug in an app for people who do not read English."
issue "$APPDEV_B" "$P1" "phase-1,area:mobile,blocks-demo" \
 "Voice note to structured attributes, asking missing fields aloud" \
 "Record, send to \`POST /v1/catalog/from-voice\`, show extracted attributes.

The API returns \`attributes.missing\` — the unfilled fields **in the order to ask about them**. Ask one question at a time, spoken. Never show a form."
issue "$APPDEV_B" "$P1" "phase-1,area:mobile,blocks-demo" \
 "Read the description back for spoken approval" \
 "Speak the generated description in her language; she approves or re-records.

**Not skippable.** An artisan who cannot read has no other way to check what was written about her own product. This is what keeps her the author rather than the subject."
issue "$APPDEV_B" "$P1" "phase-1,area:mobile,blocks-demo" \
 "Price screen: floor, suggested, stretch" \
 "Never one number. Speak the rationale.

Handle \`position == 'floor_above_market'\` explicitly: use \`Palette.belowFloor\`, an icon, **and** speech together — colour alone fails in sunlight and for colour-blind users.

Money is \`Decimal\`. Never do rupee arithmetic in floating point."

# --- Backend
issue "$BACKEND" "$P0" "phase-0,area:backend" \
 "Postgres schema and first Alembic migration" \
 "The eleven tables from the plan's data-model section. No manual DDL, ever."
issue "$BACKEND" "$P0" "phase-0,area:backend" \
 "Media upload to MinIO with immutable originals" \
 "The original capture is never overwritten, so any processing step can be re-run without asking the artisan to re-photograph."
issue "$BACKEND" "$P0" "phase-0,area:backend,area:design-data" \
 "Seed loader for crafts.json and wages.json" \
 "Idempotent — safe to re-run. Fails loudly on a malformed seed rather than importing half of it."
issue "$BACKEND" "$P1" "phase-1,area:backend,blocks-demo" \
 "Persist products, media, attributes, descriptions and price quotes" \
 "\`price_quotes\` rows are immutable: we must always be able to reproduce a suggestion we showed someone."
issue "$BACKEND" "$P1" "phase-1,area:backend,blocks-demo" \
 "Queue image post-processing through ARQ" \
 "The expensive server-side pass must never block the artisan (ADR-0003)."

# --- ML
issue "$MLDEV" "$P0" "phase-0,area:ml" \
 "Bhashini implementation of SpeechTranscriber" \
 "Implement the existing interface in \`app/providers/base.py\`, register it in \`providers/registry.py\`, switch with \`PROVIDER_TRANSCRIBER=bhashini\`.

**Nothing outside \`providers/\` should change.** If it does, the interface is wrong and we fix the interface (ADR-0002)."
issue "$MLDEV" "$P0" "phase-0,area:ml" \
 "Baseline and begin tuning the segmentation model" \
 "Start from whatever checkpoint App dev A has running. INT8, inside the 25 MB bundled-asset budget."
issue "$MLDEV" "$P1" "phase-1,area:ml,blocks-demo" \
 "Real extraction into ProductAttributes" \
 "Transcript to typed schema. Unfilled fields become spoken follow-up questions — never model invention."
issue "$MLDEV" "$P1" "phase-1,area:ml,blocks-demo" \
 "Craft-conditioned description generation (en-IN, hi-IN)" \
 "Use the craft's \`vocabulary\` from \`infra/seeds/crafts.json\`.

**Generic adjectives are the bug.** If it writes 'blue cloth' about a double-ikat saree, Bet 02 has failed."
issue "$MLDEV" "$P1" "phase-1,area:ml" \
 "Comparables band for one craft" \
 "Hardcoded is acceptable in Phase 1, but versioned and citable from Phase 2. Every quote carries the snapshot it came from."

# --- Design + data
issue "$DESIGNDATA" "$P0" "phase-0,area:design-data,blocks-demo" \
 "Zero-literacy design system" \
 "Icon set, colour semantics, touch targets, spoken-prompt patterns. Start from \`apps/mobile/lib/core/theme/tokens.dart\`, where the constraints are already encoded.

**Both app developers build against this, so it blocks them if it is late.**"
issue "$DESIGNDATA" "$P0" "phase-0,area:design-data" \
 "Verify every GI claim in crafts.json" \
 "Check each against https://search.ipindia.gov.in/GIRPublic/ — \`kantha_stitch\` is marked unverified on purpose. Under-claim where uncertain.

Wrong craft vocabulary makes a generated description *confidently* wrong, which a buyer spots before we do."
issue "$DESIGNDATA" "$P0" "phase-0,area:design-data" \
 "Fill wages.json with cited state wage notifications" \
 "Every row needs a real \`source_ref\`.

**A wage figure we cannot cite is one we cannot defend on stage**, and the fair-wage floor is our strongest impact claim."
issue "$DESIGNDATA" "$P1" "phase-1,area:design-data,blocks-demo" \
 "Buyer portal listing page" \
 "It only has to render one listing well. This is the last five seconds of the demo — the listing appearing where a buyer would see it."

echo
if [[ $DRY == 1 ]]; then echo "Dry run. Re-run without --dry-run to create."; else echo "Done. Check the Issues tab."; fi
