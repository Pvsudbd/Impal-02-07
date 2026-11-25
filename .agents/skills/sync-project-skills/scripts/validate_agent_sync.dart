import 'dart:convert';
import 'dart:io';

/// Validates workspace skills, rules, memory references, and AGENTS.md constraints.
///
/// Run from `Impal-02-07/backend` or `Impal-02-07`:
///   dart run ../.agents/skills/sync-project-skills/scripts/validate_agent_sync.dart
void main() {
  final root = _findProjectRoot();
  if (root == null) {
    stderr.writeln('FAIL: Could not locate Impal-02-07 project root (.agents + AGENTS.md).');
    exit(1);
  }

  final errors = <String>[];

  // 1. Validate every skill directory has SKILL.md with YAML name & description
  final skillsDir = Directory('${root.path}${Platform.pathSeparator}.agents${Platform.pathSeparator}skills');
  if (!skillsDir.existsSync()) {
    errors.add('Missing .agents/skills directory.');
  } else {
    final skillEntries = skillsDir.listSync().whereType<Directory>().toList();
    if (skillEntries.isEmpty) {
      errors.add('No skills found under .agents/skills/.');
    }
    for (final dir in skillEntries) {
      final skillName = dir.uri.pathSegments.where((s) => s.isNotEmpty).last;
      final skillFile = File('${dir.path}${Platform.pathSeparator}SKILL.md');
      if (!skillFile.existsSync()) {
        errors.add('Skill "$skillName" is missing SKILL.md.');
        continue;
      }
      final content = skillFile.readAsStringSync();
      final fmMatch = RegExp(r'^---\r?\n([\s\S]*?)\r?\n---').firstMatch(content);
      if (fmMatch == null) {
        errors.add('Skill "$skillName" SKILL.md is missing YAML frontmatter.');
        continue;
      }
      final fm = fmMatch.group(1)!;
      if (!RegExp(r'^name:\s*\S+', multiLine: true).hasMatch(fm)) {
        errors.add('Skill "$skillName" frontmatter is missing "name".');
      }
      if (!RegExp(r'^description:\s*\S+', multiLine: true).hasMatch(fm)) {
        errors.add('Skill "$skillName" frontmatter is missing "description".');
      }
    }
  }

  // 2. Validate every .md rule in .agents/rules/ (except README.md) is registered in README.md
  final rulesDir = Directory('${root.path}${Platform.pathSeparator}.agents${Platform.pathSeparator}rules');
  final rulesReadme = File('${rulesDir.path}${Platform.pathSeparator}README.md');
  if (!rulesReadme.existsSync()) {
    errors.add('Missing .agents/rules/README.md.');
  } else {
    final readmeText = rulesReadme.readAsStringSync();
    for (final entity in rulesDir.listSync().whereType<File>()) {
      final fileName = entity.uri.pathSegments.last;
      if (fileName.endsWith('.md') && fileName != 'README.md' && fileName != 'Agents.md') {
        if (!readmeText.contains(fileName)) {
          errors.add('Rule "$fileName" is not registered in .agents/rules/README.md.');
        }
      }
    }
  }

  // 3. Check AGENTS.md size <= 24,000 bytes
  final agentsMd = File('${root.path}${Platform.pathSeparator}AGENTS.md');
  if (!agentsMd.existsSync()) {
    errors.add('Missing AGENTS.md at project root.');
  } else {
    final byteLen = utf8.encode(agentsMd.readAsStringSync()).length;
    if (byteLen > 24000) {
      errors.add('AGENTS.md exceeds 24,000-byte limit ($byteLen bytes).');
    } else {
      stdout.writeln('OK: AGENTS.md size = $byteLen / 24000 bytes.');
    }
  }

  // 4. Check no stale HRD tokens or hardcoded machine paths in target governance docs
  final hrdTokens = ['/api/v1/employees', '/api/v1/leaves', 'DEV_2_ROYUL', 'DEV_3_LEAVES'];
  final hrdCheckFiles = [
    'AGENTS.md',
    '.agents/rules/backend_dart_frog_rules.md',
  ];
  for (final rel in hrdCheckFiles) {
    final f = File('${root.path}${Platform.pathSeparator}${rel.replaceAll('/', Platform.pathSeparator)}');
    if (!f.existsSync()) {
      errors.add('Missing expected file: $rel');
      continue;
    }
    final text = f.readAsStringSync();
    for (final token in hrdTokens) {
      if (text.contains(token)) {
        errors.add('Stale HRD token "$token" found in $rel.');
      }
    }
  }

  final machinePaths = ['D:\\Telkom University', 'D:/Telkom University', 'C:\\Telkom', 'C:/Telkom'];
  final pathCheckFiles = [
    'AGENTS.md',
    '.agents/rules/Agents.md',
    '.agents/rules/README.md',
    '.agents/rules/backend_dart_frog_rules.md',
  ];
  for (final rel in pathCheckFiles) {
    final f = File('${root.path}${Platform.pathSeparator}${rel.replaceAll('/', Platform.pathSeparator)}');
    if (!f.existsSync()) continue;
    final text = f.readAsStringSync();
    for (final p in machinePaths) {
      if (text.contains(p)) {
        errors.add('Hardcoded personal machine path "$p" found in $rel.');
      }
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('FAIL: Agent sync validation failed (${errors.length} issue(s)):');
    for (final err in errors) {
      stderr.writeln('  - $err');
    }
    exit(1);
  }

  stdout.writeln('PASS: All workspace skills, rules, and governance files are synchronized.');
}

Directory? _findProjectRoot() {
  var dir = Directory.current.absolute;
  for (var i = 0; i < 6; i++) {
    final agents = File('${dir.path}${Platform.pathSeparator}AGENTS.md');
    final dotAgents = Directory('${dir.path}${Platform.pathSeparator}.agents');
    if (agents.existsSync() && dotAgents.existsSync()) {
      return dir;
    }
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  return null;
}
