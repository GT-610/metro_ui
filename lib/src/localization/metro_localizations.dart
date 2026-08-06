import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Localized defaults used by Metro UI controls.
///
/// Applications can register [delegate] or provide their own
/// `LocalizationsDelegate<MetroLocalizations>`. Controls fall back to English
/// when no Metro localization delegate is present.
abstract class MetroLocalizations {
  const MetroLocalizations();

  static const LocalizationsDelegate<MetroLocalizations> delegate =
      _MetroLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  static MetroLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<MetroLocalizations>(context, MetroLocalizations);
  }

  static MetroLocalizations of(BuildContext context) {
    return maybeOf(context) ?? const MetroLocalizationsEn();
  }

  String get localeName;
  String get selectDateTitle;
  String get selectTimeTitle;
  String get monthLabel;
  String get dayLabel;
  String get yearLabel;
  String get hourLabel;
  String get minuteLabel;
  String get periodLabel;
  String get confirmLabel;
  String get cancelLabel;
  String get anteMeridiemLabel;
  String get postMeridiemLabel;
  String get datePickerLabel;
  String get timePickerLabel;
  String get sortAscendingLabel;
  String get sortDescendingLabel;

  /// Default accessible label for a navigation back button.
  String get backButtonLabel => 'Back';

  /// Default accessible label for submitting a search query.
  String get searchBoxSearchLabel => 'Search';

  /// Default accessible label for clearing a search query.
  String get searchBoxClearLabel => 'Clear search';

  /// Default message when no search suggestions match the query.
  String get searchBoxNoResultsLabel => 'No suggestions';

  /// Default accessible label for increasing a number-box value.
  String get numberBoxIncrementLabel => 'Increase value';

  /// Default accessible label for decreasing a number-box value.
  String get numberBoxDecrementLabel => 'Decrease value';

  /// Default accessible value for an empty number box.
  String get numberBoxEmptyValueLabel => 'No value';

  /// Default accessible label for moving to the previous FlipView item.
  String get flipViewPreviousLabel => 'Previous item';

  /// Default accessible label for moving to the next FlipView item.
  String get flipViewNextLabel => 'Next item';

  /// Default accessible label for a semantic zoom container.
  String get semanticZoomLabel => 'Semantic zoom';

  /// Accessible value for the detailed semantic zoom view.
  String get semanticZoomedInLabel => 'Detailed view';

  /// Accessible value for the summarized semantic zoom view.
  String get semanticZoomedOutLabel => 'Summary view';

  String datePickerSemanticLabel(Iterable<String> values);
  String timePickerSemanticLabel(Iterable<String> values);
  String formatPercentage(double value);

  /// Formats the one-based current FlipView position and total item count.
  String flipViewItemPosition(int index, int count) {
    return 'Item $index of $count';
  }
}

/// Built-in English defaults for Metro controls.
class MetroLocalizationsEn extends MetroLocalizations {
  const MetroLocalizationsEn();

  @override
  String get localeName => 'en';
  @override
  String get selectDateTitle => 'SELECT DATE';
  @override
  String get selectTimeTitle => 'SELECT TIME';
  @override
  String get monthLabel => 'Month';
  @override
  String get dayLabel => 'Day';
  @override
  String get yearLabel => 'Year';
  @override
  String get hourLabel => 'Hour';
  @override
  String get minuteLabel => 'Minute';
  @override
  String get periodLabel => 'Period';
  @override
  String get confirmLabel => 'DONE';
  @override
  String get cancelLabel => 'CANCEL';
  @override
  String get anteMeridiemLabel => 'AM';
  @override
  String get postMeridiemLabel => 'PM';
  @override
  String get datePickerLabel => 'Date picker';
  @override
  String get timePickerLabel => 'Time picker';
  @override
  String get sortAscendingLabel => 'Ascending';
  @override
  String get sortDescendingLabel => 'Descending';

