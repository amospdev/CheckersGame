import 'package:untitled/data/ai/computer_player.dart';
import 'package:untitled/data/ai/heuristic_data.dart';
import 'package:untitled/data/cell/cell_details.dart';
import 'package:untitled/data/pawn/pawn_path.dart';
import 'package:untitled/data/cell/position_details.dart';
import 'package:untitled/data/cell/position_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/game/checkers_board.dart';

class Evaluator {
  HeuristicData computerData = HeuristicData();
  HeuristicData humanData = HeuristicData();

  double evaluate(bool max, List<List<CellDetails>> board,
      CheckersBoard checkersBoard, CellType cellTypePlayerTurn) {
    computerData = HeuristicData();
    humanData = HeuristicData();

    for (int row = 0; row < CheckersBoard.sizeBoard; row++) {
      for (int column = 0; column < CheckersBoard.sizeBoard; column++) {
        CellDetails currCellDetails = board[row][column];
        if (currCellDetails.isNotSomePawn) continue;

        bool isMiddleBox = getScoreType(row, column) == ScoreType.MIDDLE_BOX;
        bool isMiddleRow = getScoreType(row, column) == ScoreType.MIDDLE_ROW;

        bool isPawnProtected =
            isProtected(row, column, board, currCellDetails.cellTypePlayer);

        if (currCellDetails.isBlack) {
          if (currCellDetails.isKing) humanData.king += 1;

          if (currCellDetails.isPawn) humanData.pawn += 1;

          if (isPawnProtected) humanData.protectedPiece += 1;

          if (isMiddleBox) humanData.middleBoxPiece += 1;

          if (isMiddleRow) humanData.middleRowPiece += 1;

          bool isBackRowBlackPosition = row == 0;
          if (isBackRowBlackPosition) humanData.backRowPiece += 1;
        } else if (currCellDetails.isWhite) {
          if (currCellDetails.isKing) computerData.king += 1;

          if (currCellDetails.isPawn) computerData.pawn += 1;

          if (isPawnProtected) computerData.protectedPiece += 1;

          if (isMiddleBox) computerData.middleBoxPiece += 1;

          if (isMiddleRow) computerData.middleRowPiece += 1;

          bool isBackRowWhitePosition = row == CheckersBoard.sizeBoard - 1;
          if (isBackRowWhitePosition) {
            computerData.backRowPiece += 1;
          }
        }

        vulnerablePawns(cellTypePlayerTurn, checkersBoard, currCellDetails,
            board, computerData, humanData);
      }
    }

    print(
        "EVAL final computerScore: ${computerData.sum}, humanScore: ${humanData.sum}");

    final sum = computerData.subtract(humanData).sum;

    final result = (max ? sum : -sum);

    return result;
  }

  bool hasEmptyCellsOnPromotionLine(int row) {
    return row == 0 || row == CheckersBoard.sizeBoard - 1;
  }

  int distanceToPromotion(CellType cellTypePlayer, int row) {
    int promotionLineRow =
        cellTypePlayer == humanType ? CheckersBoard.sizeBoard - 1 : 0;
    return (row - promotionLineRow).abs();
  }

  bool isEmpty(Position position, List<List<CellDetails>> board) {
    return position.isInBounds &&
        board[position.row][position.column].isEmptyCell;
  }

  bool containsOpponentKing(
    Position position,
    List<List<CellDetails>> board,
    CellType cellTypePlayer,
  ) {
    if (position.isNotInBounds) return false;

    if (board[position.row][position.column].isNotKing) return false;

    return board[position.row][position.column].cellTypePlayer !=
        cellTypePlayer;
  }

  bool containsBuddy(Position position, List<List<CellDetails>> board,
      CellType cellTypePlayer) {
    return position.isInBounds &&
        board[position.row][position.column].cellTypePlayer == cellTypePlayer;
  }

