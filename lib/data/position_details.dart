import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/position_data.dart';

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
