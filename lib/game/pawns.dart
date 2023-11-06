import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position/position_data.dart';
import 'package:untitled/enum/cell_type.dart';

class Pawns {
  final List<Pawn> _blackPawnsList = [];
  final List<Pawn> _whitePawnsList = [];

  void add(Pawn pawn) {
    if (pawn.isBlack) {
      _blackPawnsList.add(pawn);
    } else {
      _whitePawnsList.add(pawn);
    }
  }

  Pawn _getPawnWithoutKills(Position position, CellType cellTypePlayer) =>
      (cellTypePlayer == CellType.BLACK ? _blackPawnsList : _whitePawnsList)
          .where((element) => !element.pawnDataNotifier.value.isKilled)
          .toList()
          .firstWhere(
              (pawn) =>
                  pawn.row == position.row && pawn.column == position.column,
              orElse: () => Pawn.createEmpty());
}
