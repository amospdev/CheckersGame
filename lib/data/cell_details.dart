import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details_data.dart';
import 'package:untitled/data/position_data.dart';
import 'package:untitled/enum/cell_type.dart';

class CellDetails {
  CellType cellType = CellType.UNDEFINED;
  int id = -1;
  Color color;
  final int row;
  final int column;

  Position get position => _position;
  Position _position = Position(-1, -1);

  final ValueNotifier<CellDetailsData> _cellDetailsDataValueNotifier =
      ValueNotifier<CellDetailsData>(CellDetailsData.createEmpty());

  CellDetails(
      this.cellType, this.id, this.color, this.row, this.column) {
    _cellDetailsDataValueNotifier.value = CellDetailsData(tmpColor: color);
    _position = Position(row, column);
  }

  static CellDetails createEmpty() =>
      CellDetails(CellType.UNDEFINED, -1, Colors.white, -1, -1);

  // The copy method
  CellDetails copy() {
    return CellDetails(
      cellType,
      id,
      color,
      row,
      column,
    );
  }

  CellType getCellTypePlayer() {
    if (cellType == CellType.BLACK || cellType == CellType.BLACK_KING) {
      return CellType.BLACK;
    } else if (cellType == CellType.WHITE || cellType == CellType.WHITE_KING) {
      return CellType.WHITE;
    }

    return CellType.UNDEFINED;
  }

  void _setCellDetailsDataValueNotifier({Color? tmpColor}) =>
      _cellDetailsDataValueNotifier.value = CellDetailsData(
          tmpColor: tmpColor ?? _cellDetailsDataValueNotifier.value.tmpColor);

  ValueNotifier<CellDetailsData> get cellDetailsData =>
      _cellDetailsDataValueNotifier;

  Color get tmpColor => _cellDetailsDataValueNotifier.value.tmpColor;

  Offset get offset => Offset(column.toDouble(), row.toDouble());

  bool get isBlack =>
      cellType == CellType.BLACK || cellType == CellType.BLACK_KING;

  bool get isBlackKing => cellType == CellType.BLACK_KING;

  bool get isBlackPawn => cellType == CellType.BLACK;

  bool get isWhite =>
      cellType == CellType.WHITE || cellType == CellType.WHITE_KING;

  bool get isWhiteKing => cellType == CellType.WHITE_KING;

  bool get isKing =>
      cellType == CellType.WHITE_KING || cellType == CellType.BLACK_KING;

  bool get isPawn => cellType == CellType.WHITE || cellType == CellType.BLACK;

  bool get isWhitePawn => cellType == CellType.WHITE;

  bool get isEmptyCell => cellType == CellType.EMPTY;

  bool get isUnValid => cellType == CellType.UNVALID;

  bool get isUndefined => cellType == CellType.UNDEFINED;

  void setCellType({required CellType cellType}) {
    this.cellType = cellType;
  }

  void changeColor(Color color) =>
      _setCellDetailsDataValueNotifier(tmpColor: color);

  void clearColor() => changeColor(color);

  @override
  String toString() {
    return 'CellDetails{cellType: $cellType, id: $id, row: $row, column: $column}';
  }
}
