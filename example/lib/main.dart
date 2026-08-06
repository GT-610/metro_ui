import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:metro_ui/metro_ui.dart';

void main() => runApp(const MetroGalleryApp());

class MetroGalleryApp extends StatefulWidget {
  const MetroGalleryApp({super.key});

  @override
  State<MetroGalleryApp> createState() => _MetroGalleryAppState();
}

class _MetroGalleryAppState extends State<MetroGalleryApp> {
  bool _dark = false;
  Locale _locale = const Locale('en');
  bool _notifications = true;
  bool _syncEnabled = true;
  bool _favorite = false;
  DateTime _eventDate = DateTime(2026, 8, 3);
  MetroTime _eventTime = const MetroTime(hour: 14, minute: 30);
  String? _travelCity = 'seattle';
  int _flipViewIndex = 0;
  bool _semanticZoomedOut = false;
  int _semanticZoomGroupIndex = 0;
  int _copies = 3;
  double _temperature = 21.5;
  double _volume = 65;
  MetroRangeValues _comfortRange = const MetroRangeValues(18, 26);
  MetroDataGridSort? _albumSort;
  late final MetroSelectionController<int> _viewModeController =
      MetroSelectionController<int>(selectedValues: const [0]);
  late final MetroSelectionController<String> _librarySelectionController =
      MetroSelectionController<String>(
        mode: MetroSelectionMode.multiple,
        selectedValues: const ['documents'],
      );
  late final MetroSelectionController<_GalleryAlbum> _albumSelectionController =
      MetroSelectionController<_GalleryAlbum>(
        mode: MetroSelectionMode.multiple,
      );
  late final PageController _semanticZoomPageController = PageController();
  Color _accent = MetroColors.cobalt;
  String _lastAction = 'Choose a control';

