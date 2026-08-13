# metro_ui

`metro_ui` is a Flutter component library inspired by Microsoft's Windows 8,
Windows 8.1, and Windows Phone 8-era Modern UI (formerly Metro) design
language.

The project focuses on the original system's durable ideas: typography-led
hierarchy, flat high-saturation color, square geometry, direct manipulation,
clear interaction states, and directional motion. Its defaults intentionally
exclude the Windows 10/11 Fluent direction, including acrylic, Mica, reveal
highlights, and rounded surfaces.

This is an independent open-source project and is not affiliated with or
endorsed by Microsoft.

> The package is in early development. Public APIs may change before `1.0.0`.

## Preview

![Light Metro controls](screenshots/metro_controls_light.png)

![Dark Metro navigation and overlays](screenshots/metro_navigation_dark.png)

## Current components

- `MetroTheme`, `MetroThemeData`, and `AnimatedMetroTheme`
- semantic light/dark color schemes and the classic Metro accent palette
- Metro typography, spacing, and motion tokens
- `MetroButton` and `MetroIconButton`
- `MetroTile` and responsive `MetroTileGrid`
- `MetroLiveTile` and keyed, semantic live-content frames
- `MetroEntrance` for directional, staggered page-content motion
- `MetroProgressRing`
- `MetroTextField`, `MetroTextFormField`, `MetroNumberBox`, `MetroComboBox`,
  `MetroSearchBox`, `MetroToggleSwitch`, and `MetroPivot`
- `MetroCheckBox`, `MetroRadioButton`, `MetroListTile`,
  `MetroSelectableListTile`, and `MetroProgressBar`
- `MetroSelectionController` and `MetroSelectionGroup`
- `MetroFocusTraversalGroup` for desktop and spatial navigation regions
- `MetroCommandBar`, `MetroCommandButton`, and transient
  `MetroCommandBarLayer`
- `MetroFlipView` with direct swipe, banners, and circular navigation
- `MetroSemanticZoom` with detailed/summary views, pinch and desktop input
- `MetroDialog`, `MetroFlyout`, `MetroTooltip`, and their show helpers
- `MetroDatePicker`, `MetroTimePicker`, and their show helpers
- `MetroSlider` and `MetroRangeSlider`
- generic `MetroDataGrid` with sorting and shared row selection
- `MetroPage`, `MetroPageRoute`, and Windows 8-inspired route transitions

All interactive components support mouse, touch, keyboard activation, focus,
disabled state, semantics, and the platform reduced-motion preference.

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:metro_ui/metro_ui.dart';

