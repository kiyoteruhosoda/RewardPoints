import 'dart:async';
import 'dart:convert';
import 'dart:io';

sealed class CommandResult {
  const CommandResult();

  bool get isSuccess;
}

final class CommandSuccess extends CommandResult {
  const CommandSuccess(this.stdoutText, this.stderrText);

  final String stdoutText;
  final String stderrText;

  @override
  bool get isSuccess => true;
}

final class CommandFailure extends CommandResult {
  const CommandFailure(this.exitCode, this.stdoutText, this.stderrText);

  final int exitCode;
  final String stdoutText;
  final String stderrText;

  @override
  bool get isSuccess => false;
}

abstract interface class CommandRunner {
  Future<CommandResult> run(List<String> command);
}

final class ProcessCommandRunner implements CommandRunner {
  const ProcessCommandRunner();

  @override
  Future<CommandResult> run(List<String> command) async {
    final processResult = await Process.run(
      command.first,
      command.skip(1).toList(growable: false),
      runInShell: false,
    );

    final stdoutText = (processResult.stdout as Object?)?.toString() ?? '';
    final stderrText = (processResult.stderr as Object?)?.toString() ?? '';

    if (processResult.exitCode == 0) {
      return CommandSuccess(stdoutText.trim(), stderrText.trim());
    }

    return CommandFailure(processResult.exitCode, stdoutText.trim(), stderrText.trim());
  }
}

final class AndroidPackage {
  const AndroidPackage(this.id, {required this.role});

  final String id;
  final String role;
}

final class InstallSession {
  const InstallSession(this.id, this.rawLine);

  final int id;
  final String rawLine;
}

abstract interface class InstallRecoveryPort {
  Future<bool> canUseAdb();

  Future<List<String>> connectedDevices();

  Future<CommandResult> uninstall(AndroidPackage package);

  Future<List<InstallSession>> listSessions();

  Future<CommandResult> abandonSession(InstallSession session);
}

final class AdbInstallRecoveryAdapter implements InstallRecoveryPort {
  const AdbInstallRecoveryAdapter(this._runner);

  final CommandRunner _runner;

  @override
  Future<bool> canUseAdb() async {
    final result = await _runner.run(const ['adb', 'version']);
    return result.isSuccess;
  }

  @override
  Future<List<String>> connectedDevices() async {
    final result = await _runner.run(const ['adb', 'devices']);
    if (result case final CommandSuccess success) {
      return LineSplitter.split(success.stdoutText)
          .skip(1)
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && line.endsWith('\tdevice'))
          .map((line) => line.split('\t').first)
          .toList(growable: false);
    }
    return const [];
  }

  @override
  Future<CommandResult> uninstall(AndroidPackage package) {
    return _runner.run(['adb', 'uninstall', package.id]);
  }

  @override
  Future<List<InstallSession>> listSessions() async {
    final result = await _runner.run(const ['adb', 'shell', 'pm', 'list', 'install-sessions']);
    if (result case final CommandSuccess success) {
      final sessions = <InstallSession>[];
      final regex = RegExp(r'sessionId=(\d+)');
      for (final line in LineSplitter.split(success.stdoutText)) {
        final match = regex.firstMatch(line);
        if (match == null) {
          continue;
        }
        final id = int.tryParse(match.group(1) ?? '');
        if (id != null) {
          sessions.add(InstallSession(id, line.trim()));
        }
      }
      return sessions;
    }
    return const [];
  }

  @override
  Future<CommandResult> abandonSession(InstallSession session) {
    return _runner.run(['adb', 'shell', 'pm', 'install-abandon', '${session.id}']);
  }
}

final class InstallRecoveryService {
  const InstallRecoveryService(this._port);

  final InstallRecoveryPort _port;

  static const _targetPackages = [
    AndroidPackage('com.nolumia.rewardpoints', role: 'release'),
    AndroidPackage('com.nolumia.rewardpoints.debug', role: 'debug'),
  ];

  Future<int> execute() async {
    if (!await _port.canUseAdb()) {
      stderr.writeln('❌ adb が見つかりません。Android SDK Platform Tools をインストールしてください。');
      return 1;
    }

    final devices = await _port.connectedDevices();
    if (devices.isEmpty) {
      stderr.writeln('❌ 接続中デバイスがありません。USB デバッグか emulator 起動を確認してください。');
      return 1;
    }

    stdout.writeln('🔎 接続デバイス: ${devices.join(', ')}');
    stdout.writeln('🧹 パッケージ削除を実行します...');

    for (final package in _targetPackages) {
      final result = await _port.uninstall(package);
      switch (result) {
        case CommandSuccess(:final stdoutText):
          final message = stdoutText.isEmpty ? 'ok' : stdoutText;
          stdout.writeln('  • ${package.id} (${package.role}): $message');
        case CommandFailure(:final stdoutText, :final stderrText):
          final message = [stdoutText, stderrText]
              .where((part) => part.isNotEmpty)
              .join(' | ');
          final normalized = message.toLowerCase();
          if (normalized.contains('unknown package') ||
              normalized.contains('not installed')) {
            stdout.writeln('  • ${package.id} (${package.role}): 既に未インストールです');
          } else {
            stderr.writeln('  • ${package.id} (${package.role}): $message');
          }
      }
    }

    stdout.writeln('🧹 未完了 install session を確認します...');
    final sessions = await _port.listSessions();
    if (sessions.isEmpty) {
      stdout.writeln('  • abandon 対象セッションはありません');
    } else {
      for (final session in sessions) {
        final result = await _port.abandonSession(session);
        if (result.isSuccess) {
          stdout.writeln('  • abandoned session ${session.id}');
        } else {
          stderr.writeln('  • failed session ${session.id}: ${session.rawLine}');
        }
      }
    }

    stdout.writeln('\n✅ 復旧処理が完了しました。');
    stdout.writeln('次の推奨コマンド:');
    stdout.writeln('  flutter clean');
    stdout.writeln('  flutter pub get');
    stdout.writeln('  flutter run');

    return 0;
  }
}

Future<void> main() async {
  final service = InstallRecoveryService(
    const AdbInstallRecoveryAdapter(ProcessCommandRunner()),
  );
  final code = await service.execute();
  exit(code);
}
