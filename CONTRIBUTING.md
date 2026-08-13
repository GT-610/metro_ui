# Contributing to metro_ui

Thank you for improving a Flutter-native interpretation of Windows 8 Modern
UI. Contributions should make the package easier to use while preserving the
design language, accessibility, and predictable API contracts described in the
[design guide](doc/design.md).

## Before you start

- Discuss a new component family or a significant behavior change in an issue
  before investing in a large implementation.
- Keep the default style flat, typographic, square, and accent-led. Do not add
  later Fluent patterns such as acrylic, Mica, reveal effects, rounded cards,
  or elevation-heavy surfaces as Metro defaults.
- Build original Flutter code. Reference projects can inform observable
  behavior, but do not copy source code, proprietary assets, screenshots,
  Segoe UI files, or branding.

## Set up the project

Install a Flutter SDK supported by `pubspec.yaml`, then fetch dependencies for
the package and Gallery:

```sh
flutter pub get
cd example
flutter pub get
```

Run the Gallery locally with `flutter run -d windows` or `flutter run -d
chrome` from `example`.

## Build components responsibly

For a new or materially changed interactive component, consider the applicable
items below:

- touch, mouse, keyboard, focus, hover, pressed, and disabled behavior;
- semantic role, accessible name, state/value, and adjustable actions;
- light, dark, high-contrast, large-text, LTR, RTL, and reduced-motion
  presentation;
- controlled versus internal state ownership, including rejected updates where
  the application owns the value;
- style precedence: widget value, local component theme, application theme,
  then package default;
- localization or an explicit-label alternative for package-owned text;
- focused tests, Gallery coverage where helpful, documentation, and a
  `CHANGELOG.md` entry for user-visible changes.

Avoid public parameters tailored to a single demo. Prefer an existing Flutter
primitive, builder, controller, style value, or component theme when it gives
applications a durable contract.

## Test your change

Run these checks from the repository root before opening a pull request:

```sh
dart format --output=none --set-exit-if-changed lib test tool example/lib example/test
dart run tool/check_public_api.dart
dart run tool/check_package_screenshots.dart
flutter analyze
flutter test
flutter pub publish --dry-run
```

Then check the Gallery:

```sh
cd example
flutter analyze
flutter test
flutter build web --release
```

The CI workflow also runs behavioral tests on the minimum supported Flutter
version, Windows Golden tests, and release builds for the Gallery's supported
platforms.

## Public API changes

Applications should import only `package:metro_ui/metro_ui.dart`; files under
`lib/src` are implementation details. Treat every export, public constructor,
and public parameter as a compatibility commitment.

When changing the public API:

1. Document the declaration and its behavior.
2. Update `tool/public_api_declarations.txt`.
3. Add or update focused tests and `CHANGELOG.md`.
4. Explain the migration path when a non-mechanical change is necessary.

## Golden and preview images

Review visual updates deliberately. To regenerate Golden baselines, run:

```sh
flutter test --update-goldens test/goldens
```

If an approved Golden is also used in the package preview, update its copied
image explicitly:

```sh
dart run tool/check_package_screenshots.dart --update
```

Inspect every changed PNG before committing. A Golden update is evidence of an
intentional visual change, not a way to hide a failure.

## Submit a pull request

Keep a pull request focused. Describe the user-visible result, the design
rationale, and the verification you performed. Do not include generated API
documentation, build outputs, dependency caches, or unrelated local changes.

Be respectful and constructive in issues, reviews, and other project spaces.
