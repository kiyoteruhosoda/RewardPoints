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
    try {
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
    } on ProcessException catch (error) {
      return CommandFailure(
        -1,
        '',
        'Failed to start `${command.join(' ')}`: ${error.message}',
      );
    }
  }
}

final class DeviceSerial {
  const DeviceSerial(this.value);

  final String value;
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

  Future<List<DeviceSerial>> connectedDevices();

  Future<CommandResult> uninstall({
    required DeviceSerial device,
    required AndroidPackage package,
  });

  Future<CommandResult> listSessions({required DeviceSerial device});

  Future<CommandResult> abandonSession({
    required DeviceSerial device,
    required InstallSession session,
  });
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
  Future<List<DeviceSerial>> connectedDevices() async {
    final result = await _runner.run(const ['adb', 'devices']);
    if (result case final CommandSuccess success) {
      return LineSplitter.split(success.stdoutText)
          .skip(1)
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && line.endsWith('\tdevice'))
          .map((line) => DeviceSerial(line.split('\t').first))
          .toList(growable: false);
    }
    return const [];
  }

  @override
  Future<CommandResult> uninstall({
    required DeviceSerial device,
    required AndroidPackage package,
  }) {
    return _runner.run(['adb', '-s', device.value, 'uninstall', package.id]);
  }

  @override
  Future<CommandResult> listSessions({required DeviceSerial device}) {
    return _runner.run([
      'adb',
      '-s',
      device.value,
      'shell',
      'pm',
      'list',
      'install-sessions',
    ]);
  }

  @override
  Future<CommandResult> abandonSession({
    required DeviceSerial device,
    required InstallSession session,
  }) {
    return _runner.run([
      'adb',
      '-s',
      device.value,
      'shell',
      'pm',
      'install-abandon',
      '${session.id}',
    ]);
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

    final targetDevice = _resolveTargetDevice(devices);
    if (targetDevice == null) {
      return 1;
    }

    stdout.writeln('🔎 対象デバイス: ${targetDevice.value}');
    stdout.writeln('🧹 パッケージ削除を実行します...');

    var hasNonIgnorableFailure = false;

    for (final package in _targetPackages) {
      final result = await _port.uninstall(device: targetDevice, package: package);
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
            hasNonIgnorableFailure = true;
            stderr.writeln('  • ${package.id} (${package.role}): $message');
          }
      }
    }

    stdout.writeln('🧹 未完了 install session を確認します...');
    final sessionsResult = await _port.listSessions(device: targetDevice);
    switch (sessionsResult) {
      case CommandSuccess(:final stdoutText):
        final sessions = _parseSessions(stdoutText);
        if (sessions.isEmpty) {
          stdout.writeln('  • abandon 対象セッションはありません');
        } else {
          for (final session in sessions) {
            final result = await _port.abandonSession(
              device: targetDevice,
              session: session,
            );
            if (result.isSuccess) {
              stdout.writeln('  • abandoned session ${session.id}');
            } else {
              hasNonIgnorableFailure = true;
              stderr.writeln('  • failed session ${session.id}: ${session.rawLine}');
            }
          }
        }
      case CommandFailure(:final stdoutText, :final stderrText):
        hasNonIgnorableFailure = true;
        final message = [stdoutText, stderrText]
            .where((part) => part.isNotEmpty)
            .join(' | ');
        stderr.writeln('  • install session 一覧取得に失敗: $message');
    }

    if (hasNonIgnorableFailure) {
      stderr.writeln('\n⚠️ 一部の復旧処理が失敗しました。ログを確認して再実行してください。');
      return 2;
    }

    stdout.writeln('\n✅ 復旧処理が完了しました。');
    stdout.writeln('次の推奨コマンド:');
    stdout.writeln('  flutter clean');
    stdout.writeln('  flutter pub get');
    stdout.writeln('  flutter run');

    return 0;
  }

  DeviceSerial? _resolveTargetDevice(List<DeviceSerial> devices) {
    if (devices.length == 1) {
      return devices.single;
    }

    final preferredSerial = Platform.environment['ANDROID_SERIAL'];
    if (preferredSerial == null || preferredSerial.trim().isEmpty) {
      stderr.writeln('❌ 複数デバイス接続中です。`ANDROID_SERIAL` を指定してください。');
      stderr.writeln('接続デバイス: ${devices.map((d) => d.value).join(', ')}');
      return null;
    }

    final matched = devices.where((device) => device.value == preferredSerial).toList();
    if (matched.isEmpty) {
      stderr.writeln('❌ ANDROID_SERIAL=$preferredSerial は接続デバイスに存在しません。');
      stderr.writeln('接続デバイス: ${devices.map((d) => d.value).join(', ')}');
      return null;
    }

    return matched.single;
  }

  List<InstallSession> _parseSessions(String stdoutText) {
    final sessions = <InstallSession>[];
    final regex = RegExp(r'sessionId=(\d+)');
    for (final line in LineSplitter.split(stdoutText)) {
      final match = regex.firstMatch(line);
      if (match == null) {
        continue;
      }
      final id = int.tryParse(match.group(1) ?? '');
      if (id == null) {
        continue;
      }
      sessions.add(InstallSession(id, line.trim()));
    }
    return sessions;
  }
}

Future<void> main() async {
  final service = InstallRecoveryService(
    const AdbInstallRecoveryAdapter(ProcessCommandRunner()),
  );
  final code = await service.execute();
  exit(code);
}
