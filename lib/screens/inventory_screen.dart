import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../theme/glass_theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  String _category = 'الكل';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final products = await DatabaseHelper.instance.getProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _visibleProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((product) {
      final matchesCategory =
          _category == 'الكل' || product['category'] == _category;
      final text =
          '${product['name']} ${product['barcode']} ${product['category']}'
              .toLowerCase();
      return matchesCategory && (query.isEmpty || text.contains(query));
    }).toList();
  }

  Future<void> _showProductForm([Map<String, dynamic>? existing]) async {
    final name = TextEditingController(text: existing?['name']?.toString());
    final barcode =
        TextEditingController(text: existing?['barcode']?.toString());
    final category =
        TextEditingController(text: existing?['category']?.toString() ?? 'عام');
    final unit =
        TextEditingController(text: existing?['unit']?.toString() ?? 'قطعة');
    final retail = TextEditingController(
        text: existing?['retail_price']?.toString() ?? '0');
    final wholesale = TextEditingController(
        text: existing?['wholesale_price']?.toString() ?? '0');
    final stock =
        TextEditingController(text: existing?['stock']?.toString() ?? '0');
    final minStock = TextEditingController(
        text: existing?['min_stock_alert']?.toString() ?? '3');
    final saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
                padding: EdgeInsets.fromLTRB(
                    18, 4, 18, MediaQuery.of(context).viewInsets.bottom + 18),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      Text(
                          existing == null ? 'إضافة منتج جديد' : 'تعديل المنتج',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 14),
                      _field(name, 'اسم المنتج', Icons.inventory_2),
                      _field(barcode, 'الباركود / SKU', Icons.qr_code_2),
                      Row(children: [
                        Expanded(
                            child: _field(category, 'التصنيف', Icons.category)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _field(unit, 'الوحدة', Icons.straighten))
                      ]),
                      Row(children: [
                        Expanded(
                            child: _field(retail, 'سعر التجزئة', Icons.sell,
                                number: true)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _field(
                                wholesale, 'سعر الجملة', Icons.local_offer,
                                number: true))
                      ]),
                      Row(children: [
                        Expanded(
                            child: _field(
                                stock, 'الكمية الحالية', Icons.numbers,
                                number: true)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _field(
                                minStock, 'حد التنبيه', Icons.warning_amber,
                                number: true))
                      ]),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                          onPressed: () async {
                            if (name.text.trim().isEmpty) return;
                            final row = {
                              'id': existing?['id']?.toString() ??
                                  'p-${DateTime.now().microsecondsSinceEpoch}',
                              'barcode': barcode.text.trim(),
                              'name': name.text.trim(),
                              'category': category.text.trim().isEmpty
                                  ? 'عام'
                                  : category.text.trim(),
                              'unit': unit.text.trim().isEmpty
                                  ? 'قطعة'
                                  : unit.text.trim(),
                              'retail_price': double.tryParse(retail.text) ?? 0,
                              'wholesale_price':
                                  double.tryParse(wholesale.text) ?? 0,
                              'stock': int.tryParse(stock.text) ?? 0,
                              'min_stock_alert':
                                  int.tryParse(minStock.text) ?? 3
                            };
                            if (existing == null) {
                              await DatabaseHelper.instance.insertProduct(row);
                            } else {
                              await DatabaseHelper.instance.updateProduct(
                                  existing['id'].toString(), row);
                            }
                            if (context.mounted) Navigator.pop(context, true);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('حفظ المنتج'))
                    ])))));
    for (final controller in [
      name,
      barcode,
      category,
      unit,
      retail,
      wholesale,
      stock,
      minStock
    ]) {
      controller.dispose();
    }
    if (saved == true) _loadProducts();
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
          {bool number = false}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(
              controller: controller,
              keyboardType: number
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration:
                  InputDecoration(labelText: label, prefixIcon: Icon(icon))));
  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    await DatabaseHelper.instance.deleteProduct(product['id'].toString());
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'الكل',
      ..._products.map((p) => p['category'].toString()).toSet()
    ];
    final lowStock = _products
        .where((p) => (p['stock'] as num) <= (p['min_stock_alert'] as num))
        .length;
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(title: const Text('المخزن والمنتجات')),
            floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _showProductForm(),
                backgroundColor: BieLiTheme.primaryCrimson,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('منتج جديد')),
            body: RefreshIndicator(
                onRefresh: _loadProducts,
                child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
                    children: [
                      Row(children: [
                        Expanded(
                            child: _SummaryCard(
                                title: 'إجمالي المنتجات',
                                value: '${_products.length}',
                                icon: Icons.inventory_2,
                                color: BieLiTheme.darkNavy)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _SummaryCard(
                                title: 'تنبيه المخزون',
                                value: '$lowStock',
                                icon: Icons.warning_amber,
                                color: Colors.orange))
                      ]),
                      const SizedBox(height: 14),
                      TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                              labelText: 'ابحث بالاسم أو الباركود أو التصنيف',
                              prefixIcon: Icon(Icons.search))),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              children: categories
                                  .map((item) => Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: ChoiceChip(
                                          label: Text(item),
                                          selected: _category == item,
                                          onSelected: (_) => setState(
                                              () => _category = item))))
                                  .toList())),
                      const SizedBox(height: 10),
                      if (_loading)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.all(28),
                                child: CircularProgressIndicator()))
                      else if (_visibleProducts.isEmpty)
                        const _EmptyInventory()
                      else
                        ..._visibleProducts.map((product) => _ProductTile(
                            product: product,
                            onEdit: () => _showProductForm(product),
                            onDelete: () => _deleteProduct(product)))
                    ]))));
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _SummaryCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) => GlassCard(
          child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 9),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
        ]))
      ]));
}

class _ProductTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit, onDelete;
  const _ProductTile(
      {required this.product, required this.onEdit, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    final stock = (product['stock'] as num).toInt();
    final min = (product['min_stock_alert'] as num).toInt();
    final low = stock <= min;
    return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
            leading: CircleAvatar(
                backgroundColor: (low ? Colors.orange : BieLiTheme.emeraldGreen)
                    .withValues(alpha: .12),
                child: Icon(low ? Icons.warning_amber : Icons.inventory_2,
                    color: low ? Colors.orange : BieLiTheme.emeraldGreen)),
            title: Text(product['name'].toString(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${product['category']} • ${product['retail_price']} ر.س • المخزون: $stock ${product['unit']}'),
            trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('تعديل')),
                      PopupMenuItem(value: 'delete', child: Text('حذف'))
                    ])));
  }
}

class _EmptyInventory extends StatelessWidget {
  const _EmptyInventory();
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.all(45),
      child: Column(children: [
        Icon(Icons.inventory_2_outlined, size: 62, color: Colors.blueGrey),
        SizedBox(height: 12),
        Text('لا توجد منتجات بعد'),
        Text('أضف أول منتج ليظهر هنا')
      ]));
}
