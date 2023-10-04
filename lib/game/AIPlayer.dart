import 'dart:math';

import 'package:untitled/data/legal_move_state.dart';
import 'package:untitled/game/checkers_board.dart';

class AIPlayer {
  Path makeMove(CheckersBoard checkersBoard) {
    LegalMoveState? resultMove = minimax(
        LegalMoveState(checkersBoard, Path([])), 3, -99999, 99999, true);
    return resultMove?.path ?? Path([]);
  }

  LegalMoveState? minimax(LegalMoveState currState, int depth, int alpha,
      int beta, bool maxPlayer) {
    if (depth == 0) {
      return currState;
    }
    if (maxPlayer) {
      int maxEvaluation = -99999;
      LegalMoveState? bestState;
      for (LegalMoveState state
          in getLegalMoveStates(currState.board, CellType.WHITE)) {
        CheckersBoard? tmpCheckersBoard =
            minimax(state, depth - 1, alpha, beta, false)?.board;
        int evaluation =
            tmpCheckersBoard?.evaluate(false, tmpCheckersBoard) ?? 0;
        maxEvaluation = max(evaluation, maxEvaluation);
        if (maxEvaluation == evaluation) {
          bestState = state;
        }
        alpha = max(alpha, evaluation);
        if (beta <= alpha) break;
      }
      return bestState;
    } else {
      int minEvaluation = 99999;
      LegalMoveState? bestState;
      for (LegalMoveState state
          in getLegalMoveStates(currState.board, CellType.BLACK)) {
        CheckersBoard? tmpCheckersBoard =
            minimax(state, depth - 1, alpha, beta, true)?.board;

        int evaluation =
            tmpCheckersBoard?.evaluate(true, tmpCheckersBoard) ?? 0;
        minEvaluation = min(evaluation, minEvaluation);
        if (minEvaluation == evaluation) {
          bestState = state;
        }
        beta = min(beta, evaluation);
        if (beta <= alpha) break;
      }
      return bestState;
    }
  }

  List<LegalMoveState> getLegalMoveStates(
      CheckersBoard board, CellType playerType) {
    List<LegalMoveState> legalMoveStates = [];
    print("PLAYER:::: ${board.player}");

    for (Path path in board.getAllPossiblePathsForPlayer(board)) {
      CheckersBoard tempBoard = board.clone();
      Position start = path.positionDetails.first.position;
      Position end = path.positionDetails.last.position;

      tempBoard.performMove(start.row, start.column, end.row, end.column, path);
      LegalMoveState state = LegalMoveState(tempBoard, path);
      legalMoveStates.add(state);
    }
    return legalMoveStates;
  }

}

class LegalMoveState {
  CheckersBoard board;
  Path path;

  LegalMoveState(this.board, this.path);
}
