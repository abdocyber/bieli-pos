import 'package:flutter/material.dart';

import '../services/store_settings_service.dart';
import '../theme/glass_theme.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});
  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _tax = TextEditingController();
  final _footer = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StoreSettingsService.getSettings();
    _name.text = data['name'] ?? '';
    _phone.text = data['phone'] ?? '';
    _address.text = data['address'] ?? '';
    _tax.text = data['taxNumber'] ?? '';
    _footer.text = data['footer'] ?? '';
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _tax, _footer]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await StoreSettingsService.saveSettings(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        taxNumber: _tax.text.trim(),
        footerNotes: _footer.text.trim());
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ تفاصيل المتجر بنجاح')));
    }
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
          {int lines = 1}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
              controller: controller,
              maxLines: lines,
              decoration:
                  InputDecoration(labelText: label, prefixIcon: Icon(icon))));

  @override
  Widget build(BuildContext context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(title: const Text('تفاصيل المتجر والهوية')),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            const Center(
                child: Column(children: [
              BieLiLogo(size: 82),
              SizedBox(height: 10),
              Text('هوية بِع لي',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('يظهر الشعار في واجهة التطبيق والفواتير',
                  style: TextStyle(color: Colors.blueGrey))
            ])),
            const SizedBox(height: 20),
            GlassCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Text('بيانات المتجر',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 14),
                  _field(_name, 'اسم المتجر', Icons.storefront),
                  _field(_phone, 'رقم الجوال', Icons.phone),
                  _field(_address, 'العنوان', Icons.location_on, lines: 2),
                  _field(_tax, 'الرقم الضريبي', Icons.badge),
                  _field(_footer, 'ملاحظة أسفل الفاتورة', Icons.notes, lines: 2)
                ])),
            const SizedBox(height: 16),
            FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label: Text(_saving ? 'جارٍ الحفظ...' : 'حفظ تفاصيل المتجر')),
            const SizedBox(height: 18),
            const Text(
                'نصيحة: أدخل البيانات النظامية بدقة لتظهر في الفواتير المطبوعة.',
                style: TextStyle(color: Colors.blueGrey),
                textAlign: TextAlign.center),
          ])));
}
