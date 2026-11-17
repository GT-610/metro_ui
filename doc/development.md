# Architecture and maintenance

## Public package boundary

Applications should import only `package:metro_ui/metro_ui.dart`. Files below
`lib/src` are implementation details and may move without a deprecation cycle.
The package deliberately does not re-export Flutter Material, Widgets, or
Services APIs.

The gallery in `example/` is a development harness, not part of the published
package, so it may declare a newer Flutter floor than the package. It targets
Flutter 3.47 to take the Material migration that Flutter 3.50 completed: the
SDK's `package:flutter/material.dart` is deprecated there in favour of
`package:material_ui/material_ui.dart`, and the gallery depends on the latter
instead of suppressing the notice. Keep the package's own `environment.flutter`
floor at its published minimum — raising it there narrows the range for every
downstream application, which the gallery's requirement does not.

Before 1.0.0, APIs may change when doing so materially improves the Metro model
or removes an accidental contract. Record every user-visible change in
`CHANGELOG.md`; explain non-mechanical migrations in release notes or pull
requests.

## Source layout

```text
lib/
  metro_ui.dart          public entry point
  src/
    foundation/          shared interaction, entrance, and focus behavior
    theme/               semantic tokens, themes, typography, and motion
    localization/        package-owned strings and formatting
    controls/            components grouped by purpose
    layout/              page and layout primitives
```

Theme data may depend on component style data, but not widget implementations.
Components consume foundation behavior and theme data. Shared foundation code
must not depend on a particular control family.

## State and styling contracts

Controls that represent application data use controlled values where accepting
or rejecting a requested change matters. Internal state should be limited to
transient concerns such as focus, hover, draft input, paging, animation, and
overlay visibility.

All component themes follow the same precedence:

1. Explicit widget property
2. Nearest component theme
3. `MetroThemeData`
4. Package default

Use `WidgetStateProperty` for stateful visual values. New public types and
top-level declarations need Dart documentation and must be included in
`tool/public_api_declarations.txt`.

## Tests and visual verification

Focused widget tests live beside their component families under `test`. The
tagged visual suite in `test/goldens` is rendered on Windows in CI; its checked
in baselines are the canonical visual reference. Package screenshots are copies
of approved Golden images and are checked by
`tool/check_package_screenshots.dart`.

Four of the fixtures are package previews rather than single-component
surfaces: `preview_controls`, `preview_navigation`, `preview_lists`, and
`preview_inputs`. They share `test/goldens/preview_support.dart`, which pins the
1280 by 720 canvas, loads the bundled Selawik faces, and takes the golden with
`await expectLater`. Keep new previews on that helper: `expect` with an
asynchronous matcher returns before the comparison finishes, so a golden checked
that way never fails.

Regenerate baselines with:

```sh
flutter test --update-goldens --tags golden
dart run tool/check_package_screenshots.dart --update
flutter test --tags golden
```

Text rasterization differs between platforms, so a baseline refreshed on macOS
or Linux shows the current layout and colors but not the canonical Windows
pixels, and the `goldens` job rejects it. Refresh the affected baselines on the
Windows renderer before a release and review the diff; a stale baseline is worse
than none, because it silently blesses the previous design.

The **Refresh Goldens** workflow does this render for you: dispatch it for the
branch, download the `goldens` artifact, and extract it over the working tree.
The artifact keeps the repository layout, so the images land back in
`test/goldens/baselines/` and `screenshots/` and replace the tracked files there;
review the diff and commit it. It regenerates every baseline and re-syncs the
package previews, so the previews stay byte copies of the new images.

For the same reason `flutter test --tags golden` is expected to differ on a
developer machine that is not the canonical renderer. Run the behavioural suite
locally and let the `goldens` CI job on `windows-latest` judge the pixels; if a
change is genuinely visual, upload the job's failure images and adopt its
`*_testImage.png` output as the new baselines.

Use the Gallery in `example` to validate a component in an integrated
application. The quality workflow checks formatting, API declarations,
screenshots, analysis, tests, a publish dry run, and Gallery analysis/tests/web
build. It also builds the Gallery for desktop and mobile targets on native CI
runners.

## Repository hygiene

Do not commit generated `doc/api` output, build products, dependency caches, or
platform scaffolding generated only for local validation. Keep documentation
task-focused: README for adoption, `CONTRIBUTING.md` for contribution workflow,
this file for maintenance contracts, and `design.md` for visual direction.
