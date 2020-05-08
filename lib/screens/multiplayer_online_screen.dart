import 'dart:convert';

import 'package:chain_reaction_game/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:chain_reaction_game/widgets/background.dart';
import 'package:chain_reaction_game/widgets/positional_back_button.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

const String URI = "http://192.168.0.103:4545";

class MultiPlayerOnlineScreen extends StatefulWidget {
  MultiPlayerOnlineScreen({Key key}) : super(key: key);

  _MultiPlayerOnlineScreenState createState() =>
      _MultiPlayerOnlineScreenState();
}

class _MultiPlayerOnlineScreenState extends State<MultiPlayerOnlineScreen> {
  SocketIO _socketIO;

  @override
  void initState() {
    super.initState();
    _initClientSocket();
  }

  void _initClientSocket() {
    _socketIO = SocketIOManager().createSocketIO(URI, '/',
        socketStatusCallback: (data) {
      print('status');
      print(data);

      _socketIO.sendMessage('creategame', jsonEncode({'key': 'hello'}), (data) {
        print('Send Message');
        print(data);
      });
    });

    _socketIO.init();

    //subscribe event
    _socketIO.subscribe("socket_info", (data) {
      print('socket_info');
      print(data);
    });

    _socketIO.subscribe('move', (data) {
      print('ON MOVE');
      print(data);
    });

    //connect socket
    _socketIO.connect();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Background(
        child: Stack(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Coming Soon...',
                          style:
                              AppTextStyles.boldText.copyWith(fontSize: 26.0))
                    ],
                  )
                ],
              ),
            ),
            PositionalBackButton(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_socketIO != null) {
      SocketIOManager().destroySocket(_socketIO);
    }
    super.dispose();
  }
}
