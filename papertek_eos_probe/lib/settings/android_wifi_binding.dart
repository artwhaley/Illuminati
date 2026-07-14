import 'dart:io';

import 'package:flutter/services.dart';

final class AndroidWifiBinding {
  const AndroidWifiBinding._();

  static const MethodChannel _channel =
      MethodChannel('papertek_eos_probe/network');

  static Future<String?> ensureBound() async {
    if (!Platform.isAndroid) return null;
    final result = await _channel.invokeMapMethod<String, dynamic>('bindWifi');
    final detail = result?['detail'];
    final addresses = (result?['addresses'] as List<Object?>?)
        ?.whereType<String>()
        .join(', ');
    if (addresses == null || addresses.isEmpty) return '$detail.';
    return '$detail ($addresses).';
  }
}
