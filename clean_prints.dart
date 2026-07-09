// ignore_for_file: avoid_print
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart clean_prints.dart path/to/file.dart');
    return;
  }

  final filePath = args[0];
  final file = File(filePath);

  if (!file.existsSync()) {
    print('❌ File not found: $filePath');
    return;
  }

  final content = file.readAsStringSync();

  // Regex to remove all print(...) statements (including inline and with spaces)
  final cleaned = content.replaceAll(RegExp(r'^\s*print\(.*?\);\s*$', multiLine: true), '');

  file.writeAsStringSync(cleaned);

  print('✅ Removed all print() statements from $filePath');
}
