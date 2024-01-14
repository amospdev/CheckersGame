import 'package:flutter/cupertino.dart';
import 'package:untitled/data/board_elements_details.dart';
import 'package:untitled/ui/widgets/cell/cells_layer.dart';
import 'package:untitled/ui/widgets/main_game_border.dart';
import 'package:untitled/ui/widgets/pawn/pawns_layer.dart';

class CenterLayer extends StatelessWidget {
  const CenterLayer({super.key});

  @override
  Widget build(BuildContext context) => _centerLayer();

  Widget _centerLayer() => Expanded(
          child: Container(
        padding: const EdgeInsets.all(BoardElementsDetails.paddingGameBoard),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _boardLayer(),
            _cellsLayer(),
            _pawnsLayer(),
          ],
        ),
      ));

  Widget _boardLayer() => const MainGameBorder();

  Widget _cellsLayer() => SizedBox(
        width: BoardElementsDetails.innerBoardSize,
        height: BoardElementsDetails.innerBoardSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const CellsLayer(),
        ),
      );

  Widget _pawnsLayer() => SizedBox(
        width: BoardElementsDetails.innerBoardSize,
        height: BoardElementsDetails.innerBoardSize +
            BoardElementsDetails.discardPileArea,
        child: const PawnsLayer(),
      );
}
