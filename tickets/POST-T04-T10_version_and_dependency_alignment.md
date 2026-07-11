# T10 — Align version 0.1.0 and declare direct PDF dependency

## Objective

Make every user-visible and build metadata source agree on version `0.1.0`, and
declare packages the application imports directly.

## Required work

1. Set `pubspec.yaml` to `version: 0.1.0+1`.
2. Derive About-dialog version from package metadata using `package_info_plus`;
   do not retain a second hardcoded version string.
3. Update Windows file/product version metadata and any Android/iOS/macOS/Linux
   metadata generated from Flutter where applicable through supported build
   configuration, not edits to generated files.
4. Replace the default Flutter README title/description with a short PaperTek
   development README showing version 0.1.0 and the Windows run/build commands.
5. Add `pdf` as a direct dependency at the version compatible with `printing`.
   `printing` may no longer be the accidental source of an undeclared import.
6. Regenerate only normal dependency lock/plugin outputs.

## Gate

Search the repository for `1.0.0`, `0.1.0`, and `applicationVersion`. Every
relevant result must agree or be an explicitly documented third-party version.
Build Windows release.

