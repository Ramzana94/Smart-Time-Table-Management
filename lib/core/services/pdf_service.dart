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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    subtitle,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Generated on ${dateFormat.format(now)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              // Table
              if (gridData.isEmpty)
                pw.Center(
                  child: pw.Text(
                    'No timetable data available',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                )
              else
                pw.TableHelper.fromTextArray(
                  headers: ['Time', ...gridData.days],
                  data: gridData.rows.map((row) {
                    return [
                      row.timeLabel,
                      ...gridData.days.map((day) {
                        final dayEntries = row.entriesForDay(day);
                        if (dayEntries.isEmpty) {
                          return '-';
                        }
                        return dayEntries
                            .map((e) =>
                                '${e.courseTitle}${e.teacher.isNotEmpty ? '\n(${e.teacher})' : ''}\nRoom: ${e.room}')
                            .join('\n---\n');
                      }),
                    ];
                  }).toList(),
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 1,
                  ),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 11,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColor(0.157, 0.373, 0.91),
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellHeight: 60,
                  rowDecoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColors.grey200,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    // Download the PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'timetable_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf',
    );
  }
}