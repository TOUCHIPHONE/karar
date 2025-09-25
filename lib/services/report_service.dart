import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/expense_entry.dart';
import '../models/work_entry.dart';

class ReportService {
  Future<void> printWorkReport(List<WorkEntry> entries) async {
    final pdf = pw.Document();
    final currency = NumberFormat.currency(symbol: 'IQD');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'تقرير أجور الأعمال'),
          pw.Table.fromTextArray(
            headers: const ['العامل', 'نوع القطعة', 'عدد القطع', 'السعر', 'الإجمالي', 'التاريخ'],
            data: entries
                .map(
                  (entry) => [
                    entry.workerName,
                    entry.pieceType,
                    entry.piecesCount.toString(),
                    currency.format(entry.unitPrice),
                    currency.format(entry.totalAmount),
                    DateFormat.yMd().format(entry.workDate),
                  ],
                )
                .toList(),
          ),
          pw.Paragraph(
            text:
                'الإجمالي الكلي: ${currency.format(entries.fold<double>(0, (total, entry) => total + entry.totalAmount))}',
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<void> printExpenseReport(List<ExpenseEntry> entries) async {
    final pdf = pw.Document();
    final currency = NumberFormat.currency(symbol: 'IQD');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'تقرير المصروفات'),
          pw.Table.fromTextArray(
            headers: const ['المصروف', 'المبلغ', 'التاريخ', 'ملاحظة'],
            data: entries
                .map(
                  (entry) => [
                    entry.title,
                    currency.format(entry.amount),
                    DateFormat.yMd().format(entry.spentAt),
                    entry.note ?? '-',
                  ],
                )
                .toList(),
          ),
          pw.Paragraph(
            text:
                'إجمالي المصروفات: ${currency.format(entries.fold<double>(0, (total, entry) => total + entry.amount))}',
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
