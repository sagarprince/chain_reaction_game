import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:chain_reaction_game/utils/strings_utils.dart';
import 'package:chain_reaction_game/utils/styles.dart';
import 'package:chain_reaction_game/utils/constants.dart';
import 'package:chain_reaction_game/widgets/background.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import "package:flare_flutter/flare_actor.dart";
import "package:flare_flutter/flare_cache_builder.dart";
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chain_reaction_game/blocs/bloc.dart';
import 'package:chain_reaction_game/blocs/events.dart';
import 'package:chain_reaction_game/blocs/state.dart';
import 'package:chain_reaction_game/models/player.dart';

class ResultScreen extends StatefulWidget {
  ResultScreen({Key key}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final CharacterController characterController = CharacterController();
  bool isNavigating = false;

  void _resetWinner(BuildContext context) {
    BlocProvider.of<CRBloc>(context).add(SetWinnerEvent(Player('', '', true)));
  }

  Widget _animatedFireworks(GameMode gameMode, Player winner) {
    bool isVisible = true;
    if (gameMode == GameMode.PlayVersusBot && !winner.isHuman) {
      isVisible = false;
    }

    if (isVisible) {
      String _animationName = 'Animations';
      var asset =
          AssetFlare(bundle: rootBundle, name: 'assets/flares/fireworks.flr');
      return FlareCacheBuilder(
        [asset],
        builder: (BuildContext context, bool isWarm) {
          return FlareActor.asset(
            asset,
            alignment: Alignment.center,
            fit: BoxFit.fill,
            animation: _animationName,
          );
        },
      );
    }
    return SizedBox();
  }

  Widget _animatedCharacter(GameMode gameMode, Player winner) {
    var asset =
        AssetFlare(bundle: rootBundle, name: 'assets/flares/character.flr');
    if (gameMode == GameMode.PlayVersusBot && !winner.isHuman) {
      characterController.setSuccess(false);
    } else {
      characterController.setSuccess(true);
    }

    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: FlareCacheBuilder(
        [asset],
        builder: (BuildContext context, bool isWarm) {
          return FlareActor.asset(asset,
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: 'look',
              controller: characterController);
        },
      ),
    );
  }

  Widget _card(GameMode gameMode, Player winner) {
    String heading = 'Congratulations';
    String message = '';
    if (gameMode == GameMode.PlayVersusBot) {
      if (winner.isHuman) {
        message = 'You Won !!!';
      } else {
        heading = 'Oh no';
        message = 'You Lost !!!';
      }
    } else {
      message = '${camelize(winner.name)} Won !!!';
    }

    return Container(
      margin: EdgeInsets.only(left: 25.0, right: 25.0),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
            begin: Alignment.topLeft,
            colors: [Color(0xFF222222), Color(0xFF333333)],
            tileMode: TileMode.clamp),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          new BoxShadow(
            color: AppColors.black,
            offset: new Offset(0.0, 0.0),
            blurRadius: 10.0,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            heading,
            style: TextStyle(
                fontSize: 26.0,
                fontFamily: AppFonts.secondary,
                color: AppColors.white),
          ),
          SizedBox(height: 10.0),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26.0,
                fontFamily: AppFonts.secondary,
                color: AppColors.white),
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(LineAwesomeIcons.home,
                    color: AppColors.white, size: 32.0),
                onPressed: () {
                  isNavigating = true;
                  _resetWinner(context);
                  Navigator.of(context).pushReplacementNamed(AppRoutes.base);
                },
              ),
              SizedBox(
                  width: gameMode == GameMode.MultiPlayerOnline ? 0.0 : 20.0),
              gameMode != GameMode.MultiPlayerOnline
                  ? IconButton(
                      icon: Icon(LineAwesomeIcons.refresh,
                          color: AppColors.white, size: 32.0),
                      onPressed: () {
                        isNavigating = true;
                        _resetWinner(context);
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.play_game);
                      },
                    )
                  : SizedBox()
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double cardBottomPosition = height > 600 ? 50 : 20;
    double cardHeight = height > 600 ? (height / 3) : 180;
    return Scaffold(
        body: BlocBuilder<CRBloc, CRState>(condition: (previousState, state) {
      if (isNavigating) {
        return false;
      }
      return true;
    }, builder: (context, state) {
      return Background(
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Positioned.fill(
              child: _animatedFireworks(state.gameMode, state.winner),
            ),
            Positioned.fill(
              child: _animatedCharacter(state.gameMode, state.winner),
            ),
            Positioned(
              bottom: cardBottomPosition,
              width: MediaQuery.of(context).size.width,
              height: cardHeight,
              child: _card(state.gameMode, state.winner),
            ),
          ],
        ),
      );
    }));
  }
}

class CharacterController extends FlareController {
  FlareAnimationLayer _lookAnimation;
  FlareAnimationLayer _successAnimation;
  FlareAnimationLayer _failAnimation;

  bool isSuccess = true;

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    _lookAnimation.time += elapsed;
    _lookAnimation.apply(artboard);
    if (_lookAnimation.isDone) {
      if (isSuccess) {
        _successAnimation.time += elapsed;
        _successAnimation.apply(artboard);
        if (_successAnimation.isDone) {
          _successAnimation.time = 0;
        }
      } else {
        _failAnimation.time += elapsed;
        _failAnimation.apply(artboard);
        if (_failAnimation.isDone) {
          _failAnimation.time = 0;
        }
      }
    }
    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    _lookAnimation = FlareAnimationLayer()
      ..animation = artboard.getAnimation('look')
      ..mix = 1.0;
    _successAnimation = FlareAnimationLayer()
      ..animation = artboard.getAnimation('success')
      ..mix = 1.0;
    _failAnimation = FlareAnimationLayer()
      ..animation = artboard.getAnimation('fail')
      ..mix = 1.0;
  }

  setSuccess(bool _isSuccess) {
    isSuccess = _isSuccess;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
}
