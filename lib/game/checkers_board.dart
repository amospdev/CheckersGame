import 'package:flutter/foundation.dart';

class CheckersBoard {
  List<List<CellType>> _board = [];
  CellType _player = CellType.BLACK;
  static const int _whiteKingRow = 0;
  static const int _blackKingRow = 7;

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

  List<Position> _getPieceDirections() => [
        _createPosition(_getRowDirection(), 1),
        _createPosition(_getRowDirection(), -1),
      ];

  List<Position> _getKingDirections() => [
        _createPosition(1, 1),
        _createPosition(-1, -1),
        _createPosition(1, -1),
        _createPosition(-1, 1)
      ];

  void _switchPlayer() {
    _player = (_player == CellType.BLACK) ? CellType.WHITE : CellType.BLACK;
  }

  void _printBoard() {
    for (int i = 0; i < 8; i++) {
      String row = "";
      for (int j = 0; j < 8; j++) {
        row += "${_board[i][j].index} ";
      }
      if (kDebugMode) {
        print(row);
      }
    }
  }

  bool _isInBoundsByPosition(Position position) =>
      _isInBounds(position.row, position.column);

  bool _isInBounds(int row, int col) =>
      _isRowInBounds(row) && _isColumnInBounds(col);

  bool _isRowInBounds(int row) => row >= 0 && row < 8;

  bool _isColumnInBounds(int col) => col >= 0 && col < 8;

  bool _isKingByPosition(Position position) =>
      _isKing(position.row, position.column);

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

  bool _isUnValidCellByPosition(Position position) =>
      _isUnValidCell(position.row, position.column);

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

  bool _isWhitePlayerTurn() =>
      _player == CellType.WHITE || _player == CellType.WHITE_KING;

  bool _isBlackPlayerTurn() =>
      _player == CellType.BLACK || _player == CellType.BLACK_KING;

  bool _isSamePlayerByPosition(Position position) =>
      _isSamePlayer(position.row, position.column);

  bool _isSamePlayer(int row, int column) {
    if (_isWhiteByPosition(_createPosition(row, column)) &&
        _isWhitePlayerTurn()) {
      return true;
    }

    if (_isBlackByPosition(_createPosition(row, column)) &&
        _isBlackPlayerTurn()) {
      return true;
    }

    return false;
  }

  bool _isValidStartCellSelectedByPosition(Position startPosition) =>
      _isKingByPosition(startPosition)
          ? _isValidStartCellSelectedKing(startPosition)
          : _isValidStartCellSelectedPiece(startPosition);

  bool _isValidStartCellSelectedKing(Position startPosition) =>
      _isSamePlayerByPosition(startPosition) &&
      _isCanCellStartKing(startPosition);

  bool _isValidStartCellSelectedPiece(Position startPosition) =>
      _isSamePlayerByPosition(startPosition) &&
      _isCanCellStartPiece(startPosition);

  bool isValidStartCellSelected(int row, int column) =>
      _isValidStartCellSelectedByPosition(_createPosition(row, column));

  bool _isCanCellStartPiece(Position startPosition) =>
      _isCanCellStartCaptureMovePiece(startPosition, _getPieceDirections()) ||
      _isCanCellStartSimpleMovePiece(startPosition, _getPieceDirections());

  bool _isCanCellStartKing(Position startPosition) =>
      _isCanCellStartCaptureMoveKing(startPosition, _getKingDirections()) ||
      _isCanCellStartSimpleMoveKing(startPosition, _getKingDirections());

