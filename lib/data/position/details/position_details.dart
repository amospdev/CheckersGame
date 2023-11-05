import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/position/position_data.dart';

class PositionDetails {
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
}

class PositionDetailsCapture extends PositionDetails {
  PositionDetailsCapture(CellDetails cellDetails) : super(true, cellDetails);
}

class PositionDetailsNonCapture extends PositionDetails {
  PositionDetailsNonCapture(CellDetails cellDetails)
      : super(false, cellDetails);
}
