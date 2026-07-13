import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'udp_settings.dart';

abstract interface class UdpSettingsStore {
  Future<UdpSettings?> load();
  Future<void> save(UdpSettings settings);
}

final class FileUdpSettingsStore implements UdpSettingsStore {
  FileUdpSettingsStore({File? file}) : _file = file;

  final File? _file;

  Future<File> _settingsFile() async {
    final file = _file;
    if (file != null) return file;
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}${Platform.pathSeparator}settings.json');
  }

  @override
  Future<UdpSettings?> load() async {
    final file = await _settingsFile();
    if (!await file.exists()) return null;
    try {
      final data = jsonDecode(await file.readAsString());
      if (data is! Map) return null;
      return UdpSettings.fromJson(Map<String, dynamic>.from(data));
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(UdpSettings settings) async {
    if (!settings.isValid) throw const FormatException('Invalid UDP settings.');
    final file = await _settingsFile();
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(settings.toJson()), flush: true);
    if (await file.exists()) await file.delete();
    await temporary.rename(file.path);
  }
}
