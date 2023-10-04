/// Represents a move on checkers board.
/// However, it does not verify if the move is legal or not.
class Move {
  int fromRow;
  int fromCol;
  int toRow;
  int toCol;
  int skippedRow = -1;
  int skippedCol = -1;

  Move(this.fromRow, this.fromCol, this.skippedRow, this.skippedCol, this.toRow, this.toCol);

  Move.withoutSkip(this.fromRow, this.fromCol, this.toRow, this.toCol)
      : skippedRow = -1,
        skippedCol = -1;

  Move.empty()
      : fromRow = -1,
        fromCol = -1,
        skippedRow = -1,
        skippedCol = -1,
        toRow = -1,
        toCol = -1;

  /// Returns a copy of the move
  Move copy() {
    return Move(fromRow, fromCol, skippedRow, skippedCol, toRow, toCol);
  }

  /// Test whether this move is a jump.
  bool isJump() {
    return skippedRow > -1 && skippedCol > -1;
  }

  @override
  String toString() {
    final sb = StringBuffer("From: ($fromRow,$fromCol)\n");
    if (isJump()) {
      sb.write("Skipped: ($skippedRow,$skippedCol)\n");
    }
    sb.write("To: ($toRow,$toCol)\n");
    return sb.toString();
  }
}
