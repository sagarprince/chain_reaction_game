import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';

class EliminatedDialog extends StatelessWidget {
  VoidCallback callback;

  EliminatedDialog({Key key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      height: 300.0,
      decoration: BoxDecoration(
          color: AppColors.cardinal, borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 65.0,
            height: 65.0,
            child: Image.asset('assets/images/sad.png'),
          ),
          SizedBox(height: 10.0),
          Text('Oh no!',
              style: AppTextStyles.mediumText.copyWith(
                  fontFamily: AppFonts.third, color: AppColors.white)),
          SizedBox(height: 5.0),
          Text('You Eliminated !',
              style: AppTextStyles.regularText
                  .copyWith(color: AppColors.white, fontSize: 20.0)),
          SizedBox(height: 15.0),
          Text('DO YOU WANT TO STAY IN GAME?',
              textAlign: TextAlign.center,
              style: AppTextStyles.regularText
                  .copyWith(color: AppColors.white, fontSize: 16.0)),
          SizedBox(height: 25.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                color: AppColors.blueGrey,
                child: Text('No',
                    style: AppTextStyles.confirmationButton
                        .copyWith(color: AppColors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (callback != null) {
                    callback();
                  }
                },
              ),
              SizedBox(width: 10.0),
              new RaisedButton(
                color: AppColors.white,
                child: Text('Yes',
                    style: AppTextStyles.confirmationButton
                        .copyWith(color: AppColors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
