import 'package:flutter/material.dart';
import 'package:untitled/data/ai/computer_player.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/enum/tap_on_board.dart';
import 'package:untitled/extensions/cg_collections.dart';
import 'package:untitled/extensions/cg_optional.dart';
import 'package:untitled/game/checkers_board.dart';
import 'package:untitled/settings_repo.dart';

class GameViewModel extends ChangeNotifier {
  final CheckersBoard _game = CheckersBoard();
  final Set<int> _markedKings = {};

  bool _isContinuePath = false;
  int _selectedRow = -1;
  int _selectedCol = -1;
  int _destinationRow = -1;
  int _destinationCol = -1;
  int _pathSize = -1;

  bool aiMode = SettingsRepository().isAIMode;

  int get pathSize => _pathSize;
  Pawn? _currPawn;

  Pawn? get currPawn => _currPawn;

  List<PathPawn> _paths = [];
  bool _isInProcess = false;

  final List<CellDetails> _boardCells = [];

  List<CellDetails> get boardCells => _boardCells;

  final List<Pawn> _pawns = [];

  List<Pawn> get pawns => _pawns;

  CellType get currentPlayer => _currentPlayer;

  CellType _currentPlayer = CellType.UNDEFINED;

  GameViewModel() {
    _initializeGame();
  }

  void _initializeGame() {
    _setCheckersBoard(_game.flatBoard);
    _setPawns(_game.pawns);
    _setCurrentPlayer(_game.player);
  }

  _setPaths(List<PathPawn> paths) => _paths = paths;

  void _performMove() => _game.performMove(_selectedRow, _selectedCol,
      _destinationRow, _destinationCol, _paths, _game.board);

  void _continueNextIterationOrTurn(int endRow, int endColumn) =>
      _isContinuePath ? onTapBoardGame(endRow, endColumn) : _nextTurn();

  TapOnBoard onClickCell(int row, int column) => onTapBoardGame(row, column);

  void onClickPawn(int row, int column) {
    if (_isContinuePath) return;
    onTapBoardGame(row, column);
  }

  bool _isValidTap(int row, int column) {
    if (_isInProcess) return false;

    if (_isNotEqualEndPathContinuePathState(row, column)) return false;

    return true;
  }

  bool _isNotEqualEndPathContinuePathState(int row, int column) =>
      _isContinuePath &&
      _paths.every((element) =>
          element.positionDetailsList.last.position != Position(row, column));

  TapOnBoard onTapBoardGame(int rowStartOrEnd, int columnStartOrEnd) {
    if (!_isValidTap(rowStartOrEnd, columnStartOrEnd)) {
      return TapOnBoard.UNVALID;
    }

    if (_game.isValidStartCellSelected(
        rowStartOrEnd, columnStartOrEnd, _game.board, _game.player)) {
      return _handleStartCellTap(rowStartOrEnd, columnStartOrEnd);
    }

    if (_game.isValidEndCellSelected(rowStartOrEnd, columnStartOrEnd, _paths)) {
      return _handleDestinationCellTap(rowStartOrEnd, columnStartOrEnd);
    }

    return TapOnBoard.UNVALID;
  }

  TapOnBoard _handleStartCellTap(int row, int column) {
    _setSelectPiece(row, column);
    _setPaths(_game.getPossiblePathsByPosition(
        row, column, _isContinuePath, _game.board, _game.player,
        isAIMode: false));
    _setCheckersBoard(_game.flatBoard);
    return TapOnBoard.START;
  }

  TapOnBoard _handleDestinationCellTap(int row, int column) {
    _setDestinationPiece(row, column);

    Optional<PathPawn> optionalPath =
        _game.getPathByEndPosition(_destinationRow, _destinationCol, _paths);

    if (optionalPath.isAbsent) return TapOnBoard.UNVALID;

    _pathSize = optionalPath.value.positionDetailsList.length;
    _isContinuePath = optionalPath.value.isContinuePath;
    _setCurrPawn();
    return TapOnBoard.END;
  }

