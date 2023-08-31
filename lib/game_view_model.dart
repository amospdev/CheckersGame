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
  Path _currPath = Path.createEmpty();

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

  void onTapBoardGame(int row, int col) {
    List<Path> paths = _game.getPossiblePaths(row, col);
    _paths.clear();
    _paths.addAll(paths);
    notifyListeners();
    print("VM onTapBoardGame paths size: ${paths.length}");
    if (paths.isNotEmpty) {
      _selectPiece(row, col);
      return;
    } else {
      _currPath =
          _game.getPathByEndPosition(_selectedRow, _selectedCol, row, col);
      if (_isCurrPathExist()) {
        _selectTargetCell(row, col, _currPath);
        // _nextTurn();
      }
    }
  }

  bool _isCurrPathExist() => _currPath.positionDetails.isNotEmpty;

  void _selectPiece(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
    notifyListeners();
  }

  void _selectTargetCell(int row, int col, Path currPath) async {
    print("VM _selectTargetCell: $row, $col");

    for (final (index, positionDetails) in currPath.positionDetails.indexed) {
      // if (index == 0) continue;
      if (index + 1 >= currPath.positionDetails.length) break;
      _selectedRow = currPath.positionDetails[index].position.row;
      _selectedCol = currPath.positionDetails[index].position.column;
      _destinationRow = currPath.positionDetails[index + 1].position.row;
      _destinationCol = currPath.positionDetails[index + 1].position.column;
      print(
          "1 VM VM SR: $_selectedRow, SC: $_selectedCol, DR: $_destinationRow, DC: $_destinationCol index: ${index}, index + 1: ${(index + 1)}");

      notifyListeners();
      await Future.delayed(Duration(milliseconds: 1000));
      print(
          "2 VM VM SR: $_selectedRow, SC: $_selectedCol, DR: $_destinationRow, DC: $_destinationCol");
    }

    endTurn();
  }

  void endTurn() {
    if (_selectedRow != -1 &&
        _selectedCol != -1 &&
        _destinationRow != -1 &&
        _destinationCol != -1) {
      print(
          "VM endTurn $_selectedRow, $_selectedCol, $_destinationRow, $_destinationCol, $_currPath");
      _game.performMove(_selectedRow, _selectedCol, _destinationRow,
          _destinationCol, _currPath);
      _nextTurn();
      notifyListeners();
    }
  }

  void _nextTurn() {
    _clearPrevSelected();
    _clearPrevPaths();
    _game.nextTurn();
  }

  void _clearPrevSelected() {
    _selectedRow = -1;
    _selectedCol = -1;
    _destinationRow = -1;
    _destinationCol = -1;
  }

  void _clearPrevPaths() {
    _paths.clear();
    _currPath = Path.createEmpty();
  }
}
