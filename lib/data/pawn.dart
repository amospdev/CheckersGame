import 'package:flutter/material.dart';
import 'package:untitled/data/pawn_data.dart';
import 'package:untitled/data/position/position_data.dart';
import 'package:untitled/enum/cell_type.dart';

class Pawn {
  Color color;

  String id;
  int row;
  int column;
  final int index;
  final CellType cellTypePlayer;
  int indexPawnKilled = -1;

  final ValueNotifier<PawnData> _pawnDataValueNotifier =
      ValueNotifier<PawnData>(PawnData.createEmpty());

  bool isKing;

  Pawn(
      {required this.id,
      required this.index,
      required this.cellTypePlayer,
      required this.row,
      required this.column,
      required this.color,
      required this.isKing}) {
    _initPawnData();
  }

  Pawn copy({Pawn? pawn}) {
    return Pawn(
      id: pawn?.id ?? id,
      index: pawn?.index ?? index,
      row: pawn?.row ?? row,
      column: pawn?.column ?? column,
      color: pawn?.color ?? color,
      isKing: pawn?.isKing ?? isKing,
      cellTypePlayer: pawn?.cellTypePlayer ?? cellTypePlayer,
    );
  }

  static Pawn createEmpty() => Pawn(
      id: "",
      index: -1,
      cellTypePlayer: CellType.UNDEFINED,
      row: -1,
      column: -1,
      color: Colors.tealAccent,
      isKing: false);

  ValueNotifier<PawnData> get pawnDataNotifier => _pawnDataValueNotifier;

  void setPawnDataNotifier(
      {bool? isKilled,
      Offset? offset,
      bool? isAnimating,
      int? indexKilled,
      bool? hasCapture}) {
    _pawnDataValueNotifier.value = PawnData(
        hasCapture: hasCapture ?? _pawnDataValueNotifier.value.hasCapture,
        isAnimating: isAnimating ?? _pawnDataValueNotifier.value.isAnimating,
        offset: offset ?? Offset(column.toDouble(), row.toDouble()),
        isKilled: isKilled ?? _pawnDataValueNotifier.value.isKilled,
        indexKilled: indexKilled ?? _pawnDataValueNotifier.value.indexKilled);
  }

  Pawn setPosition(int row, int column) {
    this.row = row;
    this.column = column;

    return this;
  }

  bool get isBlack => cellTypePlayer == CellType.BLACK && !isKing;

  bool get isBlackKing => cellTypePlayer == CellType.BLACK && isKing;

  bool get isWhite => cellTypePlayer == CellType.WHITE && !isKing;

  bool get isSomeWhite => cellTypePlayer == CellType.WHITE;

  bool get isSomeBlack => cellTypePlayer == CellType.BLACK;

  bool get isWhiteKing => cellTypePlayer == CellType.WHITE && isKing;

  Position get position => Position(row, column);

  Pawn setIsKing(bool isKing) {
    this.isKing = isKing;
    return this;
  }

  @override
  String toString() {
    return 'Pawn{id: $id, row: $row, column: $column, isKilled: ${_pawnDataValueNotifier.value.isKilled}, offset: ${_pawnDataValueNotifier.value.offset}, isKing: $isKing}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pawn &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          id == other.id &&
          row == other.row &&
          column == other.column &&
          isKing == other.isKing;

  @override
  int get hashCode =>
      color.hashCode ^
      id.hashCode ^
      row.hashCode ^
      column.hashCode ^
      isKing.hashCode;

  void setValues(Pawn oldPawn) {
    setPosition(oldPawn.row, oldPawn.column)
        .setIsKing(oldPawn.isKing)
        .setPawnDataNotifier(
            isKilled: oldPawn.pawnDataNotifier.value.isKilled,
            offset: oldPawn.pawnDataNotifier.value.offset,
            hasCapture: oldPawn.pawnDataNotifier.value.hasCapture,
            isAnimating: oldPawn.pawnDataNotifier.value.isAnimating);
  }

  void _initPawnData() {
    _pawnDataValueNotifier.value = PawnData(
        offset: Offset(column.toDouble(), row.toDouble()),
        isKilled: false,
        isAnimating: false,
        hasCapture: false,
        indexKilled: -1);
  }
}
