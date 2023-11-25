import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/enum/cell_type.dart';

const String ROW = "|";
const String EM = "   |";
const String UV = " # |";
const String BP = " ● |";
const String BG = " 👑 |";
const String WP = " ○ |";
const String WK = " ♔ |";

abstract class BoardGameFactory {
  final int sizeBoard = 8;

  static List<List<CellDetails>> createBoard(BoardType type) {
    switch (type.runtimeType) {
      case RealBoard:
        return RealBoardGame().create();
      case TestBoard:
        return TestBoardGame().create();
      case MockBoard:
        return MockBoardGame(type.dataBoard()).create();
      default:
        return [];
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
        CellType currCellType = CellType.UNDEFINED;
        int id = (sizeBoard * row) + column;

        Color cellColor = (row + column) % 2 == 0 ? Colors.white : Colors.brown;
        if ((row + column) % 2 == 0) {
          currCellType = CellType.UNVALID;
        } else {
          if (row < (sizeBoard / 2) - 1) {
            currCellType = CellType.BLACK;
          } else if (row > (sizeBoard / 2)) {
            currCellType = CellType.WHITE;
          } else if (row == (sizeBoard / 2) - 1 || row == (sizeBoard / 2)) {
            currCellType = CellType.EMPTY;
          }
        }

        board[row][column] =
            CellDetails(currCellType, id, cellColor, row, column);
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
        CellType currCellType = CellType.EMPTY;
        int id = (sizeBoard * row) + column;

        Color cellColor = (row + column) % 2 == 0 ? Colors.white : Colors.brown;
        if ((row + column) % 2 == 0) {
          currCellType = CellType.UNVALID;
        } else {
          if (row < (sizeBoard / 2) - 1) {
            if (row == 0 && column == 7) {
              currCellType = CellType.BLACK;
            }
          } else if (row > (sizeBoard / 2)) {
            if (row == 7 && column == 2) {
              currCellType = CellType.WHITE;
            }
          } else if (row == (sizeBoard / 2) - 1 || row == (sizeBoard / 2)) {
            currCellType = CellType.EMPTY;
          }
        }

        board[row][column] =
            CellDetails(currCellType, id, cellColor, row, column);
      }
    }

    return board;
  }
}

class MockBoardGame extends BoardGameFactory {
  final List<List<String>> mockDataBoard;
  MockBoardGame(this.mockDataBoard);

  @override
  List<List<CellDetails>> create() => createMockBoard(mockDataBoard);

  List<List<CellDetails>> createMockBoard(List<List<String>> mockBoard) {
    List<List<CellDetails>> board = List.generate(sizeBoard,
        (i) => List<CellDetails>.filled(sizeBoard, CellDetails.createEmpty()));
    for (int row = 0; row < sizeBoard; row++) {
      for (int column = 0; column < sizeBoard; column++) {
        String symbol = mockBoard[row][column];

        CellType currCellType = CellType.UNDEFINED;
        int id = (sizeBoard * row) + column;

        Color cellColor = (row + column) % 2 == 0 ? Colors.white : Colors.brown;
        if ((row + column) % 2 == 0) {
          currCellType = CellType.UNVALID;
        } else {
          if (symbol == '●') {
            currCellType = CellType.BLACK;
          } else if (symbol == '○') {
            currCellType = CellType.WHITE;
          } else if (symbol.trim().isEmpty) {
            currCellType = CellType.EMPTY;
          } else if (symbol == '👑') {
            currCellType = CellType.BLACK_KING;
          } else if (symbol == '♔') {
            currCellType = CellType.WHITE_KING;
          }
        }

        board[row][column] =
            CellDetails(currCellType, id, cellColor, row, column);
      }
    }

    return board;
  }
}

abstract class BoardType {
  List<List<String>> dataBoard() => [];
}

class RealBoard extends BoardType {}

class TestBoard extends BoardType {}

class MockBoard extends BoardType {
  @override
  List<List<String>> dataBoard() => [
        ['#', ' ', '#', '●', '#', '●', '#', ' '],
        ['●', '#', '👑', '#', '●', '#', '●', '#'],
        ['#', '●', '#', ' ', '#', ' ', '#', '●'],
        ['●', '#', ' ', '#', '●', '#', ' ', '#'],
        ['#', ' ', '#', ' ', '#', '○', '#', '●'],
        ['○', '#', '○', '#', '○', '#', ' ', '#'],
        ['#', ' ', '#', '○', '#', ' ', '#', '○'],
        [' ', '#', ' ', '#', '○', '#', ' ', '#'],
      ];
}
