import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/extensions/cg_log.dart';

class PawnsOperation {
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

  SummarizerPawns pawnsSummarize(List<List<CellDetails>> board) {
    SummarizerPawns summarizerPawns = SummarizerPawns();

    for (var cellsRow in board) {
      for (var cell in cellsRow) {
        if (cell.isWhite) {
          if (cell.isKing) {
            summarizerPawns.totalWitheKings++;
          } else if (cell.isPawn) {
            summarizerPawns.totalWithePawns++;
          }
        } else if (cell.isBlack) {
          if (cell.isKing) {
            summarizerPawns.totalBlackKings++;
          } else if (cell.isPawn) {
            summarizerPawns.totalBlackPawns++;
          }
        }
      }
    }

    logDebug("$this pawnsSummarize: $summarizerPawns");

    return summarizerPawns;
  }
}

class SummarizerPawns {
  int totalBlackKings;
  int totalWitheKings;
  int totalBlackPawns;
  int totalWithePawns;

  SummarizerPawns(
      {this.totalBlackKings = 0,
      this.totalWitheKings = 0,
      this.totalBlackPawns = 0,
      this.totalWithePawns = 0});

  bool get isBlackPlayerWin => sumWithePawns == 0;

  bool get isBlackPlayerLose => sumBlackPawns == 0;

  bool get isWhitePlayerWin => sumBlackPawns == 0;

  bool get isWhitePlayerLose => sumWithePawns == 0;

  int get sumBlackPawns => totalBlackKings + totalBlackPawns;

  int get sumWithePawns => totalWitheKings + totalWithePawns;

  bool get isGameOver => sumBlackPawns == 0 || sumWithePawns == 0;

  @override
  String toString() {
    return 'SummarizerPawns{totalBlackKings: $totalBlackKings, totalWitheKings: $totalWitheKings, totalBlackPawns: $totalBlackPawns, totalWithePawns: $totalWithePawns}';
  }
}
