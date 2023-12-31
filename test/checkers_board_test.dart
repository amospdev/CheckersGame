// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:untitled/data/ai/cell_details_score.dart';
// import 'package:untitled/data/ai/evaluator.dart';
// import 'package:untitled/data/cell_details.dart';
// import 'package:untitled/data/position/position_data.dart';
// import 'package:untitled/enum/cell_type.dart';
// import 'package:untitled/game/checkers_board.dart';
//
// const String EM = "   |";
// const String UV = " # |";
// const String BP = " ● |";
// const String BG = " 👑 |";
// const String WP = " ○ |";
// const String WK = " ♔ |";
//
// void main() {
//   test('score test', () {
//     CellDetailsHeuristic cellDetailsHeuristic = CellDetailsHeuristic(false);
//     cellDetailsHeuristic.addDistancePromotionLinesScore(2);
//
//
//     Evaluator evaluator = Evaluator();
//     int distanceToPromotion = evaluator.distanceToPromotion(CellType.BLACK, 2);
//     expect(distanceToPromotion, 5);
//     expect(cellDetailsHeuristic.score, 5);
//
//     bool isBackRowPosition = evaluator.isBackRowPosition(CellType.WHITE, 7, true);
//     bool isSafePosition = evaluator.isSafePosition(Position(7, 4));
//     print("isBackRowPosition: $isBackRowPosition, isSafePosition: $isSafePosition");
//   });
//
//   // CheckersBoard checkersBoardSource = CheckersBoard();
//   // checkersBoardSource.board[0][0] =
//   //     CellDetails(CellType.WHITE, 1, Colors.black, 0, 0);
//   // test('1 source test', () {
//   //   CellType result = checkersBoardSource.board[0][0].cellType;
//   //   expect(result, CellType.WHITE_KING);
//   // });
//   //
//   // test('1 copy test', () {
//   //   CheckersBoard checkersBoardCopy = checkersBoardSource.copy();
//   //   checkersBoardCopy.board[0][0] =
//   //       CellDetails(CellType.BLACK_KING, 1, Colors.black, 0, 0);
//   //   checkersBoardCopy.nextTurn([]);
//   //
//   //   CellType result = checkersBoardCopy.board[0][0].cellType;
//   //   expect(result, CellType.BLACK_KING);
//   //   expect(checkersBoardSource.board[0][0].cellType, CellType.WHITE);
//   //   expect(checkersBoardCopy.player, CellType.WHITE);
//   //
//   //   checkersBoardSource.board[1][1] =
//   //       CellDetails(CellType.WHITE, 1, Colors.black, 0, 0);
//   //   expect(checkersBoardSource.board[1][1].cellType, CellType.WHITE);
//   //   expect(checkersBoardCopy.board[1][1].cellType, isNot(equals(CellType.WHITE)));
//   // });
//   //
//   // // List<String> board = [
//   // //   UV, 'B', 'U', 'B', 'U', 'B', 'U', 'B',
//   // //   'B', 'U', 'B', 'U', 'B', 'U', 'B', 'U',
//   // //   'U', 'B', 'U', 'B', 'U', 'B', 'U', 'B',
//   // //   'E','U'
//   // // ]
//   //
//   // test('1 source test after copy changed', () {
//   //   CellType result = checkersBoardSource.board[0][0].cellType;
//   //   expect(result, CellType.WHITE);
//   //   expect(checkersBoardSource.player, CellType.BLACK);
//   // });
// }
