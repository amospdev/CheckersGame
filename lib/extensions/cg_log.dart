import 'package:flutter/foundation.dart';

class Logger {
  void logDev(String log) {
    if (kDebugMode) {
      print(log);
    }
  }
}

void logDebug(String log) {
  if (kDebugMode) {
    // print(log);
  }
}
