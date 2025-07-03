import 'dart:io';

void main(List<String> args) async {
  final pubspec = File('pubspec.yaml');

  if (!pubspec.existsSync()) {
    print('❌ 找不到 pubspec.yaml');
    exit(1);
  }

  final lines = await pubspec.readAsLines();

  final versionLineIndex = lines.indexWhere(
    (line) => line.trim().startsWith('version: '),
  );
  if (versionLineIndex == -1) {
    print('❌ 没找到 version: 行');
    exit(1);
  }

  final versionLine = lines[versionLineIndex].trim();
  final regex = RegExp(r'version:\s*([\d]+)\.([\d]+)\.([\d]+)\+(\d+)');
  final match = regex.firstMatch(versionLine);

  if (match == null) {
    print('❌ version 格式不对，应该是 version: x.y.z+N');
    exit(1);
  }

  int major = int.parse(match.group(1)!);
  int minor = int.parse(match.group(2)!);
  int patch = int.parse(match.group(3)!);
  int build = int.parse(match.group(4)!);

  if (args.contains('--major')) {
    major += 1;
    minor = 0;
    patch = 0;
    build = 1;
    print('🔼 Bump major ➜ $major.0.0+1');
  } else if (args.contains('--minor')) {
    minor += 1;
    patch = 0;
    build = 1;
    print('🔼 Bump minor ➜ $major.$minor.0+1');
  } else if (args.contains('--patch')) {
    patch += 1;
    build = 1;
    print('🔼 Bump patch ➜ $major.$minor.$patch+1');
  } else {
    build += 1;
    print('🔼 Bump build ➜ $major.$minor.$patch+$build');
  }

  final newVersionLine = 'version: $major.$minor.$patch+$build';
  lines[versionLineIndex] = newVersionLine;

  await pubspec.writeAsString(lines.join('\n'));
  print('✅ 已更新: $newVersionLine');
}
