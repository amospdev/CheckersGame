import 'dart:math';

import 'package:untitled/data/ai/computer_player.dart';
import 'package:untitled/data/cell/cell_details.dart';
import 'package:untitled/data/pawn/pawn_path.dart';
import 'package:untitled/data/cell/position_details.dart';
import 'package:untitled/data/cell/position_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/extensions/cg_collections.dart';
import 'package:untitled/game/checkers_board.dart';

class Computer {
  late int maximizingPlayer = 1;
  late int maxDepth;

  // int timeLimit = 2;
  // late int startTime;
  // late int currentTime;
  // bool outOfTime = false;
  late int numAllyPieces, numAllyKings, numOppPieces, numOppKings;

  Computer();

  PawnPath? alphaBetaSearch(CheckersBoard checkersBoard, int depthLevel) {
    DateTime date = DateTime.now();
    // startTime = date.millisecondsSinceEpoch;
    getBoardStatus(checkersBoard);
    // outOfTime = false;
    Random random = Random();
    double bestMoveVal = 0;
    int depthReached = 0;
    PawnPath? bestMove;
    List<PawnPath> listBestMovesCurrentDepth;
    List<PawnPath> legalMovesList =
        checkersBoard.getLegalMoves(aiType, checkersBoard.board, true);

    if (legalMovesList.length == 1) {
      // print("Searched to depth 0 in 0 seconds.");
      return legalMovesList[0];
    }

    for (maxDepth = 0; maxDepth < depthLevel /*&& !outOfTime*/; maxDepth++) {
      listBestMovesCurrentDepth = [];
      double bestVal = double.negativeInfinity;
      for (PawnPath pathPawn in legalMovesList) {
        // Game copy = Game.clone(game);
        // copy.applyMove(move, copy.board);
        CheckersBoard checkersBoardCopy = checkersBoard.copy();
        checkersBoardCopy.performMove(
            checkersBoardCopy.board, [pathPawn], pathPawn,
            isAI: true);

        double min = minVal(
            checkersBoardCopy, double.negativeInfinity, double.infinity, 0);
        // if (outOfTime) break;

        if (min == bestVal) {
          listBestMovesCurrentDepth.add(pathPawn);
        }
        if (min > bestVal) {
          listBestMovesCurrentDepth = [pathPawn];
          bestVal = min;
        }
        if (bestVal == double.infinity) break;
      }
      // if (!outOfTime) {
      int chosenMove = random.nextInt(listBestMovesCurrentDepth.length);
      bestMove = listBestMovesCurrentDepth[chosenMove];
      depthReached = maxDepth;
      bestMoveVal = bestVal;
      // }
      if (bestMoveVal == double.infinity) break;
    }
    // print(
    //     "Searched to depth $depthReached in ${(currentTime - startTime) / 1000} seconds.");
    return bestMove;
  }

  bool cutoffTest(int numMoves, int depth) {
    return numMoves == 0 || depth == maxDepth;
  }

  double evalFcn(CheckersBoard checkersBoard) {
    return hardHeuristic(checkersBoard);
  }

