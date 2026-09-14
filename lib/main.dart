import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/admin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/store_settings_screen.dart';
import 'theme/glass_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const BieLiApp());
}

class BieLiApp extends StatelessWidget {
  const BieLiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
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

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});
  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    HomeScreen(),
    PosScreen(),
    InventoryScreen(),
    AdminScreen(),
    StoreSettingsScreen()
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon:
                    Icon(Icons.home, color: BieLiTheme.primaryCrimson),
                label: 'الرئيسية'),
            NavigationDestination(
                icon: Icon(Icons.point_of_sale_outlined),
                selectedIcon:
                    Icon(Icons.point_of_sale, color: BieLiTheme.primaryCrimson),
                label: 'المبيعات'),
            NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon:
                    Icon(Icons.inventory_2, color: BieLiTheme.primaryCrimson),
                label: 'المخزن'),
            NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings,
                    color: BieLiTheme.primaryCrimson),
                label: 'الإدارة'),
            NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon:
                    Icon(Icons.storefront, color: BieLiTheme.primaryCrimson),
                label: 'المتجر'),
          ],
        ),
      );
}
