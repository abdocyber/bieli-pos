import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bieli_pos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbDir = await getApplicationDocumentsDirectory();
    final path = join(dbDir.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        barcode TEXT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        unit TEXT NOT NULL DEFAULT 'قطعة',
        retail_price REAL NOT NULL,
        wholesale_price REAL NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        min_stock_alert INTEGER NOT NULL DEFAULT 3
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT,
        invoice_type TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        subtotal REAL NOT NULL,
        tax REAL NOT NULL,
        grand_total REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        unit TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> processSale({
    required String customerName,
    required String invoiceType,
    required String paymentMethod,
    required double subtotal,
    required double tax,
    required double grandTotal,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      final invoiceId = await txn.insert('invoices', {
        'customer_name': customerName.isEmpty ? 'عميل نقدي' : customerName,
        'invoice_type': invoiceType,
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'tax': tax,
        'grand_total': grandTotal,
        'created_at': DateTime.now().toIso8601String(),
      });

      for (var item in items) {
        await txn.insert('invoice_items', {
          'invoice_id': invoiceId,
          'product_id': item['id'],
          'product_name': item['name'],
          'unit': item['unit'],
          'quantity': item['quantity'],
          'unit_price': item['price'],
          'total_price': item['subtotal'],
        });

        await txn.rawUpdate('''
          UPDATE products 
          SET stock = stock - ? 
          WHERE id = ?
        ''', [item['quantity'], item['id']]);
      }

      return invoiceId;
    });
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await instance.database;
    return await db.query('products', orderBy: 'name ASC');
  }

  Future<int> insertProduct(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('products', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateProduct(String id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update('products', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(String id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    final db = await instance.database;
    return await db.query('invoices', orderBy: 'id DESC');
  }
}