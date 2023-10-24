import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/enum/game_rules_type.dart';
import 'package:untitled/enum/tap_on_board.dart';
import 'game/checkers_board.dart';

class GameViewModel extends ChangeNotifier {
  final CheckersBoard _game = CheckersBoard(GameRulesType.KING_SINGLE);
  final Set<int> _markedKings = {};

  bool _isContinuePath = false;
  int _selectedRow = -1;
  int _selectedCol = -1;
  int _destinationRow = -1;
  int _destinationCol = -1;
  int _pathSize = -1;
  int _indexCurrPawn = -1;

  int get pathSize => _pathSize;
  Pawn? _currPawn;

  Pawn? get currPawn => _currPawn;

  List<Path> _paths = [];
  bool _isInProcess = false;

  final List<CellDetails> _boardCells = [];

  List<CellDetails> get boardCells => _boardCells;

  final List<Pawn> _pawns = [];

  List<Pawn> get pawns => _pawns;

  CellType get currentPlayer => _currentPlayer;

  CellType _currentPlayer = CellType.UNDEFINED;

  GameViewModel() {
    _setCheckersBoard(_game.flatBoard);
    _setPawns(_game.pawns);
    _setCurrentPlayer(_game.player);
  }

  _setPaths(List<Path> paths) {
    _paths = paths;
  }

  void _selectedStartCellActions(int row, int column) {
    _setSelectPiece(row, column);

    List<Path> paths =
        _game.getPossiblePathsByPosition(row, column, _isContinuePath);

    _setPaths(paths);
  }

  void _selectedDestinationCellActions(
          int endRow, int endColumn, List<Path> paths) =>
      _game.performMove(_selectedRow, _selectedCol, endRow, endColumn, paths);

  void _continueNextIterationOrTurn(int endRow, int endColumn) {
    _isContinuePath ? onTapBoardGame(endRow, endColumn) : _nextTurn();
  }

  TapOnBoard onClickCell(int row, int column) {
    TapOnBoard tapOnBoard = onTapBoardGame(row, column);
    return tapOnBoard;
  }

  void onClickPawn(int row, int column) {
    if (_isContinuePath) return;
    onTapBoardGame(row, column);
  }

  TapOnBoard _onTapBoardGameValidator(int row, int column) {
    if (_isInProcess) return TapOnBoard.UNVALID;

    if (_isContinuePath &&
        _paths
            .where((element) =>
                element.positionDetailsList.last.position ==
                Position(row, column))
            .isEmpty) {
      return TapOnBoard.UNVALID;
    }

    return TapOnBoard.VALID;
  }

  TapOnBoard onTapBoardGame(int row, int column) {
    TapOnBoard tapOnBoard = _onTapBoardGameValidator(row, column);
    if (tapOnBoard == TapOnBoard.UNVALID) return TapOnBoard.UNVALID;

    bool isValidStartCellSelected = _game.isValidStartCellSelected(row, column);

    if (isValidStartCellSelected) {
      _selectedStartCellActions(row, column);
      _setCheckersBoard(_game.flatBoard);
      return TapOnBoard.START;
    }

    _destinationRow = row;
    _destinationCol = column;

    Path path =
        _game.getPathByEndPosition(_destinationRow, _destinationCol, _paths);
    bool isValidDestinationCellSelected = path.isValidPath();

    if (isValidDestinationCellSelected) {
      _pathSize = path.positionDetailsList.length;
      _isContinuePath = path.isContinuePath;
      _setCurrPawn();
      _setIndexCurrPawn(_currPawn);
      return TapOnBoard.END;
    }

    return TapOnBoard.UNVALID;
  }

  void _setIndexCurrPawn(Pawn? currPawn) {
    if (currPawn == null) return;
    _indexCurrPawn = _game.pawnsWithoutKills.indexOf(currPawn);
  }

  void _setCurrPawn() {
    _currPawn = _game.pawnsWithoutKills.firstWhere((element) =>
        element.row == _selectedRow && element.column == _selectedCol)
      ..setPawnDataNotifier(isAnimating: true);
  }

  void onPawnMoveAnimationFinish() {
    _selectedDestinationCellActions(_destinationRow, _destinationCol, _paths);
    _setCheckersBoard(_game.flatBoard);
    _setPawns(_game.pawns);
    _isInProcess = false;
    _currPawn = null;
    _continueNextIterationOrTurn(_destinationRow, _destinationCol);
  }

  void _setSelectPiece(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
  }

  void _setCheckersBoard(List<CellDetails> flatBoard) {
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

    for (var (index, pawn) in newPawns.indexed) {
      if (pawn.pawnDataNotifier.value.isKilled) {
        Pawn oldPawn = _pawns[index];
        if (!oldPawn.pawnDataNotifier.value.isKilled) {
          oldPawn.setPawnDataNotifier(isKilled: true);
        }
      }
    }

    if (_indexCurrPawn != -1) {
      _pawns[_indexCurrPawn].setPawnDataNotifier(isAnimating: false);
    }
  }

  void _setCurrentPlayer(CellType currentPlayer) {
    _currentPlayer = currentPlayer;
  }

  void _nextTurn() {
    _clearPrevState();
    _game.nextTurn();
    _setCurrentPlayer(_game.player);
  }

  void _clearPrevState() {
    _clearPrevSelected();
    _clearPrevPaths();
    _clearPathSize();
    _clearIndexCurrPawn();
  }

  void _clearPrevSelected() {
    _clearSelectedRow();
    _clearSelectedColumn();
  }

  void _clearSelectedRow() => _selectedRow = -1;

  void _clearSelectedColumn() => _selectedCol = -1;

  void _clearPrevPaths() => _paths.clear();

  void onFinishAnimateCrown(Pawn? pawn) {
    if (pawn == null || _isKingPawn(pawn)) return;
    _markedKings.add(pawn.id);
  }

  bool _isKingPawn(Pawn? pawn) => pawn?.isKing ?? false;

  bool isAlreadyMarkedKing(int id) => _markedKings.contains(id);

  void onPawnMoveAnimationStart() => _isInProcess = true;

  void _clearPathSize() => _pathSize = -1;

  void onMovePawn(Offset value) => currPawn?.setPawnDataNotifier(offset: value);

  void _clearIndexCurrPawn() => _indexCurrPawn = -1;
}
