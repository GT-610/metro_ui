# Architecture

## Public API

`lib/metro_ui.dart` is the only supported package entry point. Files below
`lib/src` are implementation details even when Dart visibility requires a
cross-file declaration to be public.

The package does not re-export Flutter's Material or Widgets libraries. This
keeps the public surface deliberate and avoids name collisions as Flutter
evolves.

The compatibility rules and intentional state-class exceptions are documented
in [public API stability](api_stability.md). Export changes are reviewed as API
changes even when the underlying declaration already existed below `lib/src`.

## Layers

```text
lib/
  metro_ui.dart
  src/
    foundation/       shared input and state behavior
    theme/            semantic design tokens and inherited theme
    localization/     replaceable control strings and semantic formatting
    controls/         user-facing components grouped by purpose
    layout/           page and layout primitives
```

The theme layer may depend on component theme-data classes, but not on widget
implementations. Components consume foundation behavior and theme data.
Foundation code does not depend on a concrete component.

## Theme precedence

```text
widget style > local component theme > application component theme > Metro default
```

State-dependent values use `WidgetStateProperty`. Light/dark theme changes use
complete `MetroThemeData` instances so semantic neutrals never become
inconsistent with brightness.

Applications can supply `MetroTheme.highContrastData` (or the matching
`AnimatedMetroTheme` property). The theme resolves it only when the ambient
`MediaQuery.highContrast` flag is true, so the selected palette is already
captured by routes and inherited component themes. The package provides light
and dark high-contrast factories but does not claim to reproduce platform
system colors that Flutter does not expose.

Small `InheritedTheme` widgets, such as `MetroTextFieldTheme`, provide local
component overrides. They compose with the matching component data stored in
`MetroThemeData` instead of replacing the complete color and typography
system. Dedicated scopes cover buttons, tiles, both progress indicators, list
tiles, check boxes, radio buttons, toggle switches, BackButton, Pivot, command
bars, number boxes, combo boxes, search boxes, FlipView, dialogs, flyouts,
tooltips, pickers, sliders, and data grids.
`MetroPickerTheme` controls both the segmented field and the popup wheels, and
is captured when a picker crosses the Navigator boundary. `MetroSliderTheme`
provides the shared track, thumb, tick, focus, and measurement tokens for both
single- and double-thumb sliders. `MetroDataGridTheme` owns header, row,
divider, focus, typography, padding, and measurement tokens for tabular data.

Route-based overlays and `MetroPageRoute` capture active `InheritedTheme`
instances before crossing the Navigator boundary. Page routes also capture the
call site's logical text direction so directional transitions remain correct
in both LTR and RTL layouts. Anchored overlays use `OverlayPortal` so they
retain the same Metro theme dependencies and cannot outlive their owning
widget.

## Motion model

`MetroMotion` stores reusable Windows animation recipes rather than only
abstract slow/medium/fast tiers. Generic 250ms fade-in, popup movement and
delayed opacity, edge-UI movement, FlipView content entrance/fade, panel
movement, page entrance and exit, pointer feedback, and Pivot content motion
have separate recipes. Reduced-motion media flags replace these durations with
zero at the component boundary without changing final state or input.

`MetroPageRoute` deliberately separates the 1000ms page transform from the
170ms entrance opacity and uses a 117ms linear reverse fade without sliding
the old page backward. Popup routes combine a 367ms 50-pixel transform with
the WinJS 83ms opacity delay and duration, then close with a separate 83ms
in-place fade. Flyout panels use the same 550ms standard curve in both
directions. `MetroCommandBarLayer` keeps the command surface out of normal
layout, translates its complete height from the selected edge for 367ms, and
uses secondary-click or inward-edge invocation plus click-eater, Escape, and
outward-drag dismissal. The narrow gesture target and drag threshold are
Flutter adaptations; the edge direction and completed transition follow the
WinJS pattern. Pivot keeps all item subtrees mounted and gives its programmatic
outgoing and incoming pages their separate verified 350ms curves; direct drag
uses a pointer-controlled offset followed by a short Metro settle.

## Interaction contract

`MetroInteractive` centralizes pointer activation, Enter/Space activation,
focus, hover, pressed state, cursor, and semantics. New controls should reuse
this contract unless their interaction model genuinely differs.

`MetroFocusTraversalGroup` operates one level above individual controls. It
owns a persistent `FocusScopeNode`, delegates ordering to Flutter traversal
policies, and configures sequential and directional edge behavior separately.
It must not replace a control's activation shortcuts or internal navigation
model.

`MetroLiveTile` composes `MetroTile` instead of reimplementing its input and
state behavior. Its content model owns only frame identity, timing, semantics,
and face transitions. Automatic timers are cancelled when the widget is
inactive, outside `TickerMode`, reduced-motion constrained, updated, or
disposed.

## Picker model

