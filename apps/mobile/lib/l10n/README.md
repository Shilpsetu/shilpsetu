# Localisation

**Owner: App dev B**

`app_en.arb` is the template — add a key there first, then to every other
locale file. `l10n.yaml` writes unfilled keys to `untranslated.json`, so a
missing translation is visible rather than silently falling back to English.

Generated code lands in `lib/l10n/generated/` (gitignored, produced by
`flutter gen-l10n`, which `flutter pub get` runs for you).

**Phase 1 ships `en` and `hi`.** The other twenty scheduled languages arrive in
Phase 2 — do not add empty ARB files for them now; an empty locale is worse
than an absent one, because it looks supported and is not.

Every string here is **heard**, not read. Write for the ear: short sentences,
no jargon, nothing that a text-to-speech engine would mangle.
