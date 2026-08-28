# Shilpsetu — mobile

Flutter, Android-first. Two owners: **Flutter A** (capture, on-device ML,
enquiries) and **Flutter B** (voice cataloger, catalog, pricing, i18n).
Feature folders are the ownership boundary — see each `README.md`.

## First run

The native `android/` and `ios/` folders are not committed yet. Generate them
over this tree without touching `lib/`:

```bash
flutter create . --platforms=android,ios --org in.shilpsetu
flutter pub get
flutter run
```

Mobile CI stays dormant until `android/` is committed, then runs on every PR.
Run `dart format .` before that first push — the scaffolding was written by
hand and has not been through the formatter.

## Every day

```bash
dart run build_runner watch -d     # freezed / riverpod / drift codegen
flutter analyze --fatal-infos
flutter test
```

## Non-negotiable

1. **No typing on the artisan's critical path.** Voice, camera, or tap.
2. Nothing interactive is smaller than `Sizes.minTouchTarget` (64dp).
3. Colour never carries meaning alone — always icon + colour + speech.
4. Every user-visible string is in the ARB files, `hi-IN` included.
5. Test on the ₹7,000 reference device before you call it done.
