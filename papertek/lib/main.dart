import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/show_provider.dart';
import 'providers/theme_provider.dart';
import 'services/backup_settings.dart';
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
  // Initialize theme settings from storage before starting the app.
  await container.read(themeProvider.notifier).initialize();
  await container.read(backupSettingsProvider.notifier).initialize();

  windowManager.addListener(_AppWindowListener(container));
  await windowManager.setPreventClose(true);

  runApp(
    UncontrolledProviderScope(container: container, child: const PaperTekApp()),
  );
}

class _AppWindowListener extends WindowListener {
  _AppWindowListener(this._container);

  final ProviderContainer _container;

  @override
  void onWindowClose() async {
    if (_closing) return;
    _closing = true;
    try {
      await _container.read(showSessionProvider.notifier).shutdown();
    } finally {
      await windowManager.setPreventClose(false);
      _container.dispose();
      await windowManager.destroy();
    }
  }
}

bool _closing = false;
