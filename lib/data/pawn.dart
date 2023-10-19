import 'package:flutter/material.dart';

class Pawn {
  Color color;

  int row; // שורה
  int column; // עמודה

  double rowFloat = 0.0; // שורה
  double columnFloat = 0.0; // עמודה

  bool isKing;
  bool isAlreadyKing = false;

  Pawn(
      {required this.row,
      required this.column,
      required this.color,
      required this.rowFloat,
      required this.columnFloat,
      required this.isKing});

  static Pawn createEmpty() => Pawn(
      row: -1,
      column: -1,
      color: Colors.tealAccent,
      rowFloat: -1,
      columnFloat: -1,
      isKing: false);

  Offset get offset => Offset(columnFloat.toDouble(), rowFloat.toDouble());

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
          rowFloat == other.rowFloat &&
          columnFloat == other.columnFloat &&
          isKing == other.isKing;

  @override
  int get hashCode =>
      color.hashCode ^
      row.hashCode ^
      column.hashCode ^
      rowFloat.hashCode ^
      columnFloat.hashCode ^
      isKing.hashCode ^
      isAlreadyKing.hashCode;

  @override
  String toString() {
    return 'Pawn{row: $row, column: $column, rowFloat: $rowFloat, columnFloat: $columnFloat, isKing: $isKing, isAlreadyKing: $isAlreadyKing}';
  }
}