  double hardHeuristic(CheckersBoard checkersBoard) {
    int numRows = CheckersBoard.sizeBoard;
    int numCols = CheckersBoard.sizeBoard;
    double boardVal = 0;
    int cntAllyPieces = 0;
    int cntAllyKings = 0;
    int cntOppPieces = 0;
    int cntOppKings = 0;
    int cntVulnerablePawns = 0;
    int cntVulnerableKings = 0;

    // Set the captured pawns
    Set<Position> capturedPawns = checkersBoard.board
        .expand((element) => element)
        .where((currCellDetailsAttack) => currCellDetailsAttack.isSomePawn)
        .where((currCellDetailsAttack) => currCellDetailsAttack.isBlack)
        .map((currCellDetailsAttack) => getVulnerablePawns(
            checkersBoard, currCellDetailsAttack, checkersBoard.board))
        .expand((list) => list)
        .doOnItem((capturedPawn) => capturedPawn.isWhite
            ? cntVulnerablePawns += 1
            : cntVulnerableKings += 1)
        .map((capturedPawn) => capturedPawn.position)
        .toSet();

    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        CellDetails cellDetails = checkersBoard.board[i][j];

        if (capturedPawns.contains(cellDetails.position)) continue;

        if (cellDetails.isWhitePawn) {
          cntAllyPieces++;
          boardVal += numDefendingNeighbors(i, j, checkersBoard.board) * 50 +
              backBonus(i) +
              (15 * (7 - i)) +
              middleBonus(i, j);
        } else if (cellDetails.isBlackPawn) {
          cntOppPieces++;
          boardVal -= numDefendingNeighbors(i, j, checkersBoard.board) * 50 +
              backBonus(i) +
              (15 * i) +
              middleBonus(i, j);
        } else if (cellDetails.isWhiteKing) {
          cntAllyKings++;
          boardVal += middleBonus(i, j);
        } else if (cellDetails.isBlackKing) {
          cntOppKings++;
          boardVal -= middleBonus(i, j);
        }
      }
    }

    if (numAllyPieces + numAllyKings > numOppPieces + numOppKings &&
        cntOppPieces + cntOppKings != 0 &&
        numOppPieces + numOppKings != 0 &&
        numOppKings != 1) {
      if ((cntAllyPieces + cntAllyKings) / (cntOppPieces + cntOppKings) >
          (numAllyPieces + numAllyKings) / (numOppPieces + numOppKings)) {
        boardVal += 150;
      } else {
        boardVal -= 150;
      }
    }

    boardVal += 600 * cntAllyPieces +
        1000 * cntAllyKings -
        600 * cntOppPieces -
        1000 * cntOppKings -
        800 * cntVulnerablePawns -
        1200 * cntVulnerableKings;

    if (numOppPieces + numOppKings < 6 || numAllyPieces + numAllyKings < 6) {
      List<PawnPath> player1Moves =
          checkersBoard.getLegalMoves(humanType, checkersBoard.board, true);
      List<PawnPath> player2Moves =
          checkersBoard.getLegalMoves(aiType, checkersBoard.board, true);

      if (player1Moves.isEmpty) {
        return maximizingPlayer == 1
            ? double.negativeInfinity
            : double.infinity;
      }

      if (player2Moves.isEmpty) {
        return maximizingPlayer == 2
            ? double.negativeInfinity
            : double.infinity;
      }
    }

    if (cntOppPieces + cntOppKings == 0 && cntAllyPieces + cntAllyKings > 0) {
      boardVal = double.infinity;
    }

    if (cntAllyPieces + cntAllyKings == 0 && cntOppPieces + cntOppKings > 0) {
      boardVal -= double.infinity;
    }

    return boardVal;
  }

  List<CellDetails> getVulnerablePawns(CheckersBoard checkersBoard,
      CellDetails currCellDetailsAttack, List<List<CellDetails>> board) {
    List<CellDetails> vulnerablePawns = [];
    _getVulnerablePawns(checkersBoard, currCellDetailsAttack, board)
        .forEach((cellDetailsCaptured) {
      if (cellDetailsCaptured.isWhitePawn) {
        vulnerablePawns.add(cellDetailsCaptured);
      }
    });
    return vulnerablePawns;
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
          if (!capturedList
              .map((e) => e.position)
              .contains(cellDetailsCaptured.position)) {
            capturedList.add(cellDetailsCaptured);
          }
        }
      }
    }

    return capturedList;
  }

  double maxVal(CheckersBoard checkersBoard, double alpha, double beta,
      int depth, CellType cellTypeCurrPlayer) {
    DateTime newDate = DateTime.now();
    // currentTime = newDate.millisecondsSinceEpoch;
    // if ((currentTime - startTime) >= timeLimit * 990) {
    //   outOfTime = true;
    //   return 0;
    // }
    List<PawnPath> listLegalMoves = checkersBoard.getLegalMoves(
        cellTypeCurrPlayer, checkersBoard.board, true);
    if (cutoffTest(listLegalMoves.length, depth)) {
      return evalFcn(checkersBoard);
    }
    double v = double.negativeInfinity;
    for (PawnPath pathPawn in listLegalMoves) {
      // Game copyGame = Game.clone(game);
      // copyGame.applyMove(move, copyGame.board);
      CheckersBoard checkersBoardCopy = checkersBoard.copy();
      checkersBoardCopy.performMove(
          checkersBoardCopy.board, [pathPawn], pathPawn,
          isAI: true);

      v = max(v, minVal(checkersBoardCopy, alpha, beta, depth + 1));
      if (v >= beta) return v;
      alpha = max(alpha, v);
    }
    return v;
  }

  double minVal(
      CheckersBoard checkersBoard, double alpha, double beta, int depth) {
    DateTime newDate = DateTime.now();
    // currentTime = newDate.millisecondsSinceEpoch;
    // if ((currentTime - startTime) > timeLimit * 990) {
    //   outOfTime = true;
    //   return 0;
    // }
    List<PawnPath> listLegalMoves =
        checkersBoard.getLegalMoves(humanType, checkersBoard.board, true);
    if (cutoffTest(listLegalMoves.length, depth)) {
      return evalFcn(checkersBoard);
    }
    double v = double.infinity;
    for (PawnPath pathPawn in listLegalMoves) {
      CheckersBoard checkersBoardCopy = checkersBoard.copy();
      checkersBoardCopy.performMove(
          checkersBoardCopy.board, [pathPawn], pathPawn,
          isAI: true);
      // checkersBoardCopy.applyMove(move, checkersBoardCopy.board);
      v = min(v, maxVal(checkersBoard, alpha, beta, depth + 1, humanType));
      if (v <= alpha) return v;
      beta = min(beta, v);
    }
    return v;
  }

  int numDefendingNeighbors(
      int row, int column, List<List<CellDetails>> board) {
    int defense = 0;
    CellDetails currentCell = board[row][column];
    Position rightTop = Position(row - 1, column + 1);
    Position leftTop = Position(row - 1, column - 1);
    Position rightBottom = Position(row + 1, column + 1);
    Position leftBottom = Position(row + 1, column - 1);

    if (currentCell.isPawn) {
      if (rightBottom.isInBounds) {
        //V
        if ((board[row + 1][column + 1].cellType.index & 1) == 1) {
          defense += 1;
        }
      }
      if (leftBottom.isInBounds) {
        //V
        if ((board[row + 1][column - 1].cellType.index & 1) == 1) {
          defense += 1;
        }
      }
    } else if (currentCell.isKing) {
      if (rightBottom.isInBounds) {
        //V
        if ((board[row + 1][column + 1].cellType.index & 1) == 1) {
          defense += 1;
        }
      }
      if (leftBottom.isInBounds) {
        if ((board[row + 1][column - 1].cellType.index & 1) == 1) {
          defense += 1;
        }
      }
      if (rightTop.isInBounds) {
        if ((board[row - 1][column + 1].cellType.index & 1) == 1) {
          defense += 1;
        }
      }
      if (leftTop.isInBounds) {
        if ((board[row - 1][column - 1].cellType.index & 1) == 1) {
          defense += 1;
        }
      }
    } else if (currentCell.isPawn) {
      if (rightTop.isInBounds) {
        if ((board[row - 1][column + 1].cellType.index & 1) == 0) {
          defense += 1;
        }
      }
      if (leftTop.isInBounds) {
        if ((board[row - 1][column - 1].cellType.index & 1) == 0) {
          defense += 1;
        }
      }
    } else if (currentCell.isPawn) {
      if (rightBottom.isInBounds) {
        //V
        if ((board[row + 1][column + 1].cellType.index & 1) == 1) {
          defense += 1;
        }
      }
      if (leftBottom.isInBounds) {
        if ((board[row + 1][column - 1].cellType.index & 1) == 1) {
          defense += 1;
        }
      }
      if (rightTop.isInBounds) {
        if ((board[row - 1][column + 1].cellType.index & 1) == 1) {
          defense += 1;
        }
      }
      if (leftTop.isInBounds) {
        //V
        if ((board[row - 1][column - 1].cellType.index & 1) == 1) {
          defense += 1;
        }
      }
    } else if (currentCell.isBlackKing) {
      if (rightBottom.isInBounds) {
        if ((board[row + 1][column + 1].cellType.index & 1) == 0) {
          defense += 1;
        }
      }
      if (leftBottom.isInBounds) {
        if ((board[row + 1][column - 1].cellType.index & 1) == 0) {
          defense += 1;
        }
      }
      if (rightTop.isInBounds) {
        if ((board[row - 1][column + 1].cellType.index & 1) == 0) {
          defense += 1;
        }
      }
      if (leftTop.isInBounds) {
        if ((board[row - 1][column - 1].cellType.index & 1) == 0) {
          defense += 1;
        }
      }
    }

    return defense;
  }

  int backBonus(int row) {
    if (row == 7) {
      return 100;
    }
    return 0;
  }

  int middleBonus(int row, int col) {
    return 100 - ((4 - col).abs() + (4 - row).abs()) * 10;
  }

  void getBoardStatus(CheckersBoard checkersBoard) {
    numAllyPieces = 0;
    numAllyKings = 0;
    numOppPieces = 0;
    numOppKings = 0;

    for (int i = 0; i < CheckersBoard.sizeBoard; i++) {
      for (int j = 0; j < CheckersBoard.sizeBoard; j++) {
        CellDetails cellDetails = checkersBoard.board[i][j];
        if (cellDetails.isWhitePawn) {
          numAllyPieces++;
        } else if (cellDetails.isBlackPawn) {
          numOppPieces++;
        } else if (cellDetails.isWhiteKing) {
          numAllyKings++;
        } else if (cellDetails.isBlackKing) {
          numOppKings++;
        }
      }
    }
  }
}
