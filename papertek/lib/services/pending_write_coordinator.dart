import 'dart:async';

typedef WriteFlusher = Future<void> Function();

class PendingWriteCoordinator {
  final Set<Future<void>> _writes = <Future<void>>{};
  final Map<String, WriteFlusher> _flushers = <String, WriteFlusher>{};
  bool _closed = false;

  Future<T> track<T>(Future<T> write) {
    if (_closed) throw StateError('Pending writes are closed');
    final tracked = write.then<void>((_) {}, onError: (Object error, StackTrace stack) {
      Error.throwWithStackTrace(error, stack);
    });
    _writes.add(tracked);
    tracked.then<void>((_) => _writes.remove(tracked), onError: (_, __) {
      _writes.remove(tracked);
    });
    return write;
  }

  void registerFlusher(String name, WriteFlusher flusher) {
    if (_closed) throw StateError('Pending writes are closed');
    _flushers[name] = flusher;
  }

  void unregisterFlusher(String name) => _flushers.remove(name);

  Future<void> flushAndDrain() async {
    Object? firstError;
    StackTrace? firstStack;
    while (true) {
      try {
        for (final flusher in List<WriteFlusher>.of(_flushers.values)) {
          await flusher();
        }
      } catch (error, stack) {
        firstError ??= error;
        firstStack ??= stack;
      }
      final writes = List<Future<void>>.of(_writes);
      if (writes.isEmpty) break;
      for (final write in writes) {
        try {
          await write;
        } catch (error, stack) {
          firstError ??= error;
          firstStack ??= stack;
        }
      }
      if (_writes.isEmpty) break;
    }
    if (firstError != null) Error.throwWithStackTrace(firstError!, firstStack!);
  }

  void close() {
    _closed = true;
    _flushers.clear();
  }
}
