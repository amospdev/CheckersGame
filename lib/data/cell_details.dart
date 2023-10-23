import 'package:flutter/material.dart';
import 'package:untitled/enum/cell_type.dart';

class CellDetails {
  CellType cellType = CellType.UNDEFINED;
  bool isEmpty = true;
  int id = -1;
  Color color;
  final int row;
  final int column;

  Color _tmpColor = Colors.transparent;

  CellDetails(
      this.cellType, this.id, this.isEmpty, this.color, this.row, this.column) {
    _tmpColor = color;
  }

  Color get tmpColor => _tmpColor;

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
    _tmpColor = isChangeColor ? color : this.color;
  }

  void setTmpColor(Color tmpColor) {
    _tmpColor = tmpColor;
  }

  void clearColor() {
    _tmpColor = color;
  }

  @override
  String toString() {
    return 'CellDetails{cellType: $cellType, isEmpty: $isEmpty, id: $id, color: $color, row: $row, column: $column, _tmpColor: $_tmpColor}';
  }
}
