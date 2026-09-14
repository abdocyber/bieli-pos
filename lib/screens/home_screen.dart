import 'package:flutter/material.dart';

import '../theme/glass_theme.dart';
import '../services/store_settings_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String> _settings = const {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await StoreSettingsService.getSettings();
    if (mounted) setState(() => _settings = settings);
  }

  @override
  Widget build(BuildContext context) {
    final storeName = _settings['name'] ?? 'متجر بِع لي التجاري';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _loadSettings,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 210,
                pinned: true,
                backgroundColor: BieLiTheme.darkNavy,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(storeName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [BieLiTheme.darkNavy, Color(0xFF3B1024)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: const Center(child: BieLiLogo(size: 88)),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text('مرحباً بك في بِع لي',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text('منصة ذكية لإدارة المبيعات والمخزون بكل سهولة',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Expanded(
                            child: _QuickMetric(
                                icon: Icons.point_of_sale,
                                title: 'المبيعات اليوم',
                                value: 'ابدأ الآن',
                                color: BieLiTheme.primaryCrimson)),
                        SizedBox(width: 10),
                        Expanded(
                            child: _QuickMetric(
                                icon: Icons.inventory_2,
                                title: 'إدارة المنتجات',
                                value: 'مخزن متكامل',
                                color: BieLiTheme.emeraldGreen)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      tintColor: const Color(0xFFFFF7F8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: BieLiTheme.primaryCrimson
                                  .withValues(alpha: .12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome,
                                color: BieLiTheme.primaryCrimson),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('صُمم لك باحتراف',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17)),
                                SizedBox(height: 5),
                                Text(
                                    'تجربة عربية عصرية من تطوير فريق BieLi لتناسب المتاجر الصغيرة والمتوسطة.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('وصول سريع',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    const Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _FeatureChip(
                            icon: Icons.receipt_long, label: 'فواتير احترافية'),
                        _FeatureChip(
                            icon: Icons.category, label: 'تصنيفات متنوعة'),
                        _FeatureChip(
                            icon: Icons.bar_chart, label: 'تقارير المبيعات'),
                        _FeatureChip(
                            icon: Icons.cloud_done, label: 'نسخ احتياطي آمن'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('BieLi POS • إصدار 1.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blueGrey)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _QuickMetric(
      {required this.icon,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.blueGrey)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      );
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 18, color: BieLiTheme.primaryCrimson),
        label: Text(label),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        backgroundColor: Colors.white,
      );
}
