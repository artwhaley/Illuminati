import 'dart:developer' as developer;

typedef LogSink = void Function(String message, {Object? error, StackTrace? stackTrace});

class AppLogger {
  const AppLogger({this.sink = _defaultSink});
  final LogSink sink;
  void error(String operation, Object error, [StackTrace? stackTrace]) {
    sink(operation, error: error, stackTrace: stackTrace);
  }
  static void _defaultSink(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: 'papertek', error: error, stackTrace: stackTrace);
  }
}

const appLogger = AppLogger();
