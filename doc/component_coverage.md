# Component coverage and scope

This document explains why the 1.0 release-candidate surface contains its
current component families. It is a design-scope audit, not a promise to clone
every control exposed by Windows, WPF, MahApps.Metro, or later Fluent UI.

## How the references are used

- **Microsoft WinJS 3.0.1** is the primary inspectable source for Windows
  Store app motion recipes, desktop intrinsic control metrics, typography,
  and state colors. Exact accepted values and limitations are recorded in the
  [reference audit](reference_audit.md).
- **MahApps.Metro** is the strongest local reference for established Metro
  terminology, state treatment, and desktop control families such as Tile,
  Pivot, FlipView, Flyout, NumericUpDown, RangeSlider, and ProgressRing. WPF
  dependency properties, attached helpers, window chrome, and routed events do
  not define the Flutter API.
- **fluent_ui** is primarily an architectural reference for organizing a large
  Flutter package, component themes, localization, tests, and a Gallery. Its
  Acrylic, Mica, NavigationView, TeachingTip, rounded surfaces, and other later
  Fluent patterns are not evidence that they belong in Metro defaults.
- **Metro 4.5.12** is a mature Metro-style Web component reference. It
  corroborates tile press direction, live-face effects, badges, and short
  control-state transitions. Its Material variants, ripple effects, rounded
  options, and generic framework tokens do not override WinJS evidence.
- **flutter_metro_ui** is an application experiment rather than a component
  library. Its tile press/tilt experiment is useful visual corroboration, but
  its application state, Material coupling, and widget APIs are not used as
  architectural references.

All implementation in `metro_ui` remains original and Flutter-native.

## 1.0 coverage matrix

