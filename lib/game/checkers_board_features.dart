import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:untitled/data/cell/cell_details.dart';
import 'package:untitled/data/pawn/pawn_path.dart';
import 'package:untitled/data/pawn/pawn_details.dart';

class CheckersBoardFeatures {
  final Queue<PawnPath> _historyPathPawn = Queue<PawnPath>();

  final ValueNotifier<bool> _isHistoryEnable = ValueNotifier<bool>(false);

  ValueNotifier<bool> get isHistoryEnable => _isHistoryEnable;

  void resetBoard(List<PawnDetails> pawns, List<List<CellDetails>> board) {
    while (_historyPathPawn.isNotEmpty) {
      popLastStep(pawns, board);
    }
  }

  bool popLastStep(List<PawnDetails> pawns, List<List<CellDetails>> board) {
    if (_historyPathPawn.isEmpty) return false;

    PawnPath oldPathPawn = _historyPathPawn.removeLast();
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
    PawnDetails oldPawn = oldPathPawn.pawnStartPath;
    pawns[oldPawn.index].setValues(oldPawn);

    PawnDetails? oldCapturePawn = oldPathPawn.capturePawn;
    if (oldCapturePawn != null) {
      pawns[oldCapturePawn.index].setValues(oldCapturePawn);
    }

    return true;
  }

  void notifyHistoryPathPawn() =>
      setHistoryAvailability(_historyPathPawn.isNotEmpty);

  void setHistoryAvailability(bool isAvailability) =>
      _isHistoryEnable.value = isAvailability;

  void updateHistory(PawnPath pathPawn) {
    _historyPathPawn.add(pathPawn.copy());
    notifyHistoryPathPawn();
  }
}
