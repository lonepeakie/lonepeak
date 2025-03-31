import 'package:logger/logger.dart' show LogEvent, LogPrinter, PrettyPrinter;

class AppPrefixPrinter extends LogPrinter {
  final String prefix;
  final LogPrinter _realPrinter;

  AppPrefixPrinter(this.prefix, [LogPrinter? realPrinter])
    : _realPrinter = realPrinter ?? PrettyPrinter();

  @override
  List<String> log(LogEvent event) {
    return _realPrinter.log(event).map((line) => '[$prefix] $line').toList();
  }
}
