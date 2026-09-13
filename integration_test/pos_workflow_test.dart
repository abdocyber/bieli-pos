import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bieli_pos/database/db_helper.dart';
import 'package:bieli_pos/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('POS app root loads', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const BieLiApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('البيع المباشر'), findsWidgets);
    expect(find.text('السلة فارغة'), findsOneWidget);
  });

  test('processing a sale records the invoice and decrements stock', () async {
    final database = DatabaseHelper.instance;
    final productId = 'integration-${DateTime.now().microsecondsSinceEpoch}';
    final product = {
      'id': productId,
      'barcode': 'TEST-$productId',
      'name': 'منتج اختبار التكامل',
      'category': 'اختبار',
      'unit': 'قطعة',
      'retail_price': 10.0,
      'wholesale_price': 8.0,
      'stock': 10,
      'min_stock_alert': 3,
    };

    await database.insertProduct(product);
    addTearDown(() => database.deleteProduct(productId));

    final matchingProducts = (await database.getProducts())
        .where((item) => item['id'] == productId)
        .toList();
    expect(matchingProducts, hasLength(1));
    expect(matchingProducts.single['name'], 'منتج اختبار التكامل');

    const quantity = 2;
    const subtotal = 20.0;
    const tax = 3.0;
    const grandTotal = 23.0;
    final invoiceId = await database.processSale(
      customerName: 'عميل اختبار',
      invoiceType: 'قطاعي',
      paymentMethod: 'نقداً',
      subtotal: subtotal,
      tax: tax,
      grandTotal: grandTotal,
      items: [
        {
          'id': productId,
          'name': 'منتج اختبار التكامل',
          'unit': 'قطعة',
          'price': 10.0,
          'quantity': quantity,
          'subtotal': subtotal,
        },
      ],
    );

    final updated = (await database.getProducts())
        .singleWhere((item) => item['id'] == productId);
    expect(updated['stock'], 8);

    final invoice = (await database.getInvoices())
        .singleWhere((item) => item['id'] == invoiceId);
    expect(invoice['customer_name'], 'عميل اختبار');
    expect(invoice['subtotal'], subtotal);
    expect(invoice['tax'], tax);
    expect(invoice['grand_total'], grandTotal);

    final items = await (await database.database).query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
    expect(items, hasLength(1));
    expect(items.single['quantity'], quantity);
    expect(items.single['total_price'], subtotal);
  });
}
