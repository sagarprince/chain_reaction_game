import 'package:flutter/material.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/widgets/orb.dart';

class PlayersListing extends StatelessWidget {
  final List<Player> players;

  PlayersListing({Key key, this.players}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: new BoxDecoration(
          color: AppColors.blackLight,
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0))),
      child: Column(
        children: <Widget>[
          SizedBox(height: 10.0),
          Text('Players',
              style: AppTextStyles.mediumText.copyWith(fontSize: 20.0)),
          SizedBox(height: 10.0),
          Expanded(
            child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (BuildContext context, int index) {
                  var player = players[index];
                  return Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Orb(
                            color: player.color,
                            width: 35.0,
                            height: 35.0,
                            radius: 18),
                        Container(
                          padding: EdgeInsets.only(left: 10.0),
                          height: 25.0,
                          child: Text(player.isYou ? 'You' : player.name,
                              style: AppTextStyles.regularText
                                  .copyWith(fontSize: 16.0)),
                        )
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
