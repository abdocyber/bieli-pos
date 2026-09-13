import 'package:flutter/material.dart';

class StoreSettingsScreen extends StatelessWidget {
  const StoreSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المتجر والطباعة')),
        body: const Center(child: Text('إعدادات المتجر والطباعة')),
      ),
    );
  }
}
