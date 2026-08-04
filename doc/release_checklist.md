# Release checklist

This file records evidence and remaining work for a stable `1.0.0` release.
Passing a development-package check does not freeze the public API or imply
that the gallery has been published.

## Current verification

Verified locally on 2026-08-04:

- Dart formatting is clean.
- The package test suite passes all 172 widget and Golden tests.
- Golden tagging is complete: the 159 behavioral tests and 13 visual tests
  pass independently and together cover the full suite.
- Flutter 3.32.0 with Dart 3.8.0 passes dependency resolution, full static
  analysis, all 159 non-Golden behavioral tests, the public API guard, and the
  package screenshot guard in a local isolated SDK clone. The first hosted
  lower-bound CI result remains pending.
- The public API inventory passes with 143 documented declarations.
- The [1.0 API freeze review](api_freeze_review.md) approves the current
  inventory as the release-candidate surface.
- Dartdoc 9.0.8 generates the complete public library with zero warnings and
  zero errors; the quality workflow pins the same version.
- The gallery passes static analysis, both widget tests, and release builds.
  The widget tests were rerun after the latest NumberBox and local-theme
  gallery additions.
- Release Web, Windows, and Android gallery builds succeed locally. The
  Android release APK was built from a temporary platform harness so Android
  scaffolding does not expand the published example. Hosting-specific Web
  configuration is intentionally deferred until a deployment target is
  selected.
- The package screenshot guard confirms that both README/pub.dev previews are
  byte-for-byte copies of tested Golden baselines.
- `flutter pub publish --dry-run` reports zero warnings and a 796 KB compressed
  archive.
- The official pub.dev API and package page both return 404 for `metro_ui`, so
  no package currently uses the name. This observation does not reserve it and
  must be repeated immediately before publication.
- The repository, issue tracker, and license URLs declared by the package all
  return successful HTTP responses.
- Pana 0.23.15 scores 150/160 locally. It awards full points for documentation
  (300 of 1425 API elements, 21.1%), platform support, static analysis,
  dependency health, lower-bound compatibility, README, changelog, licensing,
  screenshots, and the example. Its internal dartdoc and `pub downgrade`
  checks pass. The remaining 10-point repository check cannot pass until the
  release candidate, including this `pubspec.yaml`, exists on the remote
  default branch.
- Accessibility goldens cover light/dark controls, navigation, FlipView,
  SearchBox, NumberBox, 2x raster density, 1.5x text scale, and high contrast.
- The [interaction and semantics audit](interaction_audit.md) maps every
  current interactive family to focused test evidence.
- The [component coverage audit](component_coverage.md) maps every 1.0 family
  to the references and documents deliberate exclusions and additive 1.x
  candidates without reopening the freeze.

The CI workflow also provisions missing example platform scaffolds on the
runner and builds Linux, macOS, Android, and unsigned iOS targets. Linux,
macOS, and iOS remain unverified until the workflow has completed successfully
in the hosted environments; Android has a local release result but still
awaits its hosted repetition.

## 1.0 gates

- **Public API stability and documentation — complete locally.** The package
  remains at `0.1.0-dev.1`; the compatibility policy, release-candidate API
  freeze, exported-type documentation, inventory, and dartdoc generation are
  verified. The current SDK bundles dartdoc 9.0.4, which fails internally while
  preprocessing Flutter dependency comments, so the release workflow
  explicitly uses dartdoc 9.0.8. The freeze must be reconfirmed from the
  intended release commit.
- **Declared SDK range — complete locally; pending hosted confirmation.**
  Flutter 3.32.0 and current stable both pass full static analysis. The lower
  bound passes all 159 version-independent behavioral tests plus the API and
  screenshot guards; current stable passes all 172 behavioral and Golden
  tests. CI repeats the lower-bound checks on a hosted runner.
- **Package identity — available at the latest audit.** The name and metadata
  links are valid as of 2026-08-04. Recheck the time-sensitive pub.dev name
  immediately before publication.
- **Interaction state and semantics — complete.** Every current interactive
  family is mapped to focused pointer, keyboard, state, and accessibility
  evidence in the interaction audit.
- **Reduced motion and high contrast — complete.** Motion responds to
  accessibility media flags. Applications can supply explicit high-contrast
  theme data selected by `MediaQuery.highContrast`.
- **Six-platform validation — pending hosted results.** Windows, Web, and
  Android pass locally; Linux, macOS, and iOS are configured in CI, while CI
  also repeats the Android build.
- **Visual regression and gallery — complete for the current release gate.**
  The regression suite is in place, tested light/dark previews are included in
  the README and package metadata, and the gallery builds locally. Publishing
  is intentionally outside the current gate until a hosting target is chosen.

Before changing the version to `1.0.0`, require one green CI run, reconfirm the
API freeze, and repeat dartdoc and the publish dry-run from the intended release
commit. Before publishing, recheck package-name availability and all external
metadata URLs.
