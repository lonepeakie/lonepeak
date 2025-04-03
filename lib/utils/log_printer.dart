import 'package:logger/logger.dart';

class PrefixedLogPrinter extends LogPrinter {
  final String prefix;

  PrefixedLogPrinter(this.prefix);

  @override
  List<String> log(LogEvent event) {
    return ['[$prefix] ${event.message}'];
  }
}
