import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../theme/glass_theme.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _customerCtrl = TextEditingController();

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _searchResults = [];
  final List<Map<String, dynamic>> _cart = [];

  final bool _isWholesale = false;
  final String _paymentMethod = 'نقداً';

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    final data = await DatabaseHelper.instance.getProducts();
    if (mounted) {
      setState(() => _allProducts = data);
    }
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final q = query.trim().toLowerCase();
    setState(() {
      _searchResults = _allProducts.where((p) {
        final name = (p['name'] ?? '').toString().toLowerCase();
        final barcode = (p['barcode'] ?? '').toString().toLowerCase();
        return name.contains(q) || barcode.contains(q);
      }).toList();
    });
  }

  void _openQuantitySheet(Map<String, dynamic> product) {
    final price = _isWholesale
        ? ((product['wholesale_price'] as num?)?.toDouble() ?? 0.0)
        : ((product['retail_price'] as num?)?.toDouble() ?? 0.0);
    final unit = product['unit'] ?? 'قطعة';
    final stock = (product['stock'] as num?)?.toInt() ?? 0;

    int qty = 1;
    final qtyCtrl = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(22),
            tintColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product['name'],
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                Text('المتوفر بالمستودع: $stock $unit',
                    style: GoogleFonts.tajawal(
                        color: stock <= 3 ? Colors.red : Colors.blueGrey,
                        fontSize: 13)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('سعر الوحدة (${_isWholesale ? "جملة" : "تجزئة"}):',
                        style: GoogleFonts.tajawal(fontSize: 14)),
                    Text('${price.toStringAsFixed(2)} ر.س',
                        style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: BieLiTheme.emeraldGreen)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('حدد الكمية المطلوبة:',
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _quantityBtn(Icons.remove, () {
                      if (qty > 1) {
                        setModal(() {
                          qty--;
                          qtyCtrl.text = qty.toString();
                        });
                      }
                    }),
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        onChanged: (v) {
                          final parsed = int.tryParse(v);
                          if (parsed != null && parsed > 0) qty = parsed;
                        },
                      ),
                    ),
                    _quantityBtn(Icons.add, () {
                      setModal(() {
                        qty++;
                        qtyCtrl.text = qty.toString();
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BieLiTheme.primaryCrimson,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final finalQty = int.tryParse(qtyCtrl.text) ?? qty;
                    _addToCart(product, price, finalQty, unit);
                    Navigator.pop(ctx);
                    _searchCtrl.clear();
                    setState(() => _searchResults = []);
                  },
                  child: Text(
                      'إضافة إلى الفاتورة (${(price * qty).toStringAsFixed(2)} ر.س)',
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: BieLiTheme.darkNavy.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: BieLiTheme.darkNavy),
      ),
    );
  }

  void _addToCart(
      Map<String, dynamic> product, double price, int qty, String unit) {
    setState(() {
      final index = _cart.indexWhere((it) => it['id'] == product['id']);
      if (index != -1) {
        _cart[index]['quantity'] += qty;
        _cart[index]['subtotal'] = _cart[index]['quantity'] * price;
      } else {
        _cart.add({
          'id': product['id'],
          'name': product['name'],
          'unit': unit,
          'price': price,
          'quantity': qty,
          'subtotal': price * qty,
        });
      }
    });
  }

  double get _subtotal =>
      _cart.fold(0.0, (sum, it) => sum + (it['subtotal'] as double));
  double get _tax => _subtotal * 0.15;
  double get _grandTotal => _subtotal + _tax;

  void _saveAndShowReceiptDialog() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('السلة فارغة')));
      return;
    }

    final id = await DatabaseHelper.instance.processSale(
      customerName: _customerCtrl.text.trim(),
      invoiceType: _isWholesale ? 'جملة' : 'قطاعي',
      paymentMethod: _paymentMethod,
      subtotal: _subtotal,
      tax: _tax,
      grandTotal: _grandTotal,
      items: _cart,
    );

    await _refreshProducts();

    if (!mounted) return;

    final phoneForWhatsAppCtrl = TextEditingController();
    final savedTotal = _grandTotal;

    setState(() {
      _cart.clear();
      _customerCtrl.clear();
    });

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF059669)),
              const SizedBox(width: 8),
              Text('تم إصدار الفاتورة #$id',
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('الإجمالي: ${savedTotal.toStringAsFixed(2)} ر.س',
                  style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: BieLiTheme.emeraldGreen)),
              const SizedBox(height: 12),
              TextField(
                controller: phoneForWhatsAppCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم واتساب العميل (اختياري مع الكود)',
                  hintText: '966500000000',
                  prefixIcon: Icon(Icons.phone_android, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close),
                label: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('البيع المباشر')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                decoration: const InputDecoration(
                  labelText: 'ابحث بالاسم أو الباركود',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_searchResults.isNotEmpty)
              ..._searchResults.map(
                (product) => ListTile(
                  title: Text(product['name']?.toString() ?? ''),
                  subtitle: Text('${product['retail_price'] ?? 0} ر.س'),
                  trailing: const Icon(Icons.add_shopping_cart),
                  onTap: () => _openQuantitySheet(product),
                ),
              ),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('السلة فارغة'))
                  : ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return ListTile(
                          title: Text(item['name'].toString()),
                          subtitle: Text(
                              '${item['quantity']} × ${item['price']} ر.س'),
                          trailing: Text(
                              '${item['subtotal'].toStringAsFixed(2)} ر.س'),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('الإجمالي: ${_grandTotal.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed:
                          _cart.isEmpty ? null : _saveAndShowReceiptDialog,
                      child: const Text('إصدار الفاتورة')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
