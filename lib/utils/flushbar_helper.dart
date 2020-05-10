import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';

class FlushBarHelper {
  static BuildContext context;
  static Flushbar<Object> currentToast;

  static void init(BuildContext _context) {
    print(_context);
    context = _context;
  }

  static void showToast(String message, Duration duration,
      [bool isDismissible = true]) async {
    try {
      currentToast = Flushbar(
          message: message, duration: duration, isDismissible: isDismissible)
        ..show(context);
    } catch (_) {}
  }

  static void hideToast() {
    if (currentToast != null) {
      currentToast.dismiss();
      currentToast = null;
    }
  }
}