`MetroDatePicker` and `MetroTimePicker` share a segmented field and a focused
scrolling-wheel primitive. The field follows the package interaction contract;
the wheel additionally supports arrow and Page Up/Page Down adjustment and
adjustable semantics.

Picker fields are controlled values. A null `onChanged` disables the complete
interaction surface. Popup routes keep a draft value and only return it when
the user confirms, so Escape, barrier dismissal, and `CANCEL` do not mutate
application state.

Date selection is constrained to an inclusive range and clamps invalid day
values when month or year changes. The default field order covers common US,
East Asian, and day-first locale conventions. Labels and formatting are
injected through callbacks instead of adding a mandatory `intl` dependency.
Time selection uses the immutable `MetroTime` value model, supports 12- and
24-hour presentation, and normalizes values to the nearest configured minute
increment before showing the popup.

## Combo-box model

`MetroComboBox<T>` keeps selection controlled by the application and models
rows as immutable `MetroComboBoxItem<T>` values. The field retains input focus
while its `OverlayPortal` popup is visible, so internal Up/Down, Home, End,
Enter, Space, and Escape handling does not leak into surrounding traversal.
Closing the popup restores the field focus unless focus deliberately moved to
another control.

Popup layout measures the trigger in overlay coordinates, follows the logical
start edge for LTR and RTL, and chooses the side with sufficient viewport
space. Long lists use fixed-height lazy rows inside a constrained scroll view;
keyboard highlights are scrolled into view without changing the controlled
value. Disabled rows remain visible and semantic but are excluded from pointer
selection and keyboard navigation.

## SearchBox model

`MetroSearchBox<T>` owns only the effective text-controller fallback and
keyboard highlight; applications may supply their own controller and replace
the immutable suggestion list after any query change. The default filter is a
case-insensitive substring match against each item's `queryText`. A custom
filter can implement ranking or bypass local filtering for server results.

User editing, suggestion selection, and clearing report distinct change
reasons. Choosing a suggestion writes its query text and invokes `onSelected`
without implicitly submitting it. Enter chooses a highlighted suggestion or
submits the current query; the attached search button follows the same submit
contract. Disabled suggestions remain semantic and visible but are skipped by
pointer and keyboard selection.

The suggestion popup uses `OverlayPortal` so it shares the owning theme and
lifecycle. It aligns to the logical start edge, flips above when viewport space
requires it, scales fixed rows for large text, and leaves a hit-test opening
over the field so editing can continue while results are visible. Only the
popup exterior dismisses the results.

## NumberBox model

`MetroNumberBox<T extends num>` keeps its numeric value controlled by the
application while owning a text controller for the editable draft. User text
is parsed only on submission or focus loss. Successful commits are formatted
once and marked synchronized so lossy display formatters cannot be parsed and
submitted a second time when the same action also moves focus.

Integer boxes reject fractional input. Decimal boxes can control display
precision, and applications can replace both parsing and formatting for units
or locale-specific syntax. Committed values are clamped to optional bounds and
can snap to a `smallChange` grid relative to the minimum. Invalid text either
restores the supplied value or remains visible with the text-field error state.

Inline pointer buttons, a focused mouse wheel, Arrow Up/Down, Page Up/Page
Down, Home, End, and adjustable semantics share the same stepping and boundary
logic. Pointer holding starts a cancellable repeat timer after the configured
delay. All timers and owned focus/controller resources are stopped before
disposal, and button animation follows the reduced-motion media flags.

## FlipView model

`MetroFlipView` supports either an application-owned `index` or an internal
selection initialized by `initialIndex`. User requests notify `onChanged`
before motion begins. A controlled widget reconciles back to the supplied
index if the application declines the request, while externally supplied
index changes use the same directional transition without a second callback.

Direct dragging retains the current page and at most one incoming page in the
tree. Circular navigation therefore does not create duplicate page subtrees,
which keeps children containing `GlobalKey` values safe. Horizontal physical
motion is derived from logical reading direction; vertical motion remains
independent of text direction. Arrow keys, Page Up/Page Down, Home, End,
adjustable semantics, navigation buttons, and indicators all use the same
neighbor calculation so their boundary behavior cannot drift apart.

Navigation buttons can remain visible, appear only while hovered or focused,
or stay hidden without disabling swipe and keyboard input. Reduced-motion
media flags commit the requested page immediately. Item banners and position
semantics update only when the displayed page is committed.

## Semantic Zoom model

`MetroSemanticZoom` owns two persistent focus scopes and keeps both the
detailed and summary widget subtrees mounted. Only the effective view accepts
pointer, focus, and semantics input. This preserves scroll and local widget
state without duplicating application data, while the application remains
responsible for mapping a selected summary group to its detailed item.

The widget can own its state from `initiallyZoomedOut` or accept a controlled
`zoomedOut` value. User input reports a request before a controlled transition
can begin. The 333ms cross-scale animation uses the WinJS 0.65 default factor,
with a supported range of 0.2 through 0.8, and aligns transforms to the direct
manipulation focal point. Reduced-motion media flags commit immediately.

