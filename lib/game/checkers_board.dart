import 'package:flutter/foundation.dart';
import 'package:untitled/data/heuristic.dart';

class CheckersBoard {
  static const int _whiteKingRow = 0;
  static const int _blackKingRow = 7;
  final GameRulesType gameRulesType;

  CheckersBoard(
      this.gameRulesType, List<List<CellType>> board, CellType player) {
    _board = [];
    _board.clear();
    _board.addAll(board);
    _player = player;
    resetBoard();
    _printBoard();
  }

  List<List<CellType>> _board = [];
  CellType _player = CellType.BLACK;

  List<List<CellType>> get board => _board;

  CellType get player => _player;

  List<Path> getAllPossiblePathsForPlayer(CheckersBoard checkersBoard) {
    List<Path> allPaths = [];
    for (int row = 0; row < 8; row++) {
      for (int column = 0; column < 8; column++) {
        print("PLAYER:::: ${checkersBoard.player}");
        List<Path> paths = checkersBoard.getPossiblePaths(row, column, true);
        allPaths.addAll(paths);
      }
    }
    return allPaths;
  }

  int evaluate(bool max, CheckersBoard tmpCheckersBoard) {
    int humanKing = 0;
    int humanPiece = 0;
    int humanCapture = 0;
    int computerKing = 0;
    int computerPiece = 0;
    int computerCapture = 0;

    for (int row = 0; row < 8; row++) {
      for (int column = 0; column < 8; column++) {
        CellType currCellType = board[row][column];
        Position currPosition = _createPosition(row, column);

        List<Path> paths = [];

        if (currCellType == CellType.WHITE ||
            currCellType == CellType.WHITE_KING) {
          if (currCellType == CellType.WHITE_KING) {
            // Check for kings
            computerKing += 6;

            _fetchAllCapturePathsKingSimulate(
                paths,
                currPosition,
                [_getPositionDetailsNonCapture(currPosition)],
                _getKingDirections());

            int max = -1;
            for (Path path in paths) {
              int tmpMax = path.positionDetails.map((e) => e.isCapture).length;
              if (tmpMax > max) {
                max = tmpMax;
              }
            }

            computerCapture += (max * 3);
          } else {
            // Check for pawns
            computerPiece += 2;

            tmpCheckersBoard._fetchAllCapturePathsPieceSimulate(
                paths,
                currPosition,
                [_getPositionDetailsNonCapture(currPosition)],
                _getPieceDirections());
            int max = -1;
            for (Path path in paths) {
              for (PositionDetails positionDetails in path.positionDetails) {
                if (positionDetails.isCapture) {
                  print("*^&*&^*^&*  if(positionDetails.isCapture ");
                }
              }
              int tmpMax = path.positionDetails.map((e) => e.isCapture).length;
              if (tmpMax > max) {
                max = tmpMax;
              }
            }
            print("MAX IS humanData.setVulnerable: $max");
            // humanData.setVulnerable(computerData.getVulnerable() + max);
            computerCapture += (max * 3);
          }

          if (row == 0) {
            // Check for back rows
            // computerData.setBackRowPiece(computerData.getBackRowPiece() + 1);
            // computerData
            //     .setProtectedPiece(computerData.getProtectedPiece() + 1);
          } else {
            // if (row == 3 || row == 4) {
            //   // Check for middle rows
            //   if (column >= 2 && column <= 5) {
            //     computerData
            //         .setMiddleBoxPiece(computerData.getMiddleBoxPiece() + 1);
            //   } else {
            //     // Non-box
            //     computerData
            //         .setMiddleRowPiece(computerData.getMiddleRowPiece() + 1);
            //   }
            // }

            // Check if the piece can be taken
            // if (piece.isLeftVulnerable(this)) {
            //   computerData.setVulnerable(computerData.getVulnerable() + 1);
            // }
            // if (piece.isRightVulnerable(this)) {
            //   computerData.setVulnerable(computerData.getVulnerable() + 1);
            // }

            // Check for protected checkers
            // if (piece.isProtected(this)) {
            //   computerData
            //       .setProtectedPiece(computerData.getProtectedPiece() + 1);
            // }
          }
        } else if (currCellType == CellType.BLACK ||
            currCellType == CellType.BLACK_KING) {
          if (currCellType == CellType.BLACK_KING) {
            // Check for kings
            // humanData.setKing(humanData.getKing() + 1);
            humanKing += 6;

            _fetchAllCapturePathsKingSimulate(
                paths,
                currPosition,
                [_getPositionDetailsNonCapture(currPosition)],
                _getKingDirections());

            int max = -1;
            for (Path path in paths) {
              int tmpMax = path.positionDetails.map((e) => e.isCapture).length;
              if (tmpMax > max) {
                max = tmpMax;
              }
            }

            // computerData.setVulnerable(computerData.getVulnerable() + max);
            computerCapture += (max * 3);
          } else {
            // Check for pawns
            // humanData.setPawn(humanData.getPawn() + 1);
            humanPiece += 2;

            tmpCheckersBoard._fetchAllCapturePathsPieceSimulate(
                paths,
                currPosition,
                [_getPositionDetailsNonCapture(currPosition)],
                _getPieceDirections());
            int max = -1;
            for (Path path in paths) {
              for (PositionDetails positionDetails in path.positionDetails) {
                if (positionDetails.isCapture) {
                  print("*^&*&^*^&*  if(positionDetails.isCapture ");
                }
              }
              int tmpMax = path.positionDetails.map((e) => e.isCapture).length;
              if (tmpMax > max) {
                max = tmpMax;
              }
            }
            print("MAX IS computerData.setVulnerable: $max");
            // computerData.setVulnerable(computerData.getVulnerable() + max);
            computerCapture += (max * 3);
          }

          if (row == 7) {
            // Check for back rows
            // humanData.setBackRowPiece(humanData.getBackRowPiece() + 1);
            // humanData.setProtectedPiece(humanData.getProtectedPiece() + 1);
          } else {
            // if (row == 3 || row == 4) {
            //   Check for middle rows
            // if (column >= 2 && column <= 5) {
            //   humanData.setMiddleBoxPiece(humanData.getMiddleBoxPiece() + 1);
            // } else {
            //   Non-box
            // humanData.setMiddleRowPiece(humanData.getMiddleRowPiece() + 1);
            // }
            // }
            // Check if the piece can be taken
            // if (piece.isLeftVulnerable(this)) {
            //   humanData.setVulnerable(humanData.getVulnerable() + 1);
            // }
            // if (piece.isRightVulnerable(this)) {
            //   humanData.setVulnerable(humanData.getVulnerable() + 1);
            // }

            // Check for protected checkers
            // if (piece.isProtected(this)) {
            //   humanData.setProtectedPiece(humanData.getProtectedPiece() + 1);
            // }
          }
        }
      }
    }

    // int sum = computerData.subtract(humanData).getSum().toInt();
    // if (max) {
    //   return sum;
    // } else {
    //   return -sum;
    // }

    int results = (computerPiece + computerKing + computerCapture) -
        (humanPiece + humanKing + humanCapture);
    if (!max) results = -results;
    return results;
  }

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

