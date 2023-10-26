import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position_data.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/extensions/cg_collections.dart';
import 'package:untitled/extensions/cg_log.dart';
import 'package:untitled/extensions/cg_optional.dart';

// Define the colors as constants at the top of your file for better clarity
const startPositionColor = Colors.green;
const captureColor = Colors.redAccent;
const endPositionColor = Colors.blueAccent;

class CheckersBoard {
  static const int _whiteKingRow = 0;
  static const int _blackKingRow = 7;
  static const int _sizeBoard = 8;

  CheckersBoard({List<List<CellDetails>>? board}) {
    if(board == null){
      createBoard();
    } else {
      _board.addAll(board);
    }

    _printBoard(_board);
  }

  List<List<CellDetails>> _board = [];

  List<List<CellDetails>> get board => _board;

  Iterable<CellDetails> get flatBoard => _getFlatBoard(_board);

  Iterable<CellDetails> _getFlatBoard(List<List<CellDetails>> board) =>
      _board.expand((element) => element);

  final List<Pawn> _pawns = [];

  List<Pawn> get pawns => _pawns;

  List<Pawn> get pawnsWithoutKills => _pawns
      .where((element) => !element.pawnDataNotifier.value.isKilled)
      .toList();

  CellType _player = CellType.BLACK;

  CellType get player => _player;

