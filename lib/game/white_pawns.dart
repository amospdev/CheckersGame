import 'package:untitled/data/cell_details.dart';

class WhitePawns {
  final List<CellDetails> _pawnsList = [];
  final List<CellDetails> _kingsList = [];

  void add(CellDetails cellDetails) {
    if (cellDetails.isWhitePawn) {
      _pawnsList.add(cellDetails);
    } else if (cellDetails.isWhiteKing) {
      _kingsList.add(cellDetails);
    }
  }

  void clear(){
    _pawnsList.clear();
    _kingsList.clear();
  }

}