  List<Position> _getKingDirections() => _getAllDirections();

  List<Position> _getAllDirections() => [
        _createPosition(1, 1),
        _createPosition(-1, -1),
        _createPosition(1, -1),
        _createPosition(-1, 1)
      ];

  void _switchPlayer() {
    _player = (_player == CellType.BLACK) ? CellType.WHITE : CellType.BLACK;
  }

  void _printBoard() {
    print("");
    print("********************");
    print("");
    for (int i = 0; i < 8; i++) {
      String row = "";
      for (int j = 0; j < 8; j++) {
        row += "${_board[i][j].index} ";
      }
      if (kDebugMode) {
        print(row);
      }
    }
    print("");
    print("********************");
    print("");
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

  bool _isVulnerable(int row, int column) {
    if (row == 0 || column == 0 || row == 7 || column == 7) {
      print("edge of the board");
      // It is at edge of the board, it cannot be taken.
      return false;
    }
    Position currPosition = _createPosition(row, column);
    if (_isSamePlayerByPosition(currPosition)) {
      for (Position positionDir in _getAllDirections()) {
        Position nextPosition = _getNextPosition(currPosition, positionDir);
        Position backPosition = _getNextPosition(currPosition,
            _createPosition(-positionDir.row, -positionDir.column));
        if(_isOpponentCell(nextPosition) && _isEmptyCellByPosition(backPosition)){
          if(_isKingByPosition(nextPosition)){
            print("_isVulnerable _isKingByPosition");
            return true;
          }

          if(_isWhiteByPosition(currPosition) ){
            if(_isOpponentCell(nextPosition) &&  nextPosition.row < currPosition.row){

            }
            print("_isVulnerable _isWhiteByPosition");
            return true;
          }

          if(_isBlackByPosition(currPosition) || nextPosition.row > currPosition.row){
            print("_isVulnerable _isBlackByPosition");
            return true;
          }
        }
      }
    }

    return false;
  }

  // bool isProtected(int row, int column) {
  //   if (row == 0 || column == 0 || row == 7 || column == 7) {
  //     // It is at edge of the board, it cannot be taken.
  //     return true;
  //   }
  //   Position currPosition = _createPosition(row, column);
  //
  //   if (_isSamePlayerByPosition(currPosition)) {
  //     bool leftProtected = containsBuddy(row - 1, col - 1, checkersBoard) &&
  //         !containsOpponentKing(row - 1, col - 1, checkersBoard);
  //     bool rightProtected = containsBuddy(row - 1, col + 1, checkersBoard) &&
  //         !containsOpponentKing(row - 1, col + 1, checkersBoard);
  //     return leftProtected && rightProtected;
  //   }
  //   bool leftProtected = containsBuddy(row + 1, col - 1, checkersBoard) &&
  //       !containsOpponentKing(row + 1, col - 1, checkersBoard);
  //   bool rightProtected = containsBuddy(row + 1, col + 1, checkersBoard) &&
  //       !containsOpponentKing(row + 1, col + 1, checkersBoard);
  //   return leftProtected && rightProtected;
  // }

  List<Path> getPossiblePaths(int row, int column, bool isAI) {
    bool isVulnerable = _isVulnerable(row, column);
    print("getPossiblePaths isVulnerable: $isVulnerable");

    Position startPosition = _createPosition(row, column);
    if (_isEmptyCellByPosition(startPosition)) return [];
    if (_isUnValidCellByPosition(startPosition)) return [];
    if (_isNotSamePlayerByPosition(startPosition)) return [];


    bool isKing = _isKingByPosition(startPosition);

    List<Path> paths = [];

    if (isKing) {
      _fetchAllPathsKing(paths, startPosition, isAI);
    } else {
      _fetchAllPathsPiece(paths, startPosition, isAI);
    }
    for (Path path in paths) {
      print("PATHS DETAILS:: ${path.positionDetails.map((e) => e.position)}");
    }
    print("PATHS TOTAL: ${paths.length}");
    return paths;
  }

  void _fetchAllPathsKing(List<Path> paths, Position startPosition, bool isAI) {
    if (isAI) {
      _fetchAllCapturePathsKingSimulate(paths, startPosition,
          [_getPositionDetailsNonCapture(startPosition)], _getKingDirections());
    } else {
      _fetchAllCapturePathsKing(paths, startPosition,
          [_getPositionDetailsNonCapture(startPosition)], _getKingDirections());
    }

    if (_hasCapturePaths(paths)) {
      return;
    }

    if (GameRulesType.KING_MULTIPLE == gameRulesType) {
      _fetchAllSimplePathsKingMultiple(paths, startPosition,
          [_getPositionDetailsNonCapture(startPosition)], _getKingDirections());
    } else if (GameRulesType.KING_SINGLE == gameRulesType) {
      _fetchAllSimplePathsKingSingle(paths, startPosition,
          [_getPositionDetailsNonCapture(startPosition)], _getKingDirections());
    }
  }

  void _fetchAllCapturePathsKingSimulate(
      List<Path> paths,
      Position startPosition,
      List<PositionDetails> positionDetails,
      List<Position> directions,
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

      if (_isCaptureMove(nextPosition, afterNextPosition)) {
        canCaptureFurther = true;

        List<PositionDetails> newPositionDetails = List.from(positionDetails);
        newPositionDetails.add(_getPositionDetailsCapture(nextPosition));
        newPositionDetails
            .add(_getPositionDetailsNonCapture(afterNextPosition));

        _fetchAllCapturePathsKingSimulate(
            paths, afterNextPosition, newPositionDetails, directions,
            lastDirection: positionDir);
      }
    }

    if (!canCaptureFurther) {
      paths.add(Path(positionDetails));
    }
  }

