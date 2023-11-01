class Move {
  int fromRow;
  int fromCol;
  int toRow;
  int toCol;
  int skippedRow = -1;
  int skippedCol = -1;

  Move.from(this.fromRow, this.fromCol, this.toRow, this.toCol);

  Move.withSkip(this.fromRow, this.fromCol, this.skippedRow, this.skippedCol, this.toRow, this.toCol);

  Move copy() => Move.withSkip(fromRow, fromCol, skippedRow, skippedCol, toRow, toCol);

  bool isJump() => skippedRow > -1 && skippedCol > -1;

  int getFromRow() => fromRow;
  void setFromRow(int value) => fromRow = value;

  int getFromCol() => fromCol;
  void setFromCol(int value) => fromCol = value;

  int getToRow() => toRow;
  void setToRow(int value) => toRow = value;

  int getToCol() => toCol;
  void setToCol(int value) => toCol = value;

  int getSkippedRow() => skippedRow;
  void setSkippedRow(int value) => skippedRow = value;

  int getSkippedCol() => skippedCol;
  void setSkippedCol(int value) => skippedCol = value;

  @override
  String toString() {
    var sb = StringBuffer("From: (${fromRow},${fromCol})\n");
    if (isJump()) {
      sb.write("Skipped: (${skippedRow},${skippedCol})\n");
    }
    sb.write("To: (${toRow},${toCol})\n");
    return sb.toString();
  }
}

