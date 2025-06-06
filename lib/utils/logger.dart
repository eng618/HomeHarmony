import 'package:logger/logger.dart';

/// Global logger instance for the app.
/// Use [log] for all logging instead of print statements.
final Logger log = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);