  void _setCurrPawn() {
    Pawn? currPawn = _game.pawnsWithoutKills.firstWhereOrNull((element) =>
        element.row == _selectedRow && element.column == _selectedCol);

    if (currPawn == null) return;

    currPawn.setPawnDataNotifier(isAnimating: true);

    _currPawn = currPawn;
  }

  Future<bool> onPawnMoveAnimationFinish() async {
    _performMove();
    _setCheckersBoard(_game.flatBoard);
    _setPawns(_game.pawns);
    _clearDataPreNextTurnState();
    _continueNextIterationOrTurn(_destinationRow, _destinationCol);
    await Future.delayed(const Duration(milliseconds: 500));
    return Future.value(true);
  }

  void _setSelectPiece(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
  }

  void _setDestinationPiece(int row, int col) {
    _destinationRow = row;
    _destinationCol = col;
  }

  void _setCheckersBoard(Iterable<CellDetails> flatBoard) {
    if (_boardCells.isEmpty) {
      _boardCells.addAll(flatBoard);
      return;
    }

    for (final (index, cellDetails) in flatBoard.indexed) {
      final tmpCell = _boardCells[index];

      if (tmpCell.color.value != cellDetails.tmpColor.value ||
          tmpCell.tmpColor.value != cellDetails.color.value) {
        tmpCell.changeColor(cellDetails.tmpColor);
      }
    }
  }

  void _setPawns(List<Pawn> newPawns) {
    if (_pawns.isEmpty) {
      _pawns.addAll(newPawns);
      return;
    }

    for (var (index, newPawn) in newPawns.indexed) {
      if (newPawn.pawnDataNotifier.value.isKilled) {
        Pawn oldPawn = _pawns[index];
        if (!oldPawn.pawnDataNotifier.value.isKilled) {
          oldPawn.setPawnDataNotifier(isKilled: true);
        }
      }
    }

    _currPawn?.setPawnDataNotifier(isAnimating: false);
  }

  void _setCurrentPlayer(CellType currentPlayer) =>
      _currentPlayer = currentPlayer;

  void _nextTurn() {
    print("CB NEXT TURN");
    _clearDataNextTurnState();
    _game.nextTurn(_game.board);
    _setCurrentPlayer(_game.player);
    bool isGameOver = _game.isGameOver(_game.board);
    print("CB NEXT TURN isGameOver: $isGameOver");

  }

  bool maybeAI() => currentPlayer == aiType && aiMode;

  PathPawn? aIMove() {
    ComputerPlayer aiPlayer = ComputerPlayer(SettingsRepository().depthLevel);
    PathPawn? path = aiPlayer.getBestMoveForAI(_game);

    return path;
  }

  void _clearDataPreNextTurnState() {
    _resetIsInProcess();
    _resetCurrPawn();
  }

  void _clearDataNextTurnState() {
    _clearPrevSelected();
    _clearPrevPaths();
    _resetPathSize();
  }

  void _clearPrevSelected() {
    _resetSelectedRow();
    _resetSelectedColumn();
  }

  void _resetIsInProcess() => _isInProcess = false;

  void _startProcess() => _isInProcess = true;

  void _resetCurrPawn() => _currPawn = null;

  void _resetSelectedRow() => _selectedRow = -1;

  void _resetSelectedColumn() => _selectedCol = -1;

  void _clearPrevPaths() => _paths.clear();

  void onFinishAnimateCrown(Pawn? pawn) {
    if (pawn == null || _isKingPawn(pawn)) return;
    _markedKings.add(pawn.id);
  }

  bool _isKingPawn(Pawn? pawn) => pawn?.isKing ?? false;

  bool isAlreadyMarkedKing(int id) => _markedKings.contains(id);

  void onPawnMoveAnimationStart() {
    _startProcess();
    currPawn?.setPawnDataNotifier(offset: _getDestinationOffset());
  }

  Offset _getDestinationOffset() =>
      Offset(_destinationCol.toDouble(), _destinationRow.toDouble());

  void _resetPathSize() => _pathSize = -1;

  void onMovePawn(Offset value) => currPawn?.setPawnDataNotifier(offset: value);
}
