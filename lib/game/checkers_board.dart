
class CheckersBoard {
  List<List<CellType>> _board = [];
  CellType _player = CellType.BLACK;
  List<Path> paths = [];

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
      row >= 0 && row < 8 && col >= 0 && col < 8;

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

    paths.clear();
    _fetchAllPaths(paths, _createPosition(row, col));
    print("TOTAL Paths size: ${paths.length}");

    return paths;
  }

  int _getRowDirection() => _player == CellType.BLACK ? 1 : -1;

  int _getColDirection(Position prevPosition, Position currPosition) =>
      prevPosition.column > currPosition.column ? -1 : 1;

  Position _getNextPosition(Position position, int colDir) => _createPosition(
      position.row + _getRowDirection(), position.column + colDir);

  Position _createPosition(int row, int column) => Position(row, column);

  void _fetchAllPaths(List<Path> paths, Position startPos) {
    Position colPlus = _getNextPosition(startPos, 1);

    Position colMinus = _getNextPosition(startPos, -1);

    _fetchPaths(
        [_getPositionDetailsByNonCapture(startPos)], paths, colPlus, startPos);

    _fetchPaths(
        [_getPositionDetailsByNonCapture(startPos)], paths, colMinus, startPos);
  }

  PositionDetails _getPositionDetailsByNonCapture(Position position) =>
      _createPositionDetails(position, _getCellTypeByPosition(position), false);

  PositionDetails _getPositionDetailsByCapture(Position position) =>
      _createPositionDetails(position, _getCellTypeByPosition(position), true);

  PositionDetails _createPositionDetails(
          Position position, CellType cellType, bool isCapture) =>
      PositionDetails(position, _getCellTypeByPosition(position), isCapture);

  void _fetchPaths(List<PositionDetails> positionDetailsList, List<Path> paths,
      Position currPosition, Position startPos) {
    Position prevPosition = positionDetailsList.last.position;

    int colDirection = _getColDirection(prevPosition, currPosition);

    Position nextPosition = _getNextPosition(currPosition, colDirection);

    bool isCaptureMove = _isCaptureMove(currPosition, nextPosition);

    // Capture move
    if (isCaptureMove) {
      positionDetailsList.add(_getPositionDetailsByCapture(currPosition));
      positionDetailsList.add(_getPositionDetailsByNonCapture(nextPosition));

      Position nextIterationPositionChangeDirection =
          _getNextPosition(nextPosition, (colDirection * -1));

      Position nextNextIterationPositionChangeDirection = _getNextPosition(
          nextIterationPositionChangeDirection, (colDirection * -1));

      bool isChangeDirCaptureMove = _isCaptureMove(
          nextIterationPositionChangeDirection,
          nextNextIterationPositionChangeDirection);

      if (isChangeDirCaptureMove) {
        List<PositionDetails> positionDetailsListTmp = [...positionDetailsList];

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
        _fetchPaths(
            positionDetailsList, paths, nextIterationPosition, startPos);
      }

      // Ent of path
      if (!isChangeDirCaptureMove && !isNextCaptureMove) {
        //Determine if the list has captures
        if (positionDetailsList.length >= 3) {
          _addPath(positionDetailsList, paths);
        }
      }
    } else if (_isInBoundsByPosition(currPosition) &&
        _isEmptyCellByPosition(currPosition)) {
      //Simple move
      // positionDetailsList.add(_getPositionDetailsByNonCapture(startPos));
      positionDetailsList.add(_getPositionDetailsByNonCapture(currPosition));

      _addPath(positionDetailsList, paths);
    }
  }

  void _addPath(List<PositionDetails> positionDetailsList, List<Path> paths) {
    Path path = Path(positionDetailsList);
    paths.add(path);
  }

  bool _isCaptureMove(Position currPosition, Position nextPosition) {
    return _isInBoundsByPosition(currPosition) &&
        _isInBoundsByPosition(nextPosition) &&
        _isOpponentCell(currPosition) &&
        _isEmptyCellByPosition(nextPosition);
  }

  void performMove(
      int startRow, int startCol, int endRow, int endCol, Path path) {
    if (path.positionDetails.isEmpty) return;

    Position startPosition = _createPosition(
        path.positionDetails.first.position.row,
        path.positionDetails.first.position.column);
    Position endPosition = _createPosition(
        path.positionDetails.last.position.row,
        path.positionDetails.last.position.column);

    // Update the end position based on the type of the piece and its final position on the board
    if (_isBlackByPosition(startPosition)) {
      if (_isKingByPosition(startPosition) || endPosition.row == 7) {
        _board[endPosition.row][endPosition.column] = CellType.BLACK_KING;
      } else {
        _board[endPosition.row][endPosition.column] = CellType.BLACK;
      }
    } else {
      if (_isKingByPosition(startPosition) || endPosition.row == 0) {
        _board[endPosition.row][endPosition.column] = CellType.WHITE_KING;
      } else {
        _board[endPosition.row][endPosition.column] = CellType.WHITE;
      }
    }

    // Remove captured pieces
    for (PositionDetails positionDetails in path.positionDetails) {
      if (positionDetails.isCapture) {
        _board[positionDetails.position.row][positionDetails.position.column] =
            CellType.EMPTY;
      }
    }

    // IMPORTANT: Update the starting position to empty
    _board[startPosition.row][startPosition.column] = CellType.EMPTY;
  }

  void nextTurn() {
    _clearPrevData();
    _printBoard();
    _switchPlayer();
  }

  void _clearPrevData() {
    paths.clear();
  }

  Path getPathByEndPosition(
      int startRow, int startCol, int endRow, int endCol) {
    Position to = _createPosition(endRow, endCol);
    for (Path path in paths) {
      Position pathEnd = path.positionDetails.last.position;
      if (pathEnd.row == to.row && pathEnd.column == to.column) {
        print("RESULT: ${path}");
        return path;
      }
    }
    return Path([]);
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
