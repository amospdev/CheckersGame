// import 'package:untitled/data/location.dart';
// import 'package:untitled/data/move.dart';
// import 'package:untitled/data/move.dart';
// import 'package:untitled/data/player.dart';
//
// import '../game/checkers_board_game.dart';
//
// class Piece {
//   int playerNumber;
//   int row;
//   int col;
//   bool isKing = false;
//   List<Move> moves = [];
//
//   Piece(this.playerNumber, this.row, this.col);
//
//   ///////////*********//////////***********
//   bool canJump(CheckersBoard checkersBoard) {
//     moves.clear();
//     if (playerNumber == CheckersBoard.HUMAN_PLAYER) {
//       Location topFarLeft = Location(row - 2, col - 2);
//       Location topFarRight = Location(row - 2, col + 2);
//       if (checkersBoard.isEmpty(topFarLeft.row, topFarLeft.col) &&
//           checkersBoard.contains(
//               CheckersBoard.COMPUTER_PLAYER, row - 1, col - 1)) {
//         Move move = Move(
//             row, col, row - 1, col - 1, topFarLeft.row, topFarLeft.col);
//         moves.add(move);
//       }
//       if (checkersBoard.isEmpty(topFarRight.row, topFarRight.col) &&
//           checkersBoard.contains(
//               CheckersBoard.COMPUTER_PLAYER, row - 1, col + 1)) {
//         Move move = Move(
//             row, col, row - 1, col + 1, topFarRight.row, topFarRight.col);
//         moves.add(move);
//       }
//       if (isKing) {
//         Location bottomFarLeft = Location(row + 2, col - 2);
//         Location bottomFarRight = Location(row + 2, col + 2);
//         if (checkersBoard.isEmpty(bottomFarLeft.row, bottomFarLeft.col) &&
//             checkersBoard.contains(
//                 CheckersBoard.COMPUTER_PLAYER, row + 1, col - 1)) {
//           Move move = Move(
//               row, col, row + 1, col - 1, bottomFarLeft.row, bottomFarLeft.col);
//           moves.add(move);
//         }
//         if (checkersBoard.isEmpty(bottomFarRight.row, bottomFarRight.col)
//             && checkersBoard.contains(
//                 CheckersBoard.COMPUTER_PLAYER, row + 1, col + 1)) {
//           Move move = Move(row, col, row + 1, col + 1, bottomFarRight.row,
//               bottomFarRight.col);
//           moves.add(move);
//         }
//       }
//     } else if (playerNumber == CheckersBoard.COMPUTER_PLAYER) {
//       Location bottomFarLeft = Location(row + 2, col - 2);
//       Location bottomFarRight = Location(row + 2, col + 2);
//       if (checkersBoard.isEmpty(bottomFarLeft.row, bottomFarLeft.col) &&
//           checkersBoard.contains(
//               CheckersBoard.HUMAN_PLAYER, row + 1, col - 1)) {
//         Move move = Move(
//             row, col, row + 1, col - 1, bottomFarLeft.row, bottomFarLeft.col);
//         moves.add(move);
//       }
//       if (checkersBoard.isEmpty(bottomFarRight.row, bottomFarRight.col) &&
//           checkersBoard.contains(
//               CheckersBoard.HUMAN_PLAYER, row + 1, col + 1)) {
//         Move move = Move(
//             row, col, row + 1, col + 1, bottomFarRight.row, bottomFarRight.col);
//         moves.add(move);
//       }
//       if (isKing) {
//         Location topFarLeft = Location(row - 2, col - 2);
//         Location topFarRight = Location(row - 2, col + 2);
//         if (checkersBoard.isEmpty(topFarLeft.row, topFarLeft.col) &&
//             checkersBoard.contains(
//                 CheckersBoard.HUMAN_PLAYER, row - 1, col - 1)) {
//           Move move = Move(
//               row, col, row - 1, col - 1, topFarLeft.row, topFarLeft.col);
//           moves.add(move);
//         }
//         if (checkersBoard.isEmpty(topFarRight.row, topFarRight.col) &&
//             checkersBoard.contains(
//                 CheckersBoard.HUMAN_PLAYER, row - 1, col + 1)) {
//           Move move = Move(
//               row, col, row - 1, col + 1, topFarRight.row, topFarRight.col);
//           moves.add(move);
//         }
//       }
//     }
//     return moves.isNotEmpty;
//   }
//
//   ///////////*********//////////***********
//   bool canMove(CheckersBoard checkersBoard) {
//     moves.clear(); // clear existing moves
//     if (playerNumber == CheckersBoard.HUMAN_PLAYER) {
//       Location topLeft = Location(row - 1, col - 1);
//       Location topRight = Location(row - 1, col + 1);
//       if (checkersBoard.isEmpty(topLeft.row, topLeft.col)) {
//         Move move = Move.withoutSkip(row, col, topLeft.row, topLeft.col);
//         moves.add(move);
//       }
//       if (checkersBoard.isEmpty(topRight.row, topRight.col)) {
//         Move move = Move.withoutSkip(row, col, topRight.row, topRight.col);
//         moves.add(move);
//       }
//       if (isKing) {
//         Location bottomLeft = Location(row + 1, col - 1);
//         Location bottomRight = Location(row + 1, col + 1);
//         if (checkersBoard.isEmpty(bottomLeft.row, bottomLeft.col)) {
//           Move move = Move.withoutSkip(
//               row, col, bottomLeft.row, bottomLeft.col);
//           moves.add(move);
//         }
//         if (checkersBoard.isEmpty(bottomRight.row, bottomRight.col)) {
//           Move move = Move.withoutSkip(
//               row, col, bottomRight.row, bottomRight.col);
//           moves.add(move);
//         }
//       }
//     } else if (playerNumber == CheckersBoard.COMPUTER_PLAYER) {
//       Location bottomLeft = Location(row + 1, col - 1);
//       Location bottomRight = Location(row + 1, col + 1);
//       if (checkersBoard.isEmpty(bottomLeft.row, bottomLeft.col)) {
//         Move move = Move.withoutSkip(row, col, bottomLeft.row, bottomLeft.col);
//         moves.add(move);
//       }
//       if (checkersBoard.isEmpty(bottomRight.row, bottomRight.col)) {
//         Move move = Move.withoutSkip(
//             row, col, bottomRight.row, bottomRight.col);
//         moves.add(move);
//       }
//       if (isKing) {
//         Location topLeft = Location(row - 1, col - 1);
//         Location topRight = Location(row - 1, col + 1);
//
//         if (checkersBoard.isEmpty(topLeft.row, topLeft.col)) {
//           Move move = Move.withoutSkip(row, col, topLeft.row, topLeft.col);
//           moves.add(move);
//         }
//         if (checkersBoard.isEmpty(topRight.row, topRight.col)) {
//           Move move = Move.withoutSkip(row, col, topRight.row, topRight.col);
//           moves.add(move);
//         }
//       }
//     }
//     return moves.isNotEmpty;
//   }
//
//   ///////////*********//////////***********
//   void moveTo(int row, int col, CheckersBoard checkersBoard, bool autoplay,
//       List<Player> players) {
//     if (!checkersBoard.isEmpty(row, col)) {
//       return;
//     }
//     this.row = row;
//     this.col = col;
//     checkersBoard.board[row][col] = this;
//     if (!isKing && playerNumber == 1) {
//       if (row == 7) {
//         isKing = true;
//         if (autoplay) {
//           players[CheckersBoard.COMPUTER_PLAYER_INDEX].setAllTimeKings();
//         }
//       }
//     } else if (!isKing && playerNumber == 2) {
//       if (row == 0) {
//         isKing = true;
//         if (autoplay) {
//           players[CheckersBoard.HUMAN_PLAYER_INDEX].setAllTimeKings();
//         }
//       }
//     }
//   }
//
//   // This method checks if this piece can move to (row, col). It will return
//   // true if piece can move to the given location or false if otherwise.
//   ///////////*********//////////***********
//   bool canMoveTo(int row, int col) {
//     for (Move move in moves) {
//       if (move.toRow == row && move.toCol == col) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   ///////////*********//////////***********
//   Move? getMoveAt(int row, int col) {
//     for (Move move in moves) {
//       if (move.toRow == row && move.toCol == col) {
//         return move;
//       }
//     }
//     return null;
//   }
//
//   // Check if a piece cannot be taken until it moves or another piece moves.
//   ///////////*********//////////***********
//   bool isProtected(CheckersBoard checkersBoard) {
//     if (row == 0 || col == 0 || row == 7 || col == 7) {
//       // It is at edge of the board, it cannot be taken.
//       return true;
//     }
//     if (playerNumber == CheckersBoard.COMPUTER_PLAYER) {
//       bool leftProtected = containsBuddy(row - 1, col - 1, checkersBoard) &&
//           !containsOpponentKing(row - 1, col - 1, checkersBoard);
//       bool rightProtected = containsBuddy(row - 1, col + 1, checkersBoard) &&
//           !containsOpponentKing(row - 1, col + 1, checkersBoard);
//       return leftProtected && rightProtected;
//     }
//     bool leftProtected = containsBuddy(row + 1, col - 1, checkersBoard) &&
//         !containsOpponentKing(row + 1, col - 1, checkersBoard);
//     bool rightProtected = containsBuddy(row + 1, col + 1, checkersBoard) &&
//         !containsOpponentKing(row + 1, col + 1, checkersBoard);
//     return leftProtected && rightProtected;
//   }
//
//   // Check if a piece can be taken this turn - left to right jump
//   ///////////*********//////////***********
//   bool isLeftVulnerable(CheckersBoard checkersBoard) {
//     if (playerNumber == CheckersBoard.COMPUTER_PLAYER) {
//       return checkersBoard.isEmpty(row - 1, col + 1) && containsOpponentPiece(row + 1, col - 1, checkersBoard);
//     }
//     return checkersBoard.isEmpty(row + 1, col + 1) && containsOpponentPiece(row - 1, col - 1, checkersBoard);
//   }
//
//   // Check if a piece can be taken this turn - right to left jump
//   ///////////*********//////////***********
//   bool isRightVulnerable(CheckersBoard checkersBoard) {
//     if (playerNumber == CheckersBoard.COMPUTER_PLAYER) {
//       return checkersBoard.isEmpty(row - 1, col - 1) && containsOpponentPiece(row + 1, col + 1, checkersBoard);
//     }
//     return checkersBoard.isEmpty(row + 1, col - 1) && containsOpponentPiece(row - 1, col + 1, checkersBoard);
//   }
//
//   // Check if piece at a given location is buddy or not.
//   ///////////*********//////////***********
//   bool containsBuddy(int row, int col, CheckersBoard checkersBoard) {
//     if (!checkersBoard.inbounds(row, col) || checkersBoard.isEmpty(row, col)) {
//       return false;
//     }
//     return checkersBoard.board[row][col]?.playerNumber == playerNumber;
//   }
//
//   // Check if piece at a given location is opponent's piece
//   ///////////*********//////////***********
//   bool containsOpponentPiece(int row, int col, CheckersBoard checkersBoard) {
//     if (!checkersBoard.inbounds(row, col) || checkersBoard.isEmpty(row, col)) {
//       return false;
//     }
//     return checkersBoard.board[row][col]?.playerNumber != playerNumber;
//   }
//
//   // Check if piece at a given location is opponent's king
//   ///////////*********//////////***********
//   bool containsOpponentKing(int row, int col, CheckersBoard checkersBoard) {
//     if (!checkersBoard.inbounds(row, col) || checkersBoard.isEmpty(row, col)) {
//       return false;
//     }
//     return checkersBoard.board[row][col]?.playerNumber != playerNumber &&
//         (checkersBoard.board[row][col]?.isKing ?? false);
//   }
//
//   Piece copy() {
//     Piece piece = Piece(playerNumber, row, col);
//     piece.isKing = isKing;
//     for (Move move in moves) {
//       piece.moves.add(move.copy());
//     }
//     return piece;
//   }
// }