import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:papertek_eos_probe/settings/udp_settings.dart';
import 'package:papertek_eos_probe/settings/udp_settings_store.dart';

void main() {
  test('new settings default to the proven console UDP endpoint', () {
    const settings = UdpSettings();
    expect(settings.host, '10.101.50.100');
    expect(settings.consoleRxPort, 8000);
    expect(settings.feedbackRxPort, 8001);
  });

  test('legacy settings migrate a missing feedback port to 8001', () {
    final settings = UdpSettings.fromJson(<String, dynamic>{
      'consoleHost': '127.0.0.1',
      'consoleReceivePort': 8000,
      'localAddress': '127.0.0.1',
    });
    expect(settings, isNotNull);
    expect(settings!.feedbackRxPort, 8001);
  });

  test('invalid settings do not replace the last valid cache', () async {
    final directory =
        await Directory.systemTemp.createTemp('papertek-settings-');
    addTearDown(() => directory.delete(recursive: true));
    final file =
        File('${directory.path}${Platform.pathSeparator}settings.json');
    final store = FileUdpSettingsStore(file: file);
    const valid = UdpSettings(host: '127.0.0.1');
    await store.save(valid);
    expect(UdpSettings(host: '', consoleRxPort: 0).isValid, isFalse);
    await expectLater(store.save(const UdpSettings(host: '', consoleRxPort: 0)),
        throwsA(isA<FormatException>()));
    expect(jsonDecode(await file.readAsString())['consoleHost'], '127.0.0.1');
  });
}
