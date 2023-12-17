// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:untitled/data/cell_details_data.dart';
// import 'package:untitled/enum/tap_on_board.dart';
// import 'package:untitled/game_view_model.dart';
//
// class CellsLayer extends StatelessWidget{
//   const CellsLayer({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     GameViewModel gameViewModel = Provider.of<GameViewModel>(context, listen: false);
//     // TODO: implement build
//     throw UnimplementedError();
//   }
//
//   Widget _getCells(double cellSize, double widthBoardByOrientation, GameViewModel gameViewModel) {
//     List<Widget> cells = gameViewModel.boardCells.map((cell) {
//       double leftPos = (cell.offset.dx) * cellSize;
//       double topPos = (cell.offset.dy) * cellSize;
//       return Positioned(
//         left: leftPos,
//         top: topPos,
//         child: GestureDetector(
//           onTap: () {
//             TapOnBoard tapOnBoard =
//             gameViewModel.onTapBoardGame(cell.row, cell.column);
//             if (tapOnBoard == TapOnBoard.END) {
//               movePlayerTo(cell.row, cell.column);
//             }
//           },
//           child: ValueListenableBuilder<CellDetailsData>(
//             valueListenable: cell.cellDetailsData,
//             builder: (ctx, cellDetailsData, _) {
//               return RepaintBoundary(
//                   child: Image.asset(
//                       cell.isUnValid
//                           ? 'assets/wood_horizontal.png'
//                           : 'assets/wood.png',
//                       color: cell.isUnValid
//                           ? Colors.white
//                           : cell.tmpColor == cell.color
//                           ? Colors.black
//                           : cell.tmpColor,
//                       colorBlendMode: cell.isUnValid
//                           ? BlendMode.modulate
//                           : cell.tmpColor == cell.color
//                           ? BlendMode.overlay
//                           : BlendMode.color,
//                       width: cellSize,
//                       height: cellSize));
//             },
//           ),
//         ),
//       );
//     }).toList();
//
//     return Stack(
//       children: cells,
//     );
//   }
//
//
// }