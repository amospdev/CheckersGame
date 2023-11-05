import 'package:untitled/data/position/details/position_details.dart';

class PathPawn {
  final List<PositionDetails> positionDetailsList;

  bool isContinuePath = false;

  PathPawn(this.positionDetailsList);

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

  static PathPawn createEmpty() => PathPawn([]);

  bool isValidPath() => positionDetailsList.isNotEmpty;
}