Two-pointer pinch, Ctrl+wheel, Ctrl+Plus/Minus, the transient desktop minus
button, and adjustable semantics all converge on the same request path.
Keyboard and assistive transitions restore focus after the destination scope
is active; each scope remembers its last focused descendant. `locked` removes
all switching affordances without unmounting either view. RTL changes the
button's logical edge but does not reinterpret pinch geometry.

## Slider model

`MetroSlider` and `MetroRangeSlider` share one geometry and painter model so
pointer hit testing, keyboard direction, ticks, and visual values cannot drift
apart. Geometry converts values through logical direction first: horizontal
controls adapt to LTR/RTL, vertical controls increase upward by default, and
the explicit `reversed` flag inverts either orientation.

Both sliders are controlled values and use `FocusableActionDetector` for
arrow, Page Up/Page Down, Home, and End commands. The single-value control
exposes one adjustable semantic node. A range slider overlays two independent
focus and semantic targets on a shared painted track, while its gesture layer
selects the nearest thumb or moves the complete selected segment. Snapping and
`minimumRange` constraints are applied before notifying application state.

## Data grid model

`MetroDataGrid<T>` separates the immutable column schema, application-owned
rows, controlled `MetroDataGridSort`, and reusable `MetroSelectionController`
state. The grid never silently reorders application data. Header activation
reports the next direction, and the caller returns rows in the desired order.

Stable row keys own persistent `FocusNode` and `GlobalKey` resources so sorting
or replacing rows does not leak focus state. A fixed-height grid builds rows
lazily and uses its vertical scroll controller to materialize off-screen Home,
End, and Page-navigation targets before focusing them. An unconstrained grid
builds all rows for small page-embedded tables.

Column geometry resolves fixed widths first and distributes remaining width
among flex columns subject to minimum and maximum bounds. When the resolved
table is wider than its viewport, one horizontal scroll surface keeps headers
and rows aligned. Each row is one semantic and focus target; cell content stays
available to assistive technologies unless the application supplies a custom
row semantic label.

## Localization and directionality

`MetroLocalizations` supplies package-owned defaults without imposing an
`intl` dependency on applications. The bundled delegate supports English and
Simplified Chinese. Missing delegates deliberately fall back to English so a
control remains usable in small widget trees and tests. Explicit widget text
or formatting callbacks override localized defaults, and applications can
replace the localization type with their own delegate.

Layout and motion follow the ambient `Directionality`; they do not infer text
direction from a localization class. Controls use logical start/end geometry
for padding, alignment, borders, progress, gestures, and transitions. Widget
tests cover representative mirrored controls and preserve logical column order
for tabular data.

## Selection state

`MetroSelectionController<T>` owns ordered single- or multi-selection state
and policy such as required selection and maximum counts. It returns immutable
snapshots so callers cannot mutate state without notifications.

`MetroSelectionGroup<T>` supplies that controller through a typed inherited
scope. Selection controls listen to the controller directly, allowing one
controller to be shared across subtrees while preserving Flutter's normal
widget lifecycle. A group creates and disposes an internal controller when an
external controller is not supplied.

`MetroListTile` renders that state with the WinJS desktop filled-selection
treatment: square light/dark item wells, full hover and focus outlines, accent
selection with a logical top-end checkmark, and the 167ms pointer scale recipe.
Its 52px minimum row height is a Flutter list-row composition default, not a
claimed generic WinJS ListView measurement.

`MetroDataGrid` reuses the accent, selected-hover, high-contrast, and pointer
recipes for full rows while keeping its cell dividers and 2px focus border.
The grid omits the list-only corner checkmark; MahApps DataGrid corroborates
the row-wide accent treatment, while the 44px table density remains
package-owned.

## Testing

Each public component receives widget tests for layout, theme precedence,
pointer and keyboard interaction, disabled state, semantics, and reduced
motion where applicable. Light and dark golden baselines use the package's
bundled font to keep typography deterministic across development machines.
Accessibility baselines additionally cover 2x raster output, 1.5x text
scaling, and a requested high-contrast palette.

Selected Golden baselines are also the source of the package preview images in
`screenshots`. `dart run tool/check_package_screenshots.dart` verifies that the
published copies remain byte-for-byte identical to their tested sources. After
reviewing an intentional Golden change, maintainers can run the tool with
`--update` to refresh those copies.

Golden test libraries carry the `golden` tag registered in `dart_test.yaml`.
The stable workflow runs behavioral tests with coverage on Ubuntu and runs the
tagged visual suite on Windows, the canonical renderer used to review the
committed baselines. This avoids false failures from platform-specific
high-DPI rasterization while retaining full behavioral and visual coverage.
The declared minimum Flutter 3.32 job excludes only the version-sensitive
raster comparisons and still runs every behavioral test. Both test jobs
analyze the complete package.

The `example` application is both a gallery and a multi-platform integration
harness. It is intentionally independent and references the package by path.
