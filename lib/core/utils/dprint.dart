import 'package:flutter/foundation.dart';

dynamic dPrint(dynamic message) {
  if (kDebugMode) {
    print(message);
  }
}
