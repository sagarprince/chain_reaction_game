import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/widgets/custom_dialog.dart';
import 'package:chain_reaction_game/widgets/game_rules_dialog.dart';
import 'package:chain_reaction_game/widgets/eliminated_dialog.dart';

class UiUtils {
  static Future<bool> confirmDialog(
      {BuildContext context,
      Icon icon = const Icon(Icons.info, size: 30.0, color: AppColors.white),
      Color iconBackgroundColor = AppColors.cardinal,
      String title = '',
      String message = '',
      Function callback}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 60.0,
                  height: 60.0,
                  child: Image.asset('assets/images/stop.png'),
                ),
                SizedBox(height: 20.0),
                Text(title, style: AppTextStyles.confirmationTitle),
                SizedBox(height: 10.0),
                Text(message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.confirmationMessage),
                SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: AppColors.whiteLight,
                      child:
                          Text('No', style: AppTextStyles.confirmationButton),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    SizedBox(width: 10.0),
                    new RaisedButton(
                      color: AppColors.cardinal,
                      child: Text('Yes',
                          style: AppTextStyles.confirmationButton
                              .copyWith(color: AppColors.white)),
                      onPressed: () {
                        if (callback != null) {
                          callback();
                        }
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                )
              ],
            ));
      },
    );
  }

  static void showGameRulesDialog(BuildContext context) {
    var _dialog = CustomDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: GameRulesDialog(),
    );

    showDialog(context: context, builder: (BuildContext context) => _dialog);
  }

  static bool isKeyboardOpened(BuildContext context) {
    if (context != null) {
      return MediaQuery.of(context).viewInsets.bottom > 0 ? true : false;
    }
    return false;
  }

  static void showEliminatedDialog(
      BuildContext context, VoidCallback callback) {
    var _dialog = CustomDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: EliminatedDialog(callback: callback),
    );

    showDialog(context: context, builder: (BuildContext context) => _dialog);
  }
}