  @override
  String datePickerSemanticLabel(Iterable<String> values) {
    final parts = values.toList();
    return parts.isEmpty
        ? datePickerLabel
        : '$datePickerLabel, ${parts.join(', ')}';
  }

  @override
  String timePickerSemanticLabel(Iterable<String> values) {
    final parts = values.toList();
    return parts.isEmpty
        ? timePickerLabel
        : '$timePickerLabel, ${parts.join(', ')}';
  }

  @override
  String formatPercentage(double value) => '${(value * 100).round()}%';
}

/// Built-in Simplified Chinese defaults for Metro controls.
class MetroLocalizationsZh extends MetroLocalizations {
  const MetroLocalizationsZh();

  @override
  String get localeName => 'zh';
  @override
  String get searchBoxSearchLabel => '\u641c\u7d22';
  @override
  String get searchBoxClearLabel => '\u6e05\u9664\u641c\u7d22';
  @override
  String get searchBoxNoResultsLabel => '\u6ca1\u6709\u5efa\u8bae';
  @override
  String get numberBoxIncrementLabel => '\u589e\u52a0\u6570\u503c';
  @override
  String get numberBoxDecrementLabel => '\u51cf\u5c11\u6570\u503c';
  @override
  String get numberBoxEmptyValueLabel => '\u65e0\u6570\u503c';
  @override
  String get flipViewPreviousLabel => '\u4e0a\u4e00\u9879';
  @override
  String get flipViewNextLabel => '\u4e0b\u4e00\u9879';
  @override
  String get semanticZoomLabel => '\u8bed\u4e49\u7f29\u653e';
  @override
  String get semanticZoomedInLabel => '\u8be6\u7ec6\u89c6\u56fe';
  @override
  String get semanticZoomedOutLabel => '\u6458\u8981\u89c6\u56fe';
  @override
  String get backButtonLabel => '\u8fd4\u56de';

  @override
  String flipViewItemPosition(int index, int count) {
    return '\u7b2c $index \u9879\uff0c\u5171 $count \u9879';
  }

  @override
  String get selectDateTitle => '选择日期';
  @override
  String get selectTimeTitle => '选择时间';
  @override
  String get monthLabel => '月';
  @override
  String get dayLabel => '日';
  @override
  String get yearLabel => '年';
  @override
  String get hourLabel => '时';
  @override
  String get minuteLabel => '分';
  @override
  String get periodLabel => '时段';
  @override
  String get confirmLabel => '完成';
  @override
  String get cancelLabel => '取消';
  @override
  String get anteMeridiemLabel => '上午';
  @override
  String get postMeridiemLabel => '下午';
  @override
  String get datePickerLabel => '日期选择器';
  @override
  String get timePickerLabel => '时间选择器';
  @override
  String get sortAscendingLabel => '升序';
  @override
  String get sortDescendingLabel => '降序';

  @override
  String datePickerSemanticLabel(Iterable<String> values) {
    final parts = values.toList();
    return parts.isEmpty
        ? datePickerLabel
        : '$datePickerLabel，${parts.join('，')}';
  }

  @override
  String timePickerSemanticLabel(Iterable<String> values) {
    final parts = values.toList();
    return parts.isEmpty
        ? timePickerLabel
        : '$timePickerLabel，${parts.join('，')}';
  }

  @override
  String formatPercentage(double value) => '${(value * 100).round()}%';
}

class _MetroLocalizationsDelegate
    extends LocalizationsDelegate<MetroLocalizations> {
  const _MetroLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return const <String>{'en', 'zh'}.contains(locale.languageCode);
  }

  @override
  Future<MetroLocalizations> load(Locale locale) {
    return SynchronousFuture<MetroLocalizations>(
      locale.languageCode == 'zh'
          ? const MetroLocalizationsZh()
          : const MetroLocalizationsEn(),
    );
  }

  @override
  bool shouldReload(_MetroLocalizationsDelegate old) => false;
}
