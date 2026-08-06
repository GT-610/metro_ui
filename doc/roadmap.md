# Roadmap

## Foundation — complete for 0.1.0-dev.1

- theme, semantic color, typography, spacing, and motion tokens
- common pointer, keyboard, focus, disabled, and semantics behavior
- button, icon button, tile, tile grid, progress indicators, page, Pivot, text
  field, list tile, checkbox, radio button, and toggle switch
- light and dark visual regression baselines using the bundled font
- Windows/Web gallery, widget tests, static analysis, and CI

## Core Modern UI controls — complete for 0.1.0-dev.1

- password field conveniences and validation states — complete for text input
- Flutter `Form` validation, error, and success states — complete for text input
- selection groups and richer list selection models — complete
- determinate/indeterminate progress refinements — complete
- local component theme widgets across all current component families —
  complete

## Navigation and overlays

- bottom app bar / command bar — complete
- edge flyout — complete
- dialog and tooltip — complete
- navigation transition recipes — complete
- focus traversal policies for desktop and TV-style layouts — complete

## Advanced components

- NumberBox numeric entry and repeated stepping — complete
- SearchBox query suggestions — complete
- FlipView direct-manipulation paging — complete
- Semantic Zoom grouped collection navigation — complete
- live tile content model — complete
- date and time pickers — complete
- combo box and viewport-aware drop-down selection — complete
- slider and range slider — complete
- data grid — complete
- localization and RTL audit — complete
- extended golden coverage across DPI and text scale — complete

## Release criteria for 1.0

- documented stable public API — release-candidate freeze and dartdoc complete
- declared Flutter 3.32 lower bound — current stable passes analysis and all
  216 non-Golden tests; the expanded suite still needs a Flutter 3.32 and
  hosted rerun
- complete state and semantics coverage for every interactive control —
  complete; see the interaction audit
- reduced-motion and high-contrast strategy — complete
- Windows, Web, macOS, Linux, Android, and iOS package validation — Windows,
  Web, and Android verified locally; Linux, macOS, and iOS configured in CI
- visual regression suite and locally validated interactive gallery — complete;
  hosting is deferred until a deployment target is selected

See [release checklist](release_checklist.md) for current evidence and gates.
Potential additive controls are evaluated in the
[component coverage audit](component_coverage.md); they are not implicit 1.0
requirements.
