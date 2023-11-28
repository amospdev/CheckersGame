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
import 'package:untitled/game/checkers_board_features.dart';
import 'package:untitled/game/checkers_creator.dart';
import 'package:untitled/game/pawns_operation.dart';

// Define the colors as constants at the top of your file for better clarity
const startPositionColor = Colors.green;
const captureColor = Colors.redAccent;
const endPositionColor = Colors.blueAccent;

//TODO force capture
//TODO Check the GameOver function, after copying the board if the board remains unchanged
class CheckersBoard {
  static const int sizeBoard = 8;
  static const int _whiteKingRow = 0;
  static const int _blackKingRow = sizeBoard - 1;

  bool isMandatoryCapture = true;

  CheckersBoard();

  void init() {
    _initBoard();
    _initPawns();
    _initPlayer();
  }

  void _initBoard({List<List<CellDetails>>? board}) => board == null
      ? _board = BoardGameFactory.createBoard(RealBoard())
      : _board = board;

  void _initPawns() => _pawns = _pawnsOperation.create(_board);

  void _initPlayer() => _player = CellType.BLACK;

  // final CheckersPrinter _checkersPrinter = CheckersPrinter();
  final PawnsOperation _pawnsOperation = PawnsOperation();
  final CheckersBoardFeatures _checkersBoardFeatures = CheckersBoardFeatures();

  ValueNotifier<bool> get isHistoryEnable =>
      _checkersBoardFeatures.isHistoryEnable;

  SummarizerKilledPawns get summarizerKilledPawns =>
      _pawnsOperation.summarizerKilledPawns;

  List<List<CellDetails>> _board = [];

  List<List<CellDetails>> get board => _board;

  List<Pawn> _pawns = [];

  List<Pawn> get pawns => _pawns;

  CellType _player = CellType.UNDEFINED;

  CellType get player => _player;

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
      _player = _player == CellType.BLACK ? CellType.WHITE : CellType.BLACK;

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
      getLegalMoves(cellTypePlayer, board, isAIMode);

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
        fetchAllCapturePathsKingSimulate(paths, startPosition,
            [startPositionPath], directions, board, cellTypePlayer);
      } else {
        fetchAllCapturePathsPieceSimulate(paths, startPosition,
            [startPositionPath], directions, board, cellTypePlayer);
      }
    } else {
      _fetchAllCapturePathsByDirections(paths, startPosition,
          [startPositionPath], directions, board, cellTypePlayer);
    }

    if (hasCapturePaths(paths)) return paths;

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

  bool hasCapturePaths(List<PathPawn> paths) => paths.any(
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

  void resetBoard() {
    _checkersBoardFeatures.resetBoard(pawns, board);
    _initPlayer();
    _pawnsOperation.pawnsSummarize(board);
  }

  void popLastStep() {
    bool isSuccess = _checkersBoardFeatures.popLastStep(_pawns, _board);
    if (isSuccess) clearColorsCells();

    _switchPlayer();

    _pawnsOperation.pawnsSummarize(board);
  }

  void updateHistory(PathPawn pathPawn) =>
      _checkersBoardFeatures.updateHistory(pathPawn.copy());

  CheckersBoard performMove(
      List<List<CellDetails>> board, List<PathPawn> paths, PathPawn pathPawn,
      {required bool isAI}) {
    bool isKing = _isKingPiece(
        startCellDetails: pathPawn.startCell,
        endPosition: pathPawn.endPosition);

    // Update the end position based on the type of the piece and its final position on the board
    _updateEndPosition(board, pathPawn, isKing);

    // Remove captured pieces
    _removeCapturedPieces(pathPawn, board);

    // IMPORTANT: Update the starting position to empty
    _setCellToEmpty(pathPawn.startPosition, board);

    if (!isAI) _updatePawns(pathPawn, isKing);

    return this;
  }

  void _updateEndPosition(
      List<List<CellDetails>> board, PathPawn pathPawn, bool isKing) {
    CellType cellType =
        _computePieceEndPath(pathPawn.startCell.isBlack, isKing);

    _setCell(cellType, pathPawn.endPosition, board);
  }

  void _updatePawns(PathPawn pathPawn, bool isKing) {
    _updatePawn(isKing, pathPawn);

    _pawnsOperation.pawnKilled(pathPawn.capturePawn);

    // _pawnsOperation.
    pathPawn.capturePawn?.setPawnDataNotifier(isKilled: true);

    int killedLength = _pawns
        .where((element) =>
            element.cellTypePlayer == pathPawn.capturePawn?.cellTypePlayer)
        .where((element) => element.pawnDataNotifier.value.isKilled)
        .length;
    print(
        "killedLength: $killedLength, pathPawn.capturePawn?.cellTypePlayer: ${pathPawn.capturePawn?.cellTypePlayer}");
    pathPawn.capturePawn?.setPawnDataNotifier(indexKilled: killedLength - 1);

    /*forEach((element) {
      // if(element.pawnDataNotifier.value.isKilled){
      print("_pawns.forEach: ${element}");
      // }
    });
*/
  }

  void _updatePawn(bool isKing, PathPawn pathPawn) => pathPawn.pawnStartPath
      .setPosition(pathPawn.endPosition.row, pathPawn.endPosition.column)
      .setIsKing(isKing)
      .setPawnDataNotifier(isAnimating: false);

  //CHECKED
  bool _isKingPiece(
          {required CellDetails startCellDetails,
          required Position endPosition}) =>
      startCellDetails.isKing ||
      _isWillKing(endPosition, startCellDetails.isBlack);

  //CHECKED
  bool _isWillKing(Position endPosition, bool isBlack) =>
      endPosition.row == (isBlack ? _blackKingRow : _whiteKingRow);

  void _removeCapturedPieces(
          PathPawn pathPawn, List<List<CellDetails>> board) =>
      pathPawn.positionDetailsList
          .where((element) => element.isCapture)
          .map((positionDetails) => positionDetails.position)
          .forEach((position) => _setCellToEmpty(position, board));

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

  void nextTurn() {
    _clearPrevData();
    // printBoard(board);
    _switchPlayer();
  }

  void _clearPrevData() {}

  void fetchAllCapturePathsKingSimulate(
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

        fetchAllCapturePathsKingSimulate(paths, afterNextPosition,
            newPositionDetails, directions, board, cellTypePlayer,
            lastDirection: positionDir);
      }
    }

    if (!canCaptureFurther && positionDetailsList.length > 1) {
      paths.add(
          PathPawn(positionDetailsList, _getPawnWithoutKills(startPosition)));
    }
  }

  void fetchAllCapturePathsPieceSimulate(
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

    CheckersBoard copiedBoard = CheckersBoard();
    copiedBoard._initBoard(board: newBoard);

    copiedBoard._player = _player;

    return copiedBoard;
  }

  bool isGameOver(bool isAIMode) =>
      _pawnsOperation.pawnsSummarize(board).isGameOver ||
      getLegalMoves(CellType.WHITE, board, isAIMode).isEmpty ||
      getLegalMoves(CellType.BLACK, board, isAIMode).isEmpty;

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

  void setHistoryAvailability(bool isAvailability) {
    _checkersBoardFeatures.setHistoryAvailability(isAvailability);
  }
}
