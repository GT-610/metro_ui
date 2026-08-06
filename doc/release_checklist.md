# Release checklist

This file records evidence and remaining work for a stable `1.0.0` release.
Passing a development-package check does not freeze the public API or imply
that the gallery has been published.

## Current verification

Verified locally on 2026-08-06:

- Dart formatting is clean.
- Current stable Flutter passes full static analysis and all 216 non-Golden
  behavioral tests.
- Golden tagging remains complete with 13 visual tests. Windows-rendered
  baselines remain canonical and were intentionally not regenerated on macOS;
  the package screenshot guard still validates both published previews.
- Flutter 3.32.0 with Dart 3.8.0 previously passed the then-current 159
  non-Golden tests plus analysis and repository guards in a local isolated SDK
  clone. The expanded 216-test suite must be repeated at the lower bound and
  in hosted CI before release.
- The public API inventory passes with 153 documented declarations.
- The [1.0 API freeze review](api_freeze_review.md) approves the current
  inventory as the release-candidate surface.
- Dartdoc 9.0.8 generates the complete public library with zero warnings and
  zero errors; the quality workflow pins the same version.
- The gallery passes static analysis, both widget tests, and its Web release
  build. The widget tests cover the controlled Semantic Zoom overview-to-group
  mapping in addition to the existing navigation and overlay scenarios.
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
- **Declared SDK range — pending expanded lower-bound confirmation.** Current
  stable passes full static analysis and all 216 non-Golden tests. Flutter
  3.32.0 passed the earlier 159-test surface, but the added controls and tests
  require a fresh lower-bound and hosted run. Canonical Windows Goldens remain
  a separate visual gate.
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
