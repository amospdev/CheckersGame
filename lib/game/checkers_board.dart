class CheckersBoard {
  List<List<CellType>> _board = [];
  CellType _player = CellType.BLACK;
  static const int _whiteKingRow = 0;
  static const int _blackKingRow = 7;

  // List<Path> paths = [];

  CheckersBoard() {
    resetBoard();
    _printBoard();
  }

  List<List<CellType>> get board => _board;

  CellType get player => _player;

  void resetBoard() {
    _board = List.generate(8, (i) => List<CellType>.filled(8, CellType.EMPTY));
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if ((i + j) % 2 == 0) {
          _board[i][j] = CellType.UNVALID;
        } else {
          if (i < 3) {
            _board[i][j] = CellType.BLACK;
          } else if (i > 4) {
            _board[i][j] = CellType.WHITE;
          }
        }
      }
    }
  }

  void _switchPlayer() {
    _player = (_player == CellType.BLACK) ? CellType.WHITE : CellType.BLACK;
  }

  void _printBoard() {
    for (int i = 0; i < 8; i++) {
      String row = "";
      for (int j = 0; j < 8; j++) {
        row += "${_board[i][j].index} ";
      }
      print(row);
    }
  }

  bool _isInBoundsByPosition(Position position) =>
      _isInBounds(position.row, position.column);

  bool _isInBounds(int row, int col) =>
      _isRowInBounds(row) && _isColumnInBounds(col);

  bool _isRowInBounds(int row) => row >= 0 && row < 8;

  bool _isColumnInBounds(int col) => col >= 0 && col < 8;

  bool _isKingByPosition(Position position) =>
      _isKing(position.row, position.row);

  bool _isKing(int row, int column) =>
      _getCellType(row, column) == CellType.BLACK_KING ||
      _getCellType(row, column) == CellType.WHITE_KING;

  bool _isEmptyCellByPosition(Position position) =>
      _isEmptyCell(position.row, position.column);

  bool _isEmptyCell(int row, int col) =>
      _getCellType(row, col) == CellType.EMPTY;

  bool _isBlackByPosition(Position position) =>
      _isBlack(position.row, position.column);

  bool _isBlack(int row, int column) =>
      _getCellType(row, column) == CellType.BLACK ||
      _getCellType(row, column) == CellType.BLACK_KING;

  bool _isWhiteByPosition(Position position) =>
      _isWhite(position.row, position.column);

  bool _isWhite(int row, int column) =>
      _getCellType(row, column) == CellType.WHITE ||
      _getCellType(row, column) == CellType.WHITE_KING;

  bool _isUnValidCellByPosition(int row, int col) => _isUnValidCell(row, col);

  bool _isUnValidCell(int row, int column) =>
      _getCellType(row, column) == CellType.UNVALID;

  bool _isOpponentCell(Position position) {
    if (_isWhiteByPosition(position) && _player == CellType.BLACK) {
      return true;
    }

    if (_isBlackByPosition(position) && _player == CellType.WHITE) {
      return true;
    }

    return false;
  }

  CellType _getCellTypeByPosition(Position position) =>
      _getCellType(position.row, position.column);

  CellType _getCellType(int row, int col) =>
      _isInBounds(row, col) ? _board[row][col] : CellType.UNDEFINED;

  List<Path> getPossiblePaths(int row, int col) {
    if (_isEmptyCell(row, col)) return [];
    if (_isUnValidCellByPosition(row, col)) return [];
    if (_getCellType(row, col) != player) return [];

    List<Path> paths = [];
    _fetchAllPaths(paths, _createPosition(row, col));
    print("TOTAL Paths size: ${paths.length}");

    return paths;
  }

  int _getRowDirection() => _player == CellType.BLACK ? 1 : -1;

  int _getColDirection(
          {required Position prevPosition, required Position currPosition}) =>
      prevPosition.column > currPosition.column ? -1 : 1;

  int _getColDirectionPositionDetails(
          List<PositionDetails> positionDetails, Position currPosition) =>
      _getColDirection(
          prevPosition: _getLastPosition(positionDetails),
          currPosition: currPosition);

  Position _getLastPosition(List<PositionDetails> positionDetails) =>
      positionDetails.last.position;

  Position _getNextPosition(Position position, int colDir) => _createPosition(
      position.row + _getRowDirection(), position.column + colDir);

  Position _createPosition(int row, int column) => Position(row, column);

  bool isContinuePaths(int row, int col, Path path) =>
      getPossibleContinuePaths(row, col).isNotEmpty &&
              _hasCapturePositionDetails(path.positionDetails)
          ? true
          : false;

  List<Path> getPossibleContinuePaths(int row, int col) {
    List<Path> paths = [];

    Position startPos = _createPosition(row, col);

    PositionDetails positionDetailsStartPos =
        PositionDetails(startPos, _getCellTypeByPosition(startPos), false);

    Position nextPositionPlus = _getNextPosition(startPos, 1);
    Position afterNextPositionPlus = _getNextPosition(nextPositionPlus, 1);

    Position nextPositionMinus = _getNextPosition(startPos, -1);
    Position afterNextPositionMinus = _getNextPosition(nextPositionMinus, -1);

    if (_isCaptureMove(nextPositionPlus, afterNextPositionPlus)) {
      _addPath([
        positionDetailsStartPos,
        _getPositionDetailsCapture(nextPositionPlus),
        _getPositionDetailsNonCapture(afterNextPositionPlus),
      ], paths);
    }

    if (_isCaptureMove(nextPositionMinus, afterNextPositionMinus)) {
      _addPath([
        positionDetailsStartPos,
        _getPositionDetailsCapture(nextPositionMinus),
        _getPositionDetailsNonCapture(afterNextPositionMinus),
      ], paths);
    }

    return paths;
  }

  void _fetchAllPaths(List<Path> paths, Position startPos) {
    Position colPlus = _getNextPosition(startPos, 1);

    Position colMinus = _getNextPosition(startPos, -1);

    _fetchPaths(
        [_getPositionDetailsNonCapture(startPos)], paths, colPlus, startPos);

    _fetchPaths(
        [_getPositionDetailsNonCapture(startPos)], paths, colMinus, startPos);

    Set<Position> duplicatePosition = {};

    for (var element in paths) {
      Position currPosition = element.positionDetails.last.position;
      if (duplicatePosition.contains(currPosition)) {
        for (var element in paths) {
          if (element.positionDetails.last.position == currPosition) {
            element.positionDetails
                .removeAt(element.positionDetails.length - 1);
            element.positionDetails
                .removeAt(element.positionDetails.length - 1);
          }
        }
      }
      duplicatePosition.add(currPosition);
    }
  }

  PositionDetails _getPositionDetailsNonCapture(Position position) =>
      _createPositionDetails(position, _getCellTypeByPosition(position), false);

  PositionDetails _getPositionDetailsCapture(Position position) =>
      _createPositionDetails(position, _getCellTypeByPosition(position), true);

  PositionDetails _createPositionDetails(
          Position position, CellType cellType, bool isCapture) =>
      PositionDetails(position, _getCellTypeByPosition(position), isCapture);

  void _fetchPaths(List<PositionDetails> positionDetails, List<Path> paths,
      Position currPosition, Position startPos) {
    int colDirection =
        _getColDirectionPositionDetails(positionDetails, currPosition);

    Position nextPosition = _getNextPosition(currPosition, colDirection);

    bool isCaptureMove = _isCaptureMove(currPosition, nextPosition);

    // Capture move
    if (isCaptureMove) {
      positionDetails.add(_getPositionDetailsCapture(currPosition));
      positionDetails.add(_getPositionDetailsNonCapture(nextPosition));

      Position nextIterationPositionChangeDirection =
          _getNextPosition(nextPosition, (colDirection * -1));

      Position nextNextIterationPositionChangeDirection = _getNextPosition(
          nextIterationPositionChangeDirection, (colDirection * -1));

      bool isChangeDirCaptureMove = _isCaptureMove(
          nextIterationPositionChangeDirection,
          nextNextIterationPositionChangeDirection);

      if (isChangeDirCaptureMove) {
        List<PositionDetails> positionDetailsListTmp = [...positionDetails];

        _fetchPaths(positionDetailsListTmp, paths,
            nextIterationPositionChangeDirection, startPos);
      }

      Position nextIterationPosition =
          _getNextPosition(nextPosition, colDirection);

      Position nextNextIterationPosition =
          _getNextPosition(nextIterationPosition, colDirection);

      bool isNextCaptureMove =
          _isCaptureMove(nextIterationPosition, nextNextIterationPosition);
      if (isNextCaptureMove) {
        _fetchPaths(positionDetails, paths, nextIterationPosition, startPos);
      }

      // End of path
      if (!isChangeDirCaptureMove && !isNextCaptureMove) {
        //Determine if the list has captures
        if (_hasCapturePositionDetails(positionDetails)) {
          _addPath(positionDetails, paths);
        }
      }
    } else if (_isSimpleMove(startPos, currPosition)) {
      //Simple move
      positionDetails.add(_getPositionDetailsNonCapture(currPosition));

      _addPath(positionDetails, paths);
    }
  }

  bool _hasCapturePositionDetails(List<PositionDetails> positionDetails) =>
      positionDetails.map((e) => e.isCapture).contains(true);

  void _addPath(List<PositionDetails> positionDetailsList, List<Path> paths) {
    Path path = Path(positionDetailsList);
    paths.add(path);
  }

  bool _isCaptureMove(Position currPosition, Position nextPosition) =>
      _isInBoundsByPosition(currPosition) &&
      _isInBoundsByPosition(nextPosition) &&
      _isOpponentCell(currPosition) &&
      _isEmptyCellByPosition(nextPosition);

  bool _isSimpleMove(Position currPosition, Position nextPosition) =>
      _isInBoundsByPosition(currPosition) &&
      _isInBoundsByPosition(nextPosition) &&
      _isEmptyCellByPosition(nextPosition);

  void performMove(
      int startRow, int startCol, int endRow, int endCol, Path path) {
    if (_isPathNotValid(path)) return;
    Position startPosition = _createPosition(startRow, startCol);
    Position endPosition = _createPosition(endRow, endCol);
    _performMoveByPosition(startPosition, endPosition, path.positionDetails);
  }

  bool _isPathNotValid(Path path) => path.positionDetails.isEmpty;

  void _performMoveByPosition(Position startPosition, Position endPosition,
      List<PositionDetails> positionDetails) {
    // Update the end position based on the type of the piece and its final position on the board
    _updateEndPosition(startPosition, endPosition);

    // Remove captured pieces
    _removeCapturedPieces(positionDetails);

    // IMPORTANT: Update the starting position to empty
    _clearStartPosition(startPosition);
  }

  void _updateEndPosition(Position startPosition, Position endPosition) {
    bool isBlackByPosition = _isBlackByPosition(startPosition);

    bool isKing = _isKingPiece(
        startPosition: startPosition,
        endPosition: endPosition,
        isBlack: isBlackByPosition);

    CellType cellType = _getPiece(isBlackByPosition, isKing);

    _setCell(cellType, endPosition);
  }

  bool _isKingPiece(
          {required Position startPosition,
          required Position endPosition,
          required bool isBlack}) =>
      _isKingByPosition(startPosition) ||
      _isKingRow(endPosition, isBlack ? _blackKingRow : _whiteKingRow);

  bool _isKingRow(Position position, int kingRow) => position.row == kingRow;

  void _removeCapturedPieces(List<PositionDetails> positionDetails) {
    for (PositionDetails positionDetails in positionDetails) {
      if (positionDetails.isCapture) {
        _clearCapturePiece(positionDetails.position);
      }
    }
  }

  void _clearCapturePiece(Position piecePosition) =>
      _setCellToEmpty(piecePosition);

  void _clearStartPosition(Position startPosition) =>
      _setCellToEmpty(startPosition);

  void _setCellToEmpty(Position position) => _setCell(CellType.EMPTY, position);

  CellType _getPiece(bool isBlackByPosition, bool isKing) =>
      isBlackByPosition ? _getBlackPiece(isKing) : _getWhitePiece(isKing);

  CellType _getBlackPiece(bool isKing) =>
      isKing ? CellType.BLACK_KING : CellType.BLACK;

  CellType _getWhitePiece(bool isKing) =>
      isKing ? CellType.WHITE_KING : CellType.WHITE;

  void _setCell(CellType cellType, Position position) =>
      _board[position.row][position.column] = cellType;

  void nextTurn() {
    _clearPrevData();
    _printBoard();
    _switchPlayer();
  }

  void _clearPrevData() {}

  Path? getPathByEndPosition(
      int startRow, int startCol, int endRow, int endCol) {
    List<Path> paths = getPossiblePaths(startRow, startCol);

    Position to = _createPosition(endRow, endCol);
    for (Path path in paths) {
      Position pathEnd = path.positionDetails.last.position;
      if (pathEnd.row == to.row && pathEnd.column == to.column) {
        return path;
      }
    }
    return null;
  }
}

