# Interaction and semantics audit

This audit maps every current interactive component family to focused widget
tests. Shared controls rely on `MetroInteractive` for pointer, Enter/Space,
focus, hover, pressed, disabled, cursor, and base button semantics; specialized
controls add tests for their own interaction model.

Verified locally on 2026-08-06.

| Component family | Focused evidence |
| --- | --- |
| Buttons and icon buttons | Pointer and keyboard activation, disabled semantics, accessible icon names, and theme precedence in `test/controls/metro_button_test.dart`. |
| Tiles and live tiles | Geometry, press tilt, reduced motion, disabled naming, keyboard activation, frame semantics, timer cancellation behavior, and stable frame identity in `test/controls/metro_tile_test.dart` and `test/controls/metro_live_tile_test.dart`. |
| Text and form fields | Controlled controllers, disabled semantics, validation states, password defaults, form reset, and local themes in `test/inputs/metro_text_field_test.dart`. |
| NumberBox | Controlled requests, commit and focus-loss parsing, nullable and invalid drafts, integer/decimal rules, clamping and snapping, keyboard, wheel, repeated pointer stepping, disabled/adjustable semantics, localization, reduced motion, and theme precedence in `test/inputs/metro_number_box_test.dart`. |
| ComboBox and SearchBox | Pointer selection, disabled-row skipping, keyboard navigation, controlled dismissal, viewport flipping, RTL alignment, semantics, large text, reduced motion, asynchronous results, localization, and theme precedence in `test/inputs/metro_combo_box_test.dart` and `test/inputs/metro_search_box_test.dart`. |
| Selection controls and lists | Pointer and keyboard changes, mixed/checked/toggled/selected semantics, shared single/multiple selection, policy limits, and component themes in `test/selection` and `test/controls/metro_list_tile_test.dart`. |
| Pivot, command bar, FlipView, and Semantic Zoom | Header selection semantics, keyboard navigation, command toggle semantics, controlled/uncontrolled AppBar visibility, secondary-click and edge-swipe invocation, outside/Escape/outward-drag dismissal, edge mirroring, paging, dragging, circular keyed children, RTL, banners, semantic cross-view switching, focal-point pinch and Ctrl+wheel input, transient zoom-button geometry, state/focus preservation, adjustable semantics, reduced motion, and theme precedence in `test/navigation`. |
| Focus groups and page routes | Sequential/spatial traversal, preserved activation, theme capture, logical-direction transitions, and reduced motion in `test/foundation/metro_focus_traversal_test.dart` and `test/navigation/metro_page_route_test.dart`. |
| Dialogs, flyouts, and tooltips | Theme capture, semantic labels, return values, Escape/barrier behavior, logical edges, hover/focus/long-press discovery, viewport flipping, and hidden-message semantics in `test/overlays`. |
| Date and time pickers | Locale ordering, formatting, controlled confirmation/cancellation, range clamping, keyboard wheel adjustment, disabled semantics, reduced motion, and captured local themes in `test/pickers` and `test/localization/metro_localizations_test.dart`. |
| Sliders and range sliders | Pointer geometry, snapping, logical RTL and vertical direction, small/large/boundary keys, independent range thumbs, minimum range, segment dragging, disabled and adjustable semantics, and theme precedence in `test/inputs/metro_slider_test.dart`. |
| Data grid | Controlled sorting and sort semantics, pointer/keyboard row selection, disabled-row skipping, lazy Home/End navigation, horizontal scrolling, row semantics, and theme precedence in `test/data/metro_data_grid_test.dart`. |
| Progress indicators | Determinate and indeterminate semantics, localized values, active state, logical direction, reduced motion, sizing, and local themes in `test/controls/metro_progress_bar_test.dart` and `test/controls/metro_progress_ring_test.dart`. |

Light and dark visual baselines cover controls and navigation, with dedicated
FlipView, SearchBox, and NumberBox images. Accessibility baselines additionally
exercise 2x raster density, 1.5x text scaling, and high contrast.

The remaining release evidence is environmental rather than an unimplemented
interaction contract: the latest Gallery integration tests and hosted
Linux/macOS/Android/iOS builds must run from the intended release commit.
