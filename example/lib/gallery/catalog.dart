import 'package:flutter/material.dart';
import 'package:metro_ui/metro_ui.dart';

enum GalleryDestinationId {
  home,
  tiles,
  buttonsAndFeedback,
  selectionAndLists,
  inputsAndPickers,
  navigation,
  data,
  allControls,
}

@immutable
class GalleryDestination {
  const GalleryDestination({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final GalleryDestinationId id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

@immutable
class GalleryComponent {
  const GalleryComponent({
    required this.name,
    required this.destination,
    required this.description,
    this.keywords = const <String>[],
  });

  final String name;
  final GalleryDestinationId destination;
  final String description;
  final List<String> keywords;

  String get searchText =>
      <String>[name, description, ...keywords].join(' ').toLowerCase();
}

const galleryDestinations = <GalleryDestination>[
  GalleryDestination(
    id: GalleryDestinationId.home,
    title: 'Metro UI',
    description: 'Start here, browse the catalog, or search for a control.',
    icon: Icons.home_outlined,
    color: MetroColors.cobalt,
  ),
  GalleryDestination(
    id: GalleryDestinationId.tiles,
    title: 'Layout & tiles',
    description: 'Metro surfaces for content-first dashboards and launchers.',
    icon: Icons.grid_view_outlined,
    color: MetroColors.cobalt,
  ),
  GalleryDestination(
    id: GalleryDestinationId.buttonsAndFeedback,
    title: 'Buttons & feedback',
    description: 'Actions, commands, progress, dialogs, flyouts, and tooltips.',
    icon: Icons.touch_app_outlined,
    color: MetroColors.orange,
  ),
  GalleryDestination(
    id: GalleryDestinationId.selectionAndLists,
    title: 'Selection & lists',
    description: 'Single and multiple selection patterns for Metro apps.',
    icon: Icons.check_box_outlined,
    color: MetroColors.emerald,
  ),
  GalleryDestination(
    id: GalleryDestinationId.inputsAndPickers,
    title: 'Inputs & pickers',
    description: 'Text, numeric, search, choice, date, time, and range input.',
    icon: Icons.edit_outlined,
    color: MetroColors.teal,
  ),
  GalleryDestination(
    id: GalleryDestinationId.navigation,
    title: 'Navigation',
    description: 'Directional navigation that preserves collection context.',
    icon: Icons.swap_horiz,
    color: MetroColors.magenta,
  ),
  GalleryDestination(
    id: GalleryDestinationId.data,
    title: 'Data display',
    description: 'Sortable, selectable, keyboard-friendly structured data.',
    icon: Icons.table_chart_outlined,
    color: MetroColors.violet,
  ),
  GalleryDestination(
    id: GalleryDestinationId.allControls,
    title: 'All controls',
    description: 'The complete integration playground on one scrolling page.',
    icon: Icons.apps,
    color: MetroColors.lime,
  ),
];

const galleryComponents = <GalleryComponent>[
  GalleryComponent(
    name: 'MetroTile',
    destination: GalleryDestinationId.tiles,
    description: 'Square and wide launch surfaces.',
    keywords: ['layout', 'dashboard'],
  ),
  GalleryComponent(
    name: 'MetroLiveTile',
    destination: GalleryDestinationId.tiles,
    description: 'Animated tile content with semantic frames.',
    keywords: ['animation', 'dashboard'],
  ),
  GalleryComponent(
    name: 'MetroTileGrid',
    destination: GalleryDestinationId.tiles,
    description: 'Responsive wrapping layout for Metro tiles.',
    keywords: ['layout', 'responsive'],
  ),
  GalleryComponent(
    name: 'MetroPage',
    destination: GalleryDestinationId.tiles,
    description: 'Large-title page surface with generous whitespace.',
    keywords: ['layout', 'page'],
  ),
  GalleryComponent(
    name: 'MetroEntrance',
    destination: GalleryDestinationId.tiles,
    description: 'Directional and staggered page-content entrance motion.',
    keywords: ['animation', 'motion', 'transition'],
  ),
  GalleryComponent(
    name: 'MetroButton',
    destination: GalleryDestinationId.buttonsAndFeedback,
    description: 'Standard, accent, themed, and disabled actions.',
    keywords: ['action', 'button'],
  ),
  GalleryComponent(
    name: 'MetroIconButton',
    destination: GalleryDestinationId.buttonsAndFeedback,
    description: 'Compact icon-only action.',
    keywords: ['action', 'button'],
  ),
  GalleryComponent(
    name: 'MetroCommandBar',
    destination: GalleryDestinationId.buttonsAndFeedback,
    description: 'Global and contextual application commands.',
    keywords: ['toolbar', 'command'],
  ),
  GalleryComponent(
    name: 'MetroCommandButton',
    destination: GalleryDestinationId.buttonsAndFeedback,
    description: 'Action item displayed by a Metro command bar.',
    keywords: ['toolbar', 'command', 'button'],
  ),
  GalleryComponent(
    name: 'MetroProgressRing',
    destination: GalleryDestinationId.buttonsAndFeedback,
    description: 'Determinate and indeterminate circular progress.',
    keywords: ['loading', 'status'],
  ),
  GalleryComponent(
    name: 'MetroProgressBar',
    destination: GalleryDestinationId.buttonsAndFeedback,
    description: 'Determinate and indeterminate linear progress.',
    keywords: ['loading', 'status'],
  ),
  GalleryComponent(
    name: 'MetroDialog',
    destination: GalleryDestinationId.buttonsAndFeedback,
    description: 'Modal confirmation and information surface.',
    keywords: ['overlay', 'popup'],
  ),
  GalleryComponent(
    name: 'MetroFlyout',
    destination: GalleryDestinationId.buttonsAndFeedback,
    description: 'Edge-aligned transient settings surface.',
    keywords: ['overlay', 'popup'],
  ),
  GalleryComponent(
    name: 'MetroTooltip',
    destination: GalleryDestinationId.buttonsAndFeedback,
    description: 'Short contextual help for pointer and keyboard users.',
    keywords: ['overlay', 'help'],
  ),
  GalleryComponent(
    name: 'MetroCheckBox',
    destination: GalleryDestinationId.selectionAndLists,
    description: 'Independent boolean or tri-state selection.',
    keywords: ['selection', 'check'],
  ),
  GalleryComponent(
    name: 'MetroRadioButton',
    destination: GalleryDestinationId.selectionAndLists,
    description: 'Exclusive selection within a shared group.',
    keywords: ['selection', 'radio'],
  ),
  GalleryComponent(
    name: 'MetroToggleSwitch',
    destination: GalleryDestinationId.selectionAndLists,
    description: 'Immediate on or off setting.',
    keywords: ['selection', 'switch'],
  ),
  GalleryComponent(
    name: 'MetroSelectionGroup',
    destination: GalleryDestinationId.selectionAndLists,
    description: 'Shared controller for single or multiple selection.',
    keywords: ['selection', 'controller'],
  ),
  GalleryComponent(
    name: 'MetroListTile',
    destination: GalleryDestinationId.selectionAndLists,
    description: 'Keyboard-accessible primary and secondary row.',
    keywords: ['list', 'row'],
  ),
  GalleryComponent(
    name: 'MetroSelectableListTile',
    destination: GalleryDestinationId.selectionAndLists,
    description: 'List row connected to a shared selection controller.',
    keywords: ['list', 'row', 'selection'],
  ),
  GalleryComponent(
    name: 'MetroSearchBox',
    destination: GalleryDestinationId.inputsAndPickers,
    description: 'Search input with local suggestions and submission.',
    keywords: ['input', 'autocomplete'],
  ),
  GalleryComponent(
    name: 'MetroTextField',
    destination: GalleryDestinationId.inputsAndPickers,
    description: 'Text and password entry with validation support.',
    keywords: ['input', 'form'],
  ),
  GalleryComponent(
    name: 'MetroTextFormField',
    destination: GalleryDestinationId.inputsAndPickers,
    description: 'Validated text input integrated with Flutter forms.',
    keywords: ['input', 'form', 'validation'],
  ),
  GalleryComponent(
    name: 'MetroNumberBox',
    destination: GalleryDestinationId.inputsAndPickers,
    description: 'Numeric input with stepping, parsing, and formatting.',
    keywords: ['input', 'number', 'stepper'],
  ),
  GalleryComponent(
    name: 'MetroComboBox',
    destination: GalleryDestinationId.inputsAndPickers,
    description: 'Single choice from a compact popup list.',
    keywords: ['input', 'select', 'dropdown'],
  ),
  GalleryComponent(
    name: 'MetroDatePicker',
    destination: GalleryDestinationId.inputsAndPickers,
    description: 'Localized date selection.',
    keywords: ['input', 'calendar', 'picker'],
  ),
  GalleryComponent(
    name: 'MetroTimePicker',
    destination: GalleryDestinationId.inputsAndPickers,
    description: 'Localized time selection with minute increments.',
    keywords: ['input', 'clock', 'picker'],
  ),
  GalleryComponent(
    name: 'MetroSlider',
    destination: GalleryDestinationId.inputsAndPickers,
    description: 'Continuous or discrete scalar input.',
    keywords: ['input', 'range'],
  ),
  GalleryComponent(
    name: 'MetroRangeSlider',
    destination: GalleryDestinationId.inputsAndPickers,
    description: 'Two-thumb range selection.',
    keywords: ['input', 'range'],
  ),
  GalleryComponent(
    name: 'MetroFlipView',
    destination: GalleryDestinationId.navigation,
    description: 'Swipe, pointer, and keyboard page navigation.',
    keywords: ['navigation', 'carousel'],
  ),
  GalleryComponent(
    name: 'MetroSemanticZoom',
    destination: GalleryDestinationId.navigation,
    description: 'Move between collection detail and overview.',
    keywords: ['navigation', 'zoom', 'collection'],
  ),
  GalleryComponent(
    name: 'MetroPivot',
    destination: GalleryDestinationId.navigation,
    description: 'Horizontal Metro section navigation.',
    keywords: ['navigation', 'tabs'],
  ),
  GalleryComponent(
    name: 'MetroPageRoute',
    destination: GalleryDestinationId.navigation,
    description: 'Directional route transition with theme capture.',
    keywords: ['navigation', 'route', 'motion'],
  ),
  GalleryComponent(
    name: 'MetroBackButton',
    destination: GalleryDestinationId.buttonsAndFeedback,
    description: 'Directional back navigation action.',
    keywords: ['navigation', 'button'],
  ),
  GalleryComponent(
    name: 'MetroDataGrid',
    destination: GalleryDestinationId.data,
    description: 'Sortable and selectable structured data.',
    keywords: ['table', 'data', 'grid'],
  ),
];

final Map<GalleryDestinationId, GalleryDestination> _destinationsById =
    Map<GalleryDestinationId, GalleryDestination>.unmodifiable({
      for (final destination in galleryDestinations)
        destination.id: destination,
    });

final Map<GalleryDestinationId, List<GalleryComponent>>
_componentsByDestination =
    Map<GalleryDestinationId, List<GalleryComponent>>.unmodifiable({
      for (final destination in galleryDestinations)
        destination.id: List<GalleryComponent>.unmodifiable(
          galleryComponents.where(
            (component) => component.destination == destination.id,
          ),
        ),
    });

GalleryDestination galleryDestinationOf(GalleryDestinationId id) {
  return _destinationsById[id]!;
}

List<GalleryComponent> galleryComponentsFor(GalleryDestinationId id) {
  if (id == GalleryDestinationId.allControls) return galleryComponents;
  return _componentsByDestination[id] ?? const <GalleryComponent>[];
}
