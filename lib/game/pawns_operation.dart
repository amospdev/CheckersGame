import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/enum/cell_type.dart';

class PawnsOperation {
  static const prefixPawnId = "pawn_id_";
  SummarizerKilledPawns summarizerKilledPawns = SummarizerKilledPawns();

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

  void pawnKilled(Pawn? capturePawn) {
    print("PawnsOperation pawnKilled capturePawn: $capturePawn");
    if (capturePawn == null) return;
    if (capturePawn.isBlack) {
      summarizerKilledPawns.blackPawns.add(capturePawn);
    } else if (capturePawn.isBlackKing) {
      summarizerKilledPawns.blackPawns.add(capturePawn);
    } else if (capturePawn.isWhite) {
      summarizerKilledPawns.withePawns.add(capturePawn);
    } else if (capturePawn.isWhiteKing) {
      summarizerKilledPawns.withePawns.add(capturePawn);
    }
  }

  StatusGame pawnsSummarize(List<List<CellDetails>> board, CellType player) {
    StatusGame summarizerPawns = StatusGame();
    summarizerPawns.currPlayer = player;
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

    return summarizerPawns;
  }
}

class PawnStatus {
  final int totalPawns;
  final bool isCurrPlayer;

  String get totalPawnsText => totalPawns.toString();

  PawnStatus({this.totalPawns = 0, this.isCurrPlayer = false});
}

class SummarizerKilledPawns {
  List<Pawn> blackPawns = [];
  List<Pawn> withePawns = [];
}

class StatusGame {
  int totalBlackKings;
  int totalWitheKings;
  int totalBlackPawns;
  int totalWithePawns;
  CellType currPlayer;

  StatusGame(
      {this.totalBlackKings = 0,
      this.totalWitheKings = 0,
      this.currPlayer = CellType.UNDEFINED,
      this.totalBlackPawns = 0,
      this.totalWithePawns = 0});

  PawnStatus get blackPawnStatus =>
      PawnStatus(totalPawns: allBlackPawns, isCurrPlayer: currPlayer == CellType.BLACK);

  PawnStatus get whitePawnStatus =>
      PawnStatus(totalPawns: allWithePawns, isCurrPlayer: currPlayer == CellType.WHITE);

  bool get isBlackPlayerWin => allWithePawns == 0;

  bool get isBlackPlayerLose => allBlackPawns == 0;

  bool get isWhitePlayerWin => allBlackPawns == 0;

  bool get isWhitePlayerLose => allWithePawns == 0;

  int get allBlackPawns => totalBlackKings + totalBlackPawns;

  int get allWithePawns => totalWitheKings + totalWithePawns;

  bool get isGameOver => allBlackPawns == 0 || allWithePawns == 0;

  @override
  String toString() {
    return 'SummarizerPawns{totalBlackKings: $totalBlackKings, totalWitheKings: $totalWitheKings, totalBlackPawns: $totalBlackPawns, totalWithePawns: $totalWithePawns}';
  }
}