  bool _isCanCellStartCaptureMoveKing(
      Position startPosition, List<Position> directions) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
      if (_isCaptureMove(nextPosition, afterNextPosition)) return true;
    }

    return false;
  }

  bool _isCanCellStartSimpleMoveKing(
      Position startPosition, List<Position> directions) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      if (_isSimpleMove(startPosition, nextPosition)) return true;
    }

    return false;
  }

  bool _isCanCellStartCaptureMovePiece(
      Position startPosition, List<Position> directions) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
      if (_isCaptureMove(nextPosition, afterNextPosition)) return true;
    }

    return false;
  }

  bool _isCanCellStartSimpleMovePiece(
      Position startPosition, List<Position> directions) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      if (_isSimpleMove(startPosition, nextPosition)) return true;
    }

    return false;
  }

  bool _isNotSamePlayerByPosition(Position position) =>
      !_isSamePlayerByPosition(position);

  List<Path> getPossiblePaths(int row, int column) {
    Position startPosition = _createPosition(row, column);
    if (_isEmptyCellByPosition(startPosition)) return [];
    if (_isUnValidCellByPosition(startPosition)) return [];
    if (_isNotSamePlayerByPosition(startPosition)) return [];

    bool isKing = _isKingByPosition(startPosition);

    List<Path> paths = [];

    if (isKing) {
      _fetchAllPathsKing(paths, startPosition);
    } else {
      _fetchAllPathsPiece(paths, startPosition);
    }

    return paths;
  }

  void _fetchAllPathsKing(List<Path> paths, Position startPosition) {
    _fetchAllSimplePathsKing(paths, startPosition,
        [_getPositionDetailsNonCapture(startPosition)], _getKingDirections());
  }

  void _fetchAllSimplePathsKing(List<Path> paths, Position startPosition,
      List<PositionDetails> positionDetails, List<Position> directions) {
    for (Position positionDir in directions) {
      List<PositionDetails> positionDetailsTmp = [...positionDetails];

      Position positionDirFactor =
          _createPosition(positionDir.row, positionDir.column);
      _fetchSimplePathKing(paths, startPosition, positionDetailsTmp,
          positionDir, positionDirFactor);
    }
  }

  void _fetchSimplePathKing(
      List<Path> paths,
      Position startPosition,
      List<PositionDetails> positionDetails,
      Position positionDir,
      Position positionDirFactor) {
    Position nextPosition = _getNextPosition(startPosition, positionDirFactor);
    bool isEmptyCell = _isEmptyCellByPosition(nextPosition);
    if (!isEmptyCell) return;
    positionDetails.add(_getPositionDetailsNonCapture(nextPosition));
    Path path = Path(positionDetails);

    paths.add(path);

    Position nextPositionDirFactor = _createPosition(
        positionDirFactor.row + positionDir.row,
        positionDirFactor.column + positionDir.column);

    _fetchSimplePathKing(paths, startPosition, [...positionDetails],
        positionDir, nextPositionDirFactor);
  }

  void _fetchAllCapturePathsPiece(List<Path> paths, Position startPosition,
      List<PositionDetails> positionDetails, List<Position> directions) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
      List<PositionDetails> positionDetailsTmp = [...positionDetails];
      bool isNotCaptureMove = !_isCaptureMove(nextPosition, afterNextPosition);
      if (isNotCaptureMove) continue;

      positionDetailsTmp.add(_getPositionDetailsCapture(nextPosition));
      positionDetailsTmp.add(_getPositionDetailsNonCapture(afterNextPosition));

      _fetchAllCapturePathsPiece(
          paths, afterNextPosition, positionDetailsTmp, directions);
      bool isCanCellStartCaptureMovePiece =
          _isCanCellStartCaptureMovePiece(afterNextPosition, directions);
      if (isCanCellStartCaptureMovePiece) continue;
      paths.add(Path(positionDetailsTmp));
    }
  }

  void _fetchAllPathsPiece(List<Path> paths, Position startPosition) {
    _fetchAllCapturePathsPiece(paths, startPosition,
        [_getPositionDetailsNonCapture(startPosition)], _getPieceDirections());

    _fetchAllSimplePathsPiece(paths, startPosition,
        [_getPositionDetailsNonCapture(startPosition)], _getPieceDirections());

    _cleanDuplicateEndPath(paths);
  }

  void _cleanDuplicateEndPath(List<Path> paths) {
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

  void _fetchAllSimplePathsPiece(List<Path> paths, Position startPosition,
      List<PositionDetails> positionDetails, List<Position> directions) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);

      if (_isSimpleMove(startPosition, nextPosition)) {
        Path path = Path(
            [...positionDetails, _getPositionDetailsNonCapture(nextPosition)]);
        paths.add(path);
      }
    }
  }

  int _getRowDirection() => _player == CellType.BLACK ? 1 : -1;

  Position _getNextPosition(Position position, Position positionDir) =>
      _createPosition(
          position.row + positionDir.row, position.column + positionDir.column);

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

    Position nextPositionPlus =
        _getNextPosition(startPos, _createPosition(_getRowDirection(), 1));
    Position afterNextPositionPlus = _getNextPosition(
        nextPositionPlus, _createPosition(_getRowDirection(), 1));

    Position nextPositionMinus =
        _getNextPosition(startPos, _createPosition(_getRowDirection(), -1));
    Position afterNextPositionMinus = _getNextPosition(
        nextPositionMinus, _createPosition(_getRowDirection(), -1));

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

  PositionDetails _getPositionDetailsNonCapture(Position position) =>
      _createPositionDetails(position, _getCellTypeByPosition(position), false);

  PositionDetails _getPositionDetailsCapture(Position position) =>
      _createPositionDetails(position, _getCellTypeByPosition(position), true);

  PositionDetails _createPositionDetails(
          Position position, CellType cellType, bool isCapture) =>
      PositionDetails(position, _getCellTypeByPosition(position), isCapture);

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
      _isSamePlayerByPosition(currPosition) &&
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
    bool isBlackCellPlayer = _isBlackByPosition(startPosition);

    bool isKing = _isKingPiece(
        startPosition: startPosition,
        endPosition: endPosition,
        isBlackCellPlayer: isBlackCellPlayer);

    CellType cellType = _computePieceEndPath(isBlackCellPlayer, isKing);

    _setCell(cellType, endPosition);
  }

  bool _isKingPiece(
          {required Position startPosition,
          required Position endPosition,
          required bool isBlackCellPlayer}) =>
      _isKingByPosition(startPosition) ||
      _isKingRow(endPosition, isBlackCellPlayer ? _blackKingRow : _whiteKingRow);

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

  CellType _computePieceEndPath(bool isBlackByPosition, bool isKing) =>
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

  Path? getPathByEndPosition(int endRow, int endColumn, List<Path> paths) {
    for (Path path in paths) {
      Position pathEnd = path.positionDetails.last.position;
      if (pathEnd.row == endRow && pathEnd.column == endColumn) {
        return path;
      }
    }
    return null;
  }

  bool isValidDestinationCellSelected(
          int endRow, int endColumn, List<Path> paths) =>
      getPathByEndPosition(endRow, endColumn, paths) != null;
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
