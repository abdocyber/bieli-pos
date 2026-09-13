import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'store_settings_service.dart';

class InvoiceActionService {
  static Future<void> printThermalReceipt({
    required int invoiceId,
    required String customerName,
    required String paymentMethod,
    required String invoiceType,
    required double subtotal,
    required double tax,
    required double grandTotal,
    required List<Map<String, dynamic>> items,
  }) async {
    final settings = await StoreSettingsService.getSettings();
    final doc = pw.Document();

    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(6),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(settings['name']!,
                    style: const pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 13)),
                pw.Text('هاتف: ${settings['phone']!}',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text(settings['address']!,
                    style: const pw.TextStyle(fontSize: 8)),
                if (settings['taxNumber']!.isNotEmpty)
                  pw.Text('الرقم الضريبي: ${settings['taxNumber']!}',
                      style: const pw.TextStyle(fontSize: 8)),
                pw.Divider(thickness: 1),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('فاتورة رقم: #$invoiceId',
                        style: const pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    pw.Text('النوع: $invoiceType',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('العميل: $customerName',
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('الدفع: $paymentMethod',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Divider(thickness: 0.5),
                ...items.map((it) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${it['name']} x${it['quantity']}',
                              style: const pw.TextStyle(fontSize: 8)),
                          pw.Text((it['subtotal'] as double).toStringAsFixed(2),
                              style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    )),
                pw.Divider(thickness: 1),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('المبلغ قبل الضريبة:',
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('${subtotal.toStringAsFixed(2)} ر.س',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('ضريبة القيمة المضافة (15%):',
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('${tax.toStringAsFixed(2)} ر.س',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
                pw.Divider(thickness: 1),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('الإجمالي النهائي:',
                        style: const pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('${grandTotal.toStringAsFixed(2)} ر.س',
                        style: const pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.BarcodeWidget(
                  data: 'INV-$invoiceId-${grandTotal.toStringAsFixed(2)}',
                  barcode: pw.Barcode.code128(),
                  width: 140,
                  height: 35,
                ),
                pw.SizedBox(height: 6),
                pw.Text(settings['footer']!,
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 7)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  static Future<void> shareViaWhatsApp({
    required int invoiceId,
    required String customerPhone,
    required String customerName,
    required double grandTotal,
    required List<Map<String, dynamic>> items,
  }) async {
    final settings = await StoreSettingsService.getSettings();

    final buffer = StringBuffer();
    buffer.writeln('🧾 *فاتورة إلكترونية - ${settings['name']}*');
    buffer.writeln('📍 ${settings['address']}');
    buffer.writeln('📞 هاتف: ${settings['phone']}');
    buffer.writeln('--------------------------------');
    buffer.writeln('رقم الفاتورة: #$invoiceId');
    buffer.writeln('العميل: $customerName');
    buffer.writeln('--------------------------------');
    buffer.writeln('*الأصناف المشتراة:*');

    for (var it in items) {
      buffer.writeln(
          '• ${it['name']} (x${it['quantity']} ${it['unit'] ?? ""}) = ${(it['subtotal'] as double).toStringAsFixed(2)} ر.س');
    }

    buffer.writeln('--------------------------------');
    buffer.writeln(
        '💰 *الإجمالي النهائي: ${grandTotal.toStringAsFixed(2)} ر.س* (شامل 15% ضريبة)');
    buffer.writeln('--------------------------------');
    buffer.writeln('${settings['footer']}');

    final cleanPhone = customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMsg = Uri.encodeComponent(buffer.toString());

    final url = cleanPhone.isNotEmpty
        ? 'https://wa.me/$cleanPhone?text=$encodedMsg'
        : 'https://api.whatsapp.com/send?text=$encodedMsg';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
