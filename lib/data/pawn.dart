import 'package:flutter/material.dart';
import 'package:untitled/data/pawn_data.dart';

class Pawn {
  Color color;

  int id;
  int row;
  int column;

  final ValueNotifier<PawnData> _pawnDataValueNotifier =
      ValueNotifier<PawnData>(PawnData.createEmpty());

  bool isKing;
  bool _isKilled = false;

  Pawn(
      {required this.id,
      required this.row,
      required this.column,
      required this.color,
      required this.isKing}) {
    _pawnDataValueNotifier.value = PawnData(
        offset: Offset(column.toDouble(), row.toDouble()), isKilled: false);
  }

  static Pawn createEmpty() => Pawn(
      id: -1, row: -1, column: -1, color: Colors.tealAccent, isKing: false);

  ValueNotifier<PawnData> get pawnDataNotifier => _pawnDataValueNotifier;

  void setPawnDataNotifier({bool? isKilled, Offset? offset}) {
    _pawnDataValueNotifier.value = PawnData(
        offset: offset ?? Offset(column.toDouble(), row.toDouble()),
        isKilled: isKilled ?? _isKilled);
    _isKilled = _pawnDataValueNotifier.value.isKilled;
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
          isKing == other.isKing &&
          _isKilled == other._isKilled;

  @override
  int get hashCode =>
      color.hashCode ^
      id.hashCode ^
      row.hashCode ^
      column.hashCode ^
      isKing.hashCode ^
      _isKilled.hashCode;
}
