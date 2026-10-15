import 'dart:typed_data';
import 'package:barcode/barcode.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/models/models.dart';

/// Generates a branded PDF invoice for a paid Hatri ticket and hands it to the
/// device's share sheet. Prototype uses a mock 5% convenience fee + 18% GST.
class HatriInvoice {
  final Event event;
  final TicketTier tier;
  final int quantity;
  final String ticketRef;
  final DateTime issuedAt;

  HatriInvoice({
    required this.event,
    required this.tier,
    this.quantity = 1,
    required this.ticketRef,
    DateTime? issuedAt,
  }) : issuedAt = issuedAt ?? DateTime.now();

  int get base => tier.priceRupees * quantity;
  int get convenienceFee => (base * 0.05).round();
  int get gst => ((base + convenienceFee) * 0.18).round();
  int get total => base + convenienceFee + gst;

  Future<Uint8List> build() async {
    final doc = pw.Document(title: 'Hatri Invoice · $ticketRef');
    // Non-Hatri scanners land on the event's hatri.online page which has
    // a "download the app" CTA. App users auto-open via Universal Link.
    final qrPayload = 'https://hatri.online/e/${event.slug}';
    final logo = await _loadLogo();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 42, 36, 42),
        build: (ctx) => _layout(qrPayload, logo),
      ),
    );
    return doc.save();
  }

  pw.Widget _layout(String qrPayload, pw.MemoryImage? logo) {
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Masthead
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logo != null) pw.Image(logo, width: 36, height: 36),
            pw.SizedBox(width: 12),
            pw.Text('HATRI', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(width: 10),
            pw.Text('· INVOICE',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.pink600, fontWeight: pw.FontWeight.bold)),
            pw.Spacer(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('REF · $ticketRef', style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text(
                  DateFormat('d MMM y · HH:mm').format(issuedAt),
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Container(height: 2, color: PdfColors.pink600),
        pw.SizedBox(height: 28),

        // BILL TO
        _labelValue('BILL TO', 'Hatri user · Raipur'),
        pw.SizedBox(height: 20),

        // Event block
        _sectionHeader('EVENT'),
        pw.SizedBox(height: 8),
        pw.Text(event.title,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, letterSpacing: -0.3)),
        pw.SizedBox(height: 6),
        _labelValue('WHEN',
            '${DateFormat('EEE, d MMM y').format(event.date)} · ${event.time}'),
        pw.SizedBox(height: 4),
        _labelValue('WHERE', event.venue),
        pw.SizedBox(height: 4),
        _labelValue('ORGANIZER', event.organizer),
        pw.SizedBox(height: 28),

        // Line items
        _sectionHeader('LINE ITEMS'),
        pw.SizedBox(height: 8),
        _line(
          '${tier.name} · ${tier.perk ?? "Ticket"}'
          '${quantity > 1 ? "  × $quantity @ ₹${tier.priceRupees}" : ""}',
          money.format(base),
        ),
        _line('Convenience fee (5%)', money.format(convenienceFee)),
        _line('GST (18%)', money.format(gst)),
        pw.SizedBox(height: 8),
        pw.Container(height: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        _line('TOTAL PAID', money.format(total), bold: true),
        pw.SizedBox(height: 32),

        // QR + fine print
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.BarcodeWidget(
              barcode: Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high),
              data: qrPayload,
              width: 110,
              height: 110,
              drawText: false,
            ),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SCAN AT ENTRY',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, letterSpacing: 1.4)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Present this QR at the venue door. One scan per ticket. '
                    'Refunds up to 24h before event, minus fees.',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text('Hatri · Raipur · hatri.app',
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        pw.Spacer(),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 6),
        pw.Text(
          'Thanks for showing up. — Team Hatri',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
        ),
      ],
    );
  }

  pw.Widget _sectionHeader(String label) => pw.Text(
        label,
        style: pw.TextStyle(fontSize: 10, letterSpacing: 1.6, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold),
      );

  pw.Widget _labelValue(String label, String value) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(label,
                style: pw.TextStyle(fontSize: 9, letterSpacing: 1.4, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
          ),
        ],
      );

  pw.Widget _line(String label, String amount, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(label,
                  style: pw.TextStyle(fontSize: 12, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
            ),
            pw.Text(amount,
                style: pw.TextStyle(
                  fontSize: bold ? 15 : 12,
                  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: bold ? PdfColors.pink600 : PdfColors.black,
                )),
          ],
        ),
      );

  Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final data = await rootBundle.load('assets/icons/app_icon.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  Future<void> share() async {
    final bytes = await build();
    await Printing.sharePdf(bytes: bytes, filename: 'hatri_invoice_$ticketRef.pdf');
  }
}
