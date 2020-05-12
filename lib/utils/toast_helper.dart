import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:chain_reaction_game/utils/keys.dart';
import 'package:chain_reaction_game/utils/styles.dart';

class ToastHelper {
  static Flushbar<Object> currentToast;

  static void showToast(String message, Duration duration,
      [bool isDismissible = true]) async {
    BuildContext context = Keys.navigatorKey.currentState.overlay.context;
    try {
      currentToast = Flushbar(
          message: message,
          duration: duration,
          flushbarPosition: FlushbarPosition.TOP,
          flushbarStyle: FlushbarStyle.GROUNDED,
          animationDuration: Duration(milliseconds: 400),
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
          leftBarIndicatorColor: AppColors.cardinal,
          isDismissible: isDismissible)
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
