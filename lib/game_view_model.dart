import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:untitled/game/AIPlayer.dart';
import 'game/checkers_board.dart';

class GameViewModel extends ChangeNotifier {
  final CheckersBoard _game =
      CheckersBoard(GameRulesType.KING_SINGLE, [], CellType.BLACK);
  bool _isContinuePath = false;
  int _selectedRow = -1;
  int _selectedCol = -1;
  int _destinationRow = -1;
  int _destinationCol = -1;
  List<Path> _paths = [];

  List<List<CellType>> get board => _board;
  List<List<CellType>> _board = [];

  CellType get currentPlayer => _currentPlayer;

  CellType _currentPlayer = CellType.UNDEFINED;

  int get selectedRow => _selectedRow;

  int get selectedCol => _selectedCol;

  int get destinationRow => _destinationRow;

  int get destinationCol => _destinationCol;

  List<Path> get paths => _paths;

  GameViewModel() {
    _setCheckersBoard(_game.board);
    _setCurrentPlayer(_game.player);
    notifyListeners();
  }

  _setPaths(List<Path> paths) {
    _paths = paths;
  }

  void _selectedStartCellActions(int row, int column) {
    _setSelectPiece(row, column);

    List<Path> paths = _getPathsByContinuePathState(row, column);

    _setPaths(paths);
  }

  List<Path> _getPathsByContinuePathState(int row, int column) =>
      _isContinuePath
          ? _game.getPossibleContinuePaths(row, column)
          : _getPossiblePaths(row, column, true);

  List<Path> _getPossiblePaths(int row, int column, bool isAI) {
    List<Path> paths = _game.getPossiblePaths(row, column, true);
    for (Path path in paths) {
      if (path.positionDetails.any((element) => element.isCapture)) {
        List<PositionDetails> positionDetailsTmp = [];
        positionDetailsTmp.add(path.positionDetails[0]);
        positionDetailsTmp.add(path.positionDetails[1]);
        positionDetailsTmp.add(path.positionDetails[2]);
        path.positionDetails.clear();
        path.positionDetails.addAll(positionDetailsTmp);
      }
    }
    return paths;
  }

  void _selectedDestinationCellActions(int endRow, int endColumn, Path path) =>
      _game.performMove(_selectedRow, _selectedCol, endRow, endColumn, path);

  void _continuePathOptional(int endRow, int endColumn, Path path) {
    _updateIsContinuePath(endRow, endColumn, path);

    _nextActionByContinuePathState(endRow, endColumn);
  }

  void _nextActionByContinuePathState(int endRow, int endColumn) =>
      _isContinuePath ? onTapBoardGame(endRow, endColumn) : _nextTurn();

  void _updateIsContinuePath(int endRow, int endColumn, Path path) =>
      _isContinuePath = _game.isContinuePaths(endRow, endColumn, path);

  void onTapBoardGame(int row, int column) {
    bool isValidStartCellSelected = _game.isValidStartCellSelected(row, column);

    if (isValidStartCellSelected) {
      _selectedStartCellActions(row, column);
      notifyListeners();
      return;
    }

    int endRow = row;
    int endColumn = column;

    Path? path = _game.getPathByEndPosition(endRow, endColumn, _paths);
    bool isValidDestinationCellSelected = path != null;

    if (isValidDestinationCellSelected) {
      _selectedDestinationCellActions(endRow, endColumn, path);
      _setCheckersBoard(_game.board);
      notifyListeners();
      _continuePathOptional(endRow, endColumn, path);
    } /* else {
      _clearPrevState();
      notifyListeners();
    }*/
  }

  void _setSelectPiece(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
  }

  void _setCheckersBoard(List<List<CellType>> board) {
    _board.clear();
    _board.addAll(_game.board);
  }

  void _setCurrentPlayer(CellType currentPlayer) {
    _currentPlayer = currentPlayer;
  }

  void _nextTurn() {
    _clearPrevState();
    _game.nextTurn();
    _setCurrentPlayer(_game.player);
    // _checkAITurn();
  }

  void _checkAITurn() {
    // await Future.delayed(Duration(milliseconds: 1500));
    AIPlayer aiPlayer = AIPlayer();
    print("*****_checkAITurn*******");

    if (currentPlayer == CellType.WHITE) {
      print("*****AI AI AI*******");
      print("*********************");

      Path path = aiPlayer.makeMove(_game);

      // if (path == null) {
      //   print("NO ELEMENT path: $path");
      //   return;
      // }

      print("RESULT path: $path");

      Position start = path.positionDetails.first.position;
      Position end = path.positionDetails.last.position;
      onTapBoardGame(start.row, start.column);
      onTapBoardGame(end.row, end.column);
    }
  }

  void _clearPrevState() {
    _clearIsContinuePath();
    _clearPrevSelected();
    _clearPrevPaths();
  }

  void _clearPrevSelected() {
    _selectedRow = -1;
    _selectedCol = -1;
  }

  void _clearIsContinuePath() => _isContinuePath = false;

  void _clearPrevPaths() => _paths.clear();
}
