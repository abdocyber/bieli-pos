import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BieLiTheme {
  static const primaryCrimson = Color(0xFFE11D48);
  static const darkNavy = Color(0xFF0F172A);
  static const emeraldGreen = Color(0xFF059669);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      textTheme: TextTheme(
        headlineSmall:
            GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium:
            GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
        bodyMedium:
            GoogleFonts.tajawal(fontWeight: FontWeight.w500, fontSize: 14),
        bodySmall: GoogleFonts.tajawal(fontSize: 12),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? tintColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(14),
    this.tintColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (tintColor ?? Colors.white).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
