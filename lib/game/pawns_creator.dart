import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';

class PawnsCreator {
  static const prefixPawnId = "pawn_id_";

  List<Pawn> create(List<List<CellDetails>> board) {
    List<Pawn> pawns = [];
    for (var (row, rowList) in board.indexed) {
      for (var (column, cellDeatils) in rowList.indexed) {
        if (cellDeatils.isSomePawn) {
          pawns.add(Pawn(
              id: '$prefixPawnId${pawns.length}',
              row: row,
              cellTypePlayer: cellDeatils.cellTypePlayer,
              index: pawns.length,
              column: column,
              color: cellDeatils.isWhite ? Colors.white : Colors.grey,
              isKing: cellDeatils.isKing));
        }
      }
    }

    return pawns;
  }
}
