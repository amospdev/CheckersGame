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

  TapOnBoard onTapBoardGame(int row, int col) {
    List<Path> paths = _game.getPossiblePaths(row, col);
    _paths.clear();
    _paths.addAll(paths);
    if (paths.isNotEmpty) {
      _selectPiece(row, col);
      return TapOnBoard.START;
    } else {
      Path? path = _game.getPathByEndPosition(
          _selectedRow, _selectedCol, row, col);
      if (path != null) {
        _selectTargetCell(row, col);
        return TapOnBoard.END;
      }
    }
    return TapOnBoard.UNVALID;
  }

  void onTapEndPosition() {
    Path? path = _game.getPathByEndPosition(
        _selectedRow, _selectedCol, _destinationRow, _destinationCol);
    if (path == null) return;
    _game.performMove(
        _selectedRow, _selectedCol, _destinationRow, _destinationCol, path);
    notifyListeners();
    _nextTurn();
  }

  void _selectPiece(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
    notifyListeners();
  }

  void _selectTargetCell(int row, int col) {
    _destinationRow = row;
    _destinationCol = col;
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
    _destinationRow = -1;
    _destinationCol = -1;
  }

  List<PositionDetails> onStartAnimation()  {
    Path? path = _game.getPathByEndPosition(
        _selectedRow, _selectedCol, _destinationRow, _destinationCol);
    if(path == null) return [];

    return path.positionDetails;
  }

  void onPoint(Position currPosition, Position nextPosition) {
    _selectedRow = currPosition.row;
    _selectedCol = currPosition.column;
    _destinationRow = nextPosition.row;
    _destinationCol = nextPosition.column;
  }
}

enum TapOnBoard {
  START,
  END,
  UNVALID,
}
