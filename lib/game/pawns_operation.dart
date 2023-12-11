import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/enum/cell_type.dart';

class PawnsOperation {
  static const prefixPawnId = "pawn_id_";

  static final List<Color> PLAYER_ONE_DARK = [
    Colors.grey.shade800,
    Colors.black
  ];

  static final List<Color> PLAYER_TWO_LIGHT = [Colors.white, Colors.yellow];

  static Color get playerOnePawnDarkColor => PLAYER_ONE_DARK.first;
  static Color get playerOnePawnTextLightColor => Colors.white;
  static Color get playerTwoPawnTextDarkColor => Colors.black;

  // PLAYER_ONE_DARK[Random().nextInt(PLAYER_ONE_DARK.length)];

  static Color get playerTwoPawnLightColor =>
      // PLAYER_ONE_DARK[Random().nextInt(PLAYER_ONE_DARK.length)];
      PLAYER_TWO_LIGHT.first;

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
              color: cellDeatils.isWhite
                  ? PawnsOperation.playerTwoPawnLightColor
                  : PawnsOperation.playerOnePawnDarkColor,
              isKing: cellDeatils.isKing));
        }
      }
    }

    return pawns;
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
  final int totalKingPawns;
  final bool isCurrPlayer;

  String get totalPawnsText => totalPawns.toString();

  String get totalKingPawnsText => totalKingPawns.toString();

  PawnStatus(
      {this.totalPawns = 0,
      this.totalKingPawns = 0,
      this.isCurrPlayer = false});

  @override
  String toString() {
    return 'PawnStatus{totalPawns: $totalPawns, totalKingPawns: $totalKingPawns, isCurrPlayer: $isCurrPlayer}';
  }
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

  PawnStatus get blackPawnStatus => PawnStatus(
      totalPawns: allBlackPawns,
      totalKingPawns: totalBlackKings,
      isCurrPlayer: currPlayer == CellType.BLACK);

  PawnStatus get whitePawnStatus => PawnStatus(
      totalPawns: allWithePawns,
      totalKingPawns: totalWitheKings,
      isCurrPlayer: currPlayer == CellType.WHITE);

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
