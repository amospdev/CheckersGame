import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/enum/game_rules_type.dart';
import 'package:untitled/extensions/cg_collections.dart';
import 'package:untitled/extensions/cg_log.dart';
import 'package:untitled/extensions/cg_optional.dart';

class CheckersBoard {
  static const int _whiteKingRow = 0;
  static const int _blackKingRow = 7;
  static const int _sizeBoard = 8;
  final GameRulesType gameRulesType;

  CheckersBoard(this.gameRulesType) {
    resetBoard();
    _printBoard();
  }

  List<List<CellDetails>> _board = [];

  List<List<CellDetails>> get board => _board;

  List<CellDetails> get flatBoard =>
      _board.expand((element) => element).toList();

  final List<Pawn> _pawns = [];

  List<Pawn> get pawns => _pawns;

  List<Pawn> get pawnsWithoutKills => _pawns
      .where((element) => !element.pawnDataNotifier.value.isKilled)
      .toList();

  CellType _player = CellType.BLACK;

  CellType get player => _player;

  void resetBoard() {
    _board = List.generate(
        8, (i) => List<CellDetails>.filled(8, CellDetails.createEmpty()));
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        CellType tmpCellType = CellType.UNDEFINED;
        int id = (_sizeBoard * i) + j;

        Color cellColor = (i + j) % 2 == 0 ? Colors.white : Colors.brown;
        if ((i + j) % 2 == 0) {
          tmpCellType = CellType.UNVALID;
        } else {
          if (i < 3) {
            tmpCellType = CellType.BLACK;
          } else if (i > 4) {
            tmpCellType = CellType.WHITE;
          } else if (i == 3 || i == 4) {
            tmpCellType = CellType.EMPTY;
          }
        }

        if (tmpCellType == CellType.WHITE || tmpCellType == CellType.BLACK) {
          _pawns.add(Pawn(
              id: id + 100,
              row: i,
              column: j,
              color: tmpCellType == CellType.WHITE ? Colors.white : Colors.grey,
              isKing: false));
        }

        bool isEmpty =
            tmpCellType == CellType.EMPTY || tmpCellType == CellType.UNVALID;
        _board[i][j] = CellDetails(tmpCellType, id, isEmpty, cellColor, i, j);
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

  void _switchPlayer() =>
      _player = (_player == CellType.BLACK) ? CellType.WHITE : CellType.BLACK;

  void _printBoard() {
    String horizontalLine =
        "${"+---" * 8}+"; // creates +---+---+... for 8 times

    for (int i = 0; i < 8; i++) {
      String row = "|"; // starts the row with |
      for (int j = 0; j < 8; j++) {
        CellType cellType = _board[i][j].cellType;
        if (cellType == CellType.UNVALID) {
          row += " ⊠ |"; // adds the cell value and |
        } else if (cellType == CellType.EMPTY) {
          row += "   |"; // adds the cell value and |
        } else if (cellType == CellType.BLACK) {
          row += " ● |"; // adds the cell value and |
        } else if (cellType == CellType.WHITE) {
          row += " ○ |"; // adds the cell value and |
        } else if (cellType == CellType.BLACK_KING) {
          row += " 👑 |"; // adds the cell value and |
        } else if (cellType == CellType.WHITE_KING) {
          row += " ♔ |"; // adds the cell value and |
        } else {
          row += " ${cellType.index} |"; // adds the cell value and |
        }
      }

      logDebug(horizontalLine);
      logDebug(row);
      logDebug(horizontalLine);
    }

    logDebug(horizontalLine); // closing line
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

  bool _isOpponentCell(Position position) =>
      (_isWhiteByPosition(position) && _player == CellType.BLACK) ||
      (_isBlackByPosition(position) && _player == CellType.WHITE);

  CellType _getCellTypeByPosition(Position position) =>
      _getCellType(position.row, position.column);

  CellType _getCellType(int row, int col) => _isInBounds(row, col)
      ? _getCellDetails(row, col).cellType
      : CellType.UNDEFINED;

  CellDetails _getCellDetails(int row, int col) => _board[row][col];

  CellDetails _getCellDetailsByPosition(Position position) =>
      _getCellDetails(position.row, position.column);

  bool _isWhitePlayerTurn() =>
      _player == CellType.WHITE || _player == CellType.WHITE_KING;

  bool _isBlackPlayerTurn() =>
      _player == CellType.BLACK || _player == CellType.BLACK_KING;

  bool _isSamePlayerByPosition(Position position) =>
      _isSamePlayer(position.row, position.column);

  bool _isSamePlayer(int row, int column) {
    Position position = _createPosition(row, column);
    return (_isWhiteByPosition(position) && _isWhitePlayerTurn()) ||
        (_isBlackByPosition(position) && _isBlackPlayerTurn());
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

  bool isValidEndCellSelected(int endRow, int endColumn, List<Path> paths) =>
      getPathByEndPosition(endRow, endColumn, paths)
          .condition((path) => path.isPresent && path.value.isValidPath());

  bool _isCanCellStartPiece(Position startPosition) =>
      _isCanCellStartCaptureMovePiece(startPosition, _getPieceDirections()) ||
      _isCanCellStartSimpleMovePiece(startPosition, _getPieceDirections());

  bool _isCanCellStartKing(Position startPosition) =>
      _isCanCellStartCaptureMoveKing(startPosition, _getKingDirections()) ||
      _isCanCellStartSimpleMoveKing(startPosition, _getKingDirections());

  bool _isCanCellStartCaptureMoveKing(
          Position startPosition, List<Position> directions) =>
      directions.any(
          (positionDir) => _isPointCaptureMove(startPosition, positionDir));

  bool _isPointCaptureMove(Position startPosition, Position positionDir) {
    Position nextPosition = _getNextPosition(startPosition, positionDir);
    Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
    return _isPointsCaptureMove(nextPosition, afterNextPosition);
  }

  bool _isCanCellStartSimpleMoveKing(
          Position startPosition, List<Position> directions) =>
      directions.any((positionDir) => _isSimpleMove(
          startPosition, _getNextPosition(startPosition, positionDir)));

  bool _isCanCellStartCaptureMovePiece(
      Position startPosition, List<Position> directions) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
      if (_isPointsCaptureMove(nextPosition, afterNextPosition)) return true;
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

  List<Path> getPossiblePathsByPosition(
      int row, int column, bool isContinuePath) {
    _clearAllCellColors();

    List<Path> paths = [];
    Position startPosition = _createPosition(row, column);
    List<Position> directions = _getDirectionsByType(startPosition);
    if (isContinuePath) {
      paths.addAll(getPossibleContinuePaths(row, column, directions));
    } else {
      paths.addAll(getPossiblePaths(row, column));
    }

    for (Path path in paths) {
      Position position = path.positionDetailsList.last.position;
      bool isContinuePaths = false;

      isContinuePaths = _isContinuePaths(
          position.row, position.column, path.positionDetailsList, directions);

      // path.isContinuePath = isContinuePaths;
      paths[paths.indexOf(path)].isContinuePath = isContinuePaths;
    }

    _paintCells(paths);

    return paths;
  }

  List<Path> getPossiblePaths(int row, int column) {
    Position startPosition = _createPosition(row, column);
    if (_isEmptyCellByPosition(startPosition)) return [];
    if (_isUnValidCellByPosition(startPosition)) return [];
    if (_isNotSamePlayerByPosition(startPosition)) return [];

    bool isKing = _isKingByPosition(startPosition);

    List<Path> paths = [];
    PositionDetails startPositionPath =
        _getPositionDetailsNonCapture(startPosition);
    if (isKing) {
      _fetchAllPathsKing(
          paths, startPosition, startPositionPath, _getKingDirections());
    } else {
      _fetchAllPathsPiece(
          paths, startPosition, startPositionPath, _getPieceDirections());
    }

    return paths;
  }

  void _fetchAllPathsKing(List<Path> paths, Position startPosition,
      PositionDetails startPositionPath, List<Position> kingDirections) {
    _fetchAllCapturePathsKing(
        paths, startPosition, [startPositionPath], kingDirections);

    if (_hasCapturePaths(paths)) {
      return;
    }

    _fetchAllSimplePathsKingSingle(
        paths, startPosition, [startPositionPath], kingDirections);
  }

  void _fetchAllCapturePathsKing(List<Path> paths, Position startPosition,
          List<PositionDetails> positionDetails, List<Position> directions) =>
      _fetchAllCapturePathsPiece(
          paths, startPosition, [...positionDetails], directions);

  void _fetchAllSimplePathsKingSingle(List<Path> paths, Position startPosition,
          List<PositionDetails> positionDetails, List<Position> directions) =>
      _fetchAllSimplePathsPiece(
          paths, startPosition, [...positionDetails], directions);

  void _fetchAllCapturePathsPiece(List<Path> paths, Position startPosition,
      List<PositionDetails> positionDetails, List<Position> directions) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
      List<PositionDetails> positionDetailsTmp = [...positionDetails];
      bool isNotCaptureMove =
          !_isPointsCaptureMove(nextPosition, afterNextPosition);
      if (isNotCaptureMove) continue;

      positionDetailsTmp.add(_getPositionDetailsCapture(nextPosition));
      positionDetailsTmp.add(_getPositionDetailsNonCapture(afterNextPosition));

      paths.add(_createPath(positionDetailsTmp));
    }
  }

  void _clearAllCellColors() {
    for (var element in _board) {
      for (var cell in element) {
        if (cell.tmpColor != cell.color) {
          cell.clearColor();
        }
      }
    }
  }

  void _fetchAllPathsPiece(List<Path> paths, Position startPosition,
      PositionDetails startPositionPath, List<Position> pieceDirections) {
    _fetchAllCapturePathsPiece(
        paths, startPosition, [startPositionPath], pieceDirections);

    if (_hasCapturePaths(paths)) {
      return;
    }

    _fetchAllSimplePathsPiece(
        paths, startPosition, [startPositionPath], pieceDirections);
  }

  void _paintCells(List<Path> paths) {
    for (Path path in paths) {
      for (final (index, positionDetails) in path.positionDetailsList.indexed) {
        Color color;
        if (index == 0) {
          color = Colors.green;
        } else if (positionDetails.isCapture) {
          color = Colors.redAccent;
        } else {
          color = Colors.blueAccent;
        }
        Optional<CellDetails> cellDetails = flatBoard.firstWhereOrAbsent(
            (element) => element.position == positionDetails.position);

        if (cellDetails.isAbsent) {
          logDebug("CB _paintCells cellDetails is ABSENT");

          continue;
        }

        cellDetails.value.changeColor(color);
      }
    }
  }

  void _fetchAllSimplePathsPiece(List<Path> paths, Position startPosition,
      List<PositionDetails> positionDetails, List<Position> directions) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);

