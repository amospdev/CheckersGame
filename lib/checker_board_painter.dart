import 'package:flutter/material.dart';
import 'package:untitled/game/checkers_board.dart';
import 'package:untitled/game_view_model.dart';

class CheckerBoardPainter extends CustomPainter {
  final bool drawOptionalPaths;
  final int selectedRow;
  final int selectedCol;
  final List<List<CellType>> board;
  final List<Path> paths;
  final Paint paintPiece = Paint();
  final Paint paintKingPiece = Paint()..color = Colors.amber;
  final Paint paintHighlight = Paint()
    ..color = Colors.yellowAccent.withOpacity(0.7);

  CheckerBoardPainter(this.selectedRow, this.selectedCol, this.board,
      this.paths, this.drawOptionalPaths);

  @override
  void paint(Canvas canvas, Size size) {
    // drawing the board
    final cellWidth = size.width / 8;
    final cellHeight = size.height / 8;

    // drawing the cells, board game
    _drawCells(cellWidth: cellWidth, cellHeight: cellHeight, canvas: canvas);

    // Highlight the selected cell
    _drawHighlight(
        cellWidth: cellWidth, cellHeight: cellHeight, canvas: canvas);

    // drawing the pieces
    _drawPieces(cellWidth: cellWidth, cellHeight: cellHeight, canvas: canvas);
  }

  @override
  bool shouldRepaint(covariant CheckerBoardPainter oldDelegate) {
    return oldDelegate.selectedRow != selectedRow ||
        oldDelegate.selectedCol != selectedCol;
  }

  void _drawPieces(
      {required double cellWidth,
      required double cellHeight,
      required Canvas canvas}) {
    final pieceRadius = cellWidth * 0.35;
    final pieceKingRadius = cellWidth * 0.25;

    for (final (rowIndex, row) in board.indexed) {
      for (final (colIndex, col) in row.indexed) {
        if (col == CellType.UNVALID || col == CellType.EMPTY) {
          continue;
        }

        Offset offset =
            Offset((colIndex + 0.5) * cellWidth, (rowIndex + 0.5) * cellHeight);

        if (col == CellType.BLACK || col == CellType.BLACK_KING) {
          paintPiece.color = Colors.black;
        } else if (col == CellType.WHITE || col == CellType.WHITE_KING) {
          paintPiece.color = Colors.white;
        }

        canvas.drawCircle(
          offset,
          pieceRadius,
          paintPiece,
        );

        if (col == CellType.BLACK_KING || col == CellType.WHITE_KING) {
          canvas.drawCircle(
            offset,
            pieceKingRadius,
            paintKingPiece,
          );
        }
      }
    }
  }

  void _drawHighlight(
      {required double cellWidth,
      required double cellHeight,
      required Canvas canvas}) {
    if (selectedRow >= 0 && selectedCol >= 0) {
      canvas.drawRect(
        Rect.fromLTWH(
          selectedCol * cellWidth,
          selectedRow * cellHeight,
          cellWidth,
          cellHeight,
        ),
        paintHighlight,
      );
    }
  }

  void _drawCells(
      {required double cellWidth,
      required double cellHeight,
      required Canvas canvas}) {
    for (final (rowIndex, row) in board.indexed) {
      for (final (colIndex, col) in row.indexed) {
        Paint paint = Paint()
          ..color = col == CellType.UNVALID ? Colors.white : Colors.brown;

        if (drawOptionalPaths) {
          for (Path path in paths) {
            for (PositionDetails positionDetails in path.positionDetails) {
              if (positionDetails.position.row == rowIndex &&
                  positionDetails.position.column == colIndex) {
                paint.color = Colors.yellow;
              }
            }
          }
        }

        canvas.drawRect(
          Rect.fromLTWH(
            colIndex * cellWidth,
            rowIndex * cellHeight,
            cellWidth,
            cellHeight,
          ),
          paint,
        );
      }
    }
  }
}
