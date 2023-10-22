import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/enum/game_rules_type.dart';
import 'game/checkers_board.dart';

class GameViewModel extends ChangeNotifier {
  final CheckersBoard _game = CheckersBoard(GameRulesType.KING_SINGLE);

  bool _isContinuePath = false;
  int _selectedRow = -1;
  int _selectedCol = -1;
  int _destinationRow = -1;
  int _destinationCol = -1;
  int _pathSize = -1;

  int get pathSize => _pathSize;

  List<Path> _paths = [];
  bool _isInProcess = false;

  final List<PositionDetails> _positionDetailsList = [];

  List<PositionDetails> get positionDetailsList => _positionDetailsList;

  // List<CellDetails> get board => _board;

  ValueNotifier<List<CellDetails>> boardValueNotifier =
      ValueNotifier<List<CellDetails>>([]);

  // List<CellDetails> _board = [];

  ValueNotifier<List<Pawn>> pawnsValueNotifier = ValueNotifier<List<Pawn>>([]);
  ValueNotifier<Offset> pawnMoveOffsetValueNotifier =
      ValueNotifier<Offset>(Offset.zero);

  CellType get currentPlayer => _currentPlayer;

  CellType _currentPlayer = CellType.UNDEFINED;

  GameViewModel() {
    _setCheckersBoard(_game.board);
    _setPawns(_game.pawns);
    _setCurrentPlayer(_game.player);
    notifyListeners();
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
    notifyListeners();
    print("onClickCell: $tapOnBoard");
    return tapOnBoard;
  }

  void onClickPawn(int row, int column) {
    if (_isContinuePath) return;
    TapOnBoard tapOnBoard = onTapBoardGame(row, column);
    notifyListeners();

    print(
        "onClickPawn: $tapOnBoard, currPath.isContinuePath: ${_isContinuePath}");
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
    print(
        "VM onTapBoardGame isValidStartCellSelected: $isValidStartCellSelected");

    if (isValidStartCellSelected) {
      _selectedStartCellActions(row, column);
      _setCheckersBoard(_game.board);
      return TapOnBoard.START;
    }

    _destinationRow = row;
    _destinationCol = column;

    Path path =
        _game.getPathByEndPosition(_destinationRow, _destinationCol, _paths);
    bool isValidDestinationCellSelected = path.isValidPath();

    print(
        "VM onTapBoardGame isValidDestinationCellSelected: $isValidStartCellSelected");

    if (isValidDestinationCellSelected) {
      _pathSize = path.positionDetailsList.length;
      _isContinuePath = path.isContinuePath;
      return TapOnBoard.END;
    }

    return TapOnBoard.UNVALID;
  }

  void onPawnMoveAnimationFinish() {
    print("VM onPawnMoveAnimationFinish");

    _selectedDestinationCellActions(_destinationRow, _destinationCol, _paths);
    _setCheckersBoard(_game.board);
    _setPawns(_game.pawns);
    _isInProcess = false;
    notifyListeners();
    _continueNextIterationOrTurn(_destinationRow, _destinationCol);
  }

  void _setSelectPiece(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
  }

  void _setCheckersBoard(List<List<CellDetails>> board) {
    // boardValueNotifier.value.clear();
    boardValueNotifier.value = board.expand((element) => element).toList();
  }

  void _setPawns(List<Pawn> pawns) {
    // pawnsValueNotifier.value.clear();
    pawnsValueNotifier.value = pawns;
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
  }

  void _clearPrevSelected() {
    _selectedRow = -1;
    _selectedCol = -1;
  }

  void _clearPrevPaths() => _paths.clear();

  void onFinishAnimateCrown(Pawn? pawn) {
    print("VM onFinishAnimateCrown");

    if (pawn == null || !pawn.isKing) return;

    _game.setIsAlreadyKing(pawn, true);
  }

  void onPawnMoveAnimationStart() {
    _isInProcess = true;
  }

  void _clearPathSize() {
    _pathSize = -1;
  }

  Pawn getCurrPawn() => pawnsValueNotifier.value.firstWhere(
      (pawn) => pawn.row == _selectedRow && pawn.column == _selectedCol,
      orElse: () => Pawn.createEmpty());

  void onMovePawn(Offset value) {
    print("VM onMovePawn value: $value");
    pawnMoveOffsetValueNotifier.value = value;
    // getCurrPawn().setOffset(value);
    // notifyListeners();
  }
}

enum TapOnBoard {
  START,
  END,
  UNVALID,
  VALID,
}