      if (_isSimpleMove(startPosition, nextPosition)) {
        Path path = _createPath(
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

  bool _isContinuePaths(int row, int col, List<PositionDetails> positionDetails,
          List<Position> directions) =>
      _hasCapturePositionDetails(positionDetails) &&
              getPossibleContinuePaths(row, col, directions).isNotEmpty
          ? true
          : false;

  List<Path> getPossibleContinuePaths(int row, int col, directions) {
    List<Path> paths = [];

    Position startPosition = _createPosition(row, col);

    _fetchAllCapturePathsPiece(paths, startPosition,
        [_getPositionDetailsNonCapture(startPosition)], directions);

    return paths;
  }

  List<Position> _getDirectionsByType(Position startPosition) =>
      _isKingByPosition(startPosition)
          ? _getKingDirections()
          : _getPieceDirections();

  PositionDetails _getPositionDetailsNonCapture(Position position) =>
      _createPositionDetails(position, _getCellTypeByPosition(position), false);

  PositionDetails _getPositionDetailsCapture(Position position) =>
      _createPositionDetails(position, _getCellTypeByPosition(position), true);

  PositionDetails _createPositionDetails(
          Position position, CellType cellType, bool isCapture) =>
      PositionDetails(position, _getCellTypeByPosition(position), isCapture,
          _getCellDetailsByPosition(position));

  bool _hasCapturePositionDetails(List<PositionDetails> positionDetails) =>
      positionDetails.any((element) => element.isCapture);

  bool _hasCapturePaths(List<Path> paths) => paths.any(
      (element) => _hasCapturePositionDetails(element.positionDetailsList));

  bool _isPointsCaptureMove(Position currPosition, Position nextPosition) =>
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
      int startRow, int startCol, int endRow, int endCol, List<Path> paths) {
    if (_isPathNotValid(paths)) return;
    Position startPosition = _createPosition(startRow, startCol);
    Position endPosition = _createPosition(endRow, endCol);
    Optional<Path> path = _getRelevantPath(paths, startPosition, endPosition);
    if (path.isAbsent) return;

    _performMoveByPosition(
        startPosition, endPosition, path.value.positionDetailsList);
    _clearAllCellColors();
  }

  Optional<Path> _getRelevantPath(
      List<Path> paths, Position startPosition, Position endPosition) {
    Optional<Path> path = paths.firstWhereOrAbsent((element) =>
        element.positionDetailsList.first.position == startPosition &&
        element.positionDetailsList.last.position == endPosition);

    if (path.isAbsent) {
      logDebug("CB _getRelevantPath path IS ABSENT");
      return const Optional.empty();
    }

    return path;
  }

  bool _isPathNotValid(List<Path> paths) => paths.isEmpty;

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

    _updatePawn(startPosition, endPosition, isKing);
  }

