import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../theme/glass_theme.dart';
import 'backup_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _invoices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _loading = true);
    final data = await DatabaseHelper.instance.getInvoices();
    if (mounted) {
      setState(() {
        _invoices = data;
        _loading = false;
      });
    }
  }

  double get _total => _invoices.fold(
      0, (sum, item) => sum + ((item['grand_total'] as num?)?.toDouble() ?? 0));
  double get _tax => _invoices.fold(
      0, (sum, item) => sum + ((item['tax'] as num?)?.toDouble() ?? 0));

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('لوحة الإدارة'), actions: [
            IconButton(
                onPressed: _loadInvoices, icon: const Icon(Icons.refresh))
          ]),
          body: RefreshIndicator(
              onRefresh: _loadInvoices,
              child: ListView(padding: const EdgeInsets.all(14), children: [
                Text('نظرة عامة',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: _Kpi(
                          title: 'إجمالي المبيعات',
                          value: '${_total.toStringAsFixed(2)} ر.س',
                          icon: Icons.payments,
                          color: BieLiTheme.primaryCrimson)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _Kpi(
                          title: 'الفواتير',
                          value: '${_invoices.length}',
                          icon: Icons.receipt_long,
                          color: BieLiTheme.darkNavy))
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _Kpi(
                          title: 'الضريبة المحصلة',
                          value: '${_tax.toStringAsFixed(2)} ر.س',
                          icon: Icons.account_balance,
                          color: BieLiTheme.emeraldGreen)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _Kpi(
                          title: 'متوسط الفاتورة',
                          value: _invoices.isEmpty
                              ? '0.00'
                              : '${(_total / _invoices.length).toStringAsFixed(2)} ر.س',
                          icon: Icons.analytics,
                          color: Colors.orange))
                ]),
                const SizedBox(height: 20),
                GlassCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      Text('أدوات الإدارة',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const BackupScreen())),
                            icon: const Icon(Icons.backup),
                            label: const Text('النسخ الاحتياطي')),
                        OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.print),
                            label: const Text('تقرير المبيعات'))
                      ])
                    ])),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('آخر الفواتير',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('${_invoices.length} فاتورة',
                          style: const TextStyle(color: Colors.blueGrey))
                    ]),
                const SizedBox(height: 8),
                if (_loading)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(25),
                          child: CircularProgressIndicator()))
                else if (_invoices.isEmpty)
                  const _EmptySales()
                else
                  ..._invoices.take(20).map((invoice) => Card(
                      child: ListTile(
                          leading: const CircleAvatar(
                              backgroundColor: BieLiTheme.softRose,
                              child: Icon(Icons.receipt,
                                  color: BieLiTheme.primaryCrimson)),
                          title: Text('فاتورة #${invoice['id']}'),
                          subtitle: Text(
                              '${invoice['customer_name']} • ${invoice['payment_method']}'),
                          trailing: Text(
                              '${(invoice['grand_total'] as num).toStringAsFixed(2)} ر.س',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))))),
              ])),
        ));
  }
}

class _Kpi extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _Kpi(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) => GlassCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(title,
            style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))
      ]));
}

class _EmptySales extends StatelessWidget {
  const _EmptySales();
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.all(35),
      child: Column(children: [
        Icon(Icons.bar_chart, size: 58, color: Colors.blueGrey),
        SizedBox(height: 10),
        Text('لا توجد مبيعات بعد'),
        Text('ستظهر الفواتير هنا بعد إتمام أول عملية بيع')
      ]));
}
