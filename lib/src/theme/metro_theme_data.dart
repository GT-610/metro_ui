// Flutter 3.32 does not re-export Brightness from widgets.dart.
// ignore: unnecessary_import
import 'dart:ui' show Brightness;

import 'package:flutter/widgets.dart';

import '../controls/buttons/metro_button_style.dart';
import '../controls/data/metro_data_grid_style.dart';
import '../controls/feedback/metro_progress_bar_theme.dart';
import '../controls/feedback/metro_progress_ring_theme.dart';
import '../controls/inputs/metro_combo_box_style.dart';
import '../controls/inputs/metro_number_box_style.dart';
import '../controls/inputs/metro_search_box_style.dart';
import '../controls/inputs/metro_slider_style.dart';
import '../controls/inputs/metro_text_field_style.dart';
import '../controls/lists/metro_list_tile_style.dart';
import '../controls/navigation/metro_command_bar_style.dart';
import '../controls/navigation/metro_flip_view_style.dart';
import '../controls/navigation/metro_pivot.dart';
import '../controls/overlays/metro_dialog_theme.dart';
import '../controls/overlays/metro_flyout_theme.dart';
import '../controls/overlays/metro_tooltip_theme.dart';
import '../controls/pickers/metro_picker_style.dart';
import '../controls/selection/metro_selection_control_style.dart';
import '../controls/selection/metro_toggle_switch.dart';
import '../controls/tiles/metro_tile_style.dart';
import 'metro_color_scheme.dart';
import 'metro_colors.dart';
import 'metro_motion.dart';
import 'metro_typography.dart';

/// Complete set of visual and motion tokens consumed by Metro UI widgets.
@immutable
class MetroThemeData {
  MetroThemeData({
    required this.colors,
    MetroTypography? typography,
    this.motion = const MetroMotion(),
    this.buttonTheme = const MetroButtonThemeData(),
    this.dataGridTheme = const MetroDataGridThemeData(),
    this.tileTheme = const MetroTileThemeData(),
    this.progressRingTheme = const MetroProgressRingThemeData(),
    this.progressBarTheme = const MetroProgressBarThemeData(),
    this.comboBoxTheme = const MetroComboBoxThemeData(),
    this.numberBoxTheme = const MetroNumberBoxThemeData(),
    this.searchBoxTheme = const MetroSearchBoxThemeData(),
    this.textFieldTheme = const MetroTextFieldThemeData(),
    this.sliderTheme = const MetroSliderThemeData(),
    this.listTileTheme = const MetroListTileThemeData(),
    this.commandBarTheme = const MetroCommandBarThemeData(),
    this.flipViewTheme = const MetroFlipViewThemeData(),
    this.pivotTheme = const MetroPivotThemeData(),
    this.dialogTheme = const MetroDialogThemeData(),
    this.flyoutTheme = const MetroFlyoutThemeData(),
    this.tooltipTheme = const MetroTooltipThemeData(),
    this.pickerTheme = const MetroPickerThemeData(),
    this.checkBoxTheme = const MetroCheckBoxThemeData(),
    this.radioButtonTheme = const MetroRadioButtonThemeData(),
    this.toggleSwitchTheme = const MetroToggleSwitchThemeData(),
  }) : typography = typography ?? MetroTypography.fromColorScheme(colors);

  factory MetroThemeData.light({Color accentColor = MetroColors.cobalt}) {
    return MetroThemeData(colors: MetroColorScheme.light(accent: accentColor));
  }

  factory MetroThemeData.dark({Color accentColor = MetroColors.cobalt}) {
    return MetroThemeData(colors: MetroColorScheme.dark(accent: accentColor));
  }

  factory MetroThemeData.highContrastLight({
    Color accentColor = const Color(0xFF0037DA),
  }) {
    return MetroThemeData(
      colors: MetroColorScheme.highContrastLight(accent: accentColor),
    );
  }

