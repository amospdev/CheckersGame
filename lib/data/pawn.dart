import 'package:flutter/material.dart';

class Pawn {
  Color color;

  int row;
  int column;

  Offset _offset = Offset.zero;

  bool isKing;
  bool isAlreadyKing = false;

  Pawn(
      {required this.row,
      required this.column,
      required this.color,
      required this.isKing})
      : _offset = Offset(column.toDouble(), row.toDouble());

  static Pawn createEmpty() =>
      Pawn(row: -1, column: -1, color: Colors.tealAccent, isKing: false);

  Offset get offset => _offset;

  void setOffset(Offset offset) {
    _offset = offset;
  }

  Pawn setPosition(int row, int column) {
    this.row = row;
    this.column = column;

    return this;
  }

  void setIsKing(bool isKing) {
    this.isKing = isKing;
  }

  void setIsAlreadyKing(bool isAlreadyKing) {
    this.isAlreadyKing = isAlreadyKing;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pawn &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          row == other.row &&
          column == other.column &&
          isKing == other.isKing;

  @override
  int get hashCode =>
      color.hashCode ^
      row.hashCode ^
      column.hashCode ^
      isKing.hashCode ^
      isAlreadyKing.hashCode;

  @override
  String toString() {
    return 'Pawn{row: $row, column: $column, offset: $offset, isKing: $isKing, isAlreadyKing: $isAlreadyKing}';
  }
}