void main() {
  runApp(
    MaterialApp(
      home: MetroTheme(
        data: MetroThemeData.light(accentColor: MetroColors.cobalt),
        child: MetroPage(
          title: const Text('Start'),
          child: MetroTileGrid(
            children: [
              MetroTile(
                icon: const Icon(Icons.mail_outline),
                title: 'Mail',
                onPressed: () {},
              ),
              MetroTile(
                size: MetroTileSize.wide,
                title: 'Photos',
                backgroundColor: MetroColors.magenta,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

Run the gallery on Windows or Web:

```sh
cd example
flutter run -d windows
# or
flutter run -d chrome
```

The Web gallery is currently a locally validated development artifact. Build a
release copy with `flutter build web --release` from `example`. Deployment is
intentionally deferred until a hosting target is selected; no repository
workflow publishes the gallery automatically.

## Theming

Use the light and dark factories to switch brightness coherently. Use
`withAccent` or the `accentColor` factory argument to change the single accent
color while preserving readable on-accent content.

```dart
final theme = MetroThemeData.dark(
  accentColor: MetroColors.teal,
).copyWith(
  tileTheme: const MetroTileThemeData(extent: 152, spacing: 8),
);
```

Use the high-contrast factories for a deliberately reduced palette with
strong structural borders. `MetroTheme` and `AnimatedMetroTheme` select the
supplied high-contrast data when `MediaQuery.highContrast` is true:

```dart
AnimatedMetroTheme(
  data: MetroThemeData.dark(accentColor: MetroColors.teal),
  highContrastData: MetroThemeData.highContrastDark(),
  child: const MyPage(),
)
```

Flutter exposes the high-contrast preference but not the platform's complete
system color palette. The built-in factories therefore provide stable
black/white themes with a high-contrast highlight; applications may pass an
approved accent or construct a custom `MetroColorScheme` when platform- or
brand-specific colors are required.

Widget style values override a local component theme, which overrides the
application component theme and then Metro's defaults. Stateful colors use
Flutter's `WidgetStateProperty`.

Use a component theme to restyle one subtree without constructing a complete
`MetroThemeData`:

```dart
MetroTextFieldTheme(
  data: const MetroTextFieldThemeData(
    style: MetroTextFieldStyle(
      borderColor: WidgetStatePropertyAll(MetroColors.teal),
    ),
  ),
  child: const MetroTextField(placeholder: 'Locally themed'),
)
```

Equivalent subtree themes are available for buttons, tiles, progress bars and
rings, list tiles, check boxes, radio buttons, toggle switches, Pivot, number
boxes, combo boxes, search boxes, command bars, dialogs, flyouts, tooltips,
pickers, sliders, data grids, and FlipView. Their precedence is always widget
values, then the nearest component theme, then `MetroThemeData`, then the Metro
default.

## Forms and validation

`MetroTextFormField` participates in Flutter's `Form` lifecycle. Validation
errors and optional success feedback use semantic theme colors and expose a
validation result to assistive technologies.

```dart
MetroTextFormField.password(
  label: const Text('Password'),
  supportingText: const Text('Eight characters minimum'),
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: (value) => (value?.length ?? 0) < 8
      ? 'Password is too short'
      : null,
)
```

## Combo boxes

`MetroComboBox<T>` is a controlled single-selection field with a square,
viewport-aware popup. The popup opens above or below according to available
space, constrains long lists to a scrollable maximum height, and aligns its
logical start edge in LTR and RTL layouts.

```dart
MetroComboBox<String>(
  value: destination,
  placeholder: const Text('Choose a destination'),
  items: const [
    MetroComboBoxItem(value: 'london', child: Text('London')),
    MetroComboBoxItem(value: 'seattle', child: Text('Seattle')),
    MetroComboBoxItem(
      value: 'closed',
      enabled: false,
      child: Text('Unavailable'),
    ),
  ],
  onChanged: (value) => setState(() => destination = value),
)
```

Enter and Space open or commit the highlighted item. Up/Down, Home, and End
navigate enabled items; Alt+Up/Down and F4 toggle the popup; Escape dismisses
without changing the controlled value. Disabled items remain visible and
semantic but are skipped by keyboard navigation. Popup rows grow with the
ambient text scaler while the complete list remains height constrained.
`MetroComboBoxTheme` can override field, popup, and item tokens for a subtree,
while `selectedItemBuilder` can give the closed field a presentation different
from the popup row.

## Search boxes

`MetroSearchBox<T>` combines a square search field and submit button with an
optional, viewport-aware suggestion popup. Suggestions are matched by
`queryText` by default; provide `filter` for another policy, or replace `items`
from `onChanged` when results come from an asynchronous source.

```dart
MetroSearchBox<String>(
  placeholder: 'Search controls',
  items: const [
    MetroSearchBoxItem(
      value: 'tiles',
      queryText: 'Tiles and live tiles',
      child: Text('Tiles and live tiles'),
    ),
    MetroSearchBoxItem(
      value: 'flip-view',
      queryText: 'FlipView',
      child: Text('FlipView'),
    ),
  ],
  onSelected: (item) => openControl(item.value),
  onSubmitted: runSearch,
)
```

Up/Down, Home, and End highlight enabled suggestions; Enter chooses the
highlighted row or submits the current query, and Escape dismisses the popup.
Query changes distinguish user input, suggestion selection, and clearing.
The popup flips above near the viewport edge, follows logical LTR/RTL start
alignment, and scales row height with text. `MetroSearchBoxTheme` controls the
field, action buttons, popup, rows, and no-results presentation.

## Number boxes

`MetroNumberBox<T extends num>` is a controlled numeric text field with the
square inline step controls used by desktop Metro applications. Typed text is
parsed when submitted or when focus leaves the field. Arrow Up/Down use
`smallChange`, Page Up/Page Down use `largeChange`, Home and End select the
configured bounds, and a focused field responds to the mouse wheel.

```dart
MetroNumberBox<int>(
  value: copies,
  min: 1,
  max: 99,
  smallChange: 1,
  largeChange: 10,
  semanticLabel: 'Copies',
  onChanged: (value) => setState(() => copies = value!),
)
```

The application remains authoritative: if it does not rebuild with a requested
value, the field restores the supplied value. Optional step snapping, nullable
values, custom parsers and formatters, and restore-or-retain invalid-input
policies cover integer, decimal, and domain-specific input. Holding either
step button repeats after a configurable delay. `MetroNumberBoxTheme` controls
the embedded text field and both step buttons for a subtree.

## Pivots

`MetroPivot` uses the oversized, low-opacity header rail associated with
Windows 8 and keeps item subtrees mounted while navigating. Header and keyboard
changes give the outgoing and incoming pages their separate WinJS 350ms slide
curves; horizontal dragging remains directly attached to the pointer and then
settles to the nearest accepted page. Direction and gestures mirror in RTL,
and reduced-motion settings commit immediately.

## Flip views

`MetroFlipView` presents one content story at a time using the direct,
edge-to-edge paging associated with Windows 8. It supports horizontal or
vertical dragging, pointer navigation buttons, logical RTL keyboard commands,
optional circular paging, banners, and page indicators.

```dart
MetroFlipView(
  index: featureIndex,
  circular: true,
  showIndicators: true,
  items: const [
    MetroFlipViewItem(
      semanticLabel: 'Photos story',
      banner: Text('RECENT PHOTOS'),
      child: PhotosStory(),
    ),
    MetroFlipViewItem(
      semanticLabel: 'News story',
      banner: Text('LATEST NEWS'),
      child: NewsStory(),
    ),
  ],
  onChanged: (index) => setState(() => featureIndex = index),
)
```

Leave `index` null to let the widget retain its own selection from
`initialIndex`. Supplying `index` makes selection application-owned; a request
that the application does not accept animates back to the supplied index.
Reduced-motion settings commit changes without a page transition.
`MetroFlipViewTheme` overrides navigation, banner, indicator, border, and
surface tokens for a subtree.

## Semantic zoom

`MetroSemanticZoom` switches between detailed and summarized presentations of
the same grouped collection. Both view subtrees remain mounted, so local state
and the last focus target survive a switch. The default WinJS transition uses
a 0.65 cross-scale over 333ms and aligns the transform to the pinch or wheel
focal point.

```dart
MetroSemanticZoom(
  zoomedOut: overviewVisible,
  onZoomedOutChanged: (value) {
    setState(() => overviewVisible = value);
  },
  zoomedInView: const GroupedPhotoCollection(),
  zoomedOutView: PhotoGroupOverview(
    onSelected: (group) {
      selectPhotoGroup(group);
      setState(() => overviewVisible = false);
    },
  ),
)
```

Two-pointer pinch, Ctrl+mouse wheel, Ctrl+Plus/Minus, adjustable semantics,
and the transient 25px desktop minus button share the same state contract.
`locked` disables all switching, while reduced-motion settings commit the new
view immediately. Mapping a selected summary group to the corresponding
detailed item remains application-owned.

## Date and time pickers

The closed picker fields use separate dropdown-like segments following WinJS
desktop geometry instead of a Material calendar or clock surface. Opening the
field presents a keyboard-accessible scrolling-column dialog as a Flutter
selection adaptation. Changes remain local until the user confirms them with
`DONE`; cancelling leaves the controlled value unchanged.

```dart
MetroDatePicker(
  selected: eventDate,
  firstDate: DateTime(2024),
  lastDate: DateTime(2030, 12, 31),
  onChanged: (value) => setState(() => eventDate = value),
)

MetroTimePicker(
  selected: eventTime,
  minuteIncrement: 15,
  onChanged: (value) => setState(() => eventTime = value),
)
```

Date fields follow common locale ordering by default, including month/day/year
for US English and year/month/day for Chinese, Japanese, and Korean locales.
Field order, visible parts, labels, and value formatters remain configurable.
The package deliberately avoids an `intl` dependency: applications can use
their own localization system through the formatter and label callbacks.

`MetroTime` is the package's immutable hour/minute value type. Pickers support
12- and 24-hour display, minute increments, keyboard wheel navigation, and
range-safe date changes such as clamping January 31 to the final day of
February.

## Localization and RTL

Register the package delegate to use the built-in English and Simplified
Chinese defaults for pickers, progress semantics, and data-grid sort state:

```dart
MaterialApp(
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    MetroLocalizations.delegate,
  ],
  supportedLocales: MetroLocalizations.supportedLocales,
  home: const MyApp(),
)
```

The `Global*Localizations` delegates above come from Flutter's
`flutter_localizations` SDK package and localize the surrounding Material,
Widgets, and Cupertino infrastructure. `MetroLocalizations.delegate` owns the
Metro-specific strings.

Controls fall back to English when the delegate is absent. Explicit widget
labels always take precedence over localized defaults. Applications can
subclass `MetroLocalizations` and register their own
`LocalizationsDelegate<MetroLocalizations>` before the built-in delegate;
Flutter uses the first delegate for each localization type.

Directional controls consume Flutter's ambient `Directionality`. Start/end
flyouts, progress fill, navigation motion, sliders, toggle switches, and data
grid columns therefore mirror automatically in an RTL locale. Application
content and custom builders should likewise prefer directional APIs such as
`AlignmentDirectional`, `EdgeInsetsDirectional`, and `BorderDirectional`.

## Sliders

`MetroSlider` uses the narrow rectangular thumb, thin neutral track, and
thicker accent-value track associated with Windows 8. It supports horizontal
and vertical layouts, logical RTL direction, reversed direction, optional
ticks, snapping divisions, pointer dragging, and small/large keyboard steps.

```dart
MetroSlider(
  value: volume,
  min: 0,
  max: 100,
  divisions: 20,
  tickPlacement: MetroSliderTickPlacement.after,
  onChanged: (value) => setState(() => volume = value),
)
```

`MetroRangeSlider` uses the immutable `MetroRangeValues` model. Each thumb is
an independent adjustable semantic and keyboard focus target. Drag either
thumb to change one endpoint, or drag the selected segment to preserve its
width while moving the complete range. `minimumRange` prevents the endpoints
from crossing or becoming too close.

```dart
MetroRangeSlider(
  values: comfortRange,
  min: 10,
  max: 35,
  divisions: 25,
  minimumRange: 2,
  onChanged: (values) => setState(() => comfortRange = values),
)
```

## Data grids

`MetroDataGrid<T>` presents fixed or flexible columns with the flat headers,
accent selection, square focus outlines, and compact rows used by desktop
Modern UI applications. Sorting remains controlled: the grid reports a
`MetroDataGridSort`, while the application owns the ordered row list.

```dart
MetroDataGrid<Album>(
  height: 320,
  columns: [
    MetroDataGridColumn(
      key: 'title',
      label: const Text('TITLE'),
      sortable: true,
      cellBuilder: (context, album, index) => Text(album.title),
    ),
    MetroDataGridColumn(
      key: 'year',
      label: const Text('YEAR'),
      width: 80,
      cellBuilder: (context, album, index) => Text('${album.year}'),
    ),
  ],
  rows: albums,
  sort: albumSort,
  onSortChanged: updateAlbumSort,
  selectionController: albumSelection,
)
```

Rows accept a direct `MetroSelectionController<T>` or consume the nearest
matching `MetroSelectionGroup<T>`. Arrow keys move between enabled rows,
Page Up/Page Down move by larger steps, Home/End reach the boundaries, Space
changes selection, and Enter activates a row. A non-null `height` enables a
lazy vertical viewport; without it, the grid lays out all rows for embedding
small tables in a page. Wide fixed columns scroll horizontally. Selected rows
use an accent fill with a lighter hover state, and actionable rows use the
167ms WinJS pointer-down scale while preserving the grid's dividers and full
focus border.

## Progress indicators

Pass a value from `0.0` to `1.0` for determinate progress, or leave `value`
null for an indeterminate indicator. `MetroProgressBar` uses the five moving
dots associated with Windows 8, while `MetroProgressRing` switches between
five and six orbiting dots according to its configured size.

Both controls honor reduced-motion and `TickerMode`. Set `active` to false to
hide and stop an indeterminate indicator without changing layout; determinate
progress remains visible. Use `semanticValue` for localized or task-specific
assistive text.

```dart
const MetroProgressBar(
  semanticLabel: 'Install progress',
  semanticValue: 'Preparing files',
)
```

Determinate bars fill from the logical start edge, so they adapt to LTR and RTL
layouts automatically.

## Live tiles

`MetroLiveTile` reuses the complete `MetroTile` interaction surface while
cycling notification-like content frames. Each `MetroLiveTileFrame` can carry
a stable id, an accessible label, and its own display duration. Stable ids keep
the visible frame selected when an application refreshes or reorders data.
Tiles and live tiles can also place a compact notification badge at the logical
top-end or bottom-end corner without changing the frame's semantics.

```dart
MetroLiveTile(
  size: MetroTileSize.wide,
  title: 'Weather',
  onPressed: openWeather,
  frames: const [
    MetroLiveTileFrame(
      id: 'current',
      semanticLabel: 'Sunny, 24 degrees',
      child: Center(child: Text('24°')),
    ),
    MetroLiveTileFrame(
      id: 'forecast',
      semanticLabel: 'Rain expected tomorrow',
      child: Center(child: Text('RAIN TOMORROW')),
    ),
  ],
)
```

The default transition moves the complete face upward without adding carousel
chrome. `slideDown`, `slideLeft`, `slideRight`, `fade`, `zoom`, and `none`
recipes are also available. Automatic updates pause when `active` is false,
the subtree's `TickerMode` is disabled, or the platform requests reduced
motion.

## Content entrances

`MetroEntrance` applies the Windows 8 page recipe to content inside a route:
100 logical pixels of directional travel over the navigation duration, with
the faster navigation fade. Give related siblings increasing `index` values
to stagger them while keeping layout and focus order unchanged.

```dart
Column(
  children: [
    for (var index = 0; index < sections.length; index++)
      MetroEntrance(index: index, child: sections[index]),
  ],
)
```

Direction is logical for `forward` and `backward`, so RTL layouts mirror the
motion. Reduced-motion preferences skip both movement and delay.

## Bottom commands

`MetroCommandBarLayer` reproduces the transient Windows 8 AppBar pattern: the
bar overlays page content, opens from a secondary click or inward edge swipe,
dismisses on an outside primary click, Escape, or outward drag, and slides
through its complete height using the 367ms WinJS edge-UI recipe. Its command
buttons preserve the circular glyph treatment while the rest of the component
system remains square.

```dart
MetroCommandBarLayer(
  child: const MetroPage(child: Text('Page content')),
  commandBar: MetroCommandBar(
    commands: [
      MetroCommandButton(
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save'),
        onPressed: save,
      ),
    ],
  ),
)
```

Pass `open` and `onOpenChanged` for application-controlled visibility, or use
`initiallyOpen` for an internally managed layer. `MetroPage.bottomBar` remains
available when an application deliberately needs a permanently visible,
layout-reserving command surface.

## Selection models

Use `MetroSelectionController` when several controls share single- or
multi-selection state. `MetroRadioButton` and `MetroSelectableListTile` can
consume the nearest matching `MetroSelectionGroup`, or receive a controller
directly. Controllers support required selection, maximum counts, replacement,
and batch selection while exposing immutable selected-value snapshots.

Selectable list rows use the Windows Store filled-selection treatment: a
square accent well, white content, a logical top-end checkmark, complete
hover/focus outlines, and the WinJS 0.975 pointer-down scale. The row's 52px
minimum height is a package layout default and can be changed through
`MetroListTileStyle`.

```dart
final selection = MetroSelectionController<String>(
  mode: MetroSelectionMode.multiple,
  maxSelectionCount: 2,
);

MetroSelectionGroup<String>(
  controller: selection,
  child: const Column(
    children: [
      MetroSelectableListTile(value: 'mail', title: Text('Mail')),
      MetroSelectableListTile(value: 'photos', title: Text('Photos')),
    ],
  ),
)
```

Dispose controllers owned by application state. A `MetroSelectionGroup`
without an explicit controller owns and disposes its internal controller.

## Page transitions

`MetroPageRoute` captures active Metro themes across the Navigator boundary,
follows logical LTR/RTL direction, and disables motion when accessibility
settings request reduced animation.

```dart
Navigator.of(context).push(
  MetroPageRoute<void>(
    context: context,
    transition: MetroPageTransition.slideForward,
    builder: (_) => const MetroPage(
      title: Text('Details'),
      child: Text('Page content'),
    ),
  ),
);
```

## Focus traversal

`MetroFocusTraversalGroup` adds an explicit focus scope around a control
region. The default desktop configuration follows reading order, lets Tab move
into the parent scope at the edge, and stops directional movement locally.

Use the spatial constructor for tile grids, media surfaces, and TV/gamepad
layouts. It uses Flutter's geometric directional policy and loops both Tab and
arrow-key traversal within the region without replacing Enter/Space activation
on individual controls.

```dart
MetroFocusTraversalGroup.spatial(
  child: MetroTileGrid(children: tiles),
)
```

A custom Flutter `FocusTraversalPolicy` and both edge behaviors can be supplied
when an application needs a different ordering model.

## Overlays

`showMetroDialog` and `showMetroFlyout` capture the active Metro component
themes across the Navigator boundary and use directional,
reduced-motion-aware transitions. Dialogs enter with the 367ms WinJS popup
movement and close with its separate 83ms in-place fade; edge flyouts slide in
and out for 550ms. `MetroTooltip` appears on hover, descendant focus, or long
press and keeps its message available to assistive technologies while hidden.

```dart
MetroTooltip(
  message: 'Delete item',
  child: MetroIconButton(
    icon: const Icon(Icons.delete_outline),
    semanticLabel: 'Delete item',
    onPressed: delete,
  ),
)
```

## Fonts

Windows uses the installed system `Segoe UI`. The package does not redistribute
Segoe UI because the font is proprietary. Web and non-Windows platforms use a
bundled copy of Microsoft's Selawik, an OFL-licensed open-source replacement
for Segoe UI, so the same light, regular, and semibold faces remain available
without a font CDN. Selawik currently covers primarily Latin text; the default
font fallback list lets the platform supply broader scripts such as CJK.

Applications can supply their own licensed typeface, including a font with
broader CJK coverage, through `MetroTypography.fromColorScheme`:

```dart
final typography = MetroTypography.fromColorScheme(
  colors,
  fontFamily: 'My App Sans',
  fontPackage: 'my_app_fonts',
);
```

## Project direction

See the [contribution guide](https://github.com/GT-610/metro_ui/blob/main/CONTRIBUTING.md),
[design principles](https://github.com/GT-610/metro_ui/blob/main/doc/design_principles.md),
[Windows 8 reference audit](https://github.com/GT-610/metro_ui/blob/main/doc/reference_audit.md),
[Metro 4 reference audit](https://github.com/GT-610/metro_ui/blob/main/doc/metro4_reference_audit.md),
[component coverage](https://github.com/GT-610/metro_ui/blob/main/doc/component_coverage.md),
[architecture](https://github.com/GT-610/metro_ui/blob/main/doc/architecture.md),
[roadmap](https://github.com/GT-610/metro_ui/blob/main/doc/roadmap.md),
[public API stability policy](https://github.com/GT-610/metro_ui/blob/main/doc/api_stability.md),
and [1.0 release checklist](https://github.com/GT-610/metro_ui/blob/main/doc/release_checklist.md).

The repository references `fluent_ui`, `MahApps.Metro`, and an experimental
Flutter Metro application during development. They are used to study package
structure and design behavior; `metro_ui` has its own Flutter-native API and
implementation.

## License

MIT. See the [license](https://github.com/GT-610/metro_ui/blob/main/LICENSE).
