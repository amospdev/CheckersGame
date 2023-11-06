import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position/details/position_details.dart';
import 'package:untitled/data/position/position_data.dart';

class PathPawn {
  final List<PositionDetails> positionDetailsList;

  bool isContinuePath = false;
  final Pawn pawnStartPath;

  PathPawn(this.positionDetailsList, this.pawnStartPath);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathPawn &&
          runtimeType == other.runtimeType &&
          positionDetailsList == other.positionDetailsList;

  @override
  int get hashCode => positionDetailsList.hashCode;

  @override
  String toString() {
    return 'Path{positionDetails: $positionDetailsList}';
  }

  static PathPawn createEmpty() => PathPawn([], Pawn.createEmpty());

  bool isValidPath() => positionDetailsList.isNotEmpty;

  Position get startPosition => positionDetailsList.first.position;

  Position get endPosition => positionDetailsList.last.position;
}
