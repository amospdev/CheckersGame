import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/board_elements_details.dart';
import 'package:untitled/data/cell/cell_details_data.dart';
import 'package:untitled/ui/screens/game/game_view_model.dart';

class CellsLayer extends StatelessWidget {
  const CellsLayer({super.key});

  @override
  Widget build(BuildContext context) => _getCells(
      Provider.of<GameViewModel>(context, listen: false),
      BoardElementsDetails.cellSize);

  Widget _getCells(GameViewModel gameViewModel, double cellSize) {
    List<Widget> cells = gameViewModel.boardCells.map((cell) {
      double leftPos = cell.offset.dx * cellSize;
      double topPos = cell.offset.dy * cellSize;
      return Positioned(
        left: leftPos,
        top: topPos,
        child: GestureDetector(
          onTap: () => gameViewModel.onTapBoardGame(cell.row, cell.column),
          child: ValueListenableBuilder<CellDetailsData>(
            valueListenable: cell.cellDetailsData,
            builder: (ctx, cellDetailsData, _) {
              return RepaintBoundary(
                  child: Image.asset(
                      cell.isUnValid
                          ? 'assets/wood_horizontal.png'
                          : 'assets/wood.png',
                      color: cell.isUnValid
                          ? Colors.white
                          : cell.tmpColor == cell.color
                              ? Colors.black
                              : cell.tmpColor,
                      colorBlendMode: cell.isUnValid
                          ? BlendMode.modulate
                          : cell.tmpColor == cell.color
                              ? BlendMode.overlay
                              : BlendMode.color,
                      width: cellSize,
                      height: cellSize));
            },
          ),
        ),
      );
    }).toList();

    return Stack(
      children: cells,
    );
  }
}