  bool isProtected(int row, int column, List<List<CellDetails>> board,
      CellType cellTypePlayer) {
    if (isSafePosition(Position(row, column))) {
      return true;
    }

    if (cellTypePlayer == humanType) {
      bool leftProtected =
          containsBuddy(Position(row - 1, column - 1), board, cellTypePlayer) &&
              !containsOpponentKing(
                  Position(row - 1, column - 1), board, cellTypePlayer);
      bool rightProtected =
          containsBuddy(Position(row - 1, column + 1), board, cellTypePlayer) &&
              !containsOpponentKing(
                  Position(row - 1, column + 1), board, cellTypePlayer);
      return leftProtected && rightProtected;
    }

    // AI type
    bool leftProtected =
        containsBuddy(Position(row + 1, column - 1), board, cellTypePlayer) &&
            !containsOpponentKing(
                Position(row + 1, column - 1), board, cellTypePlayer);

    bool rightProtected =
        containsBuddy(Position(row + 1, column + 1), board, cellTypePlayer) &&
            !containsOpponentKing(
                Position(row + 1, column + 1), board, cellTypePlayer);
    leftProtected && rightProtected;

    return leftProtected && rightProtected;
  }

  bool isSafePosition(Position position) {
    // Check if the position is adjacent to the edge of the board
    return position.row == 0 ||
        position.row == CheckersBoard.sizeBoard - 1 ||
        position.column == 0 ||
        position.column == CheckersBoard.sizeBoard - 1;
  }

  bool isBackRowPosition(CellType cellTypePlayer, int cellRow) {
    // Check if the position is adjacent to the edge of the board
    return cellTypePlayer == aiType && cellRow == CheckersBoard.sizeBoard - 1 ||
        cellTypePlayer == humanType && cellRow == 0;
  }

  ScoreType getScoreType(int row, int column) {
    if (row == 3 || row == 4) {
      // Check for middle rows
      if (column >= 2 && column <= 5) {
        return ScoreType.MIDDLE_BOX;
      } else {
        // Non-box
        return ScoreType.MIDDLE_ROW;
      }
    }
    return ScoreType.NONE;
  }

  void vulnerablePawns(
      CellType cellTypePlayerTurn,
      CheckersBoard checkersBoard,
      CellDetails currCellDetailsAttack,
      List<List<CellDetails>> board,
      HeuristicData computerData,
      HeuristicData humanData) {
    if (currCellDetailsAttack.isNotSomePawn) return;
    if (currCellDetailsAttack.cellTypePlayer == cellTypePlayerTurn) return;
    _getVulnerablePawns(checkersBoard, currCellDetailsAttack, board)
        .forEach((cellDetailsCaptured) {
      if (cellDetailsCaptured.cellTypePlayer == aiType) {
        computerData.vulnerable += 1;
      } else {
        humanData.vulnerable += 1;
      }
    });
  }

  List<PawnPath> fetchKills(
      CheckersBoard checkersBoard, CellDetails currCellDetailsAttack) {
    List<PawnPath> paths = [];
    if (currCellDetailsAttack.isKing) {
      checkersBoard.fetchAllCapturePathsKingSimulate(
          paths,
          currCellDetailsAttack.position,
          [PositionDetailsNonCapture(currCellDetailsAttack)],
          checkersBoard.getKingDirections(),
          checkersBoard.board,
          currCellDetailsAttack.cellTypePlayer);
    } else {
      checkersBoard.fetchAllCapturePathsPieceSimulate(
          paths,
          currCellDetailsAttack.position,
          [PositionDetailsNonCapture(currCellDetailsAttack)],
          checkersBoard.getPieceDirections(
              cellTypePlayer: currCellDetailsAttack.cellTypePlayer),
          checkersBoard.board,
          currCellDetailsAttack.cellTypePlayer);
    }

    return paths;
  }

  List<CellDetails> _getVulnerablePawns(CheckersBoard checkersBoard,
      CellDetails currCellDetailsAttack, List<List<CellDetails>> board) {
    //Find the vulnerable pawns
    List<PawnPath> newPathsPawn =
        fetchKills(checkersBoard, currCellDetailsAttack);
    List<CellDetails> capturedList = [];
    for (PawnPath pathPawn in newPathsPawn) {
      for (PositionDetails positionDetails in pathPawn.positionDetailsList) {
        if (positionDetails.isCapture) {
          CellDetails cellDetailsCaptured = board[positionDetails.position.row]
              [positionDetails.position.column];
          if(!capturedList.map((e) => e.position).contains(cellDetailsCaptured.position)){
            capturedList.add(cellDetailsCaptured);
          }
        }
      }
    }

    return capturedList;
  }
}

enum ScoreType { MIDDLE_BOX, MIDDLE_ROW, NONE }
