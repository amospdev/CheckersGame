//
// import 'package:untitled/data/computer_player.dart';
// import 'package:untitled/data/heuristic.dart';
// import 'package:untitled/data/location.dart';
// import 'package:untitled/data/move.dart';
// import 'package:untitled/data/piece.dart';
// import 'package:untitled/data/player.dart';
//
// class CheckersBoard {
//   static const int HUMAN_PLAYER = 2;
//   static const int COMPUTER_PLAYER = 1;
//   static const int BOARD_SIZE = 8;
//   static const int COMPUTER_PLAYER_INDEX = 0;
//   static const int HUMAN_PLAYER_INDEX = 1;
//
//   List<List<Piece?>> board = [];
//   List<Player> players = [];
//   int currentPlayer = 1;
//   int previousWinner = 1;
//
//   /*
// 	 * It is used to keep track of non-jump moves. It is reset each time a jump move
// 	 * is made. Game ends in a tie if moveCount = 200
// 	 */
//   int moveCount = 0;
//   bool isJump = false;
//   bool moveDisplayed = true;
//   bool autoplay = true; // true if it is computer vs human
//   Piece? selectedPiece = Piece(-1, -1, -1);
//   List<Piece> legalMovePieces = [];
//
//   CheckersBoard() {}
//
//   CheckersBoard copy() {
//     CheckersBoard checkersBoard = CheckersBoard();
//     checkersBoard.board = copyBoard();
//     checkersBoard.players = [];
//     checkersBoard.players[0] = Player();
//     checkersBoard.players[1] = Player(number: 2);
//     checkersBoard.currentPlayer = currentPlayer;
//     return checkersBoard;
//   }
//
//   List<List<Piece?>> copyBoard() {
//     List<List<Piece?>> newBoard = [];
//     for (int row = 0; row < BOARD_SIZE; row++) {
//       for (int col = 0; col < BOARD_SIZE; col++) {
//         Piece? piece = board[row][col];
//         if (piece != null) {
//           newBoard[row][col] = piece.copy();
//         }
//       }
//     }
//     return newBoard;
//   }
//
//   bool isGameOver() {
//     if (countPieceNonOpponent(COMPUTER_PLAYER) == 0) {
//       return true;
//     }
//     if (countPieceNonOpponent(HUMAN_PLAYER) == 0) {
//       return true;
//     }
//     if (getLegalMoves(COMPUTER_PLAYER).isEmpty) {
//       return true;
//     }
//     if (getLegalMoves(HUMAN_PLAYER).isEmpty) {
//       return true;
//     }
//     return false;
//   }
//
//   int evaluate(bool max) {
//     HeuristicData computerData = HeuristicData();
//     HeuristicData humanData = HeuristicData();
//
//     for (var piece in getAllPieces()) {
//       if (piece.playerNumber == COMPUTER_PLAYER) {
//         if (piece.isKing) {
//           // Check for kings
//           computerData.setKing(computerData.getKing() + 1);
//         } else {
//           // Check for pawns
//           computerData.setPawn(computerData.getPawn() + 1);
//         }
//
//         int row = piece.row;
//         int col = piece.col;
//
//         if (row == 0) {
//           // Check for back rows
//           computerData.setBackRowPiece(computerData.getBackRowPiece() + 1);
//           computerData.setProtectedPiece(computerData.getProtectedPiece() + 1);
//         } else {
//           if (row == 3 || row == 4) {
//             // Check for middle rows
//             if (col >= 2 && col <= 5) {
//               computerData
//                   .setMiddleBoxPiece(computerData.getMiddleBoxPiece() + 1);
//             } else {
//               // Non-box
//               computerData
//                   .setMiddleRowPiece(computerData.getMiddleRowPiece() + 1);
//             }
//           }
//           // Check if the piece can be taken
//           if (piece.isLeftVulnerable(this)) {
//             computerData.setVulnerable(computerData.getVulnerable() + 1);
//           }
//           if (piece.isRightVulnerable(this)) {
//             computerData.setVulnerable(computerData.getVulnerable() + 1);
//           }
//
//           // Check for protected checkers
//           if (piece.isProtected(this)) {
//             computerData
//                 .setProtectedPiece(computerData.getProtectedPiece() + 1);
//           }
//         }
//       } else if (piece.playerNumber == HUMAN_PLAYER) {
//         if (piece.isKing) {
//           // Check for kings
//           humanData.setKing(humanData.getKing() + 1);
//         } else {
//           // Check for pawns
//           humanData.setPawn(humanData.getPawn() + 1);
//         }
//
//         int row = piece.row;
//         int col = piece.col;
//
//         if (row == 7) {
//           // Check for back rows
//           humanData.setBackRowPiece(humanData.getBackRowPiece() + 1);
//           humanData.setProtectedPiece(humanData.getProtectedPiece() + 1);
//         } else {
//           if (row == 3 || row == 4) {
//             // Check for middle rows
//             if (col >= 2 && col <= 5) {
//               humanData.setMiddleBoxPiece(humanData.getMiddleBoxPiece() + 1);
//             } else {
//               // Non-box
//               humanData.setMiddleRowPiece(humanData.getMiddleRowPiece() + 1);
//             }
//           }
//           // Check if the piece can be taken
//           if (piece.isLeftVulnerable(this)) {
//             humanData.setVulnerable(humanData.getVulnerable() + 1);
//           }
//           if (piece.isRightVulnerable(this)) {
//             humanData.setVulnerable(humanData.getVulnerable() + 1);
//           }
//
//           // Check for protected checkers
//           if (piece.isProtected(this)) {
//             humanData.setProtectedPiece(humanData.getProtectedPiece() + 1);
//           }
//         }
//       }
//     }
//
//     int sum = computerData.subtract(humanData).getSum().toInt();
//     if (max) {
//       return sum;
//     } else {
//       return -sum;
//     }
//   }
//
//   void makeAutoplayMove() {
//     print("Checkers: Autoplay Move");
//     ComputerPlayer computer = ComputerPlayer();
//     Move move = computer.makeMove(this);
//     selectedPiece = board[move.fromRow][move.fromCol];
//     makeMove(this, move);
//   }
//
//   CheckersBoard makeMove(CheckersBoard checkersBoard, Move move) {
//     Piece? piece = checkersBoard.board[move.fromRow][move.fromCol];
//     if (piece != null) {
//       checkersBoard.board[move.toRow][move.toCol] = piece;
//       if (move.toRow == 7 && piece.playerNumber == 1) {
//         piece.isKing = true;
//       } else if (move.toRow == 0 && piece.playerNumber == 2) {
//         piece.isKing = true;
//       }
//       checkersBoard.removePieceAt(move.fromRow, move.fromCol);
//       if (move.isJump()) {
//         checkersBoard.removePieceAt(move.skippedRow, move.skippedCol);
//       } else {
//         checkersBoard.currentPlayer =
//         checkersBoard.currentPlayer == HUMAN_PLAYER
//             ? COMPUTER_PLAYER
//             : HUMAN_PLAYER;
//       }
//     }
//     return checkersBoard;
//   }
//
//   bool isMoveVulnerable(Move move) {
//     Piece? piece = board[move.fromRow][move.fromCol];
//     int row = move.toRow;
//     int col = move.toCol;
//     if (row == 0 || row == 7 || col == 0 || col == 7 || piece == null) {
//       return false;
//     }
//     if (piece.playerNumber == COMPUTER_PLAYER) {
//       Piece? enemy = board[row + 1][col - 1]; // Check bottom left
//       if (enemy != null && enemy.playerNumber != COMPUTER_PLAYER) {
//         return true;
//       }
//       enemy = board[row + 1][col + 1]; // Check bottom right
//       if (enemy != null && enemy.playerNumber != COMPUTER_PLAYER) {
//         return true;
//       }
//
//       if (piece.isKing) {
//         enemy = board[row - 1][col - 1]; // Check top left
//         if (enemy != null &&
//             enemy.playerNumber != COMPUTER_PLAYER &&
//             enemy.isKing) {
//           return true;
//         }
//         enemy = board[row - 1][col + 1]; // Check top right
//         if (enemy != null &&
//             enemy.playerNumber != COMPUTER_PLAYER &&
//             enemy.isKing) {
//           return true;
//         }
//       }
//     } else {
//       Piece? enemy = board[row - 1][col - 1]; // Check top left
//       if (enemy != null && enemy.playerNumber != HUMAN_PLAYER) {
//         return true;
//       }
//       enemy = board[row - 1][col + 1]; // Check top right
//       if (enemy != null && enemy.playerNumber != HUMAN_PLAYER) {
//         return true;
//       }
//
//       if (piece.isKing) {
//         enemy = board[row + 1][col - 1]; // Check bottom left
//         if (enemy != null &&
//             enemy.playerNumber != HUMAN_PLAYER &&
//             enemy.isKing) {
//           return true;
//         }
//         enemy = board[row + 1][col + 1]; // Check bottom right
//         if (enemy != null &&
//             enemy.playerNumber != HUMAN_PLAYER &&
//             enemy.isKing) {
//           return true;
//         }
//       }
//     }
//     return false;
//   }
//
//   List<Move> getDefensiveMoves(int playerNumber) {
//     List<Move> moves = [];
//     List<Location> locations = [];
//     List<Piece> vulnerablePieces = [];
//
//     // Search for vulnerable pieces and save empty locations that must be occupied
//     // to protect the pieces
//     for (var piece in getAllPieces()) {
//       bool isVulnerable = false;
//       if (piece.isLeftVulnerable(this) && piece.playerNumber == playerNumber) {
//         isVulnerable = true;
//         if (piece.playerNumber == COMPUTER_PLAYER) {
//           locations.add(Location(piece.row - 1, piece.col + 1));
//         } else {
//           locations.add(Location(piece.row + 1, piece.col + 1));
//         }
//       }
//       if (piece.isRightVulnerable(this) && piece.playerNumber == playerNumber) {
//         isVulnerable = true;
//         if (piece.playerNumber == COMPUTER_PLAYER) {
//           locations.add(Location(piece.row - 1, piece.col - 1));
//         } else {
//           locations.add(Location(piece.row + 1, piece.col - 1));
//         }
//       }
//       if (isVulnerable) {
//         vulnerablePieces.add(piece);
//       }
//     }
//
//     if (locations.isNotEmpty) {
//       List<Move> tempMoves = [];
//       for (var piece in getAllPieces()) {
//         if (piece.canMove(this) && piece.playerNumber == playerNumber) {
//           tempMoves.addAll(piece.moves);
//         }
//       }
//       while (tempMoves.isNotEmpty) {
//         var m = tempMoves.removeLast();
//         for (var loc in locations) {
//           if (loc.row == m.toRow && loc.col == m.toCol) {
//             moves.add(m);
//             break;
//           }
//         }
//       }
//       if (moves.isNotEmpty) {
//         return moves;
//       }
//     }
//
//     if (vulnerablePieces.isNotEmpty) {
//       if (playerNumber == COMPUTER_PLAYER) {
//         for (var piece in vulnerablePieces) {
//           if (piece.canMove(this) && piece.playerNumber == playerNumber) {
//             for (var m in piece.moves) {
//               if (!isMoveVulnerable(m)) {
//                 moves.add(m);
//               }
//             }
//           }
//         }
//       }
//
//       if (moves.isNotEmpty) {
//         return moves;
//       }
//     }
//
//     if (vulnerablePieces.isNotEmpty) {
//       if (playerNumber == COMPUTER_PLAYER) {
//         for (var piece in vulnerablePieces) {
//           if (piece.canMove(this) && piece.playerNumber == playerNumber) {
//             moves.addAll(piece.moves);
//           }
//         }
//       }
//     }
//     return moves;
//   }
//
//   List<Move> getLegalMoves(int playerNumber) {
//     List<Move> moves = [];
//     // Legal Jump moves
//     for (Piece piece in getAllPieces()) {
//       // Search for legal jump moves for a given player
//       if (piece.canJump(this) && piece.playerNumber == playerNumber) {
//         moves.addAll(piece.moves);
//       }
//     }
//
//     if (moves.isEmpty) {
//       // Legal Defensive Moves
//       moves = getDefensiveMoves(playerNumber);
//     }
//
//     if (moves.isEmpty) {
//       // Legal moves that turn piece to king
//       for (Piece piece in getAllPieces()) {
//         if (piece.canMove(this) && piece.playerNumber == playerNumber) {
//           for (Move move in piece.moves) {
//             if (playerNumber == COMPUTER_PLAYER) {
//               if (move.toRow == 7 && !piece.isKing) {
//                 moves.add(move);
//               }
//             } else {
//               if (move.toRow == 0 && !piece.isKing) {
//                 moves.add(move);
//               }
//             }
//           }
//         }
//       }
//     }
//
//     if (moves.isEmpty) {
//       for (Piece piece in getAllPieces()) {
//         // Search for legal moves for a given player
//         if (piece.canMove(this) && piece.playerNumber == playerNumber) {
//           for (Move m in piece.moves) {
//             if (!isMoveVulnerable(m)) {
//               // Prevent irrational moves when possible. That is, unnecessary
//               // exposure of pieces to attack
//               moves.add(m);
//             }
//           }
//         }
//       }
//     }
//
//     if (moves.isEmpty) {
//       // Normal moves
//       for (Piece piece in getAllPieces()) {
//         // Search for legal moves for a given player
//         if (piece.canMove(this) && piece.playerNumber == playerNumber) {
//           moves.addAll(piece.moves);
//         }
//       }
//     }
//
//     return moves; // Empty if no legal move
//   }
//
//   void getLegalMovePiece(int playerNumber) {
//     legalMovePieces.clear();
//     isJump = false;
//
//     for (Piece piece in getAllPieces()) {
//       // Search for legal jump moves for a given player
//       if (piece.canJump(this) && piece.playerNumber == playerNumber) {
//         legalMovePieces.add(piece);
//       }
//     }
//
//     if (legalMovePieces.isNotEmpty) {
//       if (legalMovePieces.length == 1) {
//         // If we find only one legal jump, select the piece.
//         selectedPiece = legalMovePieces[0];
//       }
//
//       // If we find legal jump(s), return. No need to find other moves as player must jump
//       isJump = true;
//       return;
//     }
//
//     // If we get here that means no legal jump move.
//     for (Piece piece in getAllPieces()) {
//       // Search for legal moves for a given player
//       if (piece.canMove(this) && piece.playerNumber == playerNumber) {
//         legalMovePieces.add(piece);
//       }
//     }
//
//     if (legalMovePieces.length == 1) {
//       // If we find only one legal move, select the piece.
//       selectedPiece = legalMovePieces[0];
//     }
//     // Note: legalMovePieces will be empty if there is no legal move for the player.
//   }
//
//   void passTurn() {
//     if (isJump) {
//       // Check if the previous move was a jump
//       if (autoplay) {
//         players[currentPlayer - 1].increaseJumpStreak();
//       }
//       if (countPiece(currentPlayer, true) == 0) {
//         // Check if opponent does not have any piece left
//         String msg =
//             "${"Game Over: ${players[currentPlayer - 1].name}"} WON!!!";
//         if (currentPlayer == COMPUTER_PLAYER) {
//           gameOver(msg, COMPUTER_PLAYER_INDEX, HUMAN_PLAYER_INDEX, false);
//         } else {
//           gameOver(msg, HUMAN_PLAYER_INDEX, COMPUTER_PLAYER_INDEX, false);
//         }
//         return;
//       }
//       // If we get here, that means opponent has some piece(s) left
//       // Check if current player can still jump with the selected piece
//       isJump = selectedPiece?.canJump(this) ?? false;
//     }
//
//     if (isJump) {
//       // Another jump move is found. Current player must make the next move.
//       if (autoplay && currentPlayer == COMPUTER_PLAYER) {
//         makeAutoplayMove();
//         return;
//       }
//       String msg = "${players[currentPlayer - 1].name} must jump";
//       print(msg);
//       return;
//     }
//     // Check if moveCount is up to 200
//     if (moveCount >= 200) {
//       // It is a tile
//       gameOver("Game Over: It's a TIE", COMPUTER_PLAYER_INDEX,
//           HUMAN_PLAYER_INDEX, true);
//       return;
//     }
//     // If we get this place, reset currentPlayer's jumpStreak,
//     // set selectedPiece to null and change currentPlayer
//     players[currentPlayer - 1].resetJumpStreak();
//     selectedPiece = null;
//     int previousPlayer =
//         currentPlayer; // Take note of the previous player. This variable will be useful if we
//     // don't find move(s) for the new current player.
//     if (currentPlayer == COMPUTER_PLAYER) {
//       currentPlayer = HUMAN_PLAYER;
//     } else {
//       currentPlayer = COMPUTER_PLAYER;
//     }
//     getLegalMovePiece(currentPlayer);
//     if (legalMovePieces.isEmpty) {
//       // No legal move found for the new current player. Game over.
//       String msg = "Game Over: ${players[previousPlayer - 1].name} WON!!!";
//       if (previousPlayer == COMPUTER_PLAYER) {
//         gameOver(msg, COMPUTER_PLAYER_INDEX, HUMAN_PLAYER_INDEX, false);
//       } else {
//         gameOver(msg, HUMAN_PLAYER_INDEX, COMPUTER_PLAYER_INDEX, false);
//       }
//       return;
//     }
//     if (autoplay && currentPlayer == COMPUTER_PLAYER) {
//       makeAutoplayMove();
//       return;
//     }
//     String msg = "${players[currentPlayer - 1].name}: Make your move.";
//     print(msg);
//   }
//
//   void removePieceAt(int row, int col) {
//     if (!inbounds(row, col)) {
//       return;
//     }
//     board[row][col] = null;
//   }
//
//   void gameOver(String str, int winnerIndex, int loserIndex, bool tied) {
//     print(str);
//     if (autoplay && tied) {
//       players[winnerIndex].setStatistics(Player.TIED);
//       players[loserIndex].setStatistics(Player.TIED);
//       currentPlayer = previousWinner;
//       return;
//     }
//     previousWinner = winnerIndex + 1;
//     currentPlayer = winnerIndex + 1; // Winner moves first in the next game.
//     if (autoplay) {
//       players[winnerIndex].setStatistics(Player.WIN);
//       players[loserIndex].setStatistics(Player.LOSS);
//     }
//   }
//
//   /// count pieces of a specified player or of their opponent.
//   ///
//   /// @param playerNumber the player to count their pieces or their opponent's
//   ///                     pieces.
//   /// @param opponent     if true count opponent's piece or specified player's
//   ///                     piece if otherwise.
//   /// @return the number remaining pieces.
//   int countPiece(int playerNumber, bool opponent) {
//     int count = 0;
//     if (opponent) {
//       for (Piece piece in getAllPieces()) {
//         if (piece.playerNumber != playerNumber) {
//           count++;
//         }
//       }
//     } else {
//       for (Piece piece in getAllPieces()) {
//         if (piece.playerNumber == playerNumber) {
//           count++;
//         }
//       }
//     }
//     return count;
//   }
//
//   int countPieceNonOpponent(int playerNumber) {
//     return countPiece(playerNumber, false);
//   }
//
//   List<Piece> getAllPieces() {
//     List<Piece> pieces = [];
//     for (int row = 0; row < BOARD_SIZE; row++) {
//       for (int col = 0; col < BOARD_SIZE; col++) {
//         Piece? piece = board[row][col];
//         if (row % 2 == col % 2 || piece == null) {
//           continue; // skip white and empty spaces
//         }
//         pieces.add(piece);
//       }
//     }
//     return pieces;
//   }
//
//   bool inbounds(int row, int col) {
//     return row >= 0 && col >= 0 && row < BOARD_SIZE && col < BOARD_SIZE;
//   }
//
//   bool isEmpty(int row, int col) {
//     if (!inbounds(row, col)) {
//       return false;
//     }
//     return board[row][col] == null;
//   }
//
//   bool contains(int player, int row, int col) {
//     return !isEmpty(row, col) && getPieceAt(row, col)?.playerNumber == player;
//   }
//
//   Piece? getPieceAt(int row, int col) {
//     if (!inbounds(row, col)) return null;
//     return board[row][col];
//   }
//
//   void setUpGame() {
//     for (int row = 0; row < BOARD_SIZE; row++) {
//       for (int col = 0; col < BOARD_SIZE; col++) {
//         if (row % 2 != col % 2) {
//           if (row < 3) {
//             board[row][col] = Piece(1, row, col);
//           } else if (row > 4) {
//             board[row][col] = Piece(2, row, col);
//           } else {
//             board[row][col] = null;
//           }
//         } else {
//           board[row][col] = null;
//         }
//       }
//     }
//     players[COMPUTER_PLAYER_INDEX].reset();
//     players[HUMAN_PLAYER_INDEX].reset();
//     selectedPiece = null;
//     moveCount = 0;
//   }
//
//   void createNewGame() {
//     setUpGame(); // Set up the pieces.
//     players[COMPUTER_PLAYER_INDEX].increaseGameCount();
//     players[HUMAN_PLAYER_INDEX].increaseGameCount();
//     // gameOverProperty.set(false);
//     if (autoplay && currentPlayer == COMPUTER_PLAYER) {
//       print("${players[currentPlayer - 1].name} is thinking...");
//       makeAutoplayMove();
//     } else {
//       getLegalMovePiece(currentPlayer); // Get current player's legal moves.
//       print("${players[currentPlayer - 1].name}:  Make your move.");
//     }
//   }
// }
