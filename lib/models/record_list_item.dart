import 'package:pocket_guard/helpers/records-utility-functions.dart';
import 'package:pocket_guard/models/record.dart';
import 'package:pocket_guard/models/records-per-day.dart';

abstract class ListItem {}

class DayHeaderItem extends ListItem {
  final RecordsPerDay dayInfo;
  DayHeaderItem(this.dayInfo);
}

class RecordRowItem extends ListItem {
  final Record record;
  final bool isLastInDay;
  RecordRowItem(this.record, {this.isLastInDay = false});
}


List<ListItem> flattenRecords(List<Record?> records) {
  final grouped = groupRecordsByDay(records);
  List<ListItem> flattened = [];

  for (var day in grouped) {
    flattened.add(DayHeaderItem(day));
    final dayRecords = day.records!.reversed.toList();
    for (int i = 0; i < dayRecords.length; i++) {
      final rec = dayRecords[i];
      if (rec != null) {
        bool isLast = (i == dayRecords.length - 1);
        flattened.add(RecordRowItem(rec, isLastInDay: isLast));
      }
    }
  }
  return flattened;
}
