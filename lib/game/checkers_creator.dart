import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/enum/cell_type.dart';

class CheckersCreator {}

enum BoardType { real, test }

abstract class BoardGameFactory {
  final int sizeBoard = 8;

  static List<List<CellDetails>> createBoard(BoardType type) {
    switch (type) {
      case BoardType.real:
        return RealBoardGame().create();
      case BoardType.test:
        return TestBoardGame().create();
      // default: return null;
    }
  }

  List<List<CellDetails>> create();
}

class RealBoardGame extends BoardGameFactory {
  @override
  List<List<CellDetails>> create() => _createBoard();

  List<List<CellDetails>> _createBoard() {
    List<List<CellDetails>> board = List.generate(sizeBoard,
        (i) => List<CellDetails>.filled(sizeBoard, CellDetails.createEmpty()));
    for (int row = 0; row < sizeBoard; row++) {
      for (int column = 0; column < sizeBoard; column++) {
        CellType tmpCellType = CellType.UNDEFINED;
        int id = (sizeBoard * row) + column;

        Color cellColor = (row + column) % 2 == 0 ? Colors.white : Colors.brown;
        if ((row + column) % 2 == 0) {
          tmpCellType = CellType.UNVALID;
        } else {
          if (row < (sizeBoard / 2) - 1) {
            tmpCellType = CellType.BLACK;
          } else if (row > (sizeBoard / 2)) {
            tmpCellType = CellType.WHITE;
          } else if (row == (sizeBoard / 2) - 1 || row == (sizeBoard / 2)) {
            tmpCellType = CellType.EMPTY;
          }
        }

        if (tmpCellType == CellType.WHITE || tmpCellType == CellType.BLACK) {
          // _pawns.add(Pawn(
          //     id: id + 100,
          //     row: row,
          //     cellTypePlayer: tmpCellType,
          //     index: _pawns.length,
          //     column: column,
          //     color: tmpCellType == CellType.WHITE ? Colors.white : Colors.grey,
          //     isKing: false));
        }

        board[row][column] =
            CellDetails(tmpCellType, id, cellColor, row, column);
      }
    }

    return board;
  }
}

class TestBoardGame extends BoardGameFactory {
  @override
  List<List<CellDetails>> create() => _createBoardTest();

  List<List<CellDetails>> _createBoardTest() {
    List<List<CellDetails>> board = List.generate(sizeBoard,
        (i) => List<CellDetails>.filled(sizeBoard, CellDetails.createEmpty()));
    for (int row = 0; row < sizeBoard; row++) {
      for (int column = 0; column < sizeBoard; column++) {
        CellType tmpCellType = CellType.EMPTY;
        int id = (sizeBoard * row) + column;

        Color cellColor = (row + column) % 2 == 0 ? Colors.white : Colors.brown;
        if ((row + column) % 2 == 0) {
          tmpCellType = CellType.UNVALID;
        } else {
          if (row < (sizeBoard / 2) - 1) {
            if (column % 2 == 0) {
              tmpCellType = CellType.BLACK_KING;
            }
          } else if (row > (sizeBoard / 2)) {
            if (column % 2 != 0) {
              tmpCellType = CellType.WHITE_KING;
            }
          } else if (row == (sizeBoard / 2) - 1 || row == (sizeBoard / 2)) {
            tmpCellType = CellType.EMPTY;
          }
        }

        if (tmpCellType == CellType.WHITE ||
            tmpCellType == CellType.BLACK ||
            tmpCellType == CellType.WHITE_KING ||
            tmpCellType == CellType.BLACK_KING) {
          // _pawns.add(Pawn(
          //     id: id + 100,
          //     row: row,
          //     column: column,
          //     cellTypePlayer: tmpCellType,
          //     index: _pawns.length,
          //     color: tmpCellType == CellType.WHITE_KING
          //         ? Colors.white
          //         : Colors.grey,
          //     isKing: true));
        }

        board[row][column] =
            CellDetails(tmpCellType, id, cellColor, row, column);
      }
    }

    return board;
  }
}