import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position/position_data.dart';

abstract class PositionDetails {
  final bool isCapture;
  final CellDetails cellDetails;

  PositionDetails(this.isCapture, this.cellDetails);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionDetails &&
          runtimeType == other.runtimeType &&
          isCapture == other.isCapture;

  @override
  int get hashCode => isCapture.hashCode;

  Position get position => cellDetails.position;

  @override
  String toString() {
    return 'PositionDetails{position: $position, isCapture: $isCapture}';
  }

  PositionDetails copy();
}

class PositionDetailsCapture extends PositionDetails {
  final Pawn pawnCapture;

  PositionDetailsCapture(
      {required CellDetails cellDetails, required this.pawnCapture})
      : super(true, cellDetails);

  @override
  PositionDetailsCapture copy() {
    return PositionDetailsCapture(
        cellDetails: cellDetails.copy(), pawnCapture: pawnCapture.copy());
  }
}

class PositionDetailsNonCapture extends PositionDetails {
  PositionDetailsNonCapture(CellDetails cellDetails)
      : super(false, cellDetails);

  @override
  PositionDetailsNonCapture copy() {
    return PositionDetailsNonCapture(cellDetails.copy());
  }
}
