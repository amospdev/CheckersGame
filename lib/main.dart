import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/board_elements_size.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/enum/tap_on_board.dart';
import 'package:untitled/extensions/cg_log.dart';
import 'package:untitled/game_view_model.dart';
import 'package:untitled/ui/widgets/background_game.dart';
import 'package:untitled/ui/widgets/bottom_layer.dart';
import 'package:untitled/ui/widgets/center_layer.dart';
import 'package:untitled/ui/widgets/top_layer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then(run);
}

void run(void param0) {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameViewModel(),
      child: const CheckersGameScreen(),
    ),
  );
}

class CheckersGameScreen extends StatelessWidget {
  const CheckersGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    logDebug("REBUILD MyApp");
    return MaterialApp(
      title: 'Checkers Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CheckersGame(),
    );
  }
}

class CheckersGame extends StatefulWidget {
  const CheckersGame({super.key});

  @override
  CheckersGameState createState() => CheckersGameState();
}

class CheckersGameState extends State<CheckersGame>
    with TickerProviderStateMixin {
  late final AnimationController _pawnMoveController;

  static const int _pawnMoveDuration = 350;

  late final GameViewModel gameViewModel;
  StreamSubscription<bool>? _streamAiTurn;
  StreamSubscription<bool>? _streamPawnMove;

  @override
  void initState() {
    super.initState();
    gameViewModel = Provider.of<GameViewModel>(context, listen: false);
    _pawnMoveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..addStatusListener((status) {
        if (_pawnMoveController.isCompleted) {
          gameViewModel.onPawnMoveAnimationFinish();
        }
      });

    _streamAiTurn =
        gameViewModel.isAITurnStream.where((isAI) => isAI).listen(_aiTurn);

    _streamPawnMove = gameViewModel.isStartPawnMove
        .where((isStartPawnMove) => isStartPawnMove)
        .listen((isStartPawnMove) => _startPawnMoveAnimation());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access inherited widgets or perform initialization here

    BoardElementsSize.measurementElementsBoardSize(
        mediaQueryData: MediaQuery.of(context));
  }

  Future _delayedBeforeClick(int duration) =>
      Future.delayed(Duration(milliseconds: duration));

  Future<void> _aiTurn(bool isAI) async {
    await _delayedBeforeClick(300);

    logDebug("MAIN WIDGET _aiTurn: $isAI");
    PathPawn? pathPawn = gameViewModel.aIMove();
    if (pathPawn == null) return;
    gameViewModel.onTapBoardGame(
        pathPawn.startPosition.row, pathPawn.startPosition.column);

    await _delayedBeforeClick(300);

    TapOnBoard tapOnBoardEnd = gameViewModel.onTapBoardGame(
        pathPawn.endPosition.row, pathPawn.endPosition.column);

    await _delayedBeforeClick(100);

    if (tapOnBoardEnd == TapOnBoard.END) {
      _startPawnMoveAnimation();
    }
  }

  void _startPawnMoveAnimation() {
    _pawnMoveController.duration = Duration(
        milliseconds: (gameViewModel.pathSize > 2
            ? (_pawnMoveDuration * 1.6).toInt()
            : _pawnMoveDuration));

    _pawnMoveController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) => _mainBoard(context);

  Widget _mainBoard(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: _checkersGame(),
      ),
    );
  }

  Widget _checkersGame() => SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [const BackgroundGame(), _boardGame()],
        ),
      );

  Widget _boardGame() => SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TopLayer(),
          CenterLayer(_pawnMoveController),
          const BottomLayer(),
        ],
      ));

  @override
  void dispose() {
    _pawnMoveController.dispose();
    _streamAiTurn?.cancel();
    _streamPawnMove?.cancel();

    super.dispose();
  }
}
