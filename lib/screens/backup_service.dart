import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import 'store_settings_service.dart';

class BackupService {
  static Future<String?> createBackup({bool shareDirectly = false}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final dbPath = db.path;
      final settings = await StoreSettingsService.getSettings();

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFileName = 'BieLi_Backup_$timestamp.bieli';
      final backupFile = File(join(tempDir.path, backupFileName));

      final dbBytes = await File(dbPath).readAsBytes();
      final dbBase64 = base64Encode(dbBytes);

      final backupPayload = {
        'version': 1,
        'app_name': 'BieLi POS',
        'created_at': DateTime.now().toIso8601String(),
        'store_settings': settings,
        'database_blob': dbBase64,
      };

      await backupFile.writeAsString(jsonEncode(backupPayload));

      if (shareDirectly) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(backupFile.path)],
            text: 'النسخة الاحتياطية الشاملة لنظام بـِـع لي - $timestamp',
          ),
        );
        return backupFile.path;
      } else {
        final backupBytes = await backupFile.readAsBytes();
        final output = await FilePicker.saveFile(
          dialogTitle: 'اختر مكان حفظ النسخة الاحتياطية',
          fileName: backupFileName,
          bytes: backupBytes,
          type: FileType.custom,
          allowedExtensions: ['bieli'],
        );

        if (output != null) {
          return output.toFilePath();
        }
      }
      return backupFile.path;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> restoreBackup() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'حدد ملف النسخة الاحتياطية (.bieli)',
        type: FileType.any,
      );

      if (result.isEmpty || result.single.path == null) {
        return false;
      }

      final file = File(result.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      if (data['app_name'] != 'BieLi POS' || data['database_blob'] == null) {
        return false;
      }

      if (data['store_settings'] != null) {
        final s = Map<String, String>.from(data['store_settings']);
        await StoreSettingsService.saveSettings(
          name: s['name'] ?? '',
          phone: s['phone'] ?? '',
          address: s['address'] ?? '',
          taxNumber: s['taxNumber'] ?? '',
          footerNotes: s['footer'] ?? '',
        );
      }

      final db = await DatabaseHelper.instance.database;
      final dbPath = db.path;
      await db.close();

      final rawBytes = base64Decode(data['database_blob']);
      await File(dbPath).writeAsBytes(rawBytes, flush: true);

      return true;
    } catch (e) {
      return false;
    }
  }
}
