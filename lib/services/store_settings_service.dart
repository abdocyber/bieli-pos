
import 'package:shared_preferences/shared_preferences.dart';

class StoreSettingsService {
  static const _kStoreName = 'store_name';
  static const _kStorePhone = 'store_phone';
  static const _kStoreAddress = 'store_address';
  static const _kStoreTaxNum = 'store_tax_num';
  static const _kStoreFooter = 'store_footer';

  static Future<void> saveSettings({
    required String name,
    required String phone,
    required String address,
    required String taxNumber,
    required String footerNotes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStoreName, name);
    await prefs.setString(_kStorePhone, phone);
    await prefs.setString(_kStoreAddress, address);
    await prefs.setString(_kStoreTaxNum, taxNumber);
    await prefs.setString(_kStoreFooter, footerNotes);
  }

  static Future<Map<String, String>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_kStoreName) ?? 'متجر بِع لي التجاري',
      'phone': prefs.getString(_kStorePhone) ?? '0500000000',
      'address': prefs.getString(_kStoreAddress) ?? 'المملكة العربية السعودية',
      'taxNumber': prefs.getString(_kStoreTaxNum) ?? '300000000000003',
      'footer': prefs.getString(_kStoreFooter) ?? 'شكراً لزيارتكم • البضاعة المباعة ترد وتستبدل حسب الأنظمة',
    };
  }
}