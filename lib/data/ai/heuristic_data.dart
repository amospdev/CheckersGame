class HeuristicData {
  int pawn; // Number of normal pieces
  int king; // Number of kings
  int backRowPiece; // Number of pieces at the back row
  int middleBoxPiece; // Number of pieces in middle 4 columns of middle 2 rows
  int middleRowPiece; // Number of pieces in middle 2 rows but not the middle 4 columns
  int vulnerable; // Number of pieces that can be taken by opponent on the next turn
  int protectedPiece; // Number of pieces that cannot be taken until pieces behind it (or itself) are moved

  static const double PAWN_WEIGHT = 5/2;
  static const double KING_WEIGHT = 7.75;
  static const double BACK_ROW_PIECE_WEIGHT = 4;
  static const double MIDDLE_BOX_PIECE_WEIGHT = 2.5;
  static const double MIDDLE_ROW_PIECE_WEIGHT = 0.5;
  static const double VULNERABLE_WEIGHT = -3;
  static const double PROTECTED_PIECE_WEIGHT = 3;

  HeuristicData({
    this.pawn = 0,
    this.king = 0,
    this.backRowPiece = 0,
    this.middleBoxPiece = 0,
    this.middleRowPiece = 0,
    this.vulnerable = 0,
    this.protectedPiece = 0,
  });

  double get sum {
    return pawn * PAWN_WEIGHT +
        king * KING_WEIGHT +
        backRowPiece * BACK_ROW_PIECE_WEIGHT +
        middleBoxPiece * MIDDLE_BOX_PIECE_WEIGHT +
        middleRowPiece * MIDDLE_ROW_PIECE_WEIGHT +
        vulnerable * VULNERABLE_WEIGHT +
        protectedPiece * PROTECTED_PIECE_WEIGHT;
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
}
