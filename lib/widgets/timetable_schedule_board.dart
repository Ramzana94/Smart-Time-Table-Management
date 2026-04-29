import 'package:flutter/material.dart';
import 'package:smart_timetable_managment/models/timetable_grid_model.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';
import 'package:smart_timetable_managment/widgets/timetable_session_card.dart';


class TimetableScheduleBoard extends StatelessWidget {
  final TimetableGridData gridData;
  final bool canManage;
  final ValueChanged<List<TimetableModel>> onSlotTap;

  const TimetableScheduleBoard({
    super.key,
    required this.gridData,
    required this.canManage,
    required this.onSlotTap,
  });

  static const double _timeColumnWidth = 165;
  static const double _dayColumnWidth = 215;
  static const double _rowMinHeight = 165;
  static const double _boardBorderWidth = 1;

  @override
  Widget build(BuildContext context) {
    final totalWidth =
        _timeColumnWidth +
        (gridData.days.length * _dayColumnWidth) +
        (_boardBorderWidth * 2);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: totalWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD9E3F1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F2A4160),
              blurRadius: 24,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              _BoardHeader(
                days: gridData.days,
                timeColumnWidth: _timeColumnWidth,
              ),
              for (var index = 0; index < gridData.rows.length; index++)
                _BoardRow(
                  row: gridData.rows[index],
                  days: gridData.days,
                  canManage: canManage,
                  onSlotTap: onSlotTap,
                  timeColumnWidth: _timeColumnWidth,
                  dayColumnWidth: _dayColumnWidth,
                  rowMinHeight: _rowMinHeight,
                  isLast: index == gridData.rows.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardHeader extends StatelessWidget {
  final List<String> days;
  final double timeColumnWidth;

  const _BoardHeader({required this.days, required this.timeColumnWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF295FE7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          _HeaderCell(label: 'Time', width: timeColumnWidth, alignStart: true),
          for (final day in days) _HeaderCell(label: day),
        ],
      ),
    );
  }
}

class _BoardRow extends StatelessWidget {
  final TimetableGridRow row;
  final List<String> days;
  final bool canManage;
  final ValueChanged<List<TimetableModel>> onSlotTap;
  final double timeColumnWidth;
  final double dayColumnWidth;
  final double rowMinHeight;
  final bool isLast;

  const _BoardRow({
    required this.row,
    required this.days,
    required this.canManage,
    required this.onSlotTap,
    required this.timeColumnWidth,
    required this.dayColumnWidth,
    required this.rowMinHeight,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: rowMinHeight),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : const Color(0xFFE4ECF8),
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: timeColumnWidth,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                row.timeLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF23395D),
                  height: 1.35,
                ),
              ),
            ),
            for (final day in days)
              Container(
                width: dayColumnWidth,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFFE4ECF8))),
                ),
                child: _DaySlotCell(
                  entries: row.entriesForDay(day),
                  canManage: canManage,
                  onTap: onSlotTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DaySlotCell extends StatelessWidget {
  final List<TimetableModel> entries;
  final bool canManage;
  final ValueChanged<List<TimetableModel>> onTap;

  const _DaySlotCell({
    required this.entries,
    required this.canManage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          '-',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA3B4CC),
          ),
        ),
      );
    }

    return TimetableSessionCard(
      entries: entries,
      canManage: canManage,
      onTap: () {
        onTap(entries);
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final bool alignStart;

  const _HeaderCell({
    required this.label,
    this.width = TimetableScheduleBoard._dayColumnWidth,
    this.alignStart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: alignStart ? 24 : 16,
        vertical: 22,
        
      ),
      alignment: alignStart ? Alignment.centerLeft : Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}