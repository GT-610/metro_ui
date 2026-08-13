# Architecture and maintenance

## Public package boundary

Applications should import only `package:metro_ui/metro_ui.dart`. Files below
`lib/src` are implementation details and may move without a deprecation cycle.
The package deliberately does not re-export Flutter Material, Widgets, or
Services APIs.

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
