import 'package:flutter/material.dart';
import 'package:pocket_guard/components/category_icon_circle.dart';
import 'package:pocket_guard/helpers/datetime-utility-functions.dart';
import 'package:pocket_guard/helpers/records-utility-functions.dart';
import 'package:pocket_guard/models/record.dart';
import 'package:pocket_guard/models/record_list_item.dart';
import 'package:pocket_guard/models/records-per-day.dart';
import 'package:pocket_guard/records/edit-record-page.dart';
import 'package:pocket_guard/services/service-config.dart';
import 'package:pocket_guard/settings/constants/preferences-keys.dart';
import 'package:pocket_guard/settings/preferences-utils.dart';

class RecordsDayList extends StatelessWidget {
  /// MovementsPage is the page showing the list of movements grouped per day.
  /// It contains also buttons for filtering the list of movements and add a new movement.
  final _titleFontStyle = const TextStyle(fontSize: 18.0);
  final _currencyFontStyle = const TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.normal,
  );
  final List<Record?> records;
  final Function? onListBackCallback;

  RecordsDayList(this.records, {this.onListBackCallback});

  @override
  Widget build(BuildContext context) {
    final items = flattenRecords(records);
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        final item = items[index];
        if (item is DayHeaderItem) {
          return _buildDayHeader(context, item.dayInfo);
        } else if (item is RecordRowItem) {
          return Column(
            children: [
              _buildMovementRow(context, item.record),
              if (!item.isLastInDay)
                const Divider(thickness: 0.5, indent: 15, endIndent: 15),
            ],
          );
        }
      }, childCount: items.length),
    );
  }

  Widget _buildDayHeader(BuildContext context, RecordsPerDay dayInfo) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Day Number
                    Text(
                      dayInfo.dateTime!.day.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weekday
                          Text(
                            extractWeekdayString(dayInfo.dateTime!),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          // Month and Year
                          Text(
                            '${extractMonthString(dayInfo.dateTime!)} ${extractYearString(dayInfo.dateTime!)}',
                            style: const TextStyle(fontSize: 13),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Daily Balance
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 22, 0),
                  child: Text(
                    getCurrencyValueString(dayInfo.balance),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildMovementRow(BuildContext context, Record movement) {
    /// Returns a ListTile rendering the single movement row
    int numberOfNoteLinesToShow = PreferencesUtils.getOrDefault<int>(
      ServiceConfig.sharedPreferences!,
      PreferencesKeys.homepageRecordNotesVisible,
    )!;

    bool visualiseTags = PreferencesUtils.getOrDefault<bool>(
      ServiceConfig.sharedPreferences!,
      PreferencesKeys.visualiseTagsInMainPage,
    )!;

    return ListTile(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditRecordPage(passedRecord: movement),
          ),
        );
        if (onListBackCallback != null) await onListBackCallback!();
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movement.title == null || movement.title!.trim().isEmpty
                ? movement.category!.name!
                : movement.title!,
            style: _titleFontStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (numberOfNoteLinesToShow > 0 &&
              movement.description != null &&
              movement.description!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                movement.description!,
                style: TextStyle(
                  fontSize: 15.0, // Slightly smaller than title
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color, // Lighter color
                ),
                softWrap: true,
                maxLines: numberOfNoteLinesToShow, // if index is 4, do not wrap
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (visualiseTags && movement.tags.isNotEmpty)
            _buildTagChipsRow(movement.tags),
        ],
      ),
      trailing: Text(
        getCurrencyValueString(movement.value),
        style: _currencyFontStyle,
      ),
      leading: CategoryIconCircle(
        iconEmoji: movement.category?.iconEmoji,
        iconDataFromDefaultIconSet: movement.category?.icon,
        backgroundColor: movement.category?.color,
        overlayIcon: movement.recurrencePatternId != null ? Icons.repeat : null,
      ),
    );
  }

  Widget _buildTagChipsRow(Set<String> tags) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          List<Widget> tagChips = [];
          for (final tag in tags) {
            final chip = Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              child: Chip(
                label: Text(tag, style: TextStyle(fontSize: 12.0)),
                visualDensity: VisualDensity.compact,
              ),
            );
            tagChips.add(chip);
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: tagChips),
          );
        },
      ),
    );
  }
}
