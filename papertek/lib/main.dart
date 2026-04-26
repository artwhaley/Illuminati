import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/show_provider.dart';
import 'ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    minimumSize: Size(1024, 700),
    title: 'PaperTek',
    titleBarStyle: TitleBarStyle.normal,
    backgroundColor: Color(0xFF0B0D11),
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final container = ProviderContainer();
  windowManager.addListener(_AppWindowListener(container));
  await windowManager.setPreventClose(true);

  runApp(UncontrolledProviderScope(
    container: container,
    child: const PaperTekApp(),
  ));
}

class _AppWindowListener extends WindowListener {
  _AppWindowListener(this._container);

  final ProviderContainer _container;

  @override
  void onWindowClose() async {
    final db = _container.read(databaseProvider);
    await db?.close();
    await windowManager.destroy();
  }
}
