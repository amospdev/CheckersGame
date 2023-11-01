import 'package:flutter/material.dart';
import 'package:untitled/data/ai/evaluator.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position_data.dart';
import 'package:untitled/data/position_details.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/extensions/cg_collections.dart';
import 'package:untitled/extensions/cg_log.dart';
import 'package:untitled/extensions/cg_optional.dart';

// Define the colors as constants at the top of your file for better clarity
const startPositionColor = Colors.green;
const captureColor = Colors.redAccent;
const endPositionColor = Colors.blueAccent;

class CheckersBoard {
  static const int sizeBoard = 8;
  static const int _whiteKingRow = 0;
  static const int _blackKingRow = sizeBoard - 1;

  bool isMandatoryCapture = true;

  CheckersBoard({List<List<CellDetails>>? board}) {
    if (board == null) {
      createBoard();
    } else {
      _board.addAll(board);
    }

    // printBoard(_board);
  }

  final Evaluator evaluator = Evaluator();

  List<List<CellDetails>> _board = [];

  List<List<CellDetails>> get board => _board;

  Iterable<CellDetails> get flatBoard => _getFlatBoard(_board);

  Iterable<CellDetails> _getFlatBoard(List<List<CellDetails>> board) =>
      board.expand((element) => element);

  final List<Pawn> _pawns = [];

  List<Pawn> get pawns => _pawns;

  List<Pawn> get pawnsWithoutKills => _pawns
      .where((element) => !element.pawnDataNotifier.value.isKilled)
      .toList();

  CellType _player = CellType.BLACK;

  CellType get player => _player;

