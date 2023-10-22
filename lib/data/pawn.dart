import 'package:flutter/material.dart';

class Pawn {
  Color color;

  int id;
  int row;
  int column;

  final ValueNotifier<Offset> _offsetValueNotifier =
      ValueNotifier<Offset>(Offset.zero);

  bool isKing;

  Pawn(
      {required this.id,
      required this.row,
      required this.column,
      required this.color,
      required this.isKing}) {
    _offsetValueNotifier.value = Offset(column.toDouble(), row.toDouble());
  }

  static Pawn createEmpty() => Pawn(
      id: -1, row: -1, column: -1, color: Colors.tealAccent, isKing: false);

  ValueNotifier<Offset> get offset => _offsetValueNotifier;

  void setOffset(Offset offset) {
    _offsetValueNotifier.value = offset;
  }

  Pawn setPosition(int row, int column) {
    this.row = row;
    this.column = column;

    return this;
  }

  void setIsKing(bool isKing) {
    this.isKing = isKing;
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
      color.hashCode ^ row.hashCode ^ column.hashCode ^ isKing.hashCode;

  @override
  String toString() {
    return 'Pawn{row: $row, column: $column, offset: $offset, isKing: $isKing}';
  }
}
