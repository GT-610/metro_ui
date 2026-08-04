# Component coverage and scope

This document explains why the 1.0 release-candidate surface contains its
current component families. It is a design-scope audit, not a promise to clone
every control exposed by Windows, WPF, MahApps.Metro, or later Fluent UI.

## How the references are used

- **MahApps.Metro** is the strongest local reference for established Metro
  terminology, state treatment, and desktop control families such as Tile,
  Pivot, FlipView, Flyout, NumericUpDown, RangeSlider, and ProgressRing. WPF
  dependency properties, attached helpers, window chrome, and routed events do
  not define the Flutter API.
- **fluent_ui** is primarily an architectural reference for organizing a large
  Flutter package, component themes, localization, tests, and a Gallery. Its
  Acrylic, Mica, NavigationView, TeachingTip, rounded surfaces, and other later
  Fluent patterns are not evidence that they belong in Metro defaults.
- **flutter_metro_ui** is an application experiment rather than a component
  library. Its tile press/tilt experiment is useful visual corroboration, but
  its application state, Material coupling, and widget APIs are not used as
  architectural references.

All implementation in `metro_ui` remains original and Flutter-native.

## 1.0 coverage matrix

| Design area | metro_ui surface | Reference correspondence | 1.0 decision |
| --- | --- | --- | --- |
| Theme, type, color, spacing, and motion | `MetroTheme`, semantic schemes, typography, spacing, and motion tokens | Shared design vocabulary across both mature references | **Covered.** These tokens define the system before individual widgets. |
| Page surface and navigation motion | `MetroPage`, `MetroPageRoute` | MahApps `MetroContentControl`/navigation window; fluent_ui page and route organization | **Covered by Flutter composition.** Native window chrome remains application/platform-owned. |
| Buttons and compact actions | `MetroButton`, `MetroIconButton` | Styled buttons in both mature references | **Covered.** The circular command glyph is isolated to CommandBar rather than becoming general rounded geometry. |
| Tiles and live content | `MetroTile`, `MetroTileGrid`, `MetroLiveTile` | MahApps `Tile`; tile experiment in flutter_metro_ui | **Covered.** Includes direct press feedback, layout sizes, live frames, semantics, and reduced motion. |
| Text, password, and form input | `MetroTextField`, password conveniences, `MetroTextFormField` | MahApps text/password helpers; fluent_ui TextBox and PasswordBox | **Covered.** Uses Flutter controllers and `Form` instead of attached properties. |
| Numeric, choice, and suggestion input | `MetroNumberBox`, `MetroComboBox`, `MetroSearchBox` | MahApps `NumericUpDown`; fluent_ui NumberBox, ComboBox, and AutoSuggestBox | **Covered.** Controlled values and viewport-aware overlays are explicit Flutter contracts. |
| Binary and grouped selection | CheckBox, RadioButton, ToggleSwitch, selectable list tiles, selection controllers/groups | MahApps `ToggleSwitch`; selection controls in fluent_ui | **Covered.** Shared selection policy is package-owned rather than application state management. |
| Continuous values | `MetroSlider`, `MetroRangeSlider` | MahApps `RangeSlider`; fluent_ui Slider | **Covered.** Pointer, keyboard, RTL/vertical direction, ticks, and independent range-thumb semantics share one geometry model. |
| Date and time | `MetroDatePicker`, `MetroTimePicker` | MahApps TimePicker/DateTimePicker; fluent_ui picker organization | **Covered.** Uses the segmented scrolling-column interaction associated with Metro rather than a Material calendar/clock. |
| Progress and task feedback | `MetroProgressBar`, `MetroProgressRing` | MahApps MetroProgressBar/ProgressRing; fluent_ui indicators | **Covered.** Includes determinate, indeterminate, active, localized semantic, and reduced-motion behavior. |
| Lists and tabular data | list tiles, selectable list tiles, `MetroDataGrid` | WPF list/grid styling and fluent_ui list surfaces | **Covered for common flat collections.** The grid keeps sorting and rows application-owned. |
| Pivot and direct paging | `MetroPivot`, `MetroFlipView` | MahApps Pivot and FlipView | **Covered.** Logical keyboard direction, controlled/uncontrolled state, direct dragging, and banners are defined. |
| Commands | `MetroCommandBar`, `MetroCommandButton` | Windows 8 AppBar command treatment; command surfaces in both references | **Covered.** The outlined circular glyph remains a control-specific exception. |
| Dialogs and transient surfaces | `MetroDialog`, `MetroFlyout`, `MetroTooltip` and show helpers | MahApps Dialogs/Flyout; fluent_ui overlay organization | **Covered.** Theme capture, logical edges, dismissal, focus discovery, and reduced motion are tested. |
| Focus, keyboard, RTL, localization, and accessibility | focus traversal groups, Metro localizations, semantics and media-query behavior across controls | Cross-cutting behavior studied from mature libraries | **Covered as system behavior.** These are acceptance requirements, not optional per-widget additions. |

## Deliberate exclusions from Metro defaults

The following reference components do not belong in the core 1.0 visual
language:

- Acrylic, Mica, reveal highlights, rounded cards, elevation-heavy surfaces,
  and Windows 11 focus treatments;
- NavigationView, breadcrumb bars, teaching tips, InfoBar styling, and other
  patterns whose reference appearance is primarily later Fluent;
- WPF window chrome, title-bar buttons, dependency-property helpers, routed
  events, and application navigation/window management;
- proprietary fonts, Microsoft logos, system artwork, and reference-project
  screenshots or source code.

Applications may compose later patterns around Metro widgets, but they do not
change package defaults.

## Additive 1.x candidates

These gaps are plausible minor-version additions, not blockers for the current
1.0 candidate:

| Candidate | Rationale and admission bar |
| --- | --- |
| Hub / panoramic sections | A highly recognizable Windows Store composition. Add only after defining responsive section measurement, keyboard/focus order, semantics, and narrow-screen behavior that improve on ordinary `MetroPage` composition. |
| Semantic zoom / grouped collection navigation | A distinctive Windows 8 collection pattern. Requires a durable controller model, direct manipulation, focus restoration, large-data behavior, and accessible alternate navigation. |
| SplitButton / DropDownButton | Present in mature references and useful for desktop commands. Must define primary versus secondary keyboard activation and a viewport-aware Metro menu without duplicating ComboBox. |
| ColorPicker | Useful but domain-specific and substantially larger than a styled input. Requires keyboard-accessible channels/spectrum, high-contrast behavior, parsing/formatting, and localization. |
| TreeView | Valuable for desktop data but not a defining Metro primitive. Requires lazy expansion, controlled selection, focus navigation, semantics, and large-tree performance. |
| Calendar view | DatePicker already covers the Metro segmented picker. A full calendar is additive only if it preserves Metro styling and supplies range, blackout, keyboard, locale, and accessibility behavior. |
| Rating, hot-key input, or multi-selection ComboBox | Reference-supported specialist controls. Each should enter only with a concrete reusable contract and complete interaction evidence. |

SplitView/hamburger navigation may be reconsidered only as an explicitly dated
Windows 8.1/10-era addition. It must not replace Pivot, direct content paging,
or the current Windows 8-oriented defaults.

## Freeze consequence

The current public inventory is sufficient for a coherent 1.0 component
system. A missing reference control is not by itself evidence that the API
freeze should reopen. Before adding a candidate, apply the public API change
review in [API stability](api_stability.md), the acceptance checklist in the
[contribution guide](../CONTRIBUTING.md), and the interaction evidence standard
in [interaction audit](interaction_audit.md).
