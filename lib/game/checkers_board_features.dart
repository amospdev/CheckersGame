import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:untitled/data/cell_details.dart';
import 'package:untitled/data/path_pawn.dart';
import 'package:untitled/data/pawn.dart';

class CheckersBoardFeatures {
  final Queue<PathPawn> _historyPathPawn = Queue<PathPawn>();

  final ValueNotifier<bool> _isHistoryEnable = ValueNotifier<bool>(false);

  ValueNotifier<bool> get isHistoryEnable => _isHistoryEnable;

  void resetBoard(List<Pawn> pawns, List<List<CellDetails>> board) {
    while (_historyPathPawn.isNotEmpty) {
      popLastStep(pawns, board);
    }
  }

  bool popLastStep(List<Pawn> pawns, List<List<CellDetails>> board) {
    if (_historyPathPawn.isEmpty) return false;

    PathPawn oldPathPawn = _historyPathPawn.removeLast();
    notifyHistoryPathPawn();
    //Board
    board[oldPathPawn.startCell.row][oldPathPawn.startCell.column]
        .setValues(oldPathPawn.startCell);

    board[oldPathPawn.endCell.row][oldPathPawn.endCell.column]
        .setValues(oldPathPawn.endCell);

    CellDetails? oldCaptureCell = oldPathPawn.captureCell;
    if (oldCaptureCell != null) {
      board[oldCaptureCell.position.row][oldCaptureCell.position.column]
          .setValues(oldCaptureCell);
    }

    //Pawn
    Pawn oldPawn = oldPathPawn.pawnStartPath;
    pawns[oldPawn.index].setValues(oldPawn);

    Pawn? oldCapturePawn = oldPathPawn.capturePawn;
    if (oldCapturePawn != null) {
      pawns[oldCapturePawn.index].setValues(oldCapturePawn);
    }

    return true;
  }

  void notifyHistoryPathPawn() =>
      setHistoryAvailability(_historyPathPawn.isNotEmpty);

  void setHistoryAvailability(bool isAvailability) =>
      _isHistoryEnable.value = isAvailability;

  void updateHistory(PathPawn pathPawn) {
    _historyPathPawn.add(pathPawn.copy());
    notifyHistoryPathPawn();
  }
}
