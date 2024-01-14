/// Represents the position of a pawn on a game board, defined by its left and top coordinates.
class PawnPosition {
  /// The horizontal position of the pawn on the game board, measured from the left.
  final double left;

  /// The vertical position of the pawn on the game board, measured from the top.
  final double top;

  final double durationMove;

  /// Creates a new instance of the [PawnPosition] class with the specified [left] and [top] coordinates.
  ///
  /// The [left] parameter represents the horizontal position of the pawn on the game board.
  /// The [top] parameter represents the vertical position of the pawn on the game board.
  PawnPosition({
    required this.left,
    required this.top,
    required this.durationMove,
  });
}
