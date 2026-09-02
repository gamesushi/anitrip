# App Store Resubmission Notes — anitrip 1.1.5 (24)

**Rejection:** Guideline 4.0 — Design (permission purpose strings not presented in the app's localization language)
**New version:** 1.1.5 (build 24)

---

## Response for App Store Connect Resolution Center

Hello App Review Team,

Thank you for the feedback. We have addressed the Guideline 4.0 (Design) concern regarding
permission purpose strings by ensuring every permission request is presented in the user's
selected language.

### What was wrong
The `NS*UsageDescription` purpose strings in `Info.plist` were only supplied in a single
language. When the app ran in a locale different from the base language, the system permission
alerts fell back to that single language instead of the user's chosen localization, which is
what triggered the Design guideline notice.

### What we changed (version 1.1.5, build 24)
1. **Per-language permission strings.** We added `InfoPlist.strings` localized files for all
   13 supported languages (en, es, fr, it, ja, ko, ms, pt, ru, th, vi, zh-Hans, zh-Hant) so the
   camera, photo library, and location permission alerts now render in the user's language.
2. **Declared supported localizations.** `CFBundleLocalizations` is now set to the full list of
   13 languages in `Info.plist`.
3. **Full in-app multilingual compliance.** Beyond the permission strings, we completed a sweep
   of the entire app and localized all remaining user-facing Chinese strings (enum labels,
   export/share dialogs, CSV export headers, plan-group UI, and reference-cache status messages)
   through our `gen-l10n` ARB workflow. The app now has no un-localized UI text in any of the
   13 supported languages.

### Verification
- `flutter analyze` reports 0 errors across the library.
- The iOS build compiles successfully (`xcodebuild` → BUILD SUCCEEDED).
- All 13 `.lproj/InfoPlist.strings` files are present and contain the localized usage descriptions.

The updated build (1.1.5, 24) is ready for your review. Please let us know if any further
adjustment is needed.

Thank you,
GameSushi Team

---

## Permission strings localized (reference)

| Key | Purpose |
|-----|---------|
| `NSCameraUsageDescription` | Camera — capture pilgrimage reference photos |
| `NSPhotoLibraryUsageDescription` / `NSPhotoLibraryAddUsageDescription` | Photo library — save / share exported plans & photos |
| `NSLocationWhenInUseUsageDescription` | Location — show the user's position on the pilgrimage map |

(Localized values live in `ios/Runner/<lang>.lproj/InfoPlist.strings`.)
