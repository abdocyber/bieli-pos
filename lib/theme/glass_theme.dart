import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BieLiTheme {
  static const primaryCrimson = Color(0xFFE11D48);
  static const darkNavy = Color(0xFF0F172A);
  static const emeraldGreen = Color(0xFF059669);
  static const softRose = Color(0xFFFFF1F2);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCrimson,
        primary: primaryCrimson,
        secondary: emeraldGreen,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkNavy,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryCrimson.withValues(alpha: .14),
        labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.bold)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: .06))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryCrimson, width: 1.4)),
      ),
      textTheme: TextTheme(
        headlineSmall:
            GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 20),
        titleLarge:
            GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        titleMedium:
            GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
        bodyMedium:
            GoogleFonts.tajawal(fontWeight: FontWeight.w500, fontSize: 14),
        bodySmall: GoogleFonts.tajawal(fontSize: 12),
      ),
    );
  }
}

class BieLiLogo extends StatelessWidget {
  final double size;
  const BieLiLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF4770),
            BieLiTheme.primaryCrimson,
            Color(0xFF8F1239)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: BieLiTheme.primaryCrimson.withValues(alpha: .65),
              blurRadius: 22,
              spreadRadius: 3),
          const BoxShadow(
              color: Colors.white24, blurRadius: 4, offset: Offset(-3, -3)),
        ],
        border:
            Border.all(color: Colors.white.withValues(alpha: .62), width: 2),
      ),
      child: Center(
        child: Text(
          'Bi',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * .42,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
            shadows: const [
              Shadow(color: Colors.black38, blurRadius: 5, offset: Offset(2, 3))
            ],
          ),
        ),
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

  const GlassCard(
      {super.key,
      required this.child,
      this.borderRadius = 16,
      this.padding = const EdgeInsets.all(14),
      this.tintColor,
      this.onTap});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: (tintColor ?? Colors.white).withValues(alpha: .86),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                    color: Colors.white.withValues(alpha: .72), width: 1.2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ],
              ),
              child: child,
            ),
          ),
        ),
      );
}
