import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:share/share.dart';

class ShareRoomCode extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final int roomId;

  ShareRoomCode({Key key, this.scaffoldKey, this.roomId = -1})
      : super(key: key);

  String shareText() {
    String text = 'I want to play Chain Reaction with you!\n';
    text +=
        'Start game and go to Play Multiplayer -> Play Online -> Join Game\n';
    text += 'and then enter Room code "${roomId.toString()}".';
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Room Code', style: AppTextStyles.regularText),
          SizedBox(height: 5.0),
          Text(roomId.toString(),
              style: AppTextStyles.regularText.copyWith(fontSize: 26.0)),
          SizedBox(height: 5.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.share, size: 35.0, color: AppColors.white),
                onPressed: () {
                  Share.share(shareText(), subject: '');
                },
              ),
              SizedBox(width: 10.0),
              IconButton(
                icon: Icon(Icons.content_copy,
                    size: 35.0, color: AppColors.white),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: shareText()));
                  scaffoldKey.currentState.showSnackBar(
                      SnackBar(content: Text('Copied to clipboard !!!')));
                },
              ),
            ],
          ),
          SizedBox(height: 5.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
                'Share this room code with friends and ask them to join',
                textAlign: TextAlign.center,
                style: AppTextStyles.regularText),
          )
        ],
      ),
    );
  }
}
