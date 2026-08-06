# Contributing to metro_ui

Thank you for helping build a Flutter-native interpretation of Windows 8
Modern UI. Contributions should preserve both the visual language and the
interaction quality expected from a reusable Flutter package.

## Design scope

The default component language is typography-led, flat, square, direct, and
driven by one accent color. Later Fluent ideas such as acrylic, Mica, reveal
highlights, elevation-heavy surfaces, and general rounded geometry do not
belong in core defaults.

Reference projects may be studied for publicly observable structure and
behavior, but they are not source dependencies. Do not copy implementation
code, proprietary Microsoft assets, Segoe UI files, screenshots, or branding.
Express the design intent through Flutter conventions and original code.

Read [design principles](doc/design_principles.md), the
[Windows 8 reference audit](doc/reference_audit.md),
[component coverage](doc/component_coverage.md), and
[architecture](doc/architecture.md) before proposing a new component family or
changing a shared interaction model.

## Component acceptance checklist

A new or materially changed interactive component should account for every
applicable item below:

- pointer, touch, Enter/Space activation, hover, focus, pressed, and disabled
  behavior;
- keyboard navigation appropriate to the control, without replacing Flutter's
  surrounding focus traversal;
- semantic role, accessible name, value/state, and adjustable actions where
  applicable;
- light, dark, high-contrast, text-scaling, and disabled presentation;
- `MediaQuery.disableAnimations` and `accessibleNavigation` behavior;
- ambient LTR/RTL direction and logical start/end geometry;
- widget style, nearest component theme, application theme, and default
  precedence;
- controlled versus internal state ownership, including rejected controlled
  changes where relevant;
- localization or explicit-label overrides for package-owned text;
- focused widget tests, documentation, Gallery coverage, and a changelog entry.

Avoid adding a public parameter for a single Gallery example. Prefer an
existing Flutter primitive, style property, builder, controller, or component
theme when it expresses a durable contract.

## Development setup

Install a Flutter SDK allowed by `pubspec.yaml`, then resolve both packages:

```sh
flutter pub get
cd example
flutter pub get
```

Run the Gallery locally on Windows or Web as described in the README. Gallery
deployment is intentionally separate from normal contribution work.

## Local quality checks

Run these checks from the repository root before opening a pull request:

```sh
dart format --output=none --set-exit-if-changed lib test tool example/lib example/test
dart run tool/check_public_api.dart
dart run tool/check_package_screenshots.dart
flutter analyze
flutter test
flutter pub publish --dry-run
```

Then verify the Gallery package:

```sh
cd example
flutter analyze
flutter test
flutter build web --release
```

The hosted workflow runs the behavioral suite with coverage on Ubuntu and the
tagged Golden suite on Windows, which is the canonical renderer for the
committed visual baselines. It also analyzes and runs the non-Golden suite on
the minimum supported Flutter version, and builds the Gallery for all six
Flutter platform families.

## Public API changes

Only `package:metro_ui/metro_ui.dart` is supported. Keep implementation helpers
below `lib/src` private unless applications need a durable contract.

When a public declaration changes:

1. document the declaration and behavior;
2. update `tool/public_api_declarations.txt`;
3. update focused tests and `CHANGELOG.md`;
4. update `doc/api_freeze_review.md` while the 1.0 release-candidate freeze is
   active;
5. follow [public API stability](doc/api_stability.md).

Do not treat a manifest update as automatic approval for a larger API surface.

## Golden and package preview changes

Review visual changes deliberately. To regenerate Golden files, run:

```sh
flutter test --update-goldens test/goldens
```

If either Golden used by the package preview changed and the new result is
approved, refresh the published copy explicitly:

```sh
dart run tool/check_package_screenshots.dart --update
```

Inspect all changed PNG files before committing them. Never update Goldens only
to make an unexplained failure disappear.

## Pull requests

Keep changes focused and explain the user-visible behavior, design rationale,
and verification performed. Separate broad formatting or mechanical work from
behavioral changes when possible. Do not include generated `doc/api` output,
build products, dependency caches, or unrelated local files.

Be respectful and constructive in issues, reviews, and other project spaces.
