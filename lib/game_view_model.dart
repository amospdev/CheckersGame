import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'game/checkers_board.dart';

class GameViewModel extends ChangeNotifier {
  CheckersBoard _game = CheckersBoard();

  int _selectedRow = -1;
  int _selectedCol = -1;
  int _destinationRow = -1;
  int _destinationCol = -1;
  List<Path> _paths = [];

  List<List<CellType>> get board => _game.board;

  CellType get currentPlayer => _game.player;

  int get selectedRow => _selectedRow;

  int get selectedCol => _selectedCol;

  int get destinationRow => _destinationRow;

  int get destinationCol => _destinationCol;

  List<Path> get paths => _paths;

  _setPaths(List<Path> paths) {
    _paths = paths;
  }

  bool _isContinuePath = false;

  void _selectedStartCellActions(int row, int column) {
    print("onTapBoardGame _selectedStartCellActions");
    _setSelectPiece(row, column);

    List<Path> paths = _isContinuePath
        ? _game.getPossibleContinuePaths(row, column)
        : _game.getPossiblePaths(row, column);

    _setPaths(paths);
  }

  void _selectedDestinationCellActions(int endRow, int endColumn, Path path) {
    print("onTapBoardGame _selectedDestinationCellActions");
    print("onTapBoardGame Path: $path");
    _game.performMove(_selectedRow, _selectedCol, endRow, endColumn, path);
  }

  void _continuePathOptional(int endRow, int endColumn, Path path) {
    _isContinuePath = _game.isContinuePaths(endRow, endColumn, path);
    print("onTapBoardGame _isContinuePath: $_isContinuePath");

    if (_isContinuePath) {
      print("CONTINUE CAPTURE");
      onTapBoardGame(endRow, endColumn);
    } else {
      print("NOT CONTINUE CAPTURE");
      _nextTurn();
    }
  }

  void onTapBoardGame(int row, int column) {
    bool isValidStartCellSelected = _game.isValidStartCellSelected(row, column);

    if (isValidStartCellSelected) {
      _selectedStartCellActions(row, column);
      notifyListeners();
      return;
    }

    int endRow = row;
    int endColumn = column;
    bool isValidDestinationCellSelected =
        _game.isValidDestinationCellSelected(endRow, endColumn, _paths);
    Path? path = _game.getPathByEndPosition(endRow, endColumn, _paths);

    if (isValidDestinationCellSelected && path != null) {
      _selectedDestinationCellActions(endRow, endColumn, path);
      notifyListeners();
      _continuePathOptional(endRow, endColumn, path);
    } else {
      _clearPrevState();
      notifyListeners();
    }
  }

  void _setSelectPiece(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
  }

  void _nextTurn() {
    _clearPrevState();
    _game.nextTurn();
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

  void _clearIsContinuePath() {
    _isContinuePath = false;
  }

  void _clearPrevPaths() {
    _paths.clear();
  }
}
