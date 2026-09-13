import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'theme/glass_theme.dart';
import 'screens/pos_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/store_settings_screen.dart';
import 'screens/backup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة مشغل FFI لتشغيل قاعدة بيانات SQLite على أنظمة Windows و Linux بسلاسة
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const BieLiApp());
}

class BieLiApp extends StatelessWidget {
  const BieLiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بِع لي POS',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: BieLiTheme.themeData,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // شاشات التطبيق الأربع الرئيسية
  final List<Widget> _pages = const [
    PosScreen(),
    InventoryScreen(),
    StoreSettingsScreen(),
    BackupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: BieLiTheme.primaryCrimson.withValues(alpha: 0.18),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon:
                Icon(Icons.point_of_sale, color: BieLiTheme.primaryCrimson),
            label: 'البيع المباشر',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon:
                Icon(Icons.inventory_2, color: BieLiTheme.primaryCrimson),
            label: 'المخزن',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon:
                Icon(Icons.storefront, color: BieLiTheme.primaryCrimson),
            label: 'المتجر والطباعة',
          ),
          NavigationDestination(
            icon: Icon(Icons.security_outlined),
            selectedIcon:
                Icon(Icons.security, color: BieLiTheme.primaryCrimson),
            label: 'النسخ الاحتياطي',
          ),
        ],
      ),
    );
  }
}
