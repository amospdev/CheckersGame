import 'package:flutter/material.dart';
import 'package:untitled/data/pawn_data.dart';

class Pawn {
  Color color;

  int id;
  int row;
  int column;
  final int index;

  final ValueNotifier<PawnData> _pawnDataValueNotifier =
      ValueNotifier<PawnData>(PawnData.createEmpty());

  bool isKing;

  Pawn(
      {required this.id,
      required this.index,
      required this.row,
      required this.column,
      required this.color,
      required this.isKing}) {
    _pawnDataValueNotifier.value = PawnData(
        offset: Offset(column.toDouble(), row.toDouble()),
        isKilled: false,
        isAnimating: false);
  }

  Pawn copy() {
    return Pawn(
      id: id,
      index: index,
      row: row,
      column: column,
      color: color,
      // Assuming Color is immutable, which it is in Dart.
      isKing: isKing,
      // ... (copy any other properties) ...
    );
  }

  static Pawn createEmpty() => Pawn(
      id: -1,
      index: -1,
      row: -1,
      column: -1,
      color: Colors.tealAccent,
      isKing: false);

  ValueNotifier<PawnData> get pawnDataNotifier => _pawnDataValueNotifier;

  void setPawnDataNotifier(
      {bool? isKilled, Offset? offset, bool? isAnimating}) {
    _pawnDataValueNotifier.value = PawnData(
        isAnimating: isAnimating ?? _pawnDataValueNotifier.value.isAnimating,
        offset: offset ?? Offset(column.toDouble(), row.toDouble()),
        isKilled: isKilled ?? _pawnDataValueNotifier.value.isKilled);
  }

  Pawn setPosition(int row, int column) {
    this.row = row;
    this.column = column;

    return this;
  }

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
}
