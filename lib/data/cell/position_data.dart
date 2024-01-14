import 'package:untitled/game/checkers_board.dart';

class Position {
  final int row;
  final int column;

  Position(this.row, this.column);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.column == column;
  }

  bool get isNotInBounds => !isInBounds;

  bool get isInBounds =>
      row >= 0 &&
      row < CheckersBoard.sizeBoard &&
      column >= 0 &&
      column < CheckersBoard.sizeBoard;

  Position nextPosition(Position positionDir) =>
      Position(row + positionDir.row, column + positionDir.column);

  @override
  int get hashCode => row.hashCode ^ column.hashCode;

  @override
  String toString() => '($row, $column)';
}
