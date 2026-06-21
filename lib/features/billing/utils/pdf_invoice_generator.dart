import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/repositories/billing_repository.dart';

class PdfInvoiceGenerator {
  /// Generates and prints a PDF invoice for the given bill.
  static Future<void> printInvoice(BillModel bill) async {
    final pdf = pw.Document();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final monthName = months[bill.billingMonth - 1];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue800,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Vanthenda Paalkaran',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Milk Delivery Invoice',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#FFFFFFB3'),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              // Invoice details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To:',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12)),
                      pw.SizedBox(height: 4),
                      pw.Text(bill.customerName,
                          style: const pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Period: $monthName ${bill.billingYear}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Invoice #${bill.id.substring(0, 8).toUpperCase()}',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 12),
              // Table header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Description',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text('Amount',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'Milk delivery — ${bill.totalLiters.toStringAsFixed(1)}L'),
                  pw.Text('₹${bill.totalAmount.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 8),
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Amount',
                      style:
                          pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    '₹${bill.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Amount Paid'),
                  pw.Text('₹${bill.amountPaid.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Amount Due',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red)),
                  pw.Text(
                    '₹${bill.amountDue.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red),
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              pw.Center(
                child: pw.Text(
                  bill.isPaid ? 'PAID' : 'PAYMENT PENDING',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color:
                        bill.isPaid ? PdfColors.green : PdfColors.orange,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