  factory MetroThemeData.highContrastDark({
    Color accentColor = MetroColors.yellow,
  }) {
    return MetroThemeData(
      colors: MetroColorScheme.highContrastDark(accent: accentColor),
    );
  }

  final MetroColorScheme colors;
  final MetroTypography typography;
  final MetroMotion motion;
  final MetroButtonThemeData buttonTheme;
  final MetroDataGridThemeData dataGridTheme;
  final MetroTileThemeData tileTheme;
  final MetroProgressRingThemeData progressRingTheme;
  final MetroProgressBarThemeData progressBarTheme;
  final MetroComboBoxThemeData comboBoxTheme;
  final MetroNumberBoxThemeData numberBoxTheme;
  final MetroSearchBoxThemeData searchBoxTheme;
  final MetroTextFieldThemeData textFieldTheme;
  final MetroSliderThemeData sliderTheme;
  final MetroListTileThemeData listTileTheme;
  final MetroCommandBarThemeData commandBarTheme;
  final MetroFlipViewThemeData flipViewTheme;
  final MetroPivotThemeData pivotTheme;
  final MetroDialogThemeData dialogTheme;
  final MetroFlyoutThemeData flyoutTheme;
  final MetroTooltipThemeData tooltipTheme;
  final MetroPickerThemeData pickerTheme;
  final MetroCheckBoxThemeData checkBoxTheme;
  final MetroRadioButtonThemeData radioButtonTheme;
  final MetroToggleSwitchThemeData toggleSwitchTheme;

  Brightness get brightness => colors.brightness;

