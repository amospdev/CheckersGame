import 'package:untitled/data/ai/computer_player.dart';
import 'package:untitled/data/ai/heuristic_data.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/position_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/game/checkers_board.dart';

class Evaluator {
  int evaluate(
      bool max, List<List<CellDetails>> board, CheckersBoard checkersBoard) {
    final HeuristicData computerData = HeuristicData();
    final HeuristicData humanData = HeuristicData();

    for (int row = 0; row < CheckersBoard.sizeBoard; row++) {
      for (int column = 0; column < CheckersBoard.sizeBoard; column++) {
        CellDetails cellDetails = board[row][column];
        Position currPosition = Position(row, column);
        if (cellDetails.cellType != CellType.EMPTY &&
            cellDetails.cellType != CellType.UNVALID) {
          if (checkersBoard.isBlackByPosition(currPosition, board)) {
            if (checkersBoard.isKingByPosition(currPosition, board)) {
              humanData.king += 1;
            } else {
              humanData.pawn += 1;
            }

            if (row == 0) {
              humanData.backRowPiece += 1;
              humanData.protectedPiece += 1;
            } else {
              if (row == 3 || row == 4) {
                if (column >= 2 && column <= 5) {
                  humanData.middleBoxPiece += 1;
                } else {
                  humanData.middleRowPiece += 1;
                }
              }

              if (isRightVulnerable(board, checkersBoard, row, column)) {
                humanData.vulnerable += 1;
              }

              if (isLeftVulnerable(board, checkersBoard, row, column)) {
                humanData.vulnerable += 1;
              }

              if (isProtected(
                  row, column, board, cellDetails.cellType, checkersBoard)) {
                humanData.protectedPiece += 1;
              }
            }
          } else if (checkersBoard.isWhiteByPosition(currPosition, board)) {
            if (checkersBoard.isKingByPosition(currPosition, board)) {
              computerData.king += 1;
            } else {
              computerData.pawn += 1;
            }

            if (row == 7) {
              computerData.backRowPiece += 1;
              computerData.protectedPiece += 1;
            } else {
              if (row == 3 || row == 4) {
                if (column >= 2 && column <= 5) {
                  computerData.middleBoxPiece += 1;
                } else {
                  computerData.middleRowPiece += 1;
                }
              }

              if (isRightVulnerable(board, checkersBoard, row, column)) {
                computerData.vulnerable += 1;
              }

              if (isLeftVulnerable(board, checkersBoard, row, column)) {
                computerData.vulnerable += 1;
              }
              if (isProtected(
                  row, column, board, cellDetails.cellType, checkersBoard)) {
                computerData.protectedPiece += 1;
              }
            }
          }
        }
      }
    }

    final sum = computerData.subtract(humanData).sum;

    return (max ? sum : -sum).toInt();
  }
  
  bool isProtected(int row, int col, List<List<CellDetails>> board,
      CellType cellTypePlayer, CheckersBoard checkersBoard) {
    List<Position> checkPositions;

    if (cellTypePlayer == CellType.WHITE || cellTypePlayer == CellType.BLACK) {
      checkPositions = checkersBoard
          .getPieceDirections(cellTypePlayer: cellTypePlayer)
          .map((pos) => Position(row + pos.row, col + pos.column))
          .toList();
    } else if (cellTypePlayer == CellType.WHITE_KING ||
        cellTypePlayer == CellType.BLACK_KING) {
      checkPositions = checkersBoard
          .getKingDirections()
          .map((pos) => Position(row + pos.row, col + pos.column))
          .toList();
    } else {
      return false; // Return false if the cellType is not a piece or king.
    }

    for (Position pos in checkPositions) {
      if (!checkersBoard.isOpponentCell(pos, board, cellTypePlayer) &&
          !checkersBoard.isEmptyCellByPosition(pos, board)) {
        return true; // If there is a friendly piece in any of the directions, this piece is protected
      }
    }
    return false;
  }

  bool isLeftVulnerable(List<List<CellDetails>> board,
      CheckersBoard checkersBoard, int row, int col) {
    CellType cellType = board[row][col].cellType;
    bool isLeftTopVulnerable = false;
    bool isLeftBottomVulnerable = false;

    isLeftTopVulnerable = checkersBoard.isEmptyCellByPosition(
            Position(row - 1, col + 1), board) &&
        checkersBoard.isOpponentCellAI(Position(row + 1, col - 1), board);

    isLeftBottomVulnerable = checkersBoard.isEmptyCellByPosition(
            Position(row + 1, col + 1), board) &&
        checkersBoard.isOpponentCellAI(Position(row - 1, col - 1), board);

    if (cellType == CellType.BLACK_KING || cellType == CellType.WHITE_KING) {
      return isLeftTopVulnerable || isLeftBottomVulnerable;
    } else if (cellType == humanType) {
      return isLeftTopVulnerable;
    } else {
      return isLeftBottomVulnerable;
    }
  }

  bool isRightVulnerable(List<List<CellDetails>> board,
      CheckersBoard checkersBoard, int row, int col) {
    CellType cellType = board[row][col].cellType;
    bool isRightTopVulnerable = false;
    bool isRightBottomVulnerable = false;

    isRightTopVulnerable = checkersBoard.isEmptyCellByPosition(
            Position(row - 1, col - 1), board) &&
        checkersBoard.isOpponentCellAI(Position(row + 1, col + 1), board);

    isRightBottomVulnerable = checkersBoard.isEmptyCellByPosition(
            Position(row + 1, col - 1), board) &&
        checkersBoard.isOpponentCellAI(Position(row - 1, col + 1), board);

    if (cellType == CellType.BLACK_KING || cellType == CellType.WHITE_KING) {
      return isRightTopVulnerable || isRightBottomVulnerable;
    } else if (cellType == humanType) {
      return isRightTopVulnerable;
    } else {
      return isRightBottomVulnerable;
    }
  }
}
