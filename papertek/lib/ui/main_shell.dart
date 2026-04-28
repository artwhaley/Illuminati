import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/tracked_write_repository.dart';
import '../providers/show_provider.dart';
import '../services/import/csv_field_definitions.dart';
import '../services/import/csv_import_parser.dart';
import '../services/import/lightwright_column_detector.dart';
import 'import/column_mapping_screen.dart';
import 'show_tab.dart';
import 'spreadsheet/spreadsheet_tab.dart';
import 'maintenance/maintenance_tab.dart';
import '../services/commit_service.dart';

// ── Designer mode toggle widget ───────────────────────────────────────────────

class _DesignerModeToggle extends ConsumerWidget {
  const _DesignerModeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesigner = ref.watch(designerModeProvider);
    final tracked    = ref.watch(trackedWriteProvider);
    final theme      = Theme.of(context);

    // Themed colors: designer = warm amber; tracked = cool teal
    final activeColor   = isDesigner
        ? const Color(0xFFE8A000)   // amber — "you're designing freely"
        : theme.colorScheme.primary;// teal/blue — "changes are tracked"

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _handleToggle(context, ref, tracked, isDesigner),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: activeColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activeColor.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDesigner ? Icons.edit_outlined : Icons.track_changes,
              size: 14,
              color: activeColor,
            ),
            const SizedBox(width: 5),
            Text(
              isDesigner ? 'Designer Mode' : 'Tracked Changes',
              style: theme.textTheme.labelSmall?.copyWith(
                color: activeColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggle(
    BuildContext context,
    WidgetRef ref,
    TrackedWriteRepository? tracked,
    bool currentlyDesigner,
  ) async {
    if (tracked == null) return;

    if (currentlyDesigner) {
      // Switching FROM designer → tracked: just switch.
      await tracked.exitDesignerMode();
      ref.read(designerModeProvider.notifier).state = false;
      return;
    }

    // Switching FROM tracked → designer.
    final hasPending = await tracked.hasPendingRevisions();
    if (!context.mounted) return;

    if (!hasPending) {
      tracked.enterDesignerMode();
      ref.read(designerModeProvider.notifier).state = true;
      return;
    }

    // Pending revisions exist — warn the user.
    final result = await showDialog<_DesignerSwitchResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _DesignerModeSwitchDialog(),
    );
    if (!context.mounted) return;

    switch (result) {
      case _DesignerSwitchResult.commitAndContinue:
        // Auto-approve all pending revisions, then switch.
        final service = ref.read(commitServiceProvider);
        if (service != null) {
          final repo = ref.read(revisionRepoProvider);
          final pending = await repo?.watchAllPending().first;
          if (pending != null && pending.isNotEmpty) {
            final decisions = {for (final r in pending) r.id: ReviewDecision.approve};
            await service.commitBatch(decisions: decisions);
          }
        }
        tracked.enterDesignerMode();
        ref.read(designerModeProvider.notifier).state = true;
      case _DesignerSwitchResult.cancel:
        break; // do nothing
      case _DesignerSwitchResult.goToReview:
        // Navigate to the Maintenance tab (index 3).
        // The MainShell's tab index is managed in _MainShellState, so we use
        // a global ValueNotifier to signal it.
        mainShellTabNotifier.value = 3;
      case null:
        break;
    }
  }
}

enum _DesignerSwitchResult { commitAndContinue, cancel, goToReview }

class _DesignerModeSwitchDialog extends StatelessWidget {
  const _DesignerModeSwitchDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Switch to Designer Mode?'),
      content: const Text(
        'You have pending tracked changes that haven\'t been reviewed.\n\n'
        'Entering Designer Mode will commit all tracked changes automatically. '
        'You can also cancel and review them first.',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, _DesignerSwitchResult.goToReview),
          child: const Text('Go to Edit Review'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _DesignerSwitchResult.cancel),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, _DesignerSwitchResult.commitAndContinue),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE8A000),
            foregroundColor: Colors.black,
          ),
          child: const Text('Commit & Continue'),
        ),
      ],
    );
  }
}

// ── Global tab-switch notifier ────────────────────────────────────────────────
// Allows child widgets to programmatically switch the main tab without
// requiring a BuildContext that contains the MainShell's state.
final mainShellTabNotifier = ValueNotifier<int?>(null);

// ── Global undo/redo status bar ───────────────────────────────────────────────

class _GlobalStatusBar extends ConsumerStatefulWidget {
  const _GlobalStatusBar();

  @override
  ConsumerState<_GlobalStatusBar> createState() => _GlobalStatusBarState();
}

