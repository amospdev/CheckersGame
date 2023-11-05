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
    for (int row = 0; row < sizeBoard; row++) {
      for (int column = 0; column < sizeBoard; column++) {
        CellType tmpCellType = CellType.UNDEFINED;
        int id = (sizeBoard * row) + column;

        Color cellColor = (row + column) % 2 == 0 ? Colors.white : Colors.brown;
        if ((row + column) % 2 == 0) {
          tmpCellType = CellType.UNVALID;
        } else {
          if (row < (sizeBoard / 2) - 1) {
            tmpCellType = CellType.BLACK;
          } else if (row > (sizeBoard / 2)) {
            tmpCellType = CellType.WHITE;
          } else if (row == (sizeBoard / 2) - 1 || row == (sizeBoard / 2)) {
            tmpCellType = CellType.EMPTY;
          }
        }

        if (tmpCellType == CellType.WHITE || tmpCellType == CellType.BLACK) {
          _pawns.add(Pawn(
              id: id + 100,
              row: row,
              column: column,
              color: tmpCellType == CellType.WHITE ? Colors.white : Colors.grey,
              isKing: false));
        }

        _board[row][column] =
            CellDetails(tmpCellType, id, cellColor, row, column);
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
    logDebug("\n\n**********************************");

    String horizontalLine =
        "${"+---" * sizeBoard}+"; // creates +---+---+... for 8 times

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

      logDebug(horizontalLine);
      logDebug(row);
    }

    logDebug(horizontalLine); // closing line

    logDebug("**********************************\n\n");
  }

  bool isOpponentCell(int row, int column, List<List<CellDetails>> board,
          CellType cellTypePlayer) =>
      getCellDetails(row, column, board).isEmptyCell ||
              getCellDetails(row, column, board).isUnValid ||
              getCellDetails(row, column, board).cellType == CellType.UNDEFINED
          ? false
          : (getCellDetails(row, column, board).getCellTypePlayer() !=
              cellTypePlayer);

  CellDetails getCellDetails(
          int row, int column, List<List<CellDetails>> board) =>
      getCellDetailsByPosition(_createPosition(row, column), board);

  CellDetails getCellDetailsByPosition(
          Position position, List<List<CellDetails>> board) =>
      position.isInBounds
          ? board[position.row][position.column]
          : CellDetails.createEmpty();

  bool _isWhitePlayerTurn(CellType cellTypePlayer) =>
      cellTypePlayer == CellType.WHITE || cellTypePlayer == CellType.WHITE_KING;

  bool _isBlackPlayerTurn(CellType cellTypePlayer) =>
      cellTypePlayer == CellType.BLACK || cellTypePlayer == CellType.BLACK_KING;

  bool _isSamePlayer(List<List<CellDetails>> board, CellType cellTypePlayer,
          CellDetails cellDetails) =>
      (cellDetails.isWhite && _isWhitePlayerTurn(cellTypePlayer)) ||
      (cellDetails.isBlack && _isBlackPlayerTurn(cellTypePlayer));

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
      Position nextPosition = startPosition.nextPosition(positionDir);
      Position afterNextPosition = nextPosition.nextPosition(positionDir);
      return _isPointsCaptureMove(
          nextPosition, afterNextPosition, board, cellTypePlayer);
    });
  }

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

    CellDetails startCellDetails =
        getCellDetailsByPosition(_createPosition(row, column), board);
    List<Position> directions = _getDirectionsByType(
        startCellDetails.position, board, cellTypePlayer, startCellDetails);

    List<PathPawn> paths = isContinuePath
        ? _getPossibleContinuePaths(
            row, column, directions, board, cellTypePlayer)
        : _getPossiblePaths(
            row, column, board, isAIMode, cellTypePlayer, startCellDetails);

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

  List<PathPawn> _getPossiblePaths(
      int row,
      int column,
      List<List<CellDetails>> board,
      bool isAIMode,
      CellType cellTypePlayer,
      CellDetails startCellDetails) {
    Position startPosition = startCellDetails.position;

    // Combine conditions to exit early
    if (startCellDetails.isEmptyCell ||
        startCellDetails.isUnValid ||
        !_isSamePlayer(board, cellTypePlayer, startCellDetails)) {
      return [];
    }

    PositionDetails startPositionPath =
        _getPositionDetailsNonCapture(startPosition, board);
    return _fetchAllPathsByDirections(
        [],
        startPosition,
        startPositionPath,
        startCellDetails.isKing
            ? getKingDirections()
            : getPieceDirections(cellTypePlayer: cellTypePlayer),
        board,
        isAIMode,
        startCellDetails.isKing,
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
      Position nextPosition = startPosition.nextPosition(positionDir);
      Position afterNextPosition = nextPosition.nextPosition(positionDir);

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
      Position nextPosition = startPosition.nextPosition(positionDir);

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

  List<Position> _getDirectionsByType(
          Position startPosition,
          List<List<CellDetails>> board,
          CellType cellTypePlayer,
          CellDetails startCellDetails) =>
      startCellDetails.isKing
          ? getKingDirections()
          : getPieceDirections(cellTypePlayer: cellTypePlayer);

  PositionDetails _getPositionDetailsNonCapture(
          Position position, List<List<CellDetails>> board) =>
      _createPositionDetails(position, false, board);

  PositionDetails _getPositionDetailsCapture(
          Position position, List<List<CellDetails>> board) =>
      _createPositionDetails(position, true, board);

  PositionDetails _createPositionDetails(
          Position position, bool isCapture, List<List<CellDetails>> board) =>
      PositionDetails(isCapture, getCellDetailsByPosition(position, board));

  bool _hasCapturePositionDetails(List<PositionDetails> positionDetails) =>
      positionDetails.any((element) => element.isCapture);

  bool _hasCapturePaths(List<PathPawn> paths) => paths.any(
      (element) => _hasCapturePositionDetails(element.positionDetailsList));

  bool _isPointsCaptureMove(Position currPosition, Position nextPosition,
          List<List<CellDetails>> board, CellType cellTypePlayer) =>
      currPosition.isInBounds &&
      nextPosition.isInBounds &&
      isOpponentCell(
          currPosition.row, currPosition.column, board, cellTypePlayer) &&
      getCellDetailsByPosition(nextPosition, board).isEmptyCell;

  bool _isSimpleMove(Position currPosition, Position nextPosition,
          List<List<CellDetails>> board, CellType cellTypePlayer) =>
      currPosition.isInBounds &&
      nextPosition.isInBounds &&
      _isSamePlayer(board, cellTypePlayer,
          getCellDetailsByPosition(currPosition, board)) &&
      getCellDetailsByPosition(nextPosition, board).isEmptyCell;

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
    bool isBlackCellPlayer =
        getCellDetailsByPosition(startPosition, board).isBlack;

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
      getCellDetailsByPosition(startPosition, board).isKing ||
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
      board[position.row][position.column].setCellType(cellType: cellType);

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

      Position nextPosition = startPosition.nextPosition(positionDir);
      Position afterNextPosition = nextPosition.nextPosition(positionDir);

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
      Position nextPosition = startPosition.nextPosition(positionDir);
      Position afterNextPosition = nextPosition.nextPosition(positionDir);
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
    if (board
        .where((cellDetailsList) => cellDetailsList
            .where((element) =>
                element.cellType == CellType.BLACK ||
                element.cellType == CellType.BLACK_KING)
            .isNotEmpty)
        .isEmpty) {
      print("CB GM BLACK 0");
      return true;
    }
    if (board
        .where((cellDetailsList) => cellDetailsList
            .where((element) =>
                element.cellType == CellType.WHITE ||
                element.cellType == CellType.WHITE_KING)
            .isNotEmpty)
        .isEmpty) {
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

  List<PathPawn> getLegalMoves(
      CellType cellTypePlayer, List<List<CellDetails>> board) {
    List<PathPawn> paths = [];
    for (List<CellDetails> cellTypeList in board) {
      for (CellDetails cellDetails in cellTypeList) {
        if (_isSamePlayer(board, cellTypePlayer, cellDetails)) {
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
}
