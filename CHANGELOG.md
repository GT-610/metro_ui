# Changelog

## 0.2.0

- Reorganize documentation around package adoption, design direction,
  contribution, maintenance, and releases.
- Add Metro 4-informed logical tile badges and left/right/zoom live-face
  transitions while preserving WinJS motion curves and reduced-motion rules.
- Add `MetroEntrance` for directional and staggered Windows 8 page-content
  entrance motion.
- Apply the 0.975 Windows pointer feedback recipe to Metro buttons, with a
  themeable press scale and reduced-motion support.

## 0.1.0

- Establish the package architecture and single `metro_ui.dart` entry point.
- Add semantic colors, typography, spacing, motion, and light/dark themes.
- Add Metro button, icon button, tile, tile grid, progress ring, and page.
- Add Live Tiles with keyed content frames, frame-specific durations, dynamic
  semantics, directional face transitions, and reduced-motion freezing.
- Add Pivot navigation, text input, and toggle switch controls.
- Add checkbox, radio button, selectable list tile, and progress bar controls.
- Refine progress indicators with a five-dot indeterminate bar, size-aware
  five/six-dot rings, active-state control, localized semantic values,
  reduced-motion static states, and logical-direction determinate filling.
- Add reusable single/multiple selection controllers and inherited selection
  groups with required-selection and maximum-count policies.
- Bind radio buttons and multi-select list tiles to shared selection state,
  including keyboard and checked/selected semantics.
- Add text-field error/success feedback, secure password constructors, and
  `MetroTextFormField` integration with Flutter forms.
- Add subtree-level `MetroTextFieldTheme` overrides and semantic validation
  colors.
- Add a Windows 8-style bottom command bar, circular command buttons, and a
  `MetroPage.bottomBar` slot.
- Add theme-capturing Metro dialogs with keyboard dismissal and square Metro
  tooltips for hover, focus, and long-press discovery.
- Add start/end edge flyouts with an accent header, full-height layout, and
  directional entrance motion.
- Add theme-capturing page routes with logical LTR/RTL slide, drill, fade, and
  reduced-motion transition recipes.
- Add persistent Metro focus traversal groups with desktop parent-scope edges,
  contained spatial looping, custom policies, and directional keyboard tests.
- Add segmented date and time pickers with theme-capturing scrolling-column
  dialogs, locale-aware date ordering, configurable formatting, date-range
  clamping, 12/24-hour display, and minute increments.
- Add a generic Metro combo box with controlled selection, disabled rows,
  viewport-aware popup flipping, keyboard navigation, RTL alignment, semantics,
  reduced motion, and application/subtree/widget theme precedence.
- Add a generic Metro SearchBox with locally filtered or externally replaced
  suggestions, distinct edit/select/clear reasons, query submission, clear and
  search actions, keyboard highlighting, disabled rows, viewport-aware popup
  placement, localized semantics, and subtree theming.
- Add a generic Metro NumberBox with controlled integer and decimal values,
  commit-time parsing, optional step snapping, min/max clamping, custom
  formatting, invalid-input policies, keyboard and mouse-wheel stepping,
  press-and-hold repeat, adjustable semantics, and subtree theming.
- Add a Metro FlipView with controlled or internal selection, direct horizontal
  and vertical dragging, circular navigation without duplicate page subtrees,
  banners, indicators, RTL keyboard input, localized semantics, reduced motion,
  and application/subtree/widget theme precedence.
- Add horizontal and vertical Metro sliders with rectangular thumbs, logical
  RTL/reversed direction, ticks, snapping divisions, small/large keyboard
  changes, independent range-thumb semantics, minimum ranges, and whole-range
  dragging.
- Add a generic Metro data grid with fixed/flexible columns, controlled sort
  indicators, shared single/multiple row selection, disabled-row navigation,
  lazy fixed-height viewports, horizontal scrolling, and row semantics.
- Add English and Simplified Chinese Metro localization defaults with a
  replaceable delegate, English fallback behavior, localized picker and
  semantic strings, and a logical-direction RTL audit across controls.
- Add opt-in light and dark high-contrast theme data selected through
  `MediaQuery.highContrast`, AAA primary text palettes, corrected on-accent
  contrast selection, and accessibility goldens at 2x raster density and
  1.5x text scale.
- Expand CI gallery builds across Web, Windows, Linux, macOS, Android, and iOS,
  generating platform scaffolds on their native runners.
- Validate the declared Flutter 3.32 lower bound with static analysis and the
  complete non-Golden behavioral suite in CI.
- Keep the Web gallery as a locally validated release artifact while its
  eventual hosting target remains intentionally undecided.
- Add tested light and dark package preview images to the README and pub.dev
  screenshot metadata, with a CI guard that keeps them synchronized with their
  Golden baselines.
- Document every exported type, formalize the pre-1.0 and stable compatibility
  policy, and remove an accidentally exported internal theme tween.
- Add a contribution guide and pull-request checklist covering Modern UI
  fidelity, interaction completeness, API review, and visual regression work.
- Add a reference-derived component coverage matrix that records the 1.0 scope,
  deliberate later-Fluent exclusions, and admission criteria for 1.x controls.
- Add subtree themes for buttons, tiles, progress indicators, list tiles,
  check boxes, radio buttons, toggle switches, and Pivot, completing local
  component-theme coverage across the current library.
- Use system Segoe UI on Windows and bundle an Apache-licensed fallback font
  for reliable Web and non-Windows rendering.
- Add a Windows/Web gallery, widget tests, documentation, and CI workflows.
- Standardize non-Pivot fades and local state transitions on the shared Metro
  ease-out curve, including interruption-safe CommandBar and Tooltip motion.
- Prevent stale overlay and controlled-navigation callbacks from committing
  superseded state, and harden tile and tooltip geometry at narrow boundaries.
- Replace fixed zero-duration implicit animations with ordinary containers to
  avoid unnecessary animation state and rebuild overhead.
