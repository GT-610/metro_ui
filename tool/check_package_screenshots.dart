import 'dart:io';

/// Package screenshots paired with the Golden baseline each one is a copy of.
///
/// The preview surfaces are rendered by the tagged Golden suite, and a package
/// screenshot is only allowed to be a byte copy of the baseline that suite
/// compared. That keeps the README and the pub.dev gallery from drifting away
/// from what the tests actually assert.
const _screenshotSources = <String, String>{
  'screenshots/preview_controls_light.png':
      'test/goldens/baselines/preview_controls_light.png',
  'screenshots/preview_navigation_dark.png':
      'test/goldens/baselines/preview_navigation_dark.png',
  'screenshots/preview_lists_light.png':
      'test/goldens/baselines/preview_lists_light.png',
  'screenshots/preview_inputs_light.png':
      'test/goldens/baselines/preview_inputs_light.png',
};

void main(List<String> arguments) {
  final unexpectedArguments = arguments.where(
    (argument) => argument != '--update',
  );
  if (unexpectedArguments.isNotEmpty) {
    stderr.writeln(
      'Usage: dart run tool/check_package_screenshots.dart [--update]',
    );
    exitCode = 64;
    return;
  }

  final update = arguments.contains('--update');
  final failures = <String>[];

  for (final entry in _screenshotSources.entries) {
    final screenshot = File(entry.key);
    final golden = File(entry.value);
    if (!golden.existsSync()) {
      failures.add('Missing Golden baseline: ${golden.path}');
      continue;
    }

    if (update) {
      screenshot.parent.createSync(recursive: true);
      golden.copySync(screenshot.path);
      stdout.writeln('Updated ${screenshot.path} from ${golden.path}.');
      continue;
    }

    if (!screenshot.existsSync()) {
      failures.add('Missing package screenshot: ${screenshot.path}');
      continue;
    }

    if (!_filesMatch(golden, screenshot)) {
      failures.add(
        '${screenshot.path} does not match its tested Golden '
        '${golden.path}.',
      );
    }
  }

  if (failures.isNotEmpty) {
    for (final failure in failures) {
      stderr.writeln(failure);
    }
    stderr.writeln(
      'After reviewing the Golden changes, run this tool with --update.',
    );
    exitCode = 1;
    return;
  }

  if (!update) {
    stdout.writeln(
      'Package screenshot check passed: ${_screenshotSources.length} '
      'previews match tested Golden baselines.',
    );
  }
}

bool _filesMatch(File first, File second) {
  final firstBytes = first.readAsBytesSync();
  final secondBytes = second.readAsBytesSync();
  if (firstBytes.length != secondBytes.length) return false;

  for (var index = 0; index < firstBytes.length; index += 1) {
    if (firstBytes[index] != secondBytes[index]) return false;
  }
  return true;
}