class Position {
  final int row;
  final int column;

  Position(this.row, this.column);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.row == row && other.column == column;
  }

  @override
  int get hashCode => row.hashCode ^ column.hashCode;

  @override
  String toString() => '($row, $column)';
}

class PositionDetails {
  final Position position;
  final CellType cellType;
  final bool isCapture;

  PositionDetails(this.position, this.cellType, this.isCapture);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionDetails &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          cellType == other.cellType &&
          isCapture == other.isCapture;

  @override
  int get hashCode =>
      position.hashCode ^ cellType.hashCode ^ isCapture.hashCode;

  @override
  String toString() {
    return 'PositionDetails{position: $position, cellType: $cellType, isCapture: $isCapture}';
  }
}

class Path {
  final List<PositionDetails> positionDetails;

  Path(this.positionDetails);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Path &&
          runtimeType == other.runtimeType &&
          positionDetails == other.positionDetails;

  @override
  int get hashCode => positionDetails.hashCode;

  @override
  String toString() {
    return 'Path{positionDetails: $positionDetails}';
  }

  static Path createEmpty() => Path([]);
}

enum CellType {
  EMPTY,
  BLACK,
  WHITE,
  BLACK_KING,
  WHITE_KING,
  UNVALID,
  UNDEFINED,
}