  void _updatePawn(Position startPosition, Position endPosition, bool isKing) {
    Optional<Pawn> pawn = pawnsWithoutKills.firstWhereOrAbsent((pawn) =>
        pawn.row == startPosition.row && pawn.column == startPosition.column);

    if (pawn.isAbsent) {
      logDebug("CB _updatePawn pawn IS ABSENT");
      return;
    }

    pawn.value
        .setPosition(endPosition.row, endPosition.column)
        .setIsKing(isKing)
        .setPawnDataNotifier(
            offset: Offset(
                endPosition.column.toDouble(), endPosition.row.toDouble()),
            isAnimating: false);
  }

  bool _isKingPiece(
          {required Position startPosition,
          required Position endPosition,
          required bool isBlackCellPlayer}) =>
      _isKingByPosition(startPosition) ||
      _isKingRow(
          endPosition, isBlackCellPlayer ? _blackKingRow : _whiteKingRow);

  bool _isKingRow(Position position, int kingRow) => position.row == kingRow;

  void _removeCapturedPieces(List<PositionDetails> positionDetails) {
    for (PositionDetails positionDetails in positionDetails) {
      if (positionDetails.isCapture) {
        _clearCapturePiece(positionDetails.position);

        Optional<Pawn> pawn = pawnsWithoutKills.firstWhereOrAbsent((pawn) =>
            pawn.row == positionDetails.position.row &&
            pawn.column == positionDetails.position.column);
        if (pawn.isAbsent) {
          logDebug("CB _removeCapturedPieces pawn IS ABSENT");

          continue;
        }
        pawn.value.setPawnDataNotifier(isKilled: true);
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
      _board[position.row][position.column].setCellType(
          cellType: cellType,
          isEmpty: cellType == CellType.EMPTY || cellType == CellType.UNVALID);

  void nextTurn() {
    _clearPrevData();
    _printBoard();
    _switchPlayer();
  }

  void _clearPrevData() {}

  Optional<Path> getPathByEndPosition(
      int endRow, int endColumn, List<Path> paths) {
    Optional<Path> path = paths.firstWhereOrAbsent((element) =>
        element.positionDetailsList.last.position ==
        _createPosition(endRow, endColumn));

    if (path.isAbsent) {
      logDebug(
          "CB getPathByEndPosition pawn IS ABSENT endRow: $endRow, endColumn: $endColumn, paths: ${paths.length}, paths: $paths");

      return const Optional.empty();
    }

    return path;
  }

  Path _createPath(List<PositionDetails> positionDetailsList) =>
      Path(positionDetailsList);
}

class PositionDetails {
  final Position position;
  final CellType cellType;
  final bool isCapture;
  final CellDetails cellDetails;

  PositionDetails(
      this.position, this.cellType, this.isCapture, this.cellDetails);

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
  final List<PositionDetails> positionDetailsList;

  bool isContinuePath = false;

  Path(this.positionDetailsList);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Path &&
          runtimeType == other.runtimeType &&
          positionDetailsList == other.positionDetailsList;

  @override
  int get hashCode => positionDetailsList.hashCode;

  @override
  String toString() {
    return 'Path{positionDetails: $positionDetailsList}';
  }

  static Path createEmpty() => Path([]);

  bool isValidPath() => positionDetailsList.isNotEmpty;
}

// void _fetchAllCapturePathsKingSimulate(
//     List<Path> paths,
//     Position startPosition,
//     List<PositionDetails> positionDetails,
//     List<Position> directions,
//     {Position? lastDirection}) {
//   bool canCaptureFurther = false;
//
//   for (Position positionDir in directions) {
//     if (lastDirection != null &&
//         positionDir.row == -lastDirection.row &&
//         positionDir.column == -lastDirection.column) {
//       continue;
//     }
//
//     Position nextPosition = _getNextPosition(startPosition, positionDir);
//     Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
//
//     //Check if the position already exists
//     if (positionDetails.any((details) => details.position == nextPosition)) {
//       continue;
//     }
//
//     if (_isCaptureMove(nextPosition, afterNextPosition)) {
//       canCaptureFurther = true;
//
//       List<PositionDetails> newPositionDetails = List.from(positionDetails);
//       newPositionDetails.add(_getPositionDetailsCapture(nextPosition));
//       newPositionDetails
//           .add(_getPositionDetailsNonCapture(afterNextPosition));
//
//       _fetchAllCapturePathsKingSimulate(
//           paths, afterNextPosition, newPositionDetails, directions,
//           lastDirection: positionDir);
//     }
//   }
//
//   if (!canCaptureFurther) {
//     paths.add(Path(positionDetails));
//   }
// }

// void _fetchAllCapturePathsPieceSimulate(
//     List<Path> paths,
//     Position startPosition,
//     List<PositionDetails> positionDetails,
//     List<Position> directions) {
//   for (Position positionDir in directions) {
//     Position nextPosition = _getNextPosition(startPosition, positionDir);
//     Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
//     List<PositionDetails> positionDetailsTmp = [...positionDetails];
//     bool isNotCaptureMove = !_isCaptureMove(nextPosition, afterNextPosition);
//     if (isNotCaptureMove) continue;
//
//     positionDetailsTmp.add(_getPositionDetailsCapture(nextPosition));
//     positionDetailsTmp.add(_getPositionDetailsNonCapture(afterNextPosition));
//
//     _fetchAllCapturePathsPiece(
//         paths, afterNextPosition, positionDetailsTmp, directions);
//     bool isCanCellStartCaptureMovePiece =
//     _isCanCellStartCaptureMovePiece(afterNextPosition, directions);
//     if (isCanCellStartCaptureMovePiece) continue;
//     paths.add(Path(positionDetailsTmp));
//   }
// }
