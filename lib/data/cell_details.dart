import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details_data.dart';
import 'package:untitled/data/position_data.dart';
import 'package:untitled/enum/cell_type.dart';

class CellDetails {
  CellType cellType = CellType.UNDEFINED;
  bool isEmpty = true;
  int id = -1;
  Color color;
  final int row;
  final int column;

  Position get position => _position;
  Position _position = Position(-1, -1);

  final ValueNotifier<CellDetailsData> _cellDetailsDataValueNotifier =
      ValueNotifier<CellDetailsData>(CellDetailsData.createEmpty());

  CellDetails(
      this.cellType, this.id, this.isEmpty, this.color, this.row, this.column) {
    _cellDetailsDataValueNotifier.value = CellDetailsData(tmpColor: color);
    _position = Position(row, column);
  }

  static CellDetails createEmpty() =>
      CellDetails(CellType.UNDEFINED, -1, true, Colors.white, -1, -1);

  // The copy method
  CellDetails copy() {
    return CellDetails(
      cellType,
      id,
      isEmpty,
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

  void changeColor(Color color) =>
      _setCellDetailsDataValueNotifier(tmpColor: color);

  void clearColor() => changeColor(color);

  @override
  String toString() {
    return 'CellDetails{cellType: $cellType, isEmpty: $isEmpty, id: $id, row: $row, column: $column}';
  }
}
