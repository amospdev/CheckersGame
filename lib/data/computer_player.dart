// import 'dart:math';
//
// import 'package:untitled/data/legal_move_state.dart';
// import 'package:untitled/data/move.dart';
// import 'package:untitled/data/player.dart';
// import 'package:untitled/game/checkers_board_game.dart';
//
// class ComputerPlayer extends Player {
//   ComputerPlayer();
//
//   Move makeMove(CheckersBoard board) {
//     LegalMoveState? resultMove =
//         minimax(LegalMoveState(board, null), 3, -9999, 9999, true);
//     return resultMove?.move ?? Move.empty();
//   }
//
//   LegalMoveState? minimax(LegalMoveState currState, int depth, int alpha,
//       int beta, bool maxPlayer) {
//     if (depth == 0 || currState.board.isGameOver()) {
//       return currState;
//     }
//
//     if (maxPlayer) {
//       int maxEvaluation = -9999;
//       LegalMoveState? bestState;
//
//       for (var state in getLegalMoveStates(
//           currState.board, CheckersBoard.COMPUTER_PLAYER)) {
//         int evaluation = minimax(state, depth - 1, alpha, beta, false)
//                 ?.board
//                 .evaluate(false) ??
//             0;
//         if (evaluation > maxEvaluation) {
//           maxEvaluation = evaluation;
//           bestState = state;
//         }
//         alpha = max(alpha, evaluation);
//         if (beta <= alpha) break;
//       }
//
//       return bestState;
//     } else {
//       int minEvaluation = 9999;
//       LegalMoveState? bestState;
//
//       for (var state
//           in getLegalMoveStates(currState.board, CheckersBoard.HUMAN_PLAYER)) {
//         int evaluation = minimax(state, depth - 1, alpha, beta, true)
//                 ?.board
//                 .evaluate(true) ??
//             0;
//         if (evaluation < minEvaluation) {
//           minEvaluation = evaluation;
//           bestState = state;
//         }
//         beta = min(beta, evaluation);
//         if (beta <= alpha) break;
//       }
//
//       return bestState;
//     }
//   }
//
//   List<LegalMoveState> getLegalMoveStates(
//       CheckersBoard board, int playerNumber) {
//     List<LegalMoveState> legalMoveStates = [];
//     for (Move move in board.getLegalMoves(playerNumber)) {
//       CheckersBoard tempBoard = board.copy();
//       CheckersBoard newBoard = tempBoard.makeMove(tempBoard, move);
//       legalMoveStates.add(LegalMoveState(newBoard, move));
//     }
//     return legalMoveStates;
//   }
// }