  void createBoard() {
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

  void _printBoard(List<List<CellDetails>> board) {
    String horizontalLine =
        "${"+---" * 8}+"; // creates +---+---+... for 8 times

    for (int i = 0; i < 8; i++) {
      String row = "|"; // starts the row with |
      for (int j = 0; j < 8; j++) {
        CellType cellType = board[i][j].cellType;
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
    }

    logDebug(horizontalLine); // closing line
  }

  bool _isInBoundsByPosition(Position position) =>
      _isInBounds(position.row, position.column);

  bool _isInBounds(int row, int col) =>
      _isRowInBounds(row) && _isColumnInBounds(col);

  bool _isRowInBounds(int row) => row >= 0 && row < 8;

  bool _isColumnInBounds(int col) => col >= 0 && col < 8;

  bool _isKingByPosition(Position position, List<List<CellDetails>> board) =>
      _isKing(position.row, position.column, board);

  bool _isKing(int row, int column, List<List<CellDetails>> board) =>
      _getCellType(row, column, board) == CellType.BLACK_KING ||
      _getCellType(row, column, board) == CellType.WHITE_KING;

  bool _isEmptyCellByPosition(
          Position position, List<List<CellDetails>> board) =>
      _isEmptyCell(position.row, position.column, board);

  bool _isEmptyCell(int row, int col, List<List<CellDetails>> board) =>
      _getCellType(row, col, board) == CellType.EMPTY;

  bool _isBlackByPosition(Position position, List<List<CellDetails>> board) =>
      _isBlack(position.row, position.column, board);

  bool _isBlack(int row, int column, List<List<CellDetails>> board) =>
      _getCellType(row, column, board) == CellType.BLACK ||
      _getCellType(row, column, board) == CellType.BLACK_KING;

  bool _isWhiteByPosition(Position position, List<List<CellDetails>> board) =>
      _isWhite(position.row, position.column, board);

  bool _isWhite(int row, int column, List<List<CellDetails>> board) =>
      _getCellType(row, column, board) == CellType.WHITE ||
      _getCellType(row, column, board) == CellType.WHITE_KING;

  bool _isUnValidCellByPosition(
          Position position, List<List<CellDetails>> board) =>
      _isUnValidCell(position.row, position.column, board);

  bool _isUnValidCell(int row, int column, List<List<CellDetails>> board) =>
      _getCellType(row, column, board) == CellType.UNVALID;

  bool _isOpponentCell(Position position, List<List<CellDetails>> board) =>
      (_isWhiteByPosition(position, board) && _player == CellType.BLACK) ||
      (_isBlackByPosition(position, board) && _player == CellType.WHITE);

  CellType _getCellTypeByPosition(
          Position position, List<List<CellDetails>> board) =>
      _getCellType(position.row, position.column, board);

  CellType _getCellType(int row, int col, List<List<CellDetails>> board) =>
      _isInBounds(row, col)
          ? _getCellDetails(row, col, board).cellType
          : CellType.UNDEFINED;

  CellDetails _getCellDetails(
          int row, int col, List<List<CellDetails>> board) =>
      board[row][col];

  CellDetails _getCellDetailsByPosition(
          Position position, List<List<CellDetails>> board) =>
      _getCellDetails(position.row, position.column, board);

  bool _isWhitePlayerTurn() =>
      _player == CellType.WHITE || _player == CellType.WHITE_KING;

  bool _isBlackPlayerTurn() =>
      _player == CellType.BLACK || _player == CellType.BLACK_KING;

  bool _isSamePlayerByPosition(
          Position position, List<List<CellDetails>> board) =>
      _isSamePlayer(position.row, position.column, board);

  bool _isSamePlayer(int row, int column, List<List<CellDetails>> board) {
    Position position = _createPosition(row, column);
    return (_isWhiteByPosition(position, board) && _isWhitePlayerTurn()) ||
        (_isBlackByPosition(position, board) && _isBlackPlayerTurn());
  }

  bool _isValidStartCellSelectedByPosition(
          Position startPosition, List<List<CellDetails>> board) =>
      _isKingByPosition(startPosition, board)
          ? _isValidStartCellSelectedKing(startPosition, board)
          : _isValidStartCellSelectedPiece(startPosition, board);

  bool _isValidStartCellSelectedKing(
          Position startPosition, List<List<CellDetails>> board) =>
      _isSamePlayerByPosition(startPosition, board) &&
      _isCanCellStartKing(startPosition, board);

  bool _isValidStartCellSelectedPiece(
          Position startPosition, List<List<CellDetails>> board) =>
      _isSamePlayerByPosition(startPosition, board) &&
      _isCanCellStartPiece(startPosition, board);

  bool isValidStartCellSelected(
          int row, int column, List<List<CellDetails>> board) =>
      _isValidStartCellSelectedByPosition(_createPosition(row, column), board);

  bool isValidEndCellSelected(int endRow, int endColumn, List<Path> paths) =>
      getPathByEndPosition(endRow, endColumn, paths)
          .condition((path) => path.isPresent && path.value.isValidPath());

  bool _isCanCellStartPiece(
          Position startPosition, List<List<CellDetails>> board) =>
      _isCanCellStartCaptureMovePiece(
          startPosition, _getPieceDirections(), board) ||
      _isCanCellStartSimpleMovePiece(
          startPosition, _getPieceDirections(), board);

  bool _isCanCellStartKing(
          Position startPosition, List<List<CellDetails>> board) =>
      _isCanCellStartCaptureMoveKing(
          startPosition, _getKingDirections(), board) ||
      _isCanCellStartSimpleMoveKing(startPosition, _getKingDirections(), board);

  bool _isCanCellStartCaptureMoveKing(Position startPosition,
          List<Position> directions, List<List<CellDetails>> board) =>
      directions.any((positionDir) =>
          _isPointCaptureMove(startPosition, positionDir, board));

  bool _isPointCaptureMove(Position startPosition, Position positionDir,
      List<List<CellDetails>> board) {
    Position nextPosition = _getNextPosition(startPosition, positionDir);
    Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
    return _isPointsCaptureMove(nextPosition, afterNextPosition, board);
  }

  bool _isCanCellStartSimpleMoveKing(Position startPosition,
          List<Position> directions, List<List<CellDetails>> board) =>
      directions.any((positionDir) => _isSimpleMove(
          startPosition, _getNextPosition(startPosition, positionDir), board));

  bool _isCanCellStartCaptureMovePiece(Position startPosition,
      List<Position> directions, List<List<CellDetails>> board) {
    return directions.any((positionDir) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
      return _isPointsCaptureMove(nextPosition, afterNextPosition, board);
    });
  }

  bool _isCanCellStartSimpleMovePiece(Position startPosition,
          List<Position> directions, List<List<CellDetails>> board) =>
      directions.any((positionDir) => _isSimpleMove(
          startPosition, _getNextPosition(startPosition, positionDir), board));

  bool _isNotSamePlayerByPosition(
          Position position, List<List<CellDetails>> board) =>
      !_isSamePlayerByPosition(position, board);

  List<Path> getPossiblePathsByPosition(
      int row, int column, bool isContinuePath, List<List<CellDetails>> board) {
    _clearAllCellColors(board);

    Position startPosition = _createPosition(row, column);
    List<Position> directions = _getDirectionsByType(startPosition, board);

    List<Path> paths = isContinuePath
        ? _getPossibleContinuePaths(row, column, directions, board)
        : _getPossiblePaths(row, column, board);

    for (var path in paths) {
      Position position = path.positionDetailsList.last.position;
      paths[paths.indexOf(path)].isContinuePath = _isContinuePaths(position.row,
          position.column, path.positionDetailsList, directions, board);
    }

    _paintCells(paths);
    return paths;
  }

  List<Path> _getPossiblePaths(
      int row, int column, List<List<CellDetails>> board) {
    Position startPosition = _createPosition(row, column);

    // Combine conditions to exit early
    if (_isEmptyCellByPosition(startPosition, board) ||
        _isUnValidCellByPosition(startPosition, board) ||
        _isNotSamePlayerByPosition(startPosition, board)) {
      return [];
    }

    PositionDetails startPositionPath =
        _getPositionDetailsNonCapture(startPosition, board);

    return _isKingByPosition(startPosition, board)
        ? _fetchAllPathsByDirections(
            [], startPosition, startPositionPath, _getKingDirections(), board)
        : _fetchAllPathsByDirections(
            [], startPosition, startPositionPath, _getPieceDirections(), board);
  }

  List<Path> _fetchAllPathsByDirections(
      List<Path> paths,
      Position startPosition,
      PositionDetails startPositionPath,
      List<Position> directions,
      List<List<CellDetails>> board) {
    _fetchAllCapturePathsByDirections(
        paths, startPosition, [startPositionPath], directions, board);

    if (_hasCapturePaths(paths)) return paths;

    _fetchAllSimplePathsByDirections(
        paths, startPosition, [startPositionPath], directions, board);

    return paths;
  }

  void _fetchAllCapturePathsByDirections(
      List<Path> paths,
      Position startPosition,
      List<PositionDetails> positionDetails,
      List<Position> directions,
      List<List<CellDetails>> board) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);