  MetroThemeData copyWith({
    MetroColorScheme? colors,
    MetroTypography? typography,
    MetroMotion? motion,
    MetroButtonThemeData? buttonTheme,
    MetroDataGridThemeData? dataGridTheme,
    MetroTileThemeData? tileTheme,
    MetroProgressRingThemeData? progressRingTheme,
    MetroProgressBarThemeData? progressBarTheme,
    MetroComboBoxThemeData? comboBoxTheme,
    MetroNumberBoxThemeData? numberBoxTheme,
    MetroSearchBoxThemeData? searchBoxTheme,
    MetroTextFieldThemeData? textFieldTheme,
    MetroSliderThemeData? sliderTheme,
    MetroListTileThemeData? listTileTheme,
    MetroCommandBarThemeData? commandBarTheme,
    MetroFlipViewThemeData? flipViewTheme,
    MetroPivotThemeData? pivotTheme,
    MetroDialogThemeData? dialogTheme,
    MetroFlyoutThemeData? flyoutTheme,
    MetroTooltipThemeData? tooltipTheme,
    MetroPickerThemeData? pickerTheme,
    MetroCheckBoxThemeData? checkBoxTheme,
    MetroRadioButtonThemeData? radioButtonTheme,
    MetroToggleSwitchThemeData? toggleSwitchTheme,
  }) {
    return MetroThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      motion: motion ?? this.motion,
      buttonTheme: buttonTheme ?? this.buttonTheme,
      dataGridTheme: dataGridTheme ?? this.dataGridTheme,
      tileTheme: tileTheme ?? this.tileTheme,
      progressRingTheme: progressRingTheme ?? this.progressRingTheme,
      progressBarTheme: progressBarTheme ?? this.progressBarTheme,
      comboBoxTheme: comboBoxTheme ?? this.comboBoxTheme,
      numberBoxTheme: numberBoxTheme ?? this.numberBoxTheme,
      searchBoxTheme: searchBoxTheme ?? this.searchBoxTheme,
      textFieldTheme: textFieldTheme ?? this.textFieldTheme,
      sliderTheme: sliderTheme ?? this.sliderTheme,
      listTileTheme: listTileTheme ?? this.listTileTheme,
      commandBarTheme: commandBarTheme ?? this.commandBarTheme,
      flipViewTheme: flipViewTheme ?? this.flipViewTheme,
      pivotTheme: pivotTheme ?? this.pivotTheme,
      dialogTheme: dialogTheme ?? this.dialogTheme,
      flyoutTheme: flyoutTheme ?? this.flyoutTheme,
      tooltipTheme: tooltipTheme ?? this.tooltipTheme,
      pickerTheme: pickerTheme ?? this.pickerTheme,
      checkBoxTheme: checkBoxTheme ?? this.checkBoxTheme,
      radioButtonTheme: radioButtonTheme ?? this.radioButtonTheme,
      toggleSwitchTheme: toggleSwitchTheme ?? this.toggleSwitchTheme,
    );
  }

  /// Creates a coherent theme with a new accent and recalculated on-accent
  /// contrast color.
  MetroThemeData withAccent(Color accentColor) {
    return copyWith(colors: colors.copyWith(accent: accentColor));
  }

  static MetroThemeData lerp(MetroThemeData a, MetroThemeData b, double t) {
    return MetroThemeData(
      colors: MetroColorScheme.lerp(a.colors, b.colors, t),
      typography: MetroTypography.lerp(a.typography, b.typography, t),
      motion: MetroMotion.lerp(a.motion, b.motion, t),
      buttonTheme: MetroButtonThemeData.lerp(a.buttonTheme, b.buttonTheme, t),
      dataGridTheme: MetroDataGridThemeData.lerp(
        a.dataGridTheme,
        b.dataGridTheme,
        t,
      ),
      tileTheme: MetroTileThemeData.lerp(a.tileTheme, b.tileTheme, t),
      progressRingTheme: MetroProgressRingThemeData.lerp(
        a.progressRingTheme,
        b.progressRingTheme,
        t,
      ),
      progressBarTheme: MetroProgressBarThemeData.lerp(
        a.progressBarTheme,
        b.progressBarTheme,
        t,
      ),
      comboBoxTheme: MetroComboBoxThemeData.lerp(
        a.comboBoxTheme,
        b.comboBoxTheme,
        t,
      ),
      numberBoxTheme: MetroNumberBoxThemeData.lerp(
        a.numberBoxTheme,
        b.numberBoxTheme,
        t,
      ),
      searchBoxTheme: MetroSearchBoxThemeData.lerp(
        a.searchBoxTheme,
        b.searchBoxTheme,
        t,
      ),
      textFieldTheme: MetroTextFieldThemeData.lerp(
        a.textFieldTheme,
        b.textFieldTheme,
        t,
      ),
      sliderTheme: MetroSliderThemeData.lerp(a.sliderTheme, b.sliderTheme, t),
      listTileTheme: MetroListTileThemeData.lerp(
        a.listTileTheme,
        b.listTileTheme,
        t,
      ),
      commandBarTheme: MetroCommandBarThemeData.lerp(
        a.commandBarTheme,
        b.commandBarTheme,
        t,
      ),
      flipViewTheme: MetroFlipViewThemeData.lerp(
        a.flipViewTheme,
        b.flipViewTheme,
        t,
      ),
      pivotTheme: MetroPivotThemeData.lerp(a.pivotTheme, b.pivotTheme, t),
      dialogTheme: MetroDialogThemeData.lerp(a.dialogTheme, b.dialogTheme, t),
      flyoutTheme: MetroFlyoutThemeData.lerp(a.flyoutTheme, b.flyoutTheme, t),
      tooltipTheme: MetroTooltipThemeData.lerp(
        a.tooltipTheme,
        b.tooltipTheme,
        t,
      ),
      pickerTheme: MetroPickerThemeData.lerp(a.pickerTheme, b.pickerTheme, t),
      checkBoxTheme: MetroCheckBoxThemeData.lerp(
        a.checkBoxTheme,
        b.checkBoxTheme,
        t,
      ),
      radioButtonTheme: MetroRadioButtonThemeData.lerp(
        a.radioButtonTheme,
        b.radioButtonTheme,
        t,
      ),
      toggleSwitchTheme: MetroToggleSwitchThemeData.lerp(
        a.toggleSwitchTheme,
        b.toggleSwitchTheme,
        t,
      ),
    );
  }
}
