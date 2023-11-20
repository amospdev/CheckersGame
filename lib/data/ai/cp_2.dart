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
      print("minimax depth == 0 maxPlayer: $maxPlayer");
      return currState;
    }
    if (maxPlayer) {
      print("1 minimax maxPlayer: $maxPlayer");

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
              newLegalMoveState.checkersBoard.player);
          print("11 minimax maxPlayer: $maxPlayer Evaluator: $evaluation}");

          if (evaluation > maxEvaluation) {
            maxEvaluation = evaluation;
            bestState = state;
          }
          print("111 minimax maxPlayer: $maxPlayer maxEvaluation: $maxEvaluation}");

          alpha = max(alpha, evaluation);
          if (beta <= alpha) {
            break;
          }
        }
      }
      return bestState;
    } else {
      print("2 minimax maxPlayer: $maxPlayer");

      double minEvaluation = double.infinity;
      LegalMoveState? bestState;
      for (LegalMoveState state
          in getLegalMoveStates(currState.checkersBoard, humanType)) {
        LegalMoveState? newLegalMoveState =
            minimax(state, depth - 1, alpha, beta, true);

        if (newLegalMoveState != null) {
          double evaluation = Evaluator().evaluate(
              maxPlayer,
              newLegalMoveState.checkersBoard.board,
              newLegalMoveState.checkersBoard,
              newLegalMoveState.checkersBoard.player);
          print("22 minimax maxPlayer: $maxPlayer Evaluator: $evaluation}");

          if (evaluation < minEvaluation) {
            minEvaluation = evaluation;
            bestState = state;
          }
          print("222 minimax maxPlayer: $maxPlayer minEvaluation: $minEvaluation}");

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
