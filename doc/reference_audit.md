# Windows 8 reference audit

This file separates implementation evidence from leads collected in
`.vscode/polish-res.md`. The latter is useful as a search index, but a URL,
project name, or remembered measurement in that file is not a design token
until it has been checked against a primary source or corroborated reference.

## Evidence order

1. Microsoft-authored Windows 8/8.1 implementation or archived guidance.
2. A same-era implementation whose behavior can be inspected directly.
3. MahApps.Metro as visual and desktop-control corroboration.
4. `fluent_ui` as Flutter package architecture evidence only.
5. `flutter_metro_ui`, screenshots, and later Metro-inspired projects as
   visual leads only.

Later Fluent features such as Acrylic, Mica, reveal effects, rounded cards,
NavigationView, and Windows 11 focus treatments do not override Windows 8
evidence.

## Primary implementation snapshot

The measurements below were checked against Microsoft WinJS 3.0.1,
`release/3.0.1`, commit
[`bf76e0911e8955725536ba87504827609ca77b45`](https://github.com/winjs/winjs/commit/bf76e0911e8955725536ba87504827609ca77b45).
Its `package.json` identifies the source as Windows Library for JavaScript
3.0.1. WinJS includes desktop and phone rules; this audit uses desktop rules
unless a row says otherwise.

WinJS is strong evidence for Windows Store app controls and animation recipes.
It is not evidence that every WinJS 3 feature appeared unchanged in the first
Windows 8 release, nor that its DOM structure should be reproduced in Flutter.

## Verified motion recipes

| Recipe | WinJS evidence | Metro UI mapping |
| --- | --- | --- |
| Standard easing | `Animations.js` repeatedly uses `cubic-bezier(0.1, 0.9, 0.2, 1)` | `MetroMotion.standardCurve` and `navigationCurve` |
| Pointer down/up | `pointerDown` and `pointerUp`: 167ms; down scales to 0.975 | `MetroMotion.normal`; tile press scale 0.975 |
| Show/hide edge UI | `showEdgeUI` and `hideEdgeUI`: translate the complete visible edge distance over 367ms with the standard curve | `MetroCommandBarLayer` top/bottom entrance and exit; the bar overlays content rather than reserving page layout |
| Show popup | `showPopup`: translate from 50px over 367ms; opacity waits 83ms and fades for 83ms | dialogs, ComboBox, and SearchBox popup entrances |
| Hide popup | `hidePopup`: opacity fades from 1 to 0 over 83ms linear with no exit translation | dialog reverse route uses `popupFade` |
| Show/hide panel | `showPanel` and `hidePanel`: 364px logical-edge offset over 550ms | flyout panel duration; actual distance follows the Flutter panel width, and the reverse curve is time-mirrored so entrance and exit both appear ease-out |
| Enter page | `enterPage`: 100px logical offset over 1000ms; opacity reaches 1 in 170ms | `MetroPageRoute` forward transition |
| Exit page | `exitPage`: 117ms linear fade; transform is optional and defaults to zero offset | `MetroPageRoute` reverse transition |
| Pivot content in | Pivot calls `slideLeftIn`/`slideRightIn`; the page travels one viewport over 350ms with `cubic-bezier(0.17,0.79,0.215,1.0025)` | `MetroMotion.content` and `contentCurve` |
| Pivot content out | Pivot calls `slideLeftOut`/`slideRightOut`; 350ms with `cubic-bezier(0.3825,0.0025,0.8775,-0.1075)` and keeps opacity until the end step | `MetroMotion.contentExitCurve`; programmatic Pivot changes complete the outgoing slide/fade before starting an equal-duration incoming slide/fade with the time-mirrored curve, while direct drag remains under pointer control |
| FlipView programmatic page change | outgoing page fades in place for 167ms linear; incoming page starts 40px along the logical navigation direction, moves for 550ms, and fades in for 170ms with the standard curve | separate programmatic content transition using `contentEntrance` and `contentFade`; direct drag remains full-page manipulation |
| FlipView navigation visibility | navigation button opacity changes over 167ms linear | `MetroMotion.normal` button fade |
| Tooltip visibility | ordinary tooltip hover delay is 800ms; the tooltip remains for 5s after its 250ms linear fade-in and closes with a 167ms linear fade-out | tooltip defaults and `MetroMotion.fadeIn` / `normal` |
| Semantic Zoom switch | detailed and summary views scale and cross-fade for 333ms with `ease-in-out`; the default scale factor is 0.65 | `MetroMotion.semanticZoom`; `MetroSemanticZoom` cross-scale transition and focal-point alignment |

Primary paths:

- [`src/js/WinJS/Animations.js`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/js/WinJS/Animations.js)
- [`src/js/WinJS/Controls/AppBar.js`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/js/WinJS/Controls/AppBar.js)
- [`src/less/animation-library.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/animation-library.less)
- [`src/js/WinJS/Controls/Pivot.js`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/js/WinJS/Controls/Pivot.js)
- [`src/js/WinJS/Controls/SemanticZoom.js`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/js/WinJS/Controls/SemanticZoom.js)

The package tokens name reusable recipes, not vague speed tiers. `fast` is
100ms because ToggleSwitch uses 0.1s; `normal` is 167ms because pointer and
several opacity transitions use it. The 367ms, 550ms, and 1000ms recipes are
intentional, so the claim that Metro motion is generally confined to
100-300ms is not accepted.

WinJS verifies that AppBar position changes use edge-UI motion and that the
control supports transient shown/hidden positions. `MetroCommandBarLayer` also
offers a narrow touch-edge drag target so the pattern remains usable in
Flutter. Its 20px target and 24px threshold are package interaction choices,
not Microsoft measurements.

## Verified control geometry and type

| Area | WinJS desktop evidence | Metro UI mapping |
| --- | --- | --- |
| Button | minimum 90x32px, 2px border, 4px vertical and 8px horizontal padding | `MetroButton` defaults |
| Button pressed state | light/dark color rules invert foreground, background, and border on active | standard and accent pressed styles |
| CheckBox / RadioButton | 21px checkbox, 23px radio, 2px border; translucent white well with black glyph; light active state inverts to black/white | neutral default wells, immediate state changes, and distinct desktop sizes |
| Progress | determinate bar 6px high; indeterminate bar 4px high with transparent background; ring sizes 20, 40, and 60px | 6/4px bar defaults and 20px default ring; medium/large sizes remain theme overrides |
| Pivot headers | 45pt (60px), 72px header track, inactive opacity 0.2 light / 0.4 dark, 28px item top and 19px content padding | 60px headers, verified opacity, 28px content spacing, and 19px logical padding; MahApps independently corroborates low-opacity inactive headers |
| ToggleSwitch | 50x19px track, 12px full-height thumb, 2px border, 0.1s movement | `MetroToggleSwitch` defaults |
| Back button | 41x41px circle, 2px border, 14pt symbol; disabled uses `visibility: hidden`; RTL swaps the arrow | `MetroBackButton` geometry, disabled space preservation, and mirroring |
| FlipView navigation buttons | 69x39px, flush to the relevant edge, no normal-mode border; neutral translucent gray normal/hover fills and a dark pressed fill; high contrast uses a 2px border while preserving the 69x39 outer size | fixed WinJS geometry, immediate neutral interaction states, and high-contrast-only border |
| Tooltip | maximum width 380px, 2px gray border, white background, 60% black 9pt text, and 10/6/10/7px left/top/right/bottom padding; default placement is above; pointer, keyboard, and touch offsets are 20, 12, and 45px | desktop visuals, trigger-specific offsets, top-first placement with WinJS fallback ordering |
| Desktop DatePicker / TimePicker | composed from native `select` elements: 32px minimum height, 2px border, 80px minimum width, and 20px between fields | current Flutter field should visually converge on separate dropdown segments; the wheel dialog is retained only as a Flutter interaction adaptation, not a verified WinJS desktop pattern |
| Slider | horizontal input is 280px wide and 60px tall including 17px top / 32px bottom padding; vertical input is 45x191px; track and square thumb are both 11px; normal upper track is 10% black light / 16% white dark, with documented hover and disabled alpha changes | 11px track and thumb, 280/191px axis lengths, 60/45px cross extents, top-biased horizontal track, neutral thumb, and verified state colors |
| Filled list selection | item background is white light / `rgb(29,29,29)` dark; hover uses a full 3px outline at 30% foreground and a 30% foreground fill; focus is a full 2px outline; selected content uses the accent fill, white text, and an 11pt `U+E081` checkmark at logical top-end; pointer feedback scales to 0.975 over 167ms | `MetroListTile` uses the verified item wells, outlines, filled selection, mirrored corner mark, and pointer recipe. Its 52px minimum row height remains a package composition choice rather than a WinJS generic ListView token |
| Semantic Zoom | `zoomFactor` defaults to 0.65 and accepts 0.2–0.8; desktop minus button is 25x25px at logical end 4px and bottom 21px, appears for 3s, and switches alongside Ctrl+Plus/Minus, Ctrl+wheel, and pinch thresholds | `MetroSemanticZoom` preserves the geometry and input routes, adds Flutter focus scopes and adjustable semantics, and treats group-to-item mapping as application state |
| Page hero | desktop `win-type-xx-large` is 42pt, weight 200, line height 1.1429 | 56 logical pixels and a light Flutter weight |
| Desktop body and button | desktop large/medium/small roles are 11pt; button uses the large semibold role | 14.667 logical pixels; semibold button text |
| Desktop subheader | desktop `win-type-x-large` is 20pt, weight 200 | 26.667 logical pixels and a light Flutter weight |
| Desktop caption | desktop `win-type-xx-small` is 9pt, line height 1.6667 | 12 logical pixels |

CSS points are converted at 96dpi: one point is 4/3 logical pixels. Windows uses
the installed Segoe UI family. Other platforms use Microsoft's OFL-licensed
Selawik Light, Regular, and Semibold faces, which Microsoft describes as an
open-source replacement for Segoe UI. Its own README documents two remaining
differences: Segoe-matching kerning is incomplete and hinting can improve.

Primary paths:

- [`src/less/font-definitions.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/font-definitions.less)
- [`src/less/desktop/styles-intrinsic.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/desktop/styles-intrinsic.less)
- [`src/less/desktop/colors-intrinsic.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/desktop/colors-intrinsic.less)
- [`src/less/styles-toggleswitch.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/styles-toggleswitch.less)
- [`src/less/styles-backbutton.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/styles-backbutton.less)
- [`src/less/colors-backbutton.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/colors-backbutton.less)
- [`src/less/styles-flipview.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/styles-flipview.less)
- [`src/less/colors-flipview.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/colors-flipview.less)
- [`src/js/WinJS/Controls/FlipView.js`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/js/WinJS/Controls/FlipView.js)
- [`src/less/desktop/styles-tooltip.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/desktop/styles-tooltip.less)
- [`src/less/desktop/colors-tooltip.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/desktop/colors-tooltip.less)
- [`src/js/WinJS/Controls/Tooltip.js`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/js/WinJS/Controls/Tooltip.js)
- [`src/less/desktop/styles-datetimepicker.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/desktop/styles-datetimepicker.less)
- [`src/less/desktop/styles-intrinsic.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/desktop/styles-intrinsic.less)
- [`src/less/styles-listview.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/styles-listview.less)
- [`src/less/desktop/colors-listview.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/desktop/colors-listview.less)
- [`src/js/WinJS/Controls/ItemContainer/_Constants.js`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/js/WinJS/Controls/ItemContainer/_Constants.js)
- [`src/js/WinJS/Controls/ItemContainer/_ItemEventsHandler.js`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/js/WinJS/Controls/ItemContainer/_ItemEventsHandler.js)
- [`src/less/styles-semanticzoom.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/styles-semanticzoom.less)
- [`src/less/colors-semanticzoom.less`](https://github.com/winjs/winjs/blob/bf76e0911e8955725536ba87504827609ca77b45/src/less/colors-semanticzoom.less)

The package's 40px header, 20px title, and 16px tile-title roles are
intermediate Flutter hierarchy choices. They are not presented as direct
WinJS desktop measurements.

## Corroborated package adaptations

WinJS does not provide a desktop DataGrid control, so table geometry and row
structure cannot be attributed to it. MahApps.Metro commit
[`72099e310bac2d12ac98fd7560b69679252519f5`](https://github.com/MahApps/MahApps.Metro/commit/72099e310bac2d12ac98fd7560b69679252519f5)
corroborates full-row accent selection, a lighter accent mouse-over state,
selection-specific foregrounds, and a distinct keyboard-focus border in its
DataGrid row/cell templates. `MetroDataGrid` combines that tabular treatment
with the verified WinJS 167ms pointer scale used by directly actionable items.
The grid deliberately does not add the WinJS ItemContainer corner checkmark,
because that glyph belongs to list selection rather than the corroborating
DataGrid pattern. Its 44px header/row heights and alternating wells remain
package defaults.

Corroborating paths:

- [`Styles/Controls.DataGrid.xaml`](https://github.com/MahApps/MahApps.Metro/blob/72099e310bac2d12ac98fd7560b69679252519f5/src/MahApps.Metro/Styles/Controls.DataGrid.xaml)
- [`Styles/Themes/Theme.Template.xaml`](https://github.com/MahApps/MahApps.Metro/blob/72099e310bac2d12ac98fd7560b69679252519f5/src/MahApps.Metro/Styles/Themes/Theme.Template.xaml)

## Leads that remain non-authoritative

- Search phrases and historical Microsoft Learn entry points in
  `.vscode/polish-res.md` are discovery aids until a surviving archived page
  has been inspected.
- Third-party project existence does not prove that its measurements are
  Microsoft values. MUI, Callisto, Metro UI CSS, BootMetro, MetroFramework,
  and Elysium may corroborate a pattern but do not define defaults here.
- Windows Phone 8 Pivot/Panorama and Windows 8.1 Hub rules are valid same-era
  design evidence when a component explicitly targets that form. They are not
  silently substituted for desktop Windows Store metrics, and the documented
  desktop/phone variant must remain clear.
- Screenshots can validate silhouette, density, and hierarchy, but cannot by
  themselves establish exact duration, easing, padding, or semantic behavior.
- MahApps.Metro supplies useful WPF visual comparisons, while its current
  Fluent-era additions, WPF dependency properties, and window chrome remain
  outside the Flutter contract.

When a future polish change introduces a precise number or state rule, add the
source and interpretation here before making it a package default.
