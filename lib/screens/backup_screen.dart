import 'package:flutter/material.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('النسخ الاحتياطي')),
        body: Center(child: Text('النسخ الاحتياطي')),
      ),
    );
  }
}
