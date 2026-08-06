# Metro UI gallery

The gallery is the visual development and integration harness for `metro_ui`.
It opens on a searchable component catalog instead of rendering every control
on one page. Browse the category tiles, search by control name or capability,
or open **All controls** for the complete scrolling integration playground.
Wide windows use a persistent navigation pane; compact windows keep the same
catalog in a horizontal, touch-friendly layout.

The focused category pages demonstrate light and dark themes, accent
switching, buttons, static and live tiles, progress indicators, form
validation, shared selection models, date and time pickers, single and range
sliders, command bars, dialogs, sortable/selectable data grids, tooltips, edge
flyouts, page transitions, keyboard focus, English/Chinese localized control
defaults, reduced motion, high-contrast theme selection, and disabled states.
Use the language button in the page header to switch the locale supplied to
`MaterialApp`. The gallery also supplies
`AnimatedMetroTheme.highContrastData`, so an operating-system or test
`MediaQuery.highContrast` preference selects the accessibility palette. The
`LOCAL THEME` button demonstrates a component theme that affects only one
subtree without rebuilding the application `MetroThemeData`.

```sh
flutter run -d windows
# or
flutter run -d chrome
```
