import 'package:untitled/data/pawn.dart';

class BlackPawns {
  final List<Pawn> _pawnsList = [];
  final List<Pawn> _kingsList = [];

  void add(Pawn pawn) {
    if (pawn.isKing) {
      _kingsList.add(pawn);
    } else {
      _pawnsList.add(pawn);
    }
  }

  void clear(){
    _pawnsList.clear();
    _kingsList.clear();
  }
}
