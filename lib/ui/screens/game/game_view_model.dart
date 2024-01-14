import 'dart:async';

import 'package:flutter/material.dart';
import 'package:untitled/data/ai/computer_player.dart';
import 'package:untitled/data/ai/cp_3.dart';
import 'package:untitled/data/cell/cell_details.dart';
import 'package:untitled/data/pawn/pawn_path.dart';
import 'package:untitled/data/pawn/pawn_details.dart';
import 'package:untitled/data/cell/position_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/enum/pawn_move_state.dart';
import 'package:untitled/enum/tap_on_board.dart';
import 'package:untitled/game/checkers_board.dart';
import 'package:untitled/game/pawns_operation.dart';
import 'package:untitled/repositories/settings_repo.dart';

class GameViewModel extends ChangeNotifier {
  final CheckersBoard _checkersBoard = CheckersBoard();
  final Set<String> _markedKings = {};
  PawnsOperation pawnsOperation = PawnsOperation();

  static const int TURN_TIME_LIMIT = 31;

  final ValueNotifier<int> _turnTimerText = ValueNotifier(TURN_TIME_LIMIT - 1);

  ValueNotifier<int> get turnTimerText => _turnTimerText;

  final ValueNotifier<PawnStatus> _blackPawnStatus =
      ValueNotifier(PawnStatus());

  ValueNotifier<PawnStatus> get blackPawnStatus => _blackPawnStatus;

  final ValueNotifier<PawnStatus> _whitePawnStatus =
      ValueNotifier(PawnStatus());

  ValueNotifier<PawnStatus> get whitePawnStatus => _whitePawnStatus;

  final StreamController<PawnMoveState> _isStartPawnMove =
      StreamController<PawnMoveState>();

  Stream<PawnMoveState> get isStartPawnMove => _isStartPawnMove.stream;

  ValueNotifier<bool> get isUndoEnable => _checkersBoard.isHistoryEnable;

  int get pathSize => _pathPawn.positionDetailsList.length;

  PawnPath _pathPawn = PawnPath.createEmpty();

  List<PawnPath> _pawnPaths = [];
  bool _isInProcess = false;

  final List<CellDetails> _boardCells = [];

  List<CellDetails> get boardCells => _boardCells;

  final List<PawnDetails> _pawns = [];

  List<PawnDetails> get pawns => _pawns;

  CellType get currentPlayer => _currentPlayer;

  CellType _currentPlayer = CellType.UNDEFINED;

  GameViewModel() {
    _initializeGame(_checkersBoard);
  }

  Timer? turnTimer;

  void _initializeGame(CheckersBoard checkersBoard) {
    checkersBoard.init();
    _setCheckersBoard(checkersBoard.board);
    _setCurrentPlayer(checkersBoard.player);
    _pawns.addAll(checkersBoard.pawns);
    _setGameStatus();

    _startOrRestartTimer();
  }

  // void onTapEnd() {
  //   _isStartPawnMove.add(true);
  // }

