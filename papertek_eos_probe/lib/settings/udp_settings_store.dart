import 'dart:convert';
import 'dart:io';

import 'udp_settings.dart';

abstract interface class UdpSettingsStore {
  Future<UdpSettings?> load();
  Future<void> save(UdpSettings settings);
}

final class FileUdpSettingsStore implements UdpSettingsStore {
  FileUdpSettingsStore({File? file}) : _file = file ?? _defaultFile();

  final File _file;

  @override
  Future<UdpSettings?> load() async {
    if (!await _file.exists()) return null;
    try {
      final data = jsonDecode(await _file.readAsString());
      if (data is! Map) return null;
      return UdpSettings.fromJson(Map<String, dynamic>.from(data));
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(UdpSettings settings) async {
    if (!settings.isValid) throw const FormatException('Invalid UDP settings.');
    await _file.parent.create(recursive: true);
    final temporary = File('${_file.path}.tmp');
    await temporary.writeAsString(jsonEncode(settings.toJson()), flush: true);
    if (await _file.exists()) await _file.delete();
    await temporary.rename(_file.path);
  }

  static File _defaultFile() {
    final base = Platform.environment['APPDATA'] ?? Directory.current.path;
    return File('$base${Platform.pathSeparator}PaperTekEosProbe'
        '${Platform.pathSeparator}settings.json');
  }
}
