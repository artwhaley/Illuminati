import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/show_provider.dart';
import '../services/import/csv_field_definitions.dart';
import '../services/import/csv_import_parser.dart';
import '../services/import/lightwright_column_detector.dart';
import 'import/column_mapping_screen.dart';
import 'show_tab.dart';
import 'spreadsheet/spreadsheet_tab.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  static const _tabs = [
    NavigationDestination(
      icon: Icon(Icons.info_outline),
      selectedIcon: Icon(Icons.info),
      label: 'Show',
    ),
    NavigationDestination(
      icon: Icon(Icons.table_chart_outlined),
      selectedIcon: Icon(Icons.table_chart),
      label: 'Spreadsheet',
    ),
    NavigationDestination(
      icon: Icon(Icons.sticky_note_2_outlined),
      selectedIcon: Icon(Icons.sticky_note_2),
      label: 'Work Notes',
    ),
    NavigationDestination(
      icon: Icon(Icons.build_outlined),
      selectedIcon: Icon(Icons.build),
      label: 'Maintenance',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Reports',
    ),
  ];

  void _closeShow() async {
    final db = ref.read(databaseProvider);
    await db?.close();
    if (mounted) ref.read(databaseProvider.notifier).state = null;
  }

  Future<void> _importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select CSV File',
      allowedExtensions: ['csv', 'txt'],
      type: FileType.custom,
      lockParentWindow: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final path = result.files.single.path!;
    const parser = CsvImportParser();
    final headers = await parser.readHeaders(path);

    if (!mounted) return;
    if (headers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read CSV headers.')),
      );
      return;
    }

    final autoMapping = LightwrightColumnDetector().detectColumns(headers);
    final initialMapping = {
      for (final f in PaperTekImportField.values) f: autoMapping[f],
    };

    await showDialog<void>(
      context: context,
      builder: (_) => ColumnMappingScreen(
        csvPath: path,
        headers: headers,
        initialMapping: initialMapping,
        importServiceProvider: importServiceProvider,
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'PaperTek',
      applicationVersion: '0.1.0',
      applicationLegalese: '© 2026',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuBg = theme.colorScheme.surface;
    final menuFg = theme.colorScheme.onSurface;

    return Scaffold(
      body: Column(
        children: [
          // ── Menu bar — left-anchored, full width ──────────────────────
          ColoredBox(
            color: menuBg,
            child: Row(
              children: [
                MenuBar(
                  style: MenuStyle(
                    backgroundColor: WidgetStatePropertyAll(menuBg),
                    elevation: const WidgetStatePropertyAll(0),
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 2, vertical: 2)),
                  ),
                  children: [
                    _menu('File', [
                      _item('Close Show', Icons.close, _closeShow),
                      const Divider(height: 1),
                      _item('Exit', Icons.exit_to_app, () => exit(0)),
                    ], menuFg),
                    _menu('Edit', [
                      _item('Undo', Icons.undo, null),
                      _item('Redo', Icons.redo, null),
                    ], menuFg),
                    _menu('Operations', [
                      _item('Import Fixtures from CSV', Icons.upload_file,
                          _importCsv),
                    ], menuFg),
                    _menu('Help', [
                      _item('About PaperTek', Icons.info_outline, _showAbout),
                    ], menuFg),
                  ],
                ),
                // Fill the rest of the bar with the background color
                const Spacer(),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Tab body ──────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                const ShowTab(),
                const SpreadsheetTab(),
                _stub('Work Notes'),
                _stub('Maintenance'),
                _stub('Reports'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: _tabs,
      ),
    );
  }

  Widget _menu(
      String label, List<Widget> children, Color foreground) {
    return SubmenuButton(
      menuChildren: children,
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(foreground),
      ),
      child: Text(label),
    );
  }

  Widget _item(String label, IconData icon, VoidCallback? onPressed) {
    return MenuItemButton(
      leadingIcon: Icon(icon, size: 16),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _stub(String label) => Center(
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      );
}