  void createBoard() {
    _board = List.generate(sizeBoard,
        (i) => List<CellDetails>.filled(sizeBoard, CellDetails.createEmpty()));
    for (int i = 0; i < sizeBoard; i++) {
      for (int j = 0; j < sizeBoard; j++) {
        CellType tmpCellType = CellType.UNDEFINED;
        int id = (sizeBoard * i) + j;

        Color cellColor = (i + j) % 2 == 0 ? Colors.white : Colors.brown;
        if ((i + j) % 2 == 0) {
          tmpCellType = CellType.UNVALID;
        } else {
          if (i < (sizeBoard / 2) - 1) {
            tmpCellType = CellType.BLACK;
          } else if (i > (sizeBoard / 2)) {
            tmpCellType = CellType.WHITE;
          } else if (i == (sizeBoard / 2) - 1 || i == (sizeBoard / 2)) {
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

  List<Position> getPieceDirections({required CellType cellTypePlayer}) => [
        _createPosition(_getRowDirection(cellTypePlayer: cellTypePlayer), 1),
        _createPosition(_getRowDirection(cellTypePlayer: cellTypePlayer), -1),
      ];

  List<Position> getKingDirections() => [
        _createPosition(1, 1),
        _createPosition(-1, -1),
        _createPosition(1, -1),
        _createPosition(-1, 1)
      ];

  void _switchPlayer() =>
      _player = (_player == CellType.BLACK) ? CellType.WHITE : CellType.BLACK;

  void printBoard(List<List<CellDetails>> board) {
    String horizontalLine =
        "${"+---" * sizeBoard}+"; // creates +---+---+... for 8 times
    print("");
    print("**********************************");
    print("");

    for (int i = 0; i < sizeBoard; i++) {
      String row = "|"; // starts the row with |
      for (int j = 0; j < sizeBoard; j++) {
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

      print(horizontalLine);
      print(row);
    }

    print(horizontalLine); // closing line
    print("");
    print("");
    print("BLACKS: ${getBlacks(flatBoard)}");
    print("WHITES: ${getWithes(flatBoard)}");
    print("");

    print("**********************************");
    print("");
  }

  bool _isInBoundsByPosition(Position position) =>
      _isInBounds(position.row, position.column);

  bool _isInBounds(int row, int col) =>
      _isRowInBounds(row) && _isColumnInBounds(col);

  bool _isRowInBounds(int row) => row >= 0 && row < sizeBoard;

  bool _isColumnInBounds(int col) => col >= 0 && col < sizeBoard;

  bool isKingByPosition(Position position, List<List<CellDetails>> board) =>
      _isKing(position.row, position.column, board);

  bool _isKing(int row, int column, List<List<CellDetails>> board) =>
      _getCellType(row, column, board) == CellType.BLACK_KING ||
      _getCellType(row, column, board) == CellType.WHITE_KING;

  bool isEmptyCellByPosition(
          Position position, List<List<CellDetails>> board) =>
      _isEmptyCell(position.row, position.column, board);

  bool _isEmptyCell(int row, int col, List<List<CellDetails>> board) =>
      _getCellType(row, col, board) == CellType.EMPTY;

  bool isBlackByPosition(Position position, List<List<CellDetails>> board) =>
      _isBlack(position.row, position.column, board);

  bool _isBlack(int row, int column, List<List<CellDetails>> board) =>
      _getCellType(row, column, board) == CellType.BLACK ||
      _getCellType(row, column, board) == CellType.BLACK_KING;

  bool isWhiteByPosition(Position position, List<List<CellDetails>> board) =>
      _isWhite(position.row, position.column, board);

  bool _isWhite(int row, int column, List<List<CellDetails>> board) =>
      _getCellType(row, column, board) == CellType.WHITE ||
      _getCellType(row, column, board) == CellType.WHITE_KING;

  bool _isUnValidCellByPosition(
          Position position, List<List<CellDetails>> board) =>
      _isUnValidCell(position.row, position.column, board);

  bool _isUnValidCell(int row, int column, List<List<CellDetails>> board) =>
      _getCellType(row, column, board) == CellType.UNVALID;

  bool isOpponentCell(Position position, List<List<CellDetails>> board,
          CellType cellTypePlayer) =>
      (isWhiteByPosition(position, board) &&
          cellTypePlayer == CellType.BLACK) ||
      (isBlackByPosition(position, board) && cellTypePlayer == CellType.WHITE);

  CellType getCellTypePlayer(
          Position position, List<List<CellDetails>> board) =>
      isBlackByPosition(position, board) ? CellType.BLACK : CellType.WHITE;

  bool isOpponentCellAI(Position position, List<List<CellDetails>> board) =>
      getCellTypePlayer(position, board) != player;

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

  bool _isWhitePlayerTurn(CellType cellTypePlayer) =>
      cellTypePlayer == CellType.WHITE || cellTypePlayer == CellType.WHITE_KING;

  bool _isBlackPlayerTurn(CellType cellTypePlayer) =>
      cellTypePlayer == CellType.BLACK || cellTypePlayer == CellType.BLACK_KING;

  bool _isSamePlayerByPosition(Position position, List<List<CellDetails>> board,
          CellType cellTypePlayer) =>
      _isSamePlayer(position.row, position.column, board, cellTypePlayer);

  bool _isSamePlayer(int row, int column, List<List<CellDetails>> board,
      CellType cellTypePlayer) {
    Position position = _createPosition(row, column);
    return (isWhiteByPosition(position, board) &&
            _isWhitePlayerTurn(cellTypePlayer)) ||
        (isBlackByPosition(position, board) &&
            _isBlackPlayerTurn(cellTypePlayer));
  }

  bool isValidStartCellSelected(int row, int column,
          List<List<CellDetails>> board, CellType cellTypePlayer) =>
      getLegalMoves(cellTypePlayer, board)
          .where((pathPawn) =>
              pathPawn.positionDetailsList.first.position ==
              _createPosition(row, column))
          .isNotEmpty;

  bool isValidEndCellSelected(
          int endRow, int endColumn, List<PathPawn> paths) =>
      getPathByEndPosition(endRow, endColumn, paths)
          .condition((path) => path.isPresent && path.value.isValidPath());

  bool _isCanCellStartCaptureMovePiece(
      Position startPosition,
      List<Position> directions,
      List<List<CellDetails>> board,
      CellType cellTypePlayer) {
    return directions.any((positionDir) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
      return _isPointsCaptureMove(
          nextPosition, afterNextPosition, board, cellTypePlayer);
    });
  }

  bool _isNotSamePlayerByPosition(Position position,
          List<List<CellDetails>> board, CellType cellTypePlayer) =>
      !_isSamePlayerByPosition(position, board, cellTypePlayer);

  List<PathPawn> _getPossiblePathsByPosition(int row, int column,
      List<List<CellDetails>> board, CellType cellTypePlayer) {
    return getPossiblePathsByPosition(row, column, false, board, cellTypePlayer,
        isAIMode: true);
  }

  List<PathPawn> getPossiblePathsByPosition(
      int row,
      int column,
      bool isContinuePath,
      List<List<CellDetails>> board,
      CellType cellTypePlayer,
      {required bool isAIMode}) {
    _clearAllCellColors(board);

    Position startPosition = _createPosition(row, column);
    List<Position> directions =
        _getDirectionsByType(startPosition, board, cellTypePlayer);

    List<PathPawn> paths = isContinuePath
        ? _getPossibleContinuePaths(
            row, column, directions, board, cellTypePlayer)
        : _getPossiblePaths(row, column, board, isAIMode, cellTypePlayer);

    if (isAIMode) return paths;

    for (var path in paths) {
      Position position = path.positionDetailsList.last.position;
      paths[paths.indexOf(path)].isContinuePath = _isContinuePaths(
          position.row,
          position.column,
          path.positionDetailsList,
          directions,
          board,
          cellTypePlayer);
    }

    _paintCells(paths);
    return paths;
  }

  List<PathPawn> _getPossiblePaths(int row, int column,
      List<List<CellDetails>> board, bool isAIMode, CellType cellTypePlayer) {
    Position startPosition = _createPosition(row, column);

    // Combine conditions to exit early
    if (isEmptyCellByPosition(startPosition, board) ||
        _isUnValidCellByPosition(startPosition, board) ||
        _isNotSamePlayerByPosition(startPosition, board, cellTypePlayer)) {
      return [];
    }

    PositionDetails startPositionPath =
        _getPositionDetailsNonCapture(startPosition, board);
    bool isKing = isKingByPosition(startPosition, board);
    return isKing
        ? _fetchAllPathsByDirections([], startPosition, startPositionPath,
            getKingDirections(), board, isAIMode, isKing, cellTypePlayer)
        : _fetchAllPathsByDirections([],
            startPosition,
            startPositionPath,
            getPieceDirections(cellTypePlayer: cellTypePlayer),
            board,
            isAIMode,
            isKing,
            cellTypePlayer);
  }

  List<PathPawn> _fetchAllPathsByDirections(
      List<PathPawn> paths,
      Position startPosition,
      PositionDetails startPositionPath,
      List<Position> directions,
      List<List<CellDetails>> board,
      bool isAIMode,
      bool isKing,
      CellType cellTypePlayer) {
    if (isAIMode) {
      if (isKing) {
        _fetchAllCapturePathsKingSimulate(paths, startPosition,
            [startPositionPath], directions, board, cellTypePlayer);
      } else {
        _fetchAllCapturePathsPieceSimulate(paths, startPosition,
            [startPositionPath], directions, board, cellTypePlayer);
      }
    } else {
      _fetchAllCapturePathsByDirections(paths, startPosition,
          [startPositionPath], directions, board, cellTypePlayer);
    }

    if (_hasCapturePaths(paths)) return paths;

    _fetchAllSimplePathsByDirections(paths, startPosition, [startPositionPath],
        directions, board, cellTypePlayer);

    return paths;
  }

  void _fetchAllCapturePathsByDirections(
      List<PathPawn> paths,
      Position startPosition,
      List<PositionDetails> positionDetails,
      List<Position> directions,
      List<List<CellDetails>> board,
      CellType cellTypePlayer) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);

      if (_isPointsCaptureMove(
          nextPosition, afterNextPosition, board, cellTypePlayer)) {
        List<PositionDetails> positionDetailsList = List<PositionDetails>.from(
                positionDetails)
            .addItem(_getPositionDetailsCapture(nextPosition, board))
            .addItem(_getPositionDetailsNonCapture(afterNextPosition, board));
        paths.add(PathPawn(positionDetailsList));
      }
    }
  }

  void _fetchAllSimplePathsByDirections(
      List<PathPawn> paths,
      Position startPosition,
      List<PositionDetails> positionDetails,
      List<Position> directions,
      List<List<CellDetails>> board,
      CellType cellTypePlayer) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);

      if (_isSimpleMove(startPosition, nextPosition, board, cellTypePlayer)) {
        PathPawn path = PathPawn(List<PositionDetails>.from(positionDetails)
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

  void _paintCells(List<PathPawn> paths) {
    for (PathPawn path in paths) {
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

  int _getRowDirection({required CellType cellTypePlayer}) =>
      cellTypePlayer == CellType.BLACK ? 1 : -1;

  Position _getNextPosition(Position position, Position positionDir) =>
      _createPosition(
          position.row + positionDir.row, position.column + positionDir.column);

  Position _createPosition(int row, int column) => Position(row, column);

  bool _isContinuePaths(
          int row,
          int col,
          List<PositionDetails> positionDetails,
          List<Position> directions,
          List<List<CellDetails>> board,
          CellType cellTypePlayer) =>
      _hasCapturePositionDetails(positionDetails) &&
              _getPossibleContinuePaths(
                      row, col, directions, board, cellTypePlayer)
                  .isNotEmpty
          ? true
          : false;

  List<PathPawn> _getPossibleContinuePaths(int row, int col, directions,
      List<List<CellDetails>> board, CellType cellTypePlayer) {
    List<PathPawn> paths = [];

    Position startPosition = _createPosition(row, col);

    _fetchAllCapturePathsByDirections(
        paths,
        startPosition,
        [_getPositionDetailsNonCapture(startPosition, board)],
        directions,
        board,
        cellTypePlayer);

    return paths;
  }

  List<Position> _getDirectionsByType(Position startPosition,
          List<List<CellDetails>> board, CellType cellTypePlayer) =>
      isKingByPosition(startPosition, board)
          ? getKingDirections()
          : getPieceDirections(cellTypePlayer: cellTypePlayer);

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

  bool _hasCapturePaths(List<PathPawn> paths) => paths.any(
      (element) => _hasCapturePositionDetails(element.positionDetailsList));

  bool _isPointsCaptureMove(Position currPosition, Position nextPosition,
          List<List<CellDetails>> board, CellType cellTypePlayer) =>
      _isInBoundsByPosition(currPosition) &&
      _isInBoundsByPosition(nextPosition) &&
      isOpponentCell(currPosition, board, cellTypePlayer) &&
      isEmptyCellByPosition(nextPosition, board);

  bool _isSimpleMove(Position currPosition, Position nextPosition,
          List<List<CellDetails>> board, CellType cellTypePlayer) =>
      _isInBoundsByPosition(currPosition) &&
      _isInBoundsByPosition(nextPosition) &&
      _isSamePlayerByPosition(currPosition, board, cellTypePlayer) &&
      isEmptyCellByPosition(nextPosition, board);

  CheckersBoard performMoveAI(CheckersBoard tempBoard, PathPawn path) {
    Position startPosition = path.positionDetailsList.first.position;
    Position endPosition = path.positionDetailsList.last.position;
    tempBoard.performMove(startPosition.row, startPosition.column,
        endPosition.row, endPosition.column, [path], tempBoard.board);

    return tempBoard;
  }

  void performMove(int startRow, int startCol, int endRow, int endCol,
      List<PathPawn> paths, List<List<CellDetails>> board) {
    if (_isPathNotValid(paths)) return;
    Position startPosition = _createPosition(startRow, startCol);
    Position endPosition = _createPosition(endRow, endCol);
    Optional<PathPawn> path =
        _getRelevantPath(paths, startPosition, endPosition);
    if (path.isAbsent) {
      print("CB performMove PathPawn isAbsent");
      return;
    }

    _performMoveByPosition(
        startPosition, endPosition, path.value.positionDetailsList, board);
    _clearAllCellColors(board);
  }

  Optional<PathPawn> _getRelevantPath(
      List<PathPawn> paths, Position startPosition, Position endPosition) {
    Optional<PathPawn> path = paths.firstWhereOrAbsent((element) =>
        element.positionDetailsList.first.position == startPosition &&
        element.positionDetailsList.last.position == endPosition);

    if (path.isAbsent) {
      logDebug("CB _getRelevantPath path IS ABSENT");
      return const Optional.empty();
    }

    return path;
  }

  bool _isPathNotValid(List<PathPawn> paths) => paths.isEmpty;

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
    bool isBlackCellPlayer = isBlackByPosition(startPosition, board);

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
      isKingByPosition(startPosition, board) ||
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
    printBoard(board);
    _switchPlayer();
  }

  void _clearPrevData() {}

  Optional<PathPawn> getPathByEndPosition(
      int endRow, int endColumn, List<PathPawn> paths) {
    Optional<PathPawn> path = paths.firstWhereOrAbsent((element) =>
        element.positionDetailsList.last.position ==
        _createPosition(endRow, endColumn));

    if (path.isAbsent) {
      logDebug(
          "CB getPathByEndPosition pawn IS ABSENT endRow: $endRow, endColumn: $endColumn, paths: ${paths.length}, paths: $paths");

      return const Optional.empty();
    }

    return path;
  }

  void _fetchAllCapturePathsKingSimulate(
      List<PathPawn> paths,
      Position startPosition,
      List<PositionDetails> positionDetails,
      List<Position> directions,
      List<List<CellDetails>> board,
      CellType cellTypePlayer,
      {Position? lastDirection}) {
    bool canCaptureFurther = false;

    for (Position positionDir in directions) {
      if (lastDirection != null &&
          positionDir.row == -lastDirection.row &&
          positionDir.column == -lastDirection.column) {
        continue;
      }

      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);

      //Check if the position already exists
      if (positionDetails.any((details) => details.position == nextPosition)) {
        continue;
      }

      if (_isPointsCaptureMove(
          nextPosition, afterNextPosition, board, cellTypePlayer)) {
        canCaptureFurther = true;

        List<PositionDetails> newPositionDetails = List.from(positionDetails);
        newPositionDetails.add(_getPositionDetailsCapture(nextPosition, board));
        newPositionDetails
            .add(_getPositionDetailsNonCapture(afterNextPosition, board));

        _fetchAllCapturePathsKingSimulate(paths, afterNextPosition,
            newPositionDetails, directions, board, cellTypePlayer,
            lastDirection: positionDir);
      }
    }

    if (!canCaptureFurther) {
      paths.add(PathPawn(positionDetails));
    }
  }

  void _fetchAllCapturePathsPieceSimulate(
      List<PathPawn> paths,
      Position startPosition,
      List<PositionDetails> positionDetails,
      List<Position> directions,
      List<List<CellDetails>> board,
      CellType cellTypePlayer) {
    for (Position positionDir in directions) {
      Position nextPosition = _getNextPosition(startPosition, positionDir);
      Position afterNextPosition = _getNextPosition(nextPosition, positionDir);
      List<PositionDetails> positionDetailsTmp = [...positionDetails];
      bool isNotCaptureMove = !_isPointsCaptureMove(
          nextPosition, afterNextPosition, board, cellTypePlayer);
      if (isNotCaptureMove) continue;

      positionDetailsTmp.add(_getPositionDetailsCapture(nextPosition, board));
      positionDetailsTmp
          .add(_getPositionDetailsNonCapture(afterNextPosition, board));

      _fetchAllCapturePathsByDirections(paths, afterNextPosition,
          positionDetailsTmp, directions, board, cellTypePlayer);
      bool isCanCellStartCaptureMovePiece = _isCanCellStartCaptureMovePiece(
          afterNextPosition, directions, board, cellTypePlayer);
      if (isCanCellStartCaptureMovePiece) continue;
      paths.add(PathPawn(positionDetailsTmp));
    }
  }

  CheckersBoard copy() {
    List<List<CellDetails>> newBoard = List.generate(board.length,
        (i) => List.generate(board[i].length, (j) => board[i][j].copy()));

    CheckersBoard copiedBoard = CheckersBoard(board: newBoard);
    copiedBoard._board = newBoard;

    copiedBoard._player = _player;

    return copiedBoard;
  }

  bool isGameOver(List<List<CellDetails>> board) {
    if (getAllPieces(CellType.BLACK) == 0) {
      print("CB GM BLACK 0");
      return true;
    }
    if (getAllPieces(CellType.WHITE) == 0) {
      print("CB GM WHITE 0");

      return true;
    }
    if (getLegalMoves(CellType.WHITE, board).isEmpty) {
      print("CB GM getLegalMoves WHITE 0");

      return true;
    }
    if (getLegalMoves(CellType.BLACK, board).isEmpty) {
      print("CB GM getLegalMoves BLACK 0");

      return true;
    }

    return false;
  }

  int getAllPieces(CellType cellTypePlayer) {
    int piecesCounter = 0;
    for (List<CellDetails> cellTypeList in board) {
      for (CellDetails cellDetails in cellTypeList) {
        if (cellTypePlayer == cellDetails.getCellTypePlayer()) {
          piecesCounter++;
        }
      }
    }

    return piecesCounter;
  }

  List<PathPawn> getLegalMoves(
      CellType cellTypePlayer, List<List<CellDetails>> board) {
    List<PathPawn> paths = [];
    for (List<CellDetails> cellTypeList in board) {
      for (CellDetails cellDetails in cellTypeList) {
        if (_isSamePlayer(
            cellDetails.row, cellDetails.column, board, cellTypePlayer)) {
          List<PathPawn> currPaths = _getPossiblePathsByPosition(
              cellDetails.row, cellDetails.column, board, cellTypePlayer);
          paths.addAll(currPaths);
        }
      }
    }

    List<int> captureIndexes = [];
    for (final (index, pathPawn) in paths.indexed) {
      if (pathPawn.positionDetailsList.any((element) => element.isCapture)) {
        captureIndexes.add(index);
      }
    }

    List<PathPawn> resultPaths = [];

    if (captureIndexes.isNotEmpty) {
      for (int index in captureIndexes) {
        resultPaths.add(paths[index]);
      }
    } else {
      resultPaths.addAll(paths);
    }

    return isMandatoryCapture ? resultPaths : paths;
  }

  int getWithes(Iterable<CellDetails> flatBoard) {
    return flatBoard
        .where((element) =>
            isWhiteByPosition(Position(element.row, element.column), board))
        .length;
  }

  int getBlacks(Iterable<CellDetails> flatBoard) {
    return flatBoard
        .where((element) =>
            isBlackByPosition(Position(element.row, element.column), board))
        .length;
  }

  int evaluate(bool isMax) {
    return evaluator.evaluate(isMax, board, this);
  }
}