  @override
  Widget build(BuildContext context) {
    final theme = _dark
        ? MetroThemeData.dark(accentColor: _accent)
        : MetroThemeData.light(accentColor: _accent);
    final highContrastTheme = _dark
        ? MetroThemeData.highContrastDark()
        : MetroThemeData.highContrastLight();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Metro UI Gallery',
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MetroLocalizations.delegate,
      ],
      supportedLocales: MetroLocalizations.supportedLocales,
      theme: ThemeData(
        brightness: _dark ? Brightness.dark : Brightness.light,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      home: AnimatedMetroTheme(
        data: theme,
        highContrastData: highContrastTheme,
        child: MetroCommandBarLayer(
          commandBar: _buildCommandBar(),
          child: MetroPage(
            title: const Text('Metro UI'),
            actions: [
              MetroTooltip(
                message: _locale.languageCode == 'zh'
                    ? 'Use English Metro defaults'
                    : '使用中文 Metro 默认文本',
                child: MetroIconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () {
                    setState(() {
                      _locale = _locale.languageCode == 'zh'
                          ? const Locale('en')
                          : const Locale('zh');
                    });
                  },
                  semanticLabel: _locale.languageCode == 'zh'
                      ? 'Use English locale'
                      : 'Use Chinese locale',
                ),
              ),
              MetroTooltip(
                message: _dark ? 'Use light theme' : 'Use dark theme',
                child: MetroIconButton(
                  icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => setState(() => _dark = !_dark),
                  semanticLabel: _dark ? 'Use light theme' : 'Use dark theme',
                ),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeading(
                  title: 'Modern UI for Flutter',
                  description:
                      'Typography, flat color, direct interaction, and '
                      'directional motion—without acrylic, elevation, or '
                      'decorative chrome.',
                ),
                const SizedBox(height: MetroSpacing.lg),
                _AccentPicker(
                  selected: _accent,
                  onSelected: (color) => setState(() => _accent = color),
                ),
                const SizedBox(height: MetroSpacing.xl),
                const _SectionHeading(title: 'Tiles'),
                const SizedBox(height: MetroSpacing.sm),
                MetroFocusTraversalGroup.spatial(
                  debugLabel: 'Gallery tiles',
                  child: MetroTileGrid(
                    children: [
                      MetroTile(
                        icon: const Icon(Icons.mail_outline),
                        title: 'Mail',
                        subtitle: '3 unread',
                        onPressed: () => _record('Mail tile'),
                      ),
                      MetroLiveTile(
                        size: MetroTileSize.wide,
                        title: 'Photos',
                        subtitle: 'Live tile',
                        backgroundColor: MetroColors.magenta,
                        onPressed: () => _record('Photos tile'),
                        frames: const [
                          MetroLiveTileFrame(
                            id: 'collection',
                            semanticLabel: 'Photos, 12 new memories',
                            child: Center(
                              child: Icon(Icons.photo_outlined, size: 48),
                            ),
                          ),
                          MetroLiveTileFrame(
                            id: 'highlights',
                            semanticLabel: 'Photos, highlights from this week',
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('12 NEW\nMEMORIES'),
                            ),
                          ),
                        ],
                      ),
                      MetroTile(
                        icon: const Icon(Icons.cloud_outlined),
                        title: 'Weather',
                        backgroundColor: MetroColors.teal,
                        onPressed: () => _record('Weather tile'),
                      ),
                      MetroTile(
                        icon: const Icon(Icons.settings_outlined),
                        title: 'Disabled',
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MetroSpacing.xl),
                const _SectionHeading(title: 'Buttons and feedback'),
                const SizedBox(height: MetroSpacing.sm),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: MetroSpacing.sm,
                  runSpacing: MetroSpacing.sm,
                  children: [
                    MetroButton(
                      onPressed: () => _record('Standard button'),
                      child: const Text('STANDARD'),
                    ),
                    MetroButton.accent(
                      onPressed: () => _record('Accent button'),
                      child: const Text('ACCENT'),
                    ),
                    MetroButtonTheme(
                      data: const MetroButtonThemeData(
                        style: MetroButtonStyle(
                          borderColor: WidgetStatePropertyAll(
                            MetroColors.orange,
                          ),
                          borderWidth: WidgetStatePropertyAll(3),
                        ),
                      ),
                      child: MetroButton(
                        onPressed: () => _record('Locally themed button'),
                        child: const Text('LOCAL THEME'),
                      ),
                    ),
                    const MetroButton(onPressed: null, child: Text('DISABLED')),
                    MetroBackButton(
                      onPressed: () => _record('Back button'),
                      semanticLabel: 'Back button example',
                    ),
                    const MetroProgressRing(semanticLabel: 'Loading'),
                    const MetroProgressRing(
                      value: 0.68,
                      semanticLabel: '68 percent complete',
                    ),
                  ],
                ),
                const SizedBox(height: MetroSpacing.lg),
                const _SectionHeading(title: 'Selection and lists'),
                const SizedBox(height: MetroSpacing.sm),
                Wrap(
                  spacing: MetroSpacing.lg,
                  runSpacing: MetroSpacing.sm,
                  children: [
                    MetroCheckBox(
                      value: _syncEnabled,
                      onChanged: (value) {
                        setState(() => _syncEnabled = value ?? false);
                      },
                      label: const Text('Sync settings'),
                    ),
                    MetroSelectionGroup<int>(
                      controller: _viewModeController,
                      onChanged: (values) {
                        _record('View mode ${values.single}');
                      },
                      child: const Wrap(
                        spacing: MetroSpacing.lg,
                        runSpacing: MetroSpacing.sm,
                        children: [
                          MetroRadioButton<int>(
                            value: 0,
                            label: Text('Compact'),
                          ),
                          MetroRadioButton<int>(
                            value: 1,
                            label: Text('Comfortable'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MetroSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: MetroSelectionGroup<String>(
                    controller: _librarySelectionController,
                    onChanged: (values) {
                      _record('${values.length} library items selected');
                    },
                    child: Column(
                      children: [
                        MetroSelectableListTile<String>(
                          value: 'documents',
                          leading: const Icon(Icons.folder_outlined),
                          title: const Text('Documents'),
                          subtitle: const Text('Multi-select item'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                        MetroSelectableListTile<String>(
                          value: 'pictures',
                          leading: const Icon(Icons.image_outlined),
                          title: const Text('Pictures'),
                          subtitle: const Text('Multi-select item'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: MetroSpacing.md),
                const SizedBox(
                  width: 420,
                  child: Column(
                    children: [
                      MetroProgressBar(value: 0.64),
                      SizedBox(height: MetroSpacing.md),
                      MetroProgressBar(semanticLabel: 'Loading content'),
                    ],
                  ),
                ),
                const SizedBox(height: MetroSpacing.xl),
                const _SectionHeading(title: 'Input and navigation'),
                const SizedBox(height: MetroSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      MetroSearchBox<String>(
                        placeholder: 'Search controls',
                        semanticLabel: 'Search the gallery',
                        items: const [
                          MetroSearchBoxItem(
                            value: 'tiles',
                            queryText: 'Tiles and live tiles',
                            child: Text('Tiles and live tiles'),
                          ),
                          MetroSearchBoxItem(
                            value: 'combo-box',
                            queryText: 'Combo box',
                            child: Text('Combo box'),
                          ),
                          MetroSearchBoxItem(
                            value: 'number-box',
                            queryText: 'Number box',
                            child: Text('Number box'),
                          ),
                          MetroSearchBoxItem(
                            value: 'flip-view',
                            queryText: 'FlipView',
                            child: Text('FlipView'),
                          ),
                          MetroSearchBoxItem(
                            value: 'data-grid',
                            queryText: 'Data grid',
                            child: Text('Data grid'),
                          ),
                        ],
                        onSelected: (item) {
                          _record('Search suggestion ${item.queryText}');
                        },
                        onSubmitted: (query) {
                          _record('Search submitted: $query');
                        },
                      ),
                      const SizedBox(height: MetroSpacing.md),
                      MetroTextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        label: const Text('Account name'),
                        placeholder: 'At least four characters',
                        semanticLabel: 'Account name',
                        showSuccessWhenValid: true,
                        successText: const Text('Name is available'),
                        supportingText: const Text(
                          'Validation uses Flutter FormField semantics',
                        ),
                        validator: (value) => (value?.length ?? 0) < 4
                            ? 'Use at least four characters'
                            : null,
                      ),
                      const SizedBox(height: MetroSpacing.md),
                      MetroTextFormField.password(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        label: const Text('Password'),
                        placeholder: 'Enter a password',
                        semanticLabel: 'Password',
                        supportingText: const Text('Eight characters minimum'),
                        validator: (value) => (value?.length ?? 0) < 8
                            ? 'Password is too short'
                            : null,
                      ),
                      const SizedBox(height: MetroSpacing.md),
                      Wrap(
                        spacing: MetroSpacing.sm,
                        runSpacing: MetroSpacing.sm,
                        children: [
                          SizedBox(
                            width: 250,
                            child: MetroNumberBox<int>(
                              value: _copies,
                              min: 1,
                              max: 99,
                              largeChange: 10,
                              prefix: const Text('COPIES'),
                              semanticLabel: 'Copies',
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _copies = value);
                                _record('Copies $value');
                              },
                            ),
                          ),
                          MetroNumberBoxTheme(
                            data: const MetroNumberBoxThemeData(
                              style: MetroNumberBoxStyle(
                                buttonBackgroundColor: WidgetStatePropertyAll(
                                  MetroColors.orange,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              width: 250,
                              child: MetroNumberBox<double>(
                                value: _temperature,
                                min: -20,
                                max: 50,
                                smallChange: 0.5,
                                largeChange: 5,
                                decimalPlaces: 1,
                                formatter: (value) => value == null
                                    ? ''
                                    : '${value.toStringAsFixed(1)} °C',
                                parser: (text) => double.tryParse(
                                  text.replaceAll('°C', '').trim(),
                                ),
                                semanticLabel: 'Temperature',
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _temperature = value);
                                  _record('Temperature $value');
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 220,
                            child: MetroNumberBox<int>(
                              value: 10,
                              onChanged: null,
                              placeholder: 'Disabled',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MetroSpacing.md),
                      Wrap(
                        spacing: MetroSpacing.sm,
                        runSpacing: MetroSpacing.sm,
                        children: [
                          SizedBox(
                            width: 250,
                            child: MetroComboBox<String>(
                              value: _travelCity,
                              placeholder: const Text('Choose a destination'),
                              semanticLabel: 'Travel destination',
                              items: const [
                                MetroComboBoxItem(
                                  value: 'london',
                                  child: Text('London'),
                                ),
                                MetroComboBoxItem(
                                  value: 'seattle',
                                  child: Text('Seattle'),
                                ),
                                MetroComboBoxItem(
                                  value: 'closed',
                                  enabled: false,
                                  semanticLabel: 'Unavailable destination',
                                  child: Text('Unavailable'),
                                ),
                                MetroComboBoxItem(
                                  value: 'tokyo',
                                  child: Text('Tokyo'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _travelCity = value);
                                _record('Destination $value');
                              },
                            ),
                          ),
                          MetroComboBoxTheme(
                            data: const MetroComboBoxThemeData(
                              style: MetroComboBoxStyle(
                                borderColor: WidgetStatePropertyAll(
                                  MetroColors.orange,
                                ),
                                borderWidth: WidgetStatePropertyAll(2),
                              ),
                            ),
                            child: SizedBox(
                              width: 220,
                              child: MetroComboBox<String>(
                                placeholder: const Text('Local theme'),
                                items: const [
                                  MetroComboBoxItem(
                                    value: 'compact',
                                    child: Text('Compact'),
                                  ),
                                  MetroComboBoxItem(
                                    value: 'comfortable',
                                    child: Text('Comfortable'),
                                  ),
                                ],
                                onChanged: (value) {
                                  _record('Combo density $value');
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 190,
                            child: MetroComboBox<String>(
                              placeholder: Text('Disabled'),
                              disabledPlaceholder: Text('Unavailable'),
                              items: [
                                MetroComboBoxItem(
                                  value: 'disabled',
                                  child: Text('Disabled'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MetroSpacing.md),
                      Wrap(
                        spacing: MetroSpacing.sm,
                        runSpacing: MetroSpacing.sm,
                        children: [
                          SizedBox(
                            width: 280,
                            child: MetroDatePicker(
                              selected: _eventDate,
                              firstDate: DateTime(2024),
                              lastDate: DateTime(2030, 12, 31),
                              monthFormatter: (context, month) =>
                                  _monthNames[month - 1],
                              onChanged: (date) {
                                setState(() => _eventDate = date);
                                _record('Event date selected');
                              },
                              semanticLabel: 'Event date',
                            ),
                          ),
                          SizedBox(
                            width: 210,
                            child: MetroTimePicker(
                              selected: _eventTime,
                              minuteIncrement: 15,
                              onChanged: (time) {
                                setState(() => _eventTime = time);
                                _record('Event time selected');
                              },
                              semanticLabel: 'Event time',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MetroSpacing.lg),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Volume ${_volume.round()}'),
                      ),
                      MetroSlider(
                        value: _volume,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        tickPlacement: MetroSliderTickPlacement.after,
                        semanticLabel: 'Volume',
                        semanticFormatterCallback: (value) =>
                            '${value.round()} percent',
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                            _lastAction = 'Volume ${value.round()}';
                          });
                        },
                      ),
                      const SizedBox(height: MetroSpacing.md),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Comfort range ${_comfortRange.start.round()}–'
                          '${_comfortRange.end.round()} °C',
                        ),
                      ),
                      MetroRangeSlider(
                        values: _comfortRange,
                        min: 10,
                        max: 35,
                        divisions: 25,
                        minimumRange: 2,
                        tickPlacement: MetroSliderTickPlacement.after,
                        startSemanticLabel: 'Minimum comfort temperature',
                        endSemanticLabel: 'Maximum comfort temperature',
                        semanticFormatterCallback: (value) =>
                            '${value.round()} degrees',
                        onChanged: (values) {
                          setState(() {
                            _comfortRange = values;
                            _lastAction =
                                'Comfort range ${values.start.round()}–'
                                '${values.end.round()}';
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MetroSpacing.md),
                const _SectionHeading(
                  title: 'FlipView',
                  description:
                      'Direct swipe navigation with keyboard commands, '
                      'hover controls, banners, and optional circular paging.',
                ),
                const SizedBox(height: MetroSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: SizedBox(
                    height: 300,
                    child: MetroFlipView(
                      index: _flipViewIndex,
                      circular: true,
                      showIndicators: true,
                      semanticLabel: 'Modern UI feature stories',
                      onChanged: (index) {
                        setState(() {
                          _flipViewIndex = index;
                          _lastAction = 'FlipView page ${index + 1}';
                        });
                      },
                      items: const [
                        MetroFlipViewItem(
                          semanticLabel: 'Direct interaction story',
                          banner: Text('SWIPE, CLICK, OR USE THE ARROW KEYS'),
                          child: _FlipViewStory(
                            color: MetroColors.cobalt,
                            eyebrow: 'MODERN UI',
                            title: 'CONTENT\nBEFORE CHROME',
                            icon: Icons.swipe,
                          ),
                        ),
                        MetroFlipViewItem(
                          semanticLabel: 'Typography story',
                          banner: Text('BOLD SCALE CREATES THE HIERARCHY'),
                          child: _FlipViewStory(
                            color: MetroColors.magenta,
                            eyebrow: 'TYPOGRAPHY',
                            title: 'CLEAR, FAST,\nCONFIDENT',
                            icon: Icons.text_fields,
                          ),
                        ),
                        MetroFlipViewItem(
                          semanticLabel: 'Motion story',
                          banner: Text('DIRECTIONAL MOTION PRESERVES CONTEXT'),
                          child: _FlipViewStory(
                            color: MetroColors.emerald,
                            eyebrow: 'MOTION',
                            title: 'ONE SURFACE,\nNEXT STORY',
                            icon: Icons.arrow_forward,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: MetroSpacing.md),
                const _SectionHeading(
                  title: 'Semantic zoom',
                  description:
                      'Pinch, press Ctrl+Minus, or use the transient minus '
                      'button to move between detailed groups and a compact '
                      'overview. Choosing a group restores its detailed page.',
                ),
                const SizedBox(height: MetroSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: MetroSemanticZoom(
                    height: 320,
                    semanticLabel: 'Gallery component groups',
                    zoomedOut: _semanticZoomedOut,
                    onZoomedOutChanged: (zoomedOut) {
                      setState(() {
                        _semanticZoomedOut = zoomedOut;
                        _lastAction = zoomedOut
                            ? 'Semantic zoom overview'
                            : 'Semantic zoom details';
                      });
                    },
                    zoomedInView: PageView.builder(
                      controller: _semanticZoomPageController,
                      itemCount: _semanticZoomGroups.length,
                      onPageChanged: (index) {
                        setState(() => _semanticZoomGroupIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return _SemanticZoomGroupPage(
                          group: _semanticZoomGroups[index],
                          onItemPressed: (item) {
                            _record('Semantic zoom item $item');
                          },
                        );
                      },
                    ),
                    zoomedOutView: _SemanticZoomOverview(
                      groups: _semanticZoomGroups,
                      selectedIndex: _semanticZoomGroupIndex,
                      onSelected: _openSemanticZoomGroup,
                    ),
                  ),
                ),
                const SizedBox(height: MetroSpacing.md),
                const _SectionHeading(
                  title: 'Data grid',
                  description:
                      'Controlled sorting, shared row selection, horizontal '
                      'columns, and keyboard navigation.',
                ),
                const SizedBox(height: MetroSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: MetroDataGrid<_GalleryAlbum>(
                    autofocus: true,
                    columns: _albumColumns,
                    height: 264,
                    onSelectionChanged: (album, selected) {
                      _record(
                        '${selected ? 'Selected' : 'Cleared'} ${album.title}',
                      );
                    },
                    onSortChanged: (sort) {
                      setState(() {
                        _albumSort = sort;
                        _lastAction = 'Sorted albums ${sort.direction.name}';
                      });
                    },
                    rowSemanticLabelBuilder: (album, index) =>
                        '${album.title}, ${album.artist}, ${album.year}',
                    rows: _sortedAlbums,
                    selectionController: _albumSelectionController,
                    sort: _albumSort,
                  ),
                ),
                const SizedBox(height: MetroSpacing.md),
                MetroToggleSwitch(
                  value: _notifications,
                  onChanged: (value) {
                    setState(() => _notifications = value);
                  },
                  label: Text(
                    _notifications ? 'Notifications on' : 'Notifications off',
                  ),
                  semanticLabel: 'Notifications',
                ),
                const SizedBox(height: MetroSpacing.lg),
                SizedBox(
                  height: 190,
                  child: MetroPivot(
                    items: const [
                      MetroPivotItem(
                        header: Text('RECENT'),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text('Recently used components'),
                        ),
                      ),
                      MetroPivotItem(
                        header: Text('FAVORITES'),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text('Pinned component examples'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MetroSpacing.md),
                Builder(
                  builder: (context) {
                    return MetroButton(
                      onPressed: () => _showMotionPage(context),
                      child: const Text('OPEN TRANSITION PAGE'),
                    );
                  },
                ),
                const SizedBox(height: MetroSpacing.lg),
                Text('Last action: $_lastAction'),
                const SizedBox(height: MetroSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommandBar() {
    return MetroCommandBar(
      leading: const Text('COMMANDS'),
      commands: [
        MetroCommandButton(
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
          onPressed: () => _record('Refresh command'),
          semanticLabel: 'Refresh gallery',
        ),
        MetroCommandButton(
          icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border),
          label: const Text('Favorite'),
          onPressed: () {
            setState(() => _favorite = !_favorite);
            _record('Favorite command');
          },
          selected: _favorite,
          semanticLabel: 'Favorite gallery',
        ),
        const MetroCommandButton(
          icon: Icon(Icons.share_outlined),
          label: Text('Share'),
          onPressed: null,
          semanticLabel: 'Share unavailable',
        ),
        Builder(
          builder: (context) {
            return MetroCommandButton(
              icon: const Icon(Icons.tune),
              label: const Text('Settings'),
              onPressed: () => _showSettingsFlyout(context),
              semanticLabel: 'Open settings flyout',
            );
          },
        ),
        Builder(
          builder: (context) {
            return MetroCommandButton(
              icon: const Icon(Icons.info_outline),
              label: const Text('About'),
              onPressed: () => _showAboutDialog(context),
              semanticLabel: 'About Metro UI',
            );
          },
        ),
      ],
    );
  }

  void _record(String action) => setState(() => _lastAction = action);

  static const _monthNames = <String>[
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  static const _albums = <_GalleryAlbum>[
    _GalleryAlbum('Discovery', 'Daft Punk', 2001),
    _GalleryAlbum('Homework', 'Daft Punk', 1997),
    _GalleryAlbum('In Colour', 'Jamie xx', 2015),
    _GalleryAlbum('Settle', 'Disclosure', 2013),
    _GalleryAlbum('Immunity', 'Jon Hopkins', 2013),
  ];

  static const _semanticZoomGroups = <_SemanticZoomGroup>[
    _SemanticZoomGroup(
      label: 'LAYOUT',
      description: 'Content-first surfaces and responsive Metro composition.',
      color: MetroColors.cobalt,
      items: ['Tile', 'LiveTile', 'Semantic zoom'],
    ),
    _SemanticZoomGroup(
      label: 'NAVIGATION',
      description: 'Directional movement that keeps collection context.',
      color: MetroColors.magenta,
      items: ['Pivot', 'FlipView', 'PageRoute'],
    ),
    _SemanticZoomGroup(
      label: 'INPUT',
      description: 'Direct, square controls with explicit interaction states.',
      color: MetroColors.teal,
      items: ['SearchBox', 'NumberBox', 'Slider'],
    ),
  ];

  static final _albumColumns = <MetroDataGridColumn<_GalleryAlbum>>[
    MetroDataGridColumn<_GalleryAlbum>(
      key: 'title',
      label: const Text('TITLE'),
      semanticLabel: 'Sort albums by title',
      sortable: true,
      minimumWidth: 190,
      cellBuilder: (context, album, index) => Text(album.title),
    ),
    MetroDataGridColumn<_GalleryAlbum>(
      key: 'artist',
      label: const Text('ARTIST'),
      semanticLabel: 'Sort albums by artist',
      sortable: true,
      minimumWidth: 170,
      cellBuilder: (context, album, index) => Text(album.artist),
    ),
    MetroDataGridColumn<_GalleryAlbum>(
      key: 'year',
      label: const Text('YEAR'),
      semanticLabel: 'Sort albums by year',
      sortable: true,
      width: 90,
      alignment: AlignmentDirectional.centerEnd,
      headerAlignment: AlignmentDirectional.centerEnd,
      cellBuilder: (context, album, index) => Text('${album.year}'),
    ),
  ];

  List<_GalleryAlbum> get _sortedAlbums {
    final albums = List<_GalleryAlbum>.of(_albums);
    final sort = _albumSort;
    if (sort == null) return albums;
    albums.sort((first, second) {
      final comparison = switch (sort.columnKey) {
        'artist' => first.artist.compareTo(second.artist),
        'year' => first.year.compareTo(second.year),
        _ => first.title.compareTo(second.title),
      };
      return sort.direction == MetroDataGridSortDirection.ascending
          ? comparison
          : -comparison;
    });
    return albums;
  }

  @override
  void dispose() {
    _semanticZoomPageController.dispose();
    _viewModeController.dispose();
    _librarySelectionController.dispose();
    _albumSelectionController.dispose();
    super.dispose();
  }

  void _openSemanticZoomGroup(int index) {
    if (_semanticZoomPageController.hasClients) {
      _semanticZoomPageController.jumpToPage(index);
    }
    setState(() {
      _semanticZoomGroupIndex = index;
      _semanticZoomedOut = false;
      _lastAction = 'Semantic zoom ${_semanticZoomGroups[index].label}';
    });
  }

  void _showMotionPage(BuildContext context) {
    Navigator.of(context).push(
      MetroPageRoute<void>(
        context: context,
        builder: (pageContext) {
          return MetroPage(
            title: const Text('Directional motion'),
            actions: [
              MetroIconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(pageContext).pop(),
                semanticLabel: 'Close transition page',
              ),
            ],
            child: const Text(
              'MetroPageRoute captures the active Metro theme and follows '
              'the logical reading direction.',
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showMetroDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss about dialog',
      builder: (dialogContext) {
        return MetroDialog(
          semanticLabel: 'About Metro UI dialog',
          title: const Text('Metro UI for Flutter'),
          content: const Text(
            'A Flutter-native interpretation of the Windows 8 Modern UI '
            'design language.',
          ),
          actions: [
            MetroButton.accent(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsFlyout(BuildContext context) {
    showMetroFlyout<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss settings flyout',
      builder: (flyoutContext) {
        return StatefulBuilder(
          builder: (context, setFlyoutState) {
            return MetroFlyout(
              semanticLabel: 'Gallery settings flyout',
              title: const Text('Settings'),
              actions: [
                MetroIconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(flyoutContext).pop(),
                  semanticLabel: 'Close settings',
                  variant: MetroButtonVariant.accent,
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Experience',
                    style: MetroTheme.of(context).typography.title,
                  ),
                  const SizedBox(height: MetroSpacing.md),
                  MetroToggleSwitch(
                    value: _notifications,
                    onChanged: (value) {
                      setState(() => _notifications = value);
                      setFlyoutState(() {});
                    },
                    label: const Text('Notifications'),
                  ),
                  const SizedBox(height: MetroSpacing.md),
                  MetroCheckBox(
                    value: _syncEnabled,
                    onChanged: (value) {
                      setState(() => _syncEnabled = value ?? false);
                      setFlyoutState(() {});
                    },
                    label: const Text('Sync settings'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final typography = MetroTheme.of(context).typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: typography.title),
        if (description != null) ...[
          const SizedBox(height: MetroSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(description!),
          ),
        ],
      ],
    );
  }
}

class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.selected, required this.onSelected});

  final Color selected;
  final ValueChanged<Color> onSelected;

  static const colors = <Color>[
    MetroColors.cobalt,
    MetroColors.teal,
    MetroColors.magenta,
    MetroColors.orange,
    MetroColors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: MetroSpacing.xs,
      runSpacing: MetroSpacing.xs,
      children: [
        for (final color in colors)
          Semantics(
            button: true,
            selected: color == selected,
            label: 'Select accent ${color.toARGB32().toRadixString(16)}',
            child: GestureDetector(
              onTap: () => onSelected(color),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: color == selected
                        ? MetroTheme.of(context).colors.focus
                        : const Color(0x00000000),
                    width: 3,
                  ),
                ),
                child: const SizedBox.square(dimension: 36),
              ),
            ),
          ),
      ],
    );
  }
}

class _FlipViewStory extends StatelessWidget {
  const _FlipViewStory({
    required this.color,
    required this.eyebrow,
    required this.title,
    required this.icon,
  });

  final Color color;
  final String eyebrow;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(64, MetroSpacing.lg, 64, 72),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: MetroSpacing.sm),
                  Flexible(
                    child: FittedBox(
                      alignment: AlignmentDirectional.centerStart,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 44,
                          fontWeight: FontWeight.w300,
                          height: 0.95,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MetroSpacing.lg),
            Icon(icon, color: const Color(0xFFFFFFFF), size: 72),
          ],
        ),
      ),
    );
  }
}

class _SemanticZoomOverview extends StatelessWidget {
  const _SemanticZoomOverview({
    required this.groups,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_SemanticZoomGroup> groups;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MetroSpacing.md),
      child: GridView.builder(
        itemCount: groups.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: MetroSpacing.sm,
          mainAxisSpacing: MetroSpacing.sm,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (context, index) {
          final group = groups[index];
          return MetroButton(
            semanticLabel:
                '${group.label}, ${group.items.length} component examples',
            style: MetroButtonStyle(
              backgroundColor: WidgetStatePropertyAll(group.color),
              foregroundColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
              borderColor: WidgetStatePropertyAll(
                index == selectedIndex
                    ? const Color(0xFFFFFFFF)
                    : const Color(0x00000000),
              ),
              borderWidth: WidgetStatePropertyAll(
                index == selectedIndex ? 3 : 0,
              ),
              padding: const EdgeInsets.all(MetroSpacing.sm),
            ),
            onPressed: () => onSelected(index),
            child: Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('${group.items.length} COMPONENTS'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SemanticZoomGroupPage extends StatelessWidget {
  const _SemanticZoomGroupPage({
    required this.group,
    required this.onItemPressed,
  });

  final _SemanticZoomGroup group;
  final ValueChanged<String> onItemPressed;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: group.color,
      child: Padding(
        padding: const EdgeInsets.all(MetroSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.label,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 36,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: MetroSpacing.xs),
            Text(
              group.description,
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
            const Spacer(),
            Wrap(
              spacing: MetroSpacing.sm,
              runSpacing: MetroSpacing.sm,
              children: [
                for (final item in group.items)
                  MetroButton(
                    style: const MetroButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0x26FFFFFF),
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        Color(0xFFFFFFFF),
                      ),
                      borderColor: WidgetStatePropertyAll(Color(0x99FFFFFF)),
                    ),
                    onPressed: () => onItemPressed(item),
                    child: Text(item.toUpperCase()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class _SemanticZoomGroup {
  const _SemanticZoomGroup({
    required this.label,
    required this.description,
    required this.color,
    required this.items,
  });

  final String label;
  final String description;
  final Color color;
  final List<String> items;
}

@immutable
class _GalleryAlbum {
  const _GalleryAlbum(this.title, this.artist, this.year);

  final String title;
  final String artist;
  final int year;

  @override
  bool operator ==(Object other) {
    return other is _GalleryAlbum &&
        other.title == title &&
        other.artist == artist &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(title, artist, year);
}
