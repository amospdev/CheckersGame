class HeuristicData {
  int pawn = 0; // Number of normal pieces
  int king = 0; // Number of kings
  int backRowPiece = 0; // Number of pieces at the back row
  int middleBoxPiece =
      0; // Number of pieces in middle 4 columns of middle 2 rows
  int middleRowPiece =
      0; // Number of pieces in middle 2 rows but not the middle 4 columns
  int vulnerable =
      0; // Number of pieces that can be taken by opponent on the next turn
  int protectedPiece =
      0; // Number of pieces that cannot be taken until pieces behind it (or itself) are moved

  static const double PAWN_WEIGHT = 5 / 2;
  static const double KING_WEIGHT = 7.75;
  static const double BACK_ROW_PIECE_WEIGHT = 4;
  static const double MIDDLE_BOX_PIECE_WEIGHT = 2.5;
  static const double MIDDLE_ROW_PIECE_WEIGHT = 0.5;
  static const double VULNERABLE_WEIGHT = -3;
  static const double PROTECTED_PIECE_WEIGHT = 3;

  HeuristicData();

  int getPawn() => pawn;

  void setPawn(int pawn) {
    this.pawn = pawn;
  }

  int getKing() => king;

  void setKing(int king) {
    this.king = king;
  }

  int getBackRowPiece() => backRowPiece;

  void setBackRowPiece(int backRowPiece) {
    this.backRowPiece = backRowPiece;
  }

  int getMiddleBoxPiece() => middleBoxPiece;

  void setMiddleBoxPiece(int middleBoxPiece) {
    this.middleBoxPiece = middleBoxPiece;
  }

  int getMiddleRowPiece() => middleRowPiece;

  void setMiddleRowPiece(int middleRowPiece) {
    this.middleRowPiece = middleRowPiece;
  }

  int getVulnerable() => vulnerable;

  void setVulnerable(int vulnerable) {
    this.vulnerable = vulnerable;
  }

  int getProtectedPiece() => protectedPiece;

  void setProtectedPiece(int protectedPiece) {
    this.protectedPiece = protectedPiece;
  }

  HeuristicData subtract(HeuristicData data) {
    pawn -= data.pawn;
    king -= data.king;
    backRowPiece -= data.backRowPiece;
    vulnerable -= data.vulnerable;
    protectedPiece -= data.protectedPiece;
    middleBoxPiece -= data.middleBoxPiece;
    middleRowPiece -= data.middleRowPiece;
    return this;
  }

  double getSum() {
    double sum = pawn * PAWN_WEIGHT;
    sum += king * KING_WEIGHT;
    sum += backRowPiece * BACK_ROW_PIECE_WEIGHT;
    sum += middleBoxPiece * MIDDLE_BOX_PIECE_WEIGHT;
    sum += middleRowPiece * MIDDLE_ROW_PIECE_WEIGHT;
    sum += vulnerable * VULNERABLE_WEIGHT;
    sum += protectedPiece * PROTECTED_PIECE_WEIGHT;
    return sum;
  }
}
