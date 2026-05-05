import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smart_timetable_managment/models/timetable_grid_model.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';

class PdfService {
  Future<void> generateAndDownloadTimetable({
    required TimetableGridData gridData,
    required String title,
    required String subtitle,
    List<TimetableModel>? entries,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM dd, yyyy - hh:mm a');
    final exportEntries = _sortedEntries(_resolveEntries(gridData, entries));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build:
            (pw.Context context) => [
              _buildHeader(title, subtitle, dateFormat.format(now)),
              pw.SizedBox(height: 18),
              if (gridData.isEmpty)
                pw.Text(
                  'No weekly grid data available.',
                  style: const pw.TextStyle(fontSize: 12),
                )
              else ...[
                _buildSectionTitle('Weekly Grid'),
                pw.SizedBox(height: 8),
                _buildGridTable(gridData),
              ],
              pw.SizedBox(height: 18),
              _buildSectionTitle('All Timetable Entries'),
              pw.SizedBox(height: 8),
              if (exportEntries.isEmpty)
                pw.Text(
                  'No timetable data available.',
                  style: const pw.TextStyle(fontSize: 12),
                )
              else
                _buildEntriesTable(exportEntries),
            ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'timetable_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf',
    );
  }

  pw.Widget _buildHeader(String title, String subtitle, String generatedAt) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          subtitle,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated on $generatedAt',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget _buildGridTable(TimetableGridData gridData) {
    return pw.TableHelper.fromTextArray(
      headers: ['Time', ...gridData.days],
      data:
          gridData.rows.map((row) {
            return [
              row.timeLabel,
              ...gridData.days.map((day) {
                final dayEntries = row.entriesForDay(day);
                if (dayEntries.isEmpty) {
                  return '-';
                }

                return dayEntries.map(_gridCellText).join('\n---\n');
              }),
            ];
          }).toList(),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColor(0.157, 0.373, 0.91),
      ),
      cellStyle: const pw.TextStyle(fontSize: 7.5),
      cellPadding: const pw.EdgeInsets.all(5),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
        ),
      ),
    );
  }

  pw.Widget _buildEntriesTable(List<TimetableModel> entries) {
    return pw.TableHelper.fromTextArray(
      headers: const [
        'Department',
        'Semester',
        'Shift',
        'Day',
        'Time',
        'Subject',
        'Teacher',
        'Room',
      ],
      data:
          entries.map((entry) {
            return [
              _valueOrDash(entry.department),
              _valueOrDash(entry.semester),
              _valueOrDash(entry.shift),
              _valueOrDash(entry.day),
              _valueOrDash(entry.time),
              _valueOrDash(entry.courseTitle),
              _valueOrDash(entry.teacher),
              _valueOrDash(entry.room),
            ];
          }).toList(),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.7),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 9,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColor(0.12, 0.2, 0.35),
      ),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.all(4),
    );
  }

  List<TimetableModel> _resolveEntries(
    TimetableGridData gridData,
    List<TimetableModel>? entries,
  ) {
    if (entries != null) {
      return List<TimetableModel>.from(entries);
    }

    final seen = <String>{};
    final resolved = <TimetableModel>[];

    for (final row in gridData.rows) {
      for (final day in gridData.days) {
        for (final entry in row.entriesForDay(day)) {
          final key =
              entry.id.isNotEmpty
                  ? entry.id
                  : [
                    entry.department,
                    entry.semester,
                    entry.shift,
                    entry.day,
                    entry.time,
                    entry.courseTitle,
                    entry.teacher,
                    entry.room,
                  ].join('|');

          if (seen.add(key)) {
            resolved.add(entry);
          }
        }
      }
    }

    return resolved;
  }

  List<TimetableModel> _sortedEntries(List<TimetableModel> entries) {
    final sorted = List<TimetableModel>.from(entries);
    sorted.sort((a, b) {
      var result = _compareText(a.department, b.department);
      if (result != 0) return result;

      result = _semesterOrder(a.semester).compareTo(_semesterOrder(b.semester));
      if (result != 0) return result;

      result = _shiftOrder(a.shift).compareTo(_shiftOrder(b.shift));
      if (result != 0) return result;

      result = _dayOrder(a.day).compareTo(_dayOrder(b.day));
      if (result != 0) return result;

      result = _timeStartOrder(a.time).compareTo(_timeStartOrder(b.time));
      if (result != 0) return result;

      return _compareText(a.courseTitle, b.courseTitle);
    });
    return sorted;
  }

  String _gridCellText(TimetableModel entry) {
    final lines = <String>[
      _valueOrDash(entry.courseTitle),
      if (entry.teacher.trim().isNotEmpty) 'Teacher: ${entry.teacher.trim()}',
      'Room: ${_valueOrDash(entry.room)}',
      '${_valueOrDash(entry.department)} | ${_semesterLabel(entry.semester)} | ${_valueOrDash(entry.shift)}',
    ];

    return lines.join('\n');
  }

  String _semesterLabel(String semester) {
    final value = semester.trim();
    if (value.isEmpty) {
      return 'Semester -';
    }

    if (value.toLowerCase().startsWith('semester')) {
      return value;
    }

    return 'Semester $value';
  }

  String _valueOrDash(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '-' : trimmed;
  }

  int _compareText(String first, String second) {
    return first.trim().toLowerCase().compareTo(second.trim().toLowerCase());
  }

  int _semesterOrder(String semester) {
    final digits =
        semester.codeUnits
            .where((unit) => unit >= 48 && unit <= 57)
            .map(String.fromCharCode)
            .join();
    return int.tryParse(digits) ?? 999;
  }

  int _shiftOrder(String shift) {
    switch (shift.trim().toLowerCase()) {
      case 'morning':
        return 0;
      case 'evening':
        return 1;
      default:
        return 99;
    }
  }

  int _dayOrder(String day) {
    switch (day.trim().toLowerCase()) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      case 'sunday':
        return 7;
      default:
        return 99;
    }
  }

  int _timeStartOrder(String timeRange) {
    final parts =
        timeRange
            .split('-')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();

    if (parts.isEmpty) {
      return 9999;
    }

    return _parseClockValue(parts.first) ?? 9999;
  }

  int? _parseClockValue(String raw) {
    var value = raw.toUpperCase().replaceAll('.', '').trim();
    String? meridiem;

    if (value.endsWith('AM') || value.endsWith('PM')) {
      meridiem = value.substring(value.length - 2);
      value = value.substring(0, value.length - 2).trim();
    }

    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }

    var hour = int.tryParse(parts.first.trim());
    final minute = int.tryParse(parts.last.trim());

    if (hour == null || minute == null || minute < 0 || minute > 59) {
      return null;
    }

    if (meridiem != null) {
      if (hour < 1 || hour > 12) {
        return null;
      }

      if (meridiem == 'PM' && hour != 12) {
        hour += 12;
      } else if (meridiem == 'AM' && hour == 12) {
        hour = 0;
      }
    } else if (hour < 0 || hour > 23) {
      return null;
    }

    return (hour * 60) + minute;
  }
}