  void _fetchAllCapturePathsKing(List<Path> paths, Position startPosition,
          List<PositionDetails> positionDetails, List<Position> directions) =>
      _fetchAllCapturePathsPiece(paths, startPosition,
          [_getPositionDetailsNonCapture(startPosition)], directions);

  void _fetchAllSimplePathsKingMultiple(
      List<Path> paths,
      Position startPosition,
      List<PositionDetails> positionDetails,
      List<Position> directions) {
    for (Position positionDir in directions) {
      List<PositionDetails> positionDetailsTmp = [...positionDetails];
      Position nextPosition = _getNextPosition(startPosition, positionDir);

      if (!_isEmptyCellByPosition(nextPosition)) continue;

      positionDetailsTmp.add(_getPositionDetailsNonCapture(nextPosition));
      paths.add(Path(positionDetailsTmp));

      _fetchAllSimplePathsKingMultiple(
          paths, nextPosition, positionDetailsTmp, [positionDir]);
    }
  }

  void _fetchAllSimplePathsKingSingle(List<Path> paths, Position startPosition,
          List<PositionDetails> positionDetails, List<Position> directions) =>
      _fetchAllSimplePathsPiece(paths, startPosition,
          [_getPositionDetailsNonCapture(startPosition)], _getKingDirections());

