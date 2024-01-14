import 'package:untitled/data/cell/cell_details.dart';
import 'package:untitled/data/pawn/pawn_details.dart';
import 'package:untitled/data/cell/position_details.dart';
import 'package:untitled/data/cell/position_data.dart';
import 'package:untitled/extensions/cg_collections.dart';

class PawnPath {
  final List<PositionDetails> positionDetailsList;

  bool isContinuePath = false;
  final PawnDetails pawnStartPath;

  PawnPath(this.positionDetailsList, this.pawnStartPath);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PawnPath &&
          runtimeType == other.runtimeType &&
          positionDetailsList == other.positionDetailsList;

  @override
  int get hashCode => positionDetailsList.hashCode;

  @override
  String toString() {
    return 'Path{positionDetails: $positionDetailsList}';
  }

  static PawnPath createEmpty() => PawnPath([], PawnDetails.createEmpty());

  bool get isValidPath => positionDetailsList.isNotEmpty;

  Position get startPosition => positionDetailsList.first.position;

  Position get endPosition => positionDetailsList.last.position;

  CellDetails get startCell => positionDetailsList.first.cellDetails;

  CellDetails get endCell => positionDetailsList.last.cellDetails;

  CellDetails? get captureCell => positionDetailsList
      .firstWhereOrNull((element) => element.isCapture)
      ?.cellDetails;

  PawnDetails? get capturePawn => positionDetailsList
      .whereType<PositionDetailsCapture>()
      .firstOrNull
      ?.pawnCapture;

  PawnPath copy() {
    return PawnPath(List.from(positionDetailsList.map((e) => e.copy())),
        pawnStartPath.copy())
      ..isContinuePath = isContinuePath;
  }
}