  void _startOrRestartTimer() {
    // Cancel the existing timer if it's not null
    turnTimer?.cancel();

    // Create a new timer that runs a function every 1 second
    turnTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      int timerTime = timer.tick;

      _turnTimerText.value = (TURN_TIME_LIMIT - timerTime);

      if (timerTime == TURN_TIME_LIMIT) {
        turnTimer?.cancel();
      }
    });
  }

  void _setGameStatus() {
    StatusGame summarizerPawns = pawnsOperation.pawnsSummarize(
        _checkersBoard.board, _checkersBoard.player);

    _blackPawnStatus.value = summarizerPawns.blackPawnStatus;
    _whitePawnStatus.value = summarizerPawns.whitePawnStatus;
  }

  void _continueNextIterationOrTurn(int endRow, int endColumn) =>
      _pathPawn.isContinuePath
          ? onTapBoardGame(endRow, endColumn)
          : _nextTurn();

  TapOnBoard onClickCell(int row, int column) => onTapBoardGame(row, column);

  void onClickPawn(int row, int column) {
    if (_pathPawn.isContinuePath) return;
    onTapBoardGame(row, column);
  }

  bool _isValidTap(int row, int column) {
    if (_isInProcess) return false;

    if (_isNotEqualEndPathContinueCaptureState(row, column)) return false;

    return true;
  }

  bool _isNotEqualEndPathContinueCaptureState(int row, int column) =>
      _pathPawn.isContinuePath &&
      _pawnPaths.every((element) =>
          element.positionDetailsList.last.position != Position(row, column));

  TapOnBoard onTapBoardGame(int row, int column) {
    if (!_isValidTap(row, column)) {
      return TapOnBoard.UNVALID;
    }
    List<PawnPath> pawnPaths = _checkersBoard
        .getLegalMoves(_checkersBoard.player, _checkersBoard.board, false)
        .where((element) => element.startPosition == Position(row, column))
        .toList();
    if (pawnPaths.isNotEmpty) {
      return _handleStartCellTap(row, column, pawnPaths);
    }

    PawnPath pathPawn =
        _checkersBoard.getPathByEndCellSelected(row, column, _pawnPaths);
    if (pathPawn.isValidPath) {
      return _handleDestinationCellTap(row, column, pathPawn);
    }

    return TapOnBoard.UNVALID;
  }

  TapOnBoard _handleStartCellTap(
      int row, int column, Iterable<PawnPath> pawnPaths) {
    _pawnPaths = pawnPaths.toList();
    _checkersBoard.paintColorsCells(_pawnPaths);
    return TapOnBoard.START;
  }

  TapOnBoard _handleDestinationCellTap(
      int destinationRow, int destinationCol, PawnPath pathPawn) {
    _startProcess();
    _checkersBoard.setHistoryAvailability(false);
    _pathPawn = pathPawn;
    _setNewLocationPawn();
    _notifyStartPawnMove();
    return TapOnBoard.END;
  }

  void _notifyStartPawnMove() => _isStartPawnMove.add(PawnMoveState.START);

  void _notifyFinishPawnMove() => _isStartPawnMove.add(PawnMoveState.FINISH);

  Future<void> onPawnMoveAnimationFinish() async {
    _checkersBoard
      ..updateHistory(_pathPawn)
      ..performMove(_checkersBoard.board, _pawnPaths, _pathPawn, isAI: false);
    _setGameStatus();
    _endProcess();
    _notifyFinishPawnMove();

    _continueNextIterationOrTurn(
        _pathPawn.endPosition.row, _pathPawn.endPosition.column);
    _setGameStatus();
  }

  void _setCheckersBoard(List<List<CellDetails>> board) {
    for (var elementList in board) {
      for (var element in elementList) {
        _boardCells.add(element);
      }
    }
  }

  void _setCurrentPlayer(CellType currentPlayer) =>
      _currentPlayer = currentPlayer;

  void _nextTurn() {
    _startOrRestartTimer();

    _clearDataNextTurnState();
    _checkersBoard.nextTurn();
    _setCurrentPlayer(_checkersBoard.player);
    bool isGameOver = _checkersBoard.isGameOver(false);
    print("VM NEXT TURN isGameOver: $isGameOver");

    if (_isAITurn()) {
      _aiTurn();
    }

    _checkersBoard.setHistoryAvailability(true);
  }

  Future _delayedBeforeClick(int duration) =>
      Future.delayed(Duration(milliseconds: duration));

  Future<void> _aiTurn() async {

    PawnPath? pathPawn = aIMove();
    if (pathPawn == null) return;
    onTapBoardGame(pathPawn.startPosition.row, pathPawn.startPosition.column);

    await _delayedBeforeClick(300);

    TapOnBoard tapOnBoardEnd =
        onTapBoardGame(pathPawn.endPosition.row, pathPawn.endPosition.column);

    await _delayedBeforeClick(100);

    if (tapOnBoardEnd == TapOnBoard.END) {
      _notifyStartPawnMove();
    }
  }

  bool _isAITurn() => currentPlayer == aiType && SettingsRepository().isAIMode;

  PawnPath? aIMove() {
    // PathPawn? path = ComputerPlayer(SettingsRepository().depthLevel)
    //     .getBestMoveForAI(_checkersBoard);
    //
    // PathPawn? path = ComputerPlayerPro(SettingsRepository().depthLevel)
    //     .getBestMoveForAI(_checkersBoard);
    PawnPath? path = Computer()
        .alphaBetaSearch(_checkersBoard, SettingsRepository().depthLevel);
    return path;
  }

  void _endProcess() => _isInProcess = false;

  void _startProcess() => _isInProcess = true;

  void _clearDataNextTurnState() {
    _pawnPaths.clear();
    _pathPawn = PawnPath.createEmpty();
  }

  void onFinishAnimateCrown(String pawnId, bool isKingPawn) {
    if (isKingPawn) return;
    _markedKings.add(pawnId);
  }

  bool isAlreadyMarkedKing(String id) => _markedKings.contains(id);

  void _setNewLocationPawn() {
    _pathPawn.pawnStartPath.setPawnDataNotifier(
        offset: Offset(_pathPawn.endPosition.column.toDouble(),
            _pathPawn.endPosition.row.toDouble()),
        isAnimating: true);
  }

  void undo() => _undoOrReset(() => _checkersBoard.popLastStep(), true);

  void resetGame() => _undoOrReset(() => _checkersBoard.resetBoard(), false);

  void _undoOrReset(Function() action, bool isUndo) {
    if (_isInProcess || !isUndoEnable.value) return;
    _startProcess();

    action();

    _clearDataNextTurnState();
    _setCurrentPlayer(_checkersBoard.player);
    _endProcess();

    if (isUndo && _isAITurn()) undo();
  }

  @override
  void dispose() {
    // _isAITurnController.close();
    super.dispose();
  }
}