| Design area | metro_ui surface | Reference correspondence | 1.0 decision |
| --- | --- | --- | --- |
| Theme, type, color, spacing, and motion | `MetroTheme`, semantic schemes, typography, spacing, and motion tokens | Shared design vocabulary across both mature references | **Covered.** These tokens define the system before individual widgets. |
| Page surface and navigation motion | `MetroPage`, `MetroPageRoute`, `MetroEntrance` | WinJS page entrance; MahApps `MetroContentControl`/navigation window; fluent_ui page and route organization; Metro 4 directional animation composition | **Covered by Flutter composition.** Routes and page-content entrances share directional Metro recipes; native window chrome remains application/platform-owned. |
| Buttons and compact actions | `MetroButton`, `MetroIconButton`, `MetroBackButton` | WinJS intrinsic button and BackButton rules; styled buttons in both mature references | **Covered.** BackButton preserves the Windows 8 circular exception, RTL arrow, pressed inversion, and hidden disabled state. The circular command glyph is isolated to BackButton and CommandBar rather than becoming general rounded geometry. |
| Tiles and live content | `MetroTile`, `MetroTileGrid`, `MetroLiveTile` | Metro 4 tile badges, press sectors, and live-face effects; MahApps `Tile`; tile experiment in flutter_metro_ui | **Covered.** Includes direct press feedback, logical corner badges, multi-direction and zoom live frames, semantics, and reduced motion. |
| Text, password, and form input | `MetroTextField`, password conveniences, `MetroTextFormField` | MahApps text/password helpers; fluent_ui TextBox and PasswordBox | **Covered.** Uses Flutter controllers and `Form` instead of attached properties. |
| Numeric, choice, and suggestion input | `MetroNumberBox`, `MetroComboBox`, `MetroSearchBox` | MahApps `NumericUpDown`; fluent_ui NumberBox, ComboBox, and AutoSuggestBox | **Covered.** Controlled values and viewport-aware overlays are explicit Flutter contracts. |
| Binary and grouped selection | CheckBox, RadioButton, ToggleSwitch, selectable list tiles, selection controllers/groups | MahApps `ToggleSwitch`; selection controls in fluent_ui | **Covered.** Shared selection policy is package-owned rather than application state management. |
| Continuous values | `MetroSlider`, `MetroRangeSlider` | WinJS desktop range input; MahApps `RangeSlider`; fluent_ui Slider architecture | **Covered.** The single-value default follows WinJS 11px track/thumb and 280x60 / 45x191 geometry. Pointer, keyboard, RTL/vertical direction, ticks, and independent range-thumb semantics share one model; the two-thumb range variant remains an additive adaptation. |
| Date and time | `MetroDatePicker`, `MetroTimePicker` | WinJS desktop DatePicker/TimePicker geometry; fluent_ui picker organization | **Covered with an adaptation.** The closed field uses separate 32px dropdown-like segments with 20px gaps, matching WinJS desktop composition. The scrolling-column dialog is a keyboard-accessible Flutter selection adaptation, not a claim that WinJS desktop used wheel dialogs. |
| Progress and task feedback | `MetroProgressBar`, `MetroProgressRing` | MahApps MetroProgressBar/ProgressRing; fluent_ui indicators | **Covered.** Includes determinate, indeterminate, active, localized semantic, and reduced-motion behavior. |
| Lists and tabular data | list tiles, selectable list tiles, `MetroDataGrid` | WinJS ListView/ItemContainer selection visuals; MahApps DataGrid full-row states; fluent_ui collection architecture | **Covered for common flat collections.** List tiles use the verified WinJS filled-selection states, logical corner mark, focus/hover outlines, and pointer scale. DataGrid shares the accent/hover/pointer vocabulary but preserves a tabular row treatment without the list-only corner mark. The 52/44px row heights and the grid's sorting/row model remain package-owned adaptations. |
| Pivot and direct paging | `MetroPivot`, `MetroFlipView` | WinJS Pivot motion; MahApps Pivot and FlipView families | **Covered.** Pivot separates the verified incoming/outgoing programmatic curves while retaining item state and direct dragging. FlipView defines logical keyboard direction, controlled/uncontrolled state, direct paging, navigation surfaces, banners, and indicators. |
| Semantic collection navigation | `MetroSemanticZoom` | WinJS SemanticZoom behavior, geometry, motion, and input model | **Covered.** Detailed and summary subtrees retain state; controlled/uncontrolled switching supports pinch, Ctrl+wheel, Ctrl+Plus/Minus, a transient desktop button, focus restoration, RTL, semantics, high contrast, and reduced motion. Applications own group-to-item mapping and large-data virtualization. |
| Commands | `MetroCommandBar`, `MetroCommandButton`, `MetroCommandBarLayer` | WinJS AppBar geometry, command treatment, secondary-click/edge invocation, click-eater dismissal, and edge-UI motion | **Covered.** The layer supplies transient top/bottom overlay behavior without forcing it on applications that intentionally need a static command surface. The Flutter edge-drag threshold is an adaptation rather than a claimed WinJS measurement. The outlined circular glyph remains a control-specific exception. |
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
| Hub / panoramic sections | A recognizable Windows 8.1 Store and Windows Phone 8 composition. Same-era desktop Hub and phone Panorama evidence may be used when the variant is dated explicitly. Add only after defining responsive section measurement, keyboard/focus order, semantics, and narrow-screen behavior that improve on ordinary `MetroPage` composition. |
| SplitButton / DropDownButton | Present in mature references and useful for desktop commands. Must define primary versus secondary keyboard activation and a viewport-aware Metro menu without duplicating ComboBox. |
| ColorPicker | Useful but domain-specific and substantially larger than a styled input. Requires keyboard-accessible channels/spectrum, high-contrast behavior, parsing/formatting, and localization. |
| TreeView | Valuable for desktop data but not a defining Metro primitive. Requires lazy expansion, controlled selection, focus navigation, semantics, and large-tree performance. |
| Calendar view | DatePicker already covers the Metro segmented picker. A full calendar is additive only if it preserves Metro styling and supplies range, blackout, keyboard, locale, and accessibility behavior. |
| Rating, hot-key input, or multi-selection ComboBox | Reference-supported specialist controls. Each should enter only with a concrete reusable contract and complete interaction evidence. |

A Windows 8.1-era split-pane composition may be reconsidered only with direct
same-era evidence. Windows 10 hamburger NavigationView behavior is outside the
visual target and must not replace Pivot, Hub/Panorama, or direct paging.

## Freeze consequence

The current public inventory is sufficient for a coherent 1.0 component
system. A missing reference control is not by itself evidence that the API
freeze should reopen. Before adding a candidate, apply the public API change
review in [API stability](api_stability.md), the acceptance checklist in the
[contribution guide](../CONTRIBUTING.md), and the interaction evidence standard
in [interaction audit](interaction_audit.md).
