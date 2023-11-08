import 'dart:math';

import 'package:untitled/data/ai/evaluator.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/game/checkers_board.dart'; // Required for using the `max` and `min` functions.

CellType aiType = CellType.WHITE;
CellType humanType = aiType == CellType.WHITE ? CellType.BLACK : CellType.WHITE;

class TranspositionTable {
  // A map of board states to their evaluated values.
  final Map<String, double> _table = {};

  // Stores the evaluated value of the given board state.
  void set(String boardState, double value) {
    _table[boardState] = value;
  }

  // Returns the evaluated value of the given board state, or null if the board state has not been evaluated yet.
  double? get(String boardState) {
    return _table[boardState];
  }
}

class ComputerPlayer {
  final int depth;

  ComputerPlayer(this.depth);

  final Evaluator evaluator = Evaluator();

  // String treeData = "";
  // Set<double> depthSet = {};

  double minimax(
      CheckersBoard checkersBoard,
      int depth,
      bool isMaximizing,
      double alpha,
      double beta,
      TranspositionTable transpositionTable,
      CellType cellTypePlayer) {
    if (depth == 0) {
      double? evaluateMemory =
          transpositionTable.get(checkersBoard.board.toString());
      if (evaluateMemory != null) return evaluateMemory;

      double evaluate = evaluator.evaluate(
          isMaximizing, checkersBoard.board, checkersBoard, cellTypePlayer);
      transpositionTable.set(checkersBoard.board.toString(), evaluate);
      return evaluate;
    }

    if (checkersBoard.isGameOver(checkersBoard.board, true)) {
      double? evaluateMemory =
          transpositionTable.get(checkersBoard.board.toString());
      if (evaluateMemory != null) return evaluateMemory;

      double evaluate = evaluator.evaluate(
          isMaximizing, checkersBoard.board, checkersBoard, cellTypePlayer);
      transpositionTable.set(checkersBoard.board.toString(), evaluate);
      return evaluate;
    }

    if (isMaximizing) {
      double maxEval = -9999;

      List<PathPawn> allPaths = _getAllValidMoves(checkersBoard);

      for (PathPawn path in allPaths) {
        CheckersBoard newBoard = checkersBoard.copy();
        newBoard.performMoveAI(newBoard, path);

        double eval = minimax(newBoard, depth - 1, false, alpha, beta,
            transpositionTable, humanType);

        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }

      // printMinimaxTree(depth, "Max", maxEval);

      return maxEval;
    } else {
      double minEval = 9999;

      List<PathPawn> allPaths = _getAllValidMoves(checkersBoard);

      for (PathPawn path in allPaths) {
        CheckersBoard newBoard = checkersBoard.copy();
        newBoard.performMoveAI(newBoard, path);
        double eval = minimax(
            newBoard, depth - 1, true, alpha, beta, transpositionTable, aiType);

        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      // printMinimaxTree(depth, "Min", minEval);

      return minEval;
    }
  }

  void printMinimaxTree(int depth, String label, double value) {
    // bool isContainDepth = depthSet.contains(depth);
    // String indentation = '';
    //
    // indentation += ''.padLeft(depth * 12);
    // if (!isContainDepth) {
    //   treeData += '\n${indentation}D: $depth';
    // }
    // treeData += '\n$indentation$label: $value';
    // depthSet.add(value);
  }

  PathPawn? getBestMoveForAI(CheckersBoard checkersBoard) {
    TranspositionTable transpositionTable = TranspositionTable();
    return getMove(checkersBoard, transpositionTable);
  }

  PathPawn? getMove(
      CheckersBoard checkersBoard, TranspositionTable transpositionTable) {
    double bestValue = -9999;
    PathPawn? bestMove;
    checkersBoard.printBoard(checkersBoard.board);
    // Get all possible moves for AI
    List<PathPawn> allPossibleMoves = _getAllValidMoves(
        checkersBoard); // Fill this up with actual possible moves for AI

    for (PathPawn pathPawn in allPossibleMoves) {
      CheckersBoard tempCheckersBoard = checkersBoard.copy();
      tempCheckersBoard.performMoveAI(tempCheckersBoard, pathPawn);
      double boardValue = minimax(tempCheckersBoard, depth, false, -9999, 9999,
          transpositionTable, humanType);

      if (boardValue > bestValue) {
        bestValue = boardValue;
        bestMove = pathPawn;
      }
    }
    // debugPrint(treeData);
    print("THE RESULT IS bestValue: $bestValue");
    print("THE RESULT IS bestMove: $bestMove");
    return bestMove;
  }

  List<PathPawn> _getAllValidMoves(CheckersBoard checkersBoard) =>
      checkersBoard.getLegalMoves(aiType, checkersBoard.board, true);
}