      if (_isPointsCaptureMove(nextPosition, afterNextPosition, board)) {
        List<PositionDetails> positionDetailsList = List<PositionDetails>.from(
                positionDetails)
            .addItem(_getPositionDetailsCapture(nextPosition, board))
            .addItem(_getPositionDetailsNonCapture(afterNextPosition, board));
        paths.add(Path(positionDetailsList));
      }
    }
  }

  void _fetchAllSimplePathsByDirections(
      List<Path> paths,
      Position startPosition,
      List<PositionDetails> positionDetails,
      List<Position> directions,
      List<List<CellDetails>> board) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);

      if (_isSimpleMove(startPosition, nextPosition, board)) {
        Path path = Path(List<PositionDetails>.from(positionDetails)
            .addItem(_getPositionDetailsNonCapture(nextPosition, board)));
        paths.add(path);
      }
    }
  }

  void _clearAllCellColors(List<List<CellDetails>> board) {
    for (var element in board) {
      for (var cell in element) {
        if (cell.tmpColor != cell.color) {
          cell.clearColor();
        }
      }
    }
  }

  void _paintCells(List<Path> paths) {
    for (Path path in paths) {
      for (final (index, positionDetails) in path.positionDetailsList.indexed) {
        // Determine the color using a switch-case
        Color color;
        switch (index) {
          case 0:
            color = startPositionColor;
            break;
          default:
            color = positionDetails.isCapture ? captureColor : endPositionColor;
            break;
        }

        Optional<CellDetails> cellDetails = flatBoard
            .toList(growable: false)
            .firstWhereOrAbsent(
                (element) => element.position == positionDetails.position);

        if (cellDetails.isAbsent) {
          logDebug("CB _paintCells cellDetails is ABSENT");
          continue;
        }

        cellDetails.value.changeColor(color);
      }
    }
  }

  int _getRowDirection() => _player == CellType.BLACK ? 1 : -1;

  Position _getNextPosition(Position position, Position positionDir) =>
      _createPosition(
          position.row + positionDir.row, position.column + positionDir.column);

  Position _createPosition(int row, int column) => Position(row, column);

  bool _isContinuePaths(int row, int col, List<PositionDetails> positionDetails,
          List<Position> directions, List<List<CellDetails>> board) =>
      _hasCapturePositionDetails(positionDetails) &&
              _getPossibleContinuePaths(row, col, directions, board).isNotEmpty
          ? true
          : false;

  List<Path> _getPossibleContinuePaths(
      int row, int col, directions, List<List<CellDetails>> board) {
    List<Path> paths = [];

    Position startPosition = _createPosition(row, col);

    _fetchAllCapturePathsByDirections(
        paths,
        startPosition,
        [_getPositionDetailsNonCapture(startPosition, board)],
        directions,
        board);

    return paths;
  }

  List<Position> _getDirectionsByType(
          Position startPosition, List<List<CellDetails>> board) =>
      _isKingByPosition(startPosition, board)
          ? _getKingDirections()
          : _getPieceDirections();

  PositionDetails _getPositionDetailsNonCapture(
          Position position, List<List<CellDetails>> board) =>
      _createPositionDetails(
          position, _getCellTypeByPosition(position, board), false, board);

  PositionDetails _getPositionDetailsCapture(
          Position position, List<List<CellDetails>> board) =>
      _createPositionDetails(
          position, _getCellTypeByPosition(position, board), true, board);

  PositionDetails _createPositionDetails(Position position, CellType cellType,
          bool isCapture, List<List<CellDetails>> board) =>
      PositionDetails(position, _getCellTypeByPosition(position, board),
          isCapture, _getCellDetailsByPosition(position, board));

  bool _hasCapturePositionDetails(List<PositionDetails> positionDetails) =>
      positionDetails.any((element) => element.isCapture);

  bool _hasCapturePaths(List<Path> paths) => paths.any(
      (element) => _hasCapturePositionDetails(element.positionDetailsList));

  bool _isPointsCaptureMove(Position currPosition, Position nextPosition,
          List<List<CellDetails>> board) =>
      _isInBoundsByPosition(currPosition) &&
      _isInBoundsByPosition(nextPosition) &&
      _isOpponentCell(currPosition, board) &&
      _isEmptyCellByPosition(nextPosition, board);

  bool _isSimpleMove(Position currPosition, Position nextPosition,
          List<List<CellDetails>> board) =>
      _isInBoundsByPosition(currPosition) &&
      _isInBoundsByPosition(nextPosition) &&
      _isSamePlayerByPosition(currPosition, board) &&
      _isEmptyCellByPosition(nextPosition, board);

  void performMove(int startRow, int startCol, int endRow, int endCol,
      List<Path> paths, List<List<CellDetails>> board) {
    if (_isPathNotValid(paths)) return;
    Position startPosition = _createPosition(startRow, startCol);
    Position endPosition = _createPosition(endRow, endCol);
    Optional<Path> path = _getRelevantPath(paths, startPosition, endPosition);
    if (path.isAbsent) return;

    _performMoveByPosition(
        startPosition, endPosition, path.value.positionDetailsList, board);
    _clearAllCellColors(board);
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
      List<PositionDetails> positionDetails, List<List<CellDetails>> board) {
    // Update the end position based on the type of the piece and its final position on the board
    _updateEndPosition(startPosition, endPosition, board);

    // Remove captured pieces
    _removeCapturedPieces(positionDetails, board);

    // IMPORTANT: Update the starting position to empty
    _clearStartPosition(startPosition, board);
  }

  void _updateEndPosition(Position startPosition, Position endPosition,
      List<List<CellDetails>> board) {
    bool isBlackCellPlayer = _isBlackByPosition(startPosition, board);

    bool isKing = _isKingPiece(board,
        startPosition: startPosition,
        endPosition: endPosition,
        isBlackCellPlayer: isBlackCellPlayer);

    CellType cellType = _computePieceEndPath(isBlackCellPlayer, isKing);

    _setCell(cellType, endPosition, board);

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

  bool _isKingPiece(List<List<CellDetails>> board,
          {required Position startPosition,
          required Position endPosition,
          required bool isBlackCellPlayer}) =>
      _isKingByPosition(startPosition, board) ||
      _isKingRow(
          endPosition, isBlackCellPlayer ? _blackKingRow : _whiteKingRow);

  bool _isKingRow(Position position, int kingRow) => position.row == kingRow;

  void _removeCapturedPieces(
      List<PositionDetails> positionDetails, List<List<CellDetails>> board) {
    for (PositionDetails positionDetails in positionDetails) {
      if (positionDetails.isCapture) {
        _clearCapturePiece(positionDetails.position, board);

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

  void _clearCapturePiece(
          Position piecePosition, List<List<CellDetails>> board) =>
      _setCellToEmpty(piecePosition, board);

  void _clearStartPosition(
          Position startPosition, List<List<CellDetails>> board) =>
      _setCellToEmpty(startPosition, board);

  void _setCellToEmpty(Position position, List<List<CellDetails>> board) =>
      _setCell(CellType.EMPTY, position, board);

  CellType _computePieceEndPath(bool isBlackByPosition, bool isKing) =>
      isBlackByPosition ? _getBlackPiece(isKing) : _getWhitePiece(isKing);

  CellType _getBlackPiece(bool isKing) =>
      isKing ? CellType.BLACK_KING : CellType.BLACK;

  CellType _getWhitePiece(bool isKing) =>
      isKing ? CellType.WHITE_KING : CellType.WHITE;

  void _setCell(CellType cellType, Position position,
          List<List<CellDetails>> board) =>
      board[position.row][position.column].setCellType(
          cellType: cellType,
          isEmpty: cellType == CellType.EMPTY || cellType == CellType.UNVALID);

  void nextTurn(List<List<CellDetails>> board) {
    _clearPrevData();
    _printBoard(board);
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
