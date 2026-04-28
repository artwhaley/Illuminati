// Pure-Dart file — no Flutter imports.
typedef _Listener = void Function();

/// One sub-operation within an undo frame. A single edit has one; a batch
/// operation (reorder 51 positions, merge types, etc.) may have many — but
/// they still occupy ONE slot on the undo stack.
class UndoSubOperation {
  const UndoSubOperation({
    required this.revisionId,
    required this.operation,
    required this.targetTable,
    required this.targetId,
    this.fieldName,
    this.oldValueJson,
    this.newValueJson,
  });

  /// The ID of the revision row created for this sub-operation.
  /// NULL when in designer mode (no revision rows are written).
  final int? revisionId;

  /// 'update' | 'insert' | 'delete'
  final String operation;
  final String targetTable;
  final int targetId;
  final String? fieldName;

  /// JSON-encoded previous value (for update) or full snapshot (for delete).
  /// This is what we restore on undo. Stored here independently so we can
  /// redo even after the revision row is deleted.
  final String? oldValueJson;

  /// JSON-encoded next value (for update) or full snapshot (for insert).
  /// Used to re-apply on redo.
  final String? newValueJson;

  Map<String, dynamic> toJson() => {
        'revisionId': revisionId,
        'operation': operation,
        'targetTable': targetTable,
        'targetId': targetId,
        'fieldName': fieldName,
        'oldValueJson': oldValueJson,
        'newValueJson': newValueJson,
      };
}

/// One entry on the undo stack. May contain multiple sub-operations (for
/// batched actions that must be undone atomically). Occupies exactly ONE
/// slot regardless of how many sub-operations it has.
class UndoFrame {
  UndoFrame({
    required this.description,
    List<UndoSubOperation>? operations,
  }) : operations = operations ?? [];

  /// Human-readable label shown in the status bar:
  ///   "Edit fixture channel", "Delete fixture", "Reorder positions", etc.
  final String description;

  /// All sub-operations that must be reversed together.
  /// Mutable so batch frames can accumulate ops before being pushed.
  final List<UndoSubOperation> operations;
}

/// In-memory undo/redo stacks. Max 50 entries each.
///
/// Rules per spec:
/// - Any new manual edit clears the redo stack.
/// - Stack is cleared on supervisor commit (committed = permanent).
/// - Designer-mode operations are undoable (frames carried, no revision rows).
/// - Import operations are NOT pushed to the stack.
class UndoStack {
  static const _maxSize = 50;

  final List<UndoFrame> _undo = [];
  final List<UndoFrame> _redo = [];

  final List<_Listener> _listeners = [];

  void addListener(_Listener fn) => _listeners.add(fn);
  void removeListener(_Listener fn) => _listeners.remove(fn);
  void _notify() {
    for (final fn in List.of(_listeners)) {
      fn();
    }
  }

  // ── Mutation ──────────────────────────────────────────────────────────────

  /// Push a new undo frame. Clears the redo stack (new edit invalidates redo).
  void push(UndoFrame frame) {
    _undo.add(frame);
    if (_undo.length > _maxSize) _undo.removeAt(0);
    _redo.clear();
    _notify();
  }

  /// Pop the top undo frame (returns it for execution, moves to redo stack).
  UndoFrame? popUndo() {
    if (_undo.isEmpty) return null;
    final frame = _undo.removeLast();
    _redo.add(frame);
    _notify();
    return frame;
  }

  /// Pop the top redo frame (returns it for execution, moves to undo stack).
  UndoFrame? popRedo() {
    if (_redo.isEmpty) return null;
    final frame = _redo.removeLast();
    _undo.add(frame);
    if (_undo.length > _maxSize) _undo.removeAt(0);
    _notify();
    return frame;
  }

  /// Clear both stacks. Called on supervisor commit.
  void clearAll() {
    _undo.clear();
    _redo.clear();
    _notify();
  }

  // ── State ─────────────────────────────────────────────────────────────────

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  /// Description of the action that would be undone (shown in status bar).
  String? get undoDescription => _undo.lastOrNull?.description;

  /// Description of the action that would be redone (shown in status bar).
  String? get redoDescription => _redo.lastOrNull?.description;
}