class _GlobalStatusBarState extends ConsumerState<_GlobalStatusBar> {
  TrackedWriteRepository? _tracked;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = ref.read(trackedWriteProvider);
    if (next != _tracked) {
      _tracked?.undoStack.removeListener(_onStackChanged);
      _tracked = next;
      _tracked?.undoStack.addListener(_onStackChanged);
    }
  }

  @override
  void dispose() {
    _tracked?.undoStack.removeListener(_onStackChanged);
    super.dispose();
  }

  void _onStackChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final tracked = ref.watch(trackedWriteProvider);
    final stack   = tracked?.undoStack;

    final bg      = theme.colorScheme.surfaceContainer;
    final fg      = theme.colorScheme.onSurfaceVariant;
    final accent  = theme.colorScheme.primary;

    String centerText = '—';
    if (stack != null) {
      final undoDesc = stack.undoDescription;
      final redoDesc = stack.redoDescription;
      if (undoDesc != null && redoDesc != null) {
        centerText = 'undo : $undoDesc   ;   redo : $redoDesc';
      } else if (undoDesc != null) {
        centerText = 'undo : $undoDesc';
      } else if (redoDesc != null) {
        centerText = 'redo : $redoDesc';
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1, thickness: 1),
        SizedBox(
          height: 24,
          child: ColoredBox(
            color: bg,
            child: Row(
              children: [
                // Left pane (25%)
                Expanded(
                  flex: 25,
                  child: const SizedBox.shrink(),
                ),
                // Center pane (50%) — undo/redo hint
                Expanded(
                  flex: 50,
                  child: Center(
                    child: Text(
                      centerText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: centerText == '—' ? fg.withValues(alpha: 0.4) : fg,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Right pane (25%)
                Expanded(
                  flex: 25,
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── MainShell ─────────────────────────────────────────────────────────────────

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    mainShellTabNotifier.addListener(_onExternalTabChange);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    mainShellTabNotifier.removeListener(_onExternalTabChange);
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (HardwareKeyboard.instance.isControlPressed) {
        if (event.logicalKey == LogicalKeyboardKey.keyZ) {
          if (_isTextInputFocused()) return false;
          if (HardwareKeyboard.instance.isShiftPressed) {
            _redo();
          } else {
            _undo();
          }
          return true;
        } else if (event.logicalKey == LogicalKeyboardKey.keyY) {
          if (_isTextInputFocused()) return false;
          _redo();
          return true;
        }
      }
    }
    return false;
  }

  bool _isTextInputFocused() {
    final focus = FocusManager.instance.primaryFocus;
    return focus?.context?.widget is EditableText;
  }

  void _onExternalTabChange() {
    final idx = mainShellTabNotifier.value;
    if (idx != null && idx != _selectedIndex && mounted) {
      setState(() => _selectedIndex = idx);
      mainShellTabNotifier.value = null; // reset
    }
  }

  // ── Tabs ───────────────────────────────────────────────────────────────────

  List<NavigationDestination> _buildTabs(int pendingCount) {
    return [
      const NavigationDestination(
        icon: Icon(Icons.info_outline),
        selectedIcon: Icon(Icons.info),
        label: 'Show',
      ),
      const NavigationDestination(
        icon: Icon(Icons.table_chart_outlined),
        selectedIcon: Icon(Icons.table_chart),
        label: 'Spreadsheet',
      ),
      const NavigationDestination(
        icon: Icon(Icons.sticky_note_2_outlined),
        selectedIcon: Icon(Icons.sticky_note_2),
        label: 'Work Notes',
      ),
      NavigationDestination(
        icon: Badge(
          isLabelVisible: pendingCount > 0,
          label: Text(pendingCount > 99 ? '99+' : '$pendingCount'),
          child: const Icon(Icons.build_outlined),
        ),
        selectedIcon: Badge(
          isLabelVisible: pendingCount > 0,
          label: Text(pendingCount > 99 ? '99+' : '$pendingCount'),
          child: const Icon(Icons.build),
        ),
        label: 'Maintenance',
      ),
      const NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: 'Reports',
      ),
    ];
  }

  // ── Actions ────────────────────────────────────────────────────────────────

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

  Future<void> _undo() async {
    final tracked = ref.read(trackedWriteProvider);
    if (tracked == null) return;
    final desc = await tracked.undo();
    if (mounted && desc != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Undone: $desc'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _redo() async {
    final tracked = ref.read(trackedWriteProvider);
    if (tracked == null) return;
    final desc = await tracked.redo();
    if (mounted && desc != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Redone: $desc'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'PaperTek',
      applicationVersion: '0.1.0',
      applicationLegalese: '© 2026',
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final menuBg     = theme.colorScheme.surface;
    final menuFg     = theme.colorScheme.onSurface;
    final tracked    = ref.watch(trackedWriteProvider);
    final pendingCount = ref.watch(pendingCountProvider).valueOrNull ?? 0;

    return Focus(
      autofocus: true,
      child: Scaffold(
        body: Column(
          children: [
            // ── Menu bar + designer toggle ─────────────────────────────
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
                        _item(
                          tracked?.undoStack.canUndo == true
                              ? 'Undo: ${tracked!.undoStack.undoDescription}'
                              : 'Undo',
                          Icons.undo,
                          tracked?.undoStack.canUndo == true ? _undo : null,
                        ),
                        _item(
                          tracked?.undoStack.canRedo == true
                              ? 'Redo: ${tracked!.undoStack.redoDescription}'
                              : 'Redo',
                          Icons.redo,
                          tracked?.undoStack.canRedo == true ? _redo : null,
                        ),
                      ], menuFg),
                      _menu('Operations', [
                        _item('Import Fixtures from CSV', Icons.upload_file,
                            _importCsv),
                      ], menuFg),
                      _menu('Help', [
                        _item('About PaperTek', Icons.info_outline,
                            _showAbout),
                      ], menuFg),
                    ],
                  ),
                  const Spacer(),
                  // Designer mode toggle — top right of menu bar
                  const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: _DesignerModeToggle(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ── Tab body ───────────────────────────────────────────────
            Expanded(child: _buildTabBody()),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) =>
                  setState(() => _selectedIndex = i),
              destinations: _buildTabs(pendingCount),
            ),
            // ── Global status bar ──────────────────────────────────────
            const _GlobalStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _menu(String label, List<Widget> children, Color foreground) {
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

  Widget _buildTabBody() {
    const tabs = <Widget>[
      ShowTab(),
      SpreadsheetTab(),
      _StubTab('Work Notes'),
      MaintenanceTab(),
      _StubTab('Reports'),
    ];
    final index = _selectedIndex < 0 || _selectedIndex >= tabs.length
        ? 0
        : _selectedIndex;
    return IndexedStack(
      index: index,
      sizing: StackFit.expand,
      children: tabs,
    );
  }
}

class _StubTab extends StatelessWidget {
  const _StubTab(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
