import 'dart:collection';
import 'dart:io';

final _exportPattern = RegExp("^export\\s+'([^']+)'");
final _typePattern = RegExp(
  r'^(?:(?:abstract|base|final|sealed)\s+)?'
  r'(?:class|enum|typedef|mixin|extension)\s+'
  r'([A-Za-z][A-Za-z0-9_]*)',
);
final _functionPattern = RegExp(
  r'^[A-Za-z][A-Za-z0-9_<>,? ]*\s+'
  r'([a-z][A-Za-z0-9_]*)\s*(?:<[^>]+>)?\s*\(',
);

void main() {
  final entryPoint = File('lib/metro_ui.dart').absolute;
  final libraryRoot = Directory('lib').absolute.path.toLowerCase();
  final exportedFiles = _collectExportedFiles(entryPoint, libraryRoot);
  final declarations = SplayTreeSet<String>();
  final missingDocumentation = <String>[];

  for (final file in exportedFiles) {
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      final match =
          _typePattern.firstMatch(line) ?? _functionPattern.firstMatch(line);
      if (match == null) continue;
      final name = match.group(1)!;
      if (name.startsWith('_')) continue;

      declarations.add(name);
      if (!_hasDocumentation(lines, index)) {
        final relativePath = file.path
            .substring(Directory.current.absolute.path.length + 1)
            .replaceAll('\\', '/');
        missingDocumentation.add('$relativePath:${index + 1}: $name');
      }
    }
  }

  final manifest = File('tool/public_api_declarations.txt');
  final expected = SplayTreeSet<String>.of(
    manifest
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#')),
  );
  final added = declarations.difference(expected);
  final removed = expected.difference(declarations);

  if (missingDocumentation.isNotEmpty) {
    stderr.writeln('Exported declarations without type-level documentation:');
    for (final declaration in missingDocumentation) {
      stderr.writeln('  $declaration');
    }
  }
  if (added.isNotEmpty) {
    stderr.writeln('Declarations missing from the public API inventory:');
    for (final declaration in added) {
      stderr.writeln('  $declaration');
    }
  }
  if (removed.isNotEmpty) {
    stderr.writeln('Inventory declarations no longer exported:');
    for (final declaration in removed) {
      stderr.writeln('  $declaration');
    }
  }

  if (missingDocumentation.isNotEmpty ||
      added.isNotEmpty ||
      removed.isNotEmpty) {
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Public API check passed: ${declarations.length} documented declarations.',
  );
}

Set<File> _collectExportedFiles(File entryPoint, String libraryRoot) {
  final pending = Queue<File>()..add(entryPoint);
  final filesByPath = <String, File>{};
  while (pending.isNotEmpty) {
    final file = pending.removeFirst().absolute;
    final normalizedPath = file.path.toLowerCase();
    if (filesByPath.containsKey(normalizedPath)) continue;
    filesByPath[normalizedPath] = file;

    for (final line in file.readAsLinesSync()) {
      final match = _exportPattern.firstMatch(line);
      if (match == null) continue;
      final exported = File.fromUri(file.uri.resolve(match.group(1)!)).absolute;
      if (exported.path.toLowerCase().startsWith(libraryRoot)) {
        pending.add(exported);
      }
    }
  }
  return filesByPath.values.toSet();
}

bool _hasDocumentation(List<String> lines, int declarationIndex) {
  var previous = declarationIndex - 1;
  while (previous >= 0) {
    final line = lines[previous].trim();
    if (line.isEmpty || line.startsWith('@')) {
      previous -= 1;
      continue;
    }
    return line.startsWith('///');
  }
  return false;
}