  void _fetchAllCapturePathsPieceSimulate(
      List<Path> paths,
      Position startPosition,
      List<PositionDetails> positionDetails,
      List<Position> directions) {
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

      paths.add(Path(positionDetailsTmp));
    }
  }

  void _fetchAllPathsPiece(
      List<Path> paths, Position startPosition, bool isAI) {
    if (isAI) {
      _fetchAllCapturePathsPieceSimulate(
          paths,
          startPosition,
          [_getPositionDetailsNonCapture(startPosition)],
          _getPieceDirections());
    } else {
      _fetchAllCapturePathsPiece(
          paths,
          startPosition,
          [_getPositionDetailsNonCapture(startPosition)],
          _getPieceDirections());
    }

    if (_hasCapturePaths(paths)) {
      return;
    }

    _fetchAllSimplePathsPiece(paths, startPosition,
        [_getPositionDetailsNonCapture(startPosition)], _getPieceDirections());
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

    Position startPosition = _createPosition(row, col);
    print(
        "TYPE: ${_getCellTypeByPosition(startPosition)}, row, col: $row, $col");

    List<Position> directions = _isKingByPosition(startPosition)
        ? _getKingDirections()
        : _getPieceDirections();

    _fetchAllCapturePathsPiece(paths, startPosition,
        [_getPositionDetailsNonCapture(startPosition)], directions);

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
      positionDetails.any((element) => element.isCapture);

  bool _hasCapturePaths(List<Path> paths) => paths
      .any((element) => _hasCapturePositionDetails(element.positionDetails));

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

  CheckersBoard clone() {
    CheckersBoard clonedBoard = CheckersBoard(gameRulesType, [], player);
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        clonedBoard._board[i][j] = _board[i][j];
      }
    }

    clonedBoard._player = _player;

    return clonedBoard;
  }

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
      _isKingRow(
          endPosition, isBlackCellPlayer ? _blackKingRow : _whiteKingRow);

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

enum GameRulesType { KING_SINGLE, KING_MULTIPLE }

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
