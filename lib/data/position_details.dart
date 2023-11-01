import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/position_data.dart';
import 'package:untitled/enum/cell_type.dart';

class PositionDetails {
  final Position position;
  final CellType cellType;
  final bool isCapture;
  final CellDetails cellDetails;

  PositionDetails(
      this.position, this.cellType, this.isCapture, this.cellDetails);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PositionDetails &&
              runtimeType == other.runtimeType &&
              position == other.position &&
              cellType == other.cellType &&
              isCapture == other.isCapture;

  @override
  int get hashCode =>
      position.hashCode ^ cellType.hashCode ^ isCapture.hashCode;

  @override
  String toString() {
    return 'PositionDetails{position: $position, cellType: $cellType, isCapture: $isCapture}';
  }
}
