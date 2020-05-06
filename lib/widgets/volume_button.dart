import 'dart:async';

import 'package:flutter/material.dart';
import 'package:volume_watcher/volume_watcher.dart';

class VolumeButton extends StatefulWidget {
  VolumeButton({Key key}) : super(key: key);

  _VolumeButtonState createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<VolumeButton> {
  double currentVol = 0;

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    int _currentVol = await VolumeWatcher.getCurrentVolume;

    if (!mounted) return;

    setState(() {
      this.currentVol = _currentVol.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        VolumeWatcher(
          onVolumeChangeListener: (num volume) {
            setState(() {
              currentVol = volume.toDouble();
            });
          },
        ),
        IconButton(
          icon: Icon(currentVol > 0.0 ? Icons.volume_up : Icons.volume_off,
              color: Colors.white),
          iconSize: 34.0,
          onPressed: () {
            double vol = currentVol > 0.0 ? 0.0 : 100;
            VolumeWatcher.setVolume(vol);
          },
        )
      ],
    );
  }
}
