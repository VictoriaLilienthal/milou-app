import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:milou_app/data/comment.dart';

class Export {
  static void exportComments(List<Comment> comments) {
    {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      {
        var cell = sheetObject.cell(CellIndex.indexByString("A1"));
        cell.value = "Date"; // dynamic values support provided;

      }

      {
        var cell = sheetObject.cell(CellIndex.indexByString("B1"));
        cell.value = "Comment"; // dynamic values support provided;
      }
      {
        var cell = sheetObject.cell(CellIndex.indexByString("C1"));
        cell.value = "For Task (optional)"; // dynamic values support provided;
      }

      for (int i = 0; i < comments.length; i++) {
        var cell1 = sheetObject.cell(CellIndex.indexByString("A${i + 2}"));
        cell1.value = DateFormat.yMMMd()
            .format(DateTime.fromMillisecondsSinceEpoch(comments[i].time));
        var cell2 = sheetObject.cell(CellIndex.indexByString("B${i + 2}"));
        cell2.value = comments[i].comment;

        if (comments[i].skillName.isNotEmpty) {
          var cell3 = sheetObject.cell(CellIndex.indexByString("C${i + 2}"));
          cell3.value = comments[i].skillName;
        }
      }

      excel.save(fileName: "notes.xlsx");
    }
  }
}
