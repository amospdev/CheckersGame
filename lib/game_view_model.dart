import 'dart:async';

import 'package:flutter/material.dart';
import 'package:untitled/data/ai/computer_player.dart';
import 'package:untitled/data/ai/cp_3.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position/position_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/enum/tap_on_board.dart';
import 'package:untitled/game/checkers_board.dart';
import 'package:untitled/game/pawns_operation.dart';
import 'package:untitled/settings_repo.dart';

class GameViewModel extends ChangeNotifier {
  final CheckersBoard _checkersBoard = CheckersBoard();
  final Set<String> _markedKings = {};

  ValueNotifier<String> pawnsStatus = ValueNotifier("");

  final StreamController<bool> _isAITurnController = StreamController<bool>();

  Stream<bool> get isAITurnStream => _isAITurnController.stream;

  ValueNotifier<bool> get isUndoEnable => _checkersBoard.isHistoryEnable;

  int get pathSize => _pathPawn.positionDetailsList.length;

  PathPawn _pathPawn = PathPawn.createEmpty();

  List<PathPawn> _pawnPaths = [];
  bool _isInProcess = false;

  final List<CellDetails> _boardCells = [];

  List<CellDetails> get boardCells => _boardCells;

  final List<Pawn> _pawns = [];

  List<Pawn> get pawns => _pawns;

  CellType get currentPlayer => _currentPlayer;

  CellType _currentPlayer = CellType.UNDEFINED;

  GameViewModel() {
    _initializeGame(_checkersBoard);
  }

  void _initializeGame(CheckersBoard checkersBoard) {
    checkersBoard.init();
    _setCheckersBoard(checkersBoard.board);
    _setCurrentPlayer(checkersBoard.player);
    _pawns.addAll(checkersBoard.pawns);
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
    List<PathPawn> pawnPaths = _checkersBoard
        .getLegalMoves(_checkersBoard.player, _checkersBoard.board, false)
        .where((element) => element.startPosition == Position(row, column))
        .toList();
    if (pawnPaths.isNotEmpty) {
      return _handleStartCellTap(row, column, pawnPaths);
    }

    PathPawn pathPawn =
        _checkersBoard.getPathByEndCellSelected(row, column, _pawnPaths);
    if (pathPawn.isValidPath) {
      return _handleDestinationCellTap(row, column, pathPawn);
    }

    return TapOnBoard.UNVALID;
  }

  TapOnBoard _handleStartCellTap(
      int row, int column, Iterable<PathPawn> pawnPaths) {
    _pawnPaths = pawnPaths.toList();
    _checkersBoard.paintColorsCells(_pawnPaths);
    return TapOnBoard.START;
  }

  TapOnBoard _handleDestinationCellTap(
      int destinationRow, int destinationCol, PathPawn pathPawn) {
    _startProcess();
    _checkersBoard.setHistoryAvailability(false);
    _pathPawn = pathPawn;
    return TapOnBoard.END;
  }

  Future<void> onPawnMoveAnimationFinish() async {
    _checkersBoard
      ..updateHistory(_pathPawn)
      ..performMove(_checkersBoard.board, _pawnPaths, _pathPawn, isAI: false);
    _updatePawnsStatus();
    _endProcess();
    _continueNextIterationOrTurn(
        _pathPawn.endPosition.row, _pathPawn.endPosition.column);
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
    // bool protectedColumnArea =
    //     Evaluator().protectedColumnArea(_pathPawn.endCell.column);

    // double value = Evaluator().evaluate(_checkersBoard.player == CellType.WHITE,
    //     _checkersBoard.board, _checkersBoard, _checkersBoard.player);
    // bool isProtected =
    //     Evaluator().vulnerablePawns(_checkersBoard.player, );

    // print("VM NEXT TURN isProtected: $isProtected");
    // print("VM NEXT TURN value: $value");
    _clearDataNextTurnState();
    _checkersBoard.nextTurn();
    _setCurrentPlayer(_checkersBoard.player);
    bool isGameOver = _checkersBoard.isGameOver(false);
    print("VM NEXT TURN isGameOver: $isGameOver");
    _isAITurnController.add(_isAITurn());
    _checkersBoard.setHistoryAvailability(true);
  }

  bool _isAITurn() => currentPlayer == aiType && SettingsRepository().isAIMode;

  PathPawn? aIMove() {
    // PathPawn? path = ComputerPlayer(SettingsRepository().depthLevel)
    //     .getBestMoveForAI(_checkersBoard);
    //
    // PathPawn? path = ComputerPlayerPro(SettingsRepository().depthLevel)
    //     .getBestMoveForAI(_checkersBoard);
    PathPawn? path = Computer().alphaBetaSearch(_checkersBoard);
    return path;
  }

  void _endProcess() => _isInProcess = false;

  void _startProcess() => _isInProcess = true;

  void _clearDataNextTurnState() {
    _pawnPaths.clear();
    _pathPawn = PathPawn.createEmpty();
  }

  void onFinishAnimateCrown(Pawn pawn) {
    if (pawn.isKing) return;
    _markedKings.add(pawn.id);
  }

  bool isAlreadyMarkedKing(String id) => _markedKings.contains(id);

  void onPawnMoveAnimationStart() {
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
    _isAITurnController.close();
    super.dispose();
  }

  void _updatePawnsStatus() {
    SummarizerPawns summarizerPawns =
        PawnsOperation().pawnsSummarize(_checkersBoard.board);
    String summarize =
        "BLACK PAWNS ${summarizerPawns.totalBlackPawns}, KINGS: ${summarizerPawns.totalBlackKings}\n"
        "WHITE PAWNS ${summarizerPawns.totalWithePawns}, KINGS: ${summarizerPawns.totalWitheKings}";
    pawnsStatus.value = summarize;
  }
}
