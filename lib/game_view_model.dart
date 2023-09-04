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

  set path(List<Path> paths) {
    _paths = paths;
    notifyListeners();
  }

  set game(CheckersBoard checkersBoard) {
    _game = checkersBoard;
    notifyListeners();
  }

  set selectedRow(int row) {
    _selectedRow = row;
    notifyListeners();
  }

  set selectedCol(int col) {
    _selectedCol = col;
    notifyListeners();
  }

  set destinationRow(int row) {
    _destinationRow = row;
    notifyListeners();
  }

  set destinationCol(int col) {
    _destinationCol = col;
    notifyListeners();
  }

  bool _isContinuePath = false;

  void onTapBoardGame(int row, int col) {
    List<Path> paths = _isContinuePath
        ? _game.getPossibleContinuePaths(row, col)
        : _game.getPossiblePaths(row, col);
    _paths.clear();
    _paths.addAll(paths);
    notifyListeners();
    if (paths.isNotEmpty) {
      _setSelectPiece(row, col);
      return;
    } else {
      Path? path =
          _game.getPathByEndPosition(_selectedRow, _selectedCol, row, col);
      if (path != null) {
        _game.performMove(_selectedRow, _selectedCol, row, col, path);
        notifyListeners();
        _isContinuePath = _game.isContinuePaths(row, col, path);

        if (_isContinuePath) {
          print("CONTINUE CAPTURE");
          onTapBoardGame(row, col);
        } else {
          print("NOT CONTINUE CAPTURE");
          _nextTurn();
        }
      }
    }
  }

  void _setSelectPiece(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
    notifyListeners();
  }

  void _nextTurn() {
    _clearPrevSelected();
    _paths.clear();
    _game.nextTurn();
  }

  void _clearPrevSelected() {
    _selectedRow = -1;
    _selectedCol = -1;
    _isContinuePath = false;
  }
}
