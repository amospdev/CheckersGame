import 'dart:math';

import 'package:untitled/data/ai/computer_player.dart';
import 'package:untitled/data/ai/evaluator.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/game/checkers_board.dart';

class ComputerPlayerPro {
  final int depth;

  ComputerPlayerPro(this.depth);

  PathPawn? getBestMoveForAI(CheckersBoard board) {
    LegalMoveState? resultMove = minimax(LegalMoveState(board, null), depth,
        double.negativeInfinity, double.infinity, true);
    return resultMove?.pathPawn;
  }

  LegalMoveState? minimax(LegalMoveState currState, int depth, double alpha,
      double beta, bool maxPlayer) {
    if (depth == 0 || currState.checkersBoard.isGameOver(true)) {
      return currState;
    }
    if (maxPlayer) {
      double maxEvaluation = double.negativeInfinity;
      LegalMoveState? bestState;
      for (LegalMoveState state
          in getLegalMoveStates(currState.checkersBoard, aiType)) {
        LegalMoveState? newLegalMoveState =
            minimax(state, depth - 1, alpha, beta, false);
        if (newLegalMoveState != null) {
          double evaluation = Evaluator().evaluate(
              maxPlayer,
              newLegalMoveState.checkersBoard.board,
              newLegalMoveState.checkersBoard,
              aiType);
          if (evaluation > maxEvaluation) {
            maxEvaluation = evaluation;
            bestState = state;
          }
          alpha = max(alpha, evaluation);
          if (beta <= alpha) {
            break;
          }
        }
      }
      return bestState;
    } else {
      double minEvaluation = double.infinity;
      LegalMoveState? bestState;
      for (LegalMoveState state
          in getLegalMoveStates(currState.checkersBoard, humanType)) {
        LegalMoveState? newLegalMoveState =
            minimax(state, depth - 1, alpha, beta, true);
        print(
            "2222222 RESULT RESULT  RESULT  RESULT  RESULT: $newLegalMoveState");

        if (newLegalMoveState != null) {
          double evaluation = Evaluator().evaluate(
              maxPlayer,
              newLegalMoveState.checkersBoard.board,
              newLegalMoveState.checkersBoard,
              humanType);
          if (evaluation < minEvaluation) {
            minEvaluation = evaluation;
            bestState = state;
          }
          beta = min(beta, evaluation);
          if (beta <= alpha) {
            break;
          }
        }
      }
      return bestState;
    }
  }

  List<LegalMoveState> getLegalMoveStates(
      CheckersBoard checkersBoard, CellType cellTypePlayer) {
    List<LegalMoveState> legalMoveStates = [];
    for (PathPawn pathPawn
        in _getAllValidMoves(checkersBoard, cellTypePlayer)) {
      CheckersBoard tempBoard = checkersBoard.copy();
      CheckersBoard newBoard = _performMove(tempBoard, pathPawn);
      newBoard.nextTurn();
      LegalMoveState state = LegalMoveState(newBoard, pathPawn);
      legalMoveStates.add(state);
    }
    return legalMoveStates;
  }

  List<PathPawn> _getAllValidMoves(
          CheckersBoard checkersBoard, CellType cellTypePlayer) =>
      checkersBoard.getLegalMoves(cellTypePlayer, checkersBoard.board, true);

  CheckersBoard _performMove(CheckersBoard tempBoard, PathPawn pathPawn) =>
      tempBoard..performMove(tempBoard.board, [pathPawn], pathPawn, isAI: true);
}

// It holds the state of the checkersboard and the selected move.
class LegalMoveState {
  CheckersBoard checkersBoard;
  PathPawn? pathPawn;

  LegalMoveState(this.checkersBoard, this.pathPawn);

  LegalMoveState copy() {
    return LegalMoveState(checkersBoard.copy(), pathPawn?.copy());
  }
}
