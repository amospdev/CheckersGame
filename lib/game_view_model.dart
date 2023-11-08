import 'dart:async';

import 'package:flutter/material.dart';
import 'package:untitled/data/ai/computer_player.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position/position_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/enum/tap_on_board.dart';
import 'package:untitled/game/checkers_board.dart';
import 'package:untitled/settings_repo.dart';

class GameViewModel extends ChangeNotifier {
  final CheckersBoard _checkersBoard = CheckersBoard();
  final Set<int> _markedKings = {};

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
    List<PathPawn> pawnPaths = _checkersBoard.getPathsByStartCellSelected(
        row, column, _checkersBoard.board, _checkersBoard.player, false);
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
      int row, int column, List<PathPawn> pawnPaths) {
    _pawnPaths = pawnPaths;
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
    _checkersBoard.performMove(_checkersBoard.board, _pawnPaths, _pathPawn,
        isAI: false);
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
    print("CB NEXT TURN");
    _clearDataNextTurnState();
    _checkersBoard.nextTurn(_checkersBoard.board);
    _setCurrentPlayer(_checkersBoard.player);
    bool isGameOver = _checkersBoard.isGameOver(_checkersBoard.board, false);
    print("CB NEXT TURN isGameOver: $isGameOver");
    _isAITurnController.add(_isAITurn());
    _checkersBoard.setHistoryAvailability(true);
  }

  bool _isAITurn() => currentPlayer == aiType && SettingsRepository().isAIMode;

  PathPawn? aIMove() {
    ComputerPlayer aiPlayer = ComputerPlayer(SettingsRepository().depthLevel);
    PathPawn? path = aiPlayer.getBestMoveForAI(_checkersBoard);

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

  bool isAlreadyMarkedKing(int id) => _markedKings.contains(id);

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
}
