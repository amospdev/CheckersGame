import 'package:flutter/material.dart';
import 'package:untitled/enum/cell_type.dart';

class CellDetails {
  CellType cellType = CellType.UNDEFINED;
  bool isEmpty = true;
  int id = -1;
  Color color;
  final int row;
  final int column;

  final ValueNotifier<Color> _tmpColorValueNotifier =
      ValueNotifier<Color>(Colors.transparent);

  CellDetails(
      this.cellType, this.id, this.isEmpty, this.color, this.row, this.column) {
    _tmpColorValueNotifier.value = color;
  }

  ValueNotifier<Color> get tmpColor => _tmpColorValueNotifier;

  static CellDetails createEmpty() =>
      CellDetails(CellType.UNDEFINED, -1, true, Colors.white, -1, -1);

  Offset get offset => Offset(column.toDouble(), row.toDouble());

  bool isContainBlack() =>
      cellType == CellType.BLACK || cellType == CellType.BLACK_KING;

  bool isContainBlackKing() => cellType == CellType.BLACK_KING;

  bool isContainBlackPiece() => cellType == CellType.BLACK;

  bool isContainWhite() =>
      cellType == CellType.WHITE || cellType == CellType.WHITE_KING;

  bool isContainWhiteKing() => cellType == CellType.WHITE_KING;

  bool isContainWhitePiece() => cellType == CellType.WHITE;

  bool isEmptyCell() => cellType == CellType.EMPTY;

  bool isUnValid() => cellType == CellType.UNVALID;

  void setCellType({required CellType cellType, required bool isEmpty}) {
    this.isEmpty = isEmpty;
    this.cellType = cellType;
  }

  void changeColor(bool isChangeColor, Color color) {
    tmpColor.value = isChangeColor ? color : this.color;
  }

  void clearColor() {
    tmpColor.value = color;
  }

  @override
  String toString() {
    return 'CellDetails{cellType: $cellType, isEmpty: $isEmpty, color: $color, row: $row, column: $column}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellDetails &&
          runtimeType == other.runtimeType &&
          cellType == other.cellType &&
          isEmpty == other.isEmpty &&
          id == other.id &&
          color == other.color &&
          row == other.row &&
          column == other.column;

  @override
  int get hashCode =>
      cellType.hashCode ^
      isEmpty.hashCode ^
      id.hashCode ^
      color.hashCode ^
      row.hashCode ^
      column.hashCode;
}
