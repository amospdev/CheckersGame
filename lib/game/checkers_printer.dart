import 'package:untitled/data/cell/cell_details.dart';
import 'package:untitled/enum/cell_type.dart';
import 'package:untitled/extensions/cg_log.dart';

class CheckersPrinter{
  void printBoard(List<List<CellDetails>> board, int sizeBoard) {
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

}