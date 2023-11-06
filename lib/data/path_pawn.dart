import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position/details/position_details.dart';
import 'package:untitled/data/position/position_data.dart';
import 'package:untitled/extensions/cg_collections.dart';

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

  CellDetails get startCell => positionDetailsList.first.cellDetails;

  CellDetails get endCell => positionDetailsList.last.cellDetails;

  CellDetails? get captureCell => positionDetailsList
      .firstWhereOrNull((element) => element.isCapture)
      ?.cellDetails;

  Pawn? get capturePawn => positionDetailsList
      .whereType<PositionDetailsCapture>()
      .firstOrNull
      ?.pawnCapture;

  PathPawn copy() {
    return PathPawn(List.from(positionDetailsList.map((e) => e.copy())),
        pawnStartPath.copy());
  }
}
