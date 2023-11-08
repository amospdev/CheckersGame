import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/data/pawn.dart';
import 'package:untitled/data/position/position_data.dart';
import 'package:untitled/data/position/details/position_details.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/extensions/cg_collections.dart';
import 'package:untitled/extensions/cg_log.dart';

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

  List<List<CellDetails>> _board = [];

  final Queue<PathPawn> _historyPathPawn = Queue<PathPawn>();

  List<List<CellDetails>> get board => _board;

  final List<Pawn> _pawns = [];

  List<Pawn> get pawns => _pawns;

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
              cellTypePlayer: tmpCellType,
              index: _pawns.length,
              column: column,
              color: tmpCellType == CellType.WHITE ? Colors.white : Colors.grey,
              isKing: false));
        }

        _board[row][column] =
            CellDetails(tmpCellType, id, cellColor, row, column);
      }
    }
  }

  void createBoardTest() {
    _board = List.generate(sizeBoard,
        (i) => List<CellDetails>.filled(sizeBoard, CellDetails.createEmpty()));
    for (int row = 0; row < sizeBoard; row++) {
      for (int column = 0; column < sizeBoard; column++) {
        CellType tmpCellType = CellType.EMPTY;
        int id = (sizeBoard * row) + column;

        Color cellColor = (row + column) % 2 == 0 ? Colors.white : Colors.brown;
        if ((row + column) % 2 == 0) {
          tmpCellType = CellType.UNVALID;
        } else {
          if (row < (sizeBoard / 2) - 1) {
            if (column % 2 == 0) {
              tmpCellType = CellType.BLACK_KING;
            }
          } else if (row > (sizeBoard / 2)) {
            if (column % 2 != 0) {
              tmpCellType = CellType.WHITE_KING;
            }
          } else if (row == (sizeBoard / 2) - 1 || row == (sizeBoard / 2)) {
            tmpCellType = CellType.EMPTY;
          }
        }

        if (tmpCellType == CellType.WHITE ||
            tmpCellType == CellType.BLACK ||
            tmpCellType == CellType.WHITE_KING ||
            tmpCellType == CellType.BLACK_KING) {
          _pawns.add(Pawn(
              id: id + 100,
              row: row,
              column: column,
              cellTypePlayer: tmpCellType,
              index: _pawns.length,
              color: tmpCellType == CellType.WHITE_KING
                  ? Colors.white
                  : Colors.grey,
              isKing: true));
        }

        _board[row][column] =
            CellDetails(tmpCellType, id, cellColor, row, column);
      }
    }

    printBoard(board);
  }

  Pawn _getPawnWithoutKills(Position position) => _pawns
      .where((element) => !element.pawnDataNotifier.value.isKilled)
      .firstWhere((pawn) => pawn.position == position,
          orElse: () => Pawn.createEmpty());

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
      getCellDetails(row, column, board).isSomePawn
          ? (getCellDetails(row, column, board).cellTypePlayer !=
              cellTypePlayer)
          : false;

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

  List<PathPawn> getPathsByStartCellSelected(
          int row,
          int column,
          List<List<CellDetails>> board,
          CellType cellTypePlayer,
          bool isAIMode) =>
      getPossiblePathsByPosition(row, column, false, board, cellTypePlayer,
          isAIMode: isAIMode);

  PathPawn getPathByEndCellSelected(
          int endRow, int endColumn, List<PathPawn> paths) =>
      paths.firstWhere(
          (element) =>
              element.endPosition == _createPosition(endRow, endColumn),
          orElse: () => PathPawn.createEmpty());

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

  List<PathPawn> getPossiblePathsByPosition(
      int row,
      int column,
      bool isContinuePath,
      List<List<CellDetails>> board,
      CellType cellTypePlayer,
      {required bool isAIMode}) {
    clearColorsCells();

    CellDetails startCellDetails =
        getCellDetailsByPosition(_createPosition(row, column), board);
    List<Position> directions =
        _getDirectionsByType(cellTypePlayer, startCellDetails);

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

    print("2 TOTAL PATHS: ${paths.length}");
    print(
        "2 TOTAL PATHS SIZE: ${paths.length}, DETAILS: ${paths.map((e) => e.positionDetailsList.map((e) => e.position))}");

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

    if (startCellDetails.isEmptyCell ||
        startCellDetails.isUnValid ||
        !_isSamePlayer(board, cellTypePlayer, startCellDetails)) {
      return [];
    }

    return _fetchAllPathsByDirections(
        [],
        startPosition,
        PositionDetailsNonCapture(
            getCellDetailsByPosition(startPosition, board)),
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
        List<PositionDetails> positionDetailsList =
            List<PositionDetails>.from(positionDetails)
                .addItem(PositionDetailsCapture(
                    cellDetails: getCellDetailsByPosition(nextPosition, board),
                    pawnCapture: _getPawnWithoutKills(nextPosition)))
                .addItem(
                  PositionDetailsNonCapture(
                      getCellDetailsByPosition(afterNextPosition, board)),
                );
        paths.add(
            PathPawn(positionDetailsList, _getPawnWithoutKills(startPosition)));
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
        List<PositionDetails> positionDetailsList =
            List<PositionDetails>.from(positionDetails).addItem(
          PositionDetailsNonCapture(
              getCellDetailsByPosition(nextPosition, board)),
        );
        paths.add(
            PathPawn(positionDetailsList, _getPawnWithoutKills(startPosition)));
      }
    }
  }

  void clearColorsCells() {
    for (var elementList in _board) {
      for (var element in elementList) {
        element.clearColor();
      }
    }
  }

  void paintColorsCells(List<PathPawn> paths) {
    for (PathPawn path in paths) {
      for (final (index, positionDetails) in path.positionDetailsList.indexed) {
        CellDetails cellDetails = _board[positionDetails.position.row]
            [positionDetails.position.column];

        Color color = index == 0
            ? startPositionColor
            : positionDetails.isCapture
                ? captureColor
                : endPositionColor;

        cellDetails.changeColor(color);
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
        [
          PositionDetailsNonCapture(
              getCellDetailsByPosition(startPosition, board)),
        ],
        directions,
        board,
        cellTypePlayer);

    return paths;
  }

  List<Position> _getDirectionsByType(
          CellType cellTypePlayer, CellDetails startCellDetails) =>
      startCellDetails.isKing
          ? getKingDirections()
          : getPieceDirections(cellTypePlayer: cellTypePlayer);

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

  CheckersBoard performMoveAI(CheckersBoard tempBoard, PathPawn pathPawn) =>
      tempBoard..performMove(tempBoard.board, [pathPawn], pathPawn, isAI: true);

  final ValueNotifier<bool> _isHistoryEnable = ValueNotifier<bool>(false);

  ValueNotifier<bool> get isHistoryEnable => _isHistoryEnable;

  void notifyHistoryPathPawn() =>
      setHistoryAvailability(_historyPathPawn.isNotEmpty);

  void resetBoard() {
    while (_historyPathPawn.isNotEmpty) {
      popLastStep();
    }
    logDebug("CB resetBoard end");
    _player = CellType.BLACK;

    int black = board
        .expand((element) => element)
        .where((element) =>
            element.cellType == CellType.BLACK ||
            element.cellType == CellType.BLACK_KING)
        .length;

    int white = board
        .expand((element) => element)
        .where((element) =>
            element.cellType == CellType.WHITE ||
            element.cellType == CellType.WHITE_KING)
        .length;

    logDebug("CB resetBoard black: $black, white: $white");
  }

  void popLastStep() {
    if (_historyPathPawn.isEmpty) return;
    clearColorsCells();

    PathPawn oldPathPawn = _historyPathPawn.removeLast();
    notifyHistoryPathPawn();
    //Board
    _board[oldPathPawn.startCell.row][oldPathPawn.startCell.column]
        .setValues(oldPathPawn.startCell);

    _board[oldPathPawn.endCell.row][oldPathPawn.endCell.column]
        .setValues(oldPathPawn.endCell);

    CellDetails? oldCaptureCell = oldPathPawn.captureCell;
    if (oldCaptureCell != null) {
      _board[oldCaptureCell.position.row][oldCaptureCell.position.column]
          .setValues(oldCaptureCell);
    }

    //Pawn
    Pawn oldPawn = oldPathPawn.pawnStartPath;
    _pawns[oldPawn.index].setValues(oldPawn);

    Pawn? oldCapturePawn = oldPathPawn.capturePawn;
    if (oldCapturePawn != null) {
      _pawns[oldCapturePawn.index].setValues(oldCapturePawn);
    }

    _switchPlayer();

    int black = board
        .expand((element) => element)
        .where((element) =>
            element.cellType == CellType.BLACK ||
            element.cellType == CellType.BLACK_KING)
        .length;

    int white = board
        .expand((element) => element)
        .where((element) =>
            element.cellType == CellType.WHITE ||
            element.cellType == CellType.WHITE_KING)
        .length;

    logDebug("CB poop black: $black, white: $white");
  }

  void _updateHistory(PathPawn pathPawn) {
    _historyPathPawn.add(pathPawn.copy());
    notifyHistoryPathPawn();
  }

  void performMove(
      List<List<CellDetails>> board, List<PathPawn> paths, PathPawn pathPawn,
      {required bool isAI}) {
    if (!isAI) _updateHistory(pathPawn.copy());

    // Update the end position based on the type of the piece and its final position on the board
    _updateEndPosition(board, pathPawn, isAI);

    // Remove captured pieces
    _removeCapturedPieces(pathPawn, isAI, board);

    // IMPORTANT: Update the starting position to empty
    _setCellToEmpty(pathPawn.startPosition, board);

    clearColorsCells();
  }

  void _updateEndPosition(
      List<List<CellDetails>> board, PathPawn pathPawn, bool isAI) {
    bool isBlackCellPlayer = pathPawn.startCell.isBlack;

    bool isKing = _isKingPiece(board,
        startPosition: pathPawn.startPosition,
        endPosition: pathPawn.endPosition,
        isBlackCellPlayer: isBlackCellPlayer);

    CellType cellType = _computePieceEndPath(isBlackCellPlayer, isKing);

    _setCell(cellType, pathPawn.endPosition, board);

    if (isAI) return;
    _updatePawn(pathPawn.endPosition, isKing, pathPawn);
  }

  void _updatePawn(Position endPosition, bool isKing, PathPawn pathPawn) =>
      pathPawn.pawnStartPath
          .setPosition(endPosition.row, endPosition.column)
          .setIsKing(isKing)
          .setPawnDataNotifier(isAnimating: false);

  bool _isKingPiece(List<List<CellDetails>> board,
          {required Position startPosition,
          required Position endPosition,
          required bool isBlackCellPlayer}) =>
      getCellDetailsByPosition(startPosition, board).isKing ||
      _isKingRow(
          endPosition, isBlackCellPlayer ? _blackKingRow : _whiteKingRow);

  bool _isKingRow(Position position, int kingRow) => position.row == kingRow;

  void _removeCapturedPieces(
      PathPawn pathPawn, bool isAI, List<List<CellDetails>> board) {
    _setCellToEmpty(pathPawn.captureCell?.position, board);
    if (!isAI) {
      pathPawn.capturePawn?.setPawnDataNotifier(isKilled: true);
    }
  }

  void _setCellToEmpty(Position? position, List<List<CellDetails>> board) =>
      position != null
          ? _setCell(CellType.EMPTY, position, board)
          : logDebug('');

  CellType _computePieceEndPath(bool isBlackByPosition, bool isKing) =>
      isBlackByPosition
          ? isKing
              ? CellType.BLACK_KING
              : CellType.BLACK
          : isKing
              ? CellType.WHITE_KING
              : CellType.WHITE;

  void _setCell(CellType cellType, Position position,
          List<List<CellDetails>> board) =>
      board[position.row][position.column].setCellType(cellType: cellType);

  void nextTurn(List<List<CellDetails>> board) {
    _clearPrevData();
    // printBoard(board);
    _switchPlayer();
  }

  void _clearPrevData() {}

  void _fetchAllCapturePathsKingSimulate(
      List<PathPawn> paths,
      Position startPosition,
      List<PositionDetails> positionDetailsList,
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
      if (positionDetailsList
          .any((details) => details.position == nextPosition)) {
        continue;
      }

      if (_isPointsCaptureMove(
          nextPosition, afterNextPosition, board, cellTypePlayer)) {
        canCaptureFurther = true;

        List<PositionDetails> newPositionDetails =
            List.from(positionDetailsList);
        newPositionDetails
            .addItem(PositionDetailsCapture(
                cellDetails: getCellDetailsByPosition(nextPosition, board),
                pawnCapture: _getPawnWithoutKills(nextPosition)))
            .add(
              PositionDetailsNonCapture(
                  getCellDetailsByPosition(afterNextPosition, board)),
            );

        _fetchAllCapturePathsKingSimulate(paths, afterNextPosition,
            newPositionDetails, directions, board, cellTypePlayer,
            lastDirection: positionDir);
      }
    }

    if (!canCaptureFurther && positionDetailsList.length > 1) {
      paths.add(
          PathPawn(positionDetailsList, _getPawnWithoutKills(startPosition)));
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

      positionDetailsTmp.add(PositionDetailsCapture(
          cellDetails: getCellDetailsByPosition(nextPosition, board),
          pawnCapture: _getPawnWithoutKills(nextPosition)));
      positionDetailsTmp.add(
        PositionDetailsNonCapture(
            getCellDetailsByPosition(afterNextPosition, board)),
      );

      _fetchAllCapturePathsByDirections(paths, afterNextPosition,
          positionDetailsTmp, directions, board, cellTypePlayer);
      bool isCanCellStartCaptureMovePiece = _isCanCellStartCaptureMovePiece(
          afterNextPosition, directions, board, cellTypePlayer);
      if (isCanCellStartCaptureMovePiece) continue;
      if (positionDetailsTmp.length > 1) {
        paths.add(
            PathPawn(positionDetailsTmp, _getPawnWithoutKills(startPosition)));
      }
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

  bool isGameOver(List<List<CellDetails>> board, bool isAIMode) =>
      _isPawnsGameOver(CellType.BLACK, CellType.BLACK_KING) ||
      _isPawnsGameOver(CellType.WHITE, CellType.WHITE_KING) ||
      getLegalMoves(CellType.WHITE, board, isAIMode).isEmpty ||
      getLegalMoves(CellType.BLACK, board, isAIMode).isEmpty;

  bool _isPawnsGameOver(CellType cellType, CellType cellTypeKing) => board
      .where((cellDetailsList) => cellDetailsList
          .where((element) =>
              element.cellType == cellType || element.cellType == cellTypeKing)
          .isNotEmpty)
      .isEmpty;

  List<PathPawn> getLegalMoves(
      CellType cellTypePlayer, List<List<CellDetails>> board, bool isAIMode) {
    List<PathPawn> paths = [];
    for (List<CellDetails> cellTypeList in board) {
      for (CellDetails cellDetails in cellTypeList) {
        if (_isSamePlayer(board, cellTypePlayer, cellDetails)) {
          List<PathPawn> currPaths = getPossiblePathsByPosition(
              cellDetails.row, cellDetails.column, false, board, cellTypePlayer,
              isAIMode: isAIMode);
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

  void setHistoryAvailability(bool isAvailability) =>
      _isHistoryEnable.value = isAvailability;
}
