import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== خلفية بيضاء فاتحة =====
  static const Color bgLight     = Color(0xFFF5F5F5);
  static const Color bgWhite     = Color(0xFFFFFFFF);
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceAlt  = Color(0xFFF8F8F8);

  // ===== أحمر فودافون =====
  static const Color redVF       = Color(0xFFE60000);
  static const Color redDark     = Color(0xFFB30000);
  static const Color redLight    = Color(0xFFFF6B6B);
  static const Color redPale     = Color(0xFFFFE5E5);

  // ===== ذهبي (لللمسات) =====
  static const Color gold        = Color(0xFFD4A843);
  static const Color goldLight   = Color(0xFFF5E6C8);
  static const Color goldDark    = Color(0xFF9A7B2C);

  // ===== نصوص =====
  static const Color black       = Color(0xFF1A1A1A);
  static const Color greyDark    = Color(0xFF4A4A4A);
  static const Color grey        = Color(0xFF888888);
  static const Color greyLight   = Color(0xFFE0E0E0);
  static const Color greyBg      = Color(0xFFF0F0F0);

  // ===== إشعار =====
  static const Color warningBg   = Color(0xFFFFF8E1);
  static const Color warningText = Color(0xFFB8860B);
  static const Color warningIcon = Color(0xFFD4A843);

  // ===== Gradients =====
  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFE60000), Color(0xFFB30000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFE60000), Color(0xFFCC0000)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient shimmerRed({double t = 0}) => LinearGradient(
    colors: const [redVF, redLight, redVF, redDark, redVF],
    stops: [
      0.0,
      (t - 0.15).clamp(0.0, 1.0),
      t.clamp(0.0, 1.0),
      (t + 0.15).clamp(0.0, 1.0),
      1.0,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ===== كارت أبيض =====
  static BoxDecoration whiteCard({double radius = 16}) => BoxDecoration(
    color: bgWhite,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: greyLight.withOpacity(0.5),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );

  // ===== كارت أحمر (للكروت) =====
  static BoxDecoration redCard({double radius = 16}) => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(color: redVF.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
    ],
  );

  // ===== حقل إدخال =====
  static BoxDecoration inputField({bool focused = false}) => BoxDecoration(
    color: bgWhite,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: focused ? redVF : greyLight,
      width: focused ? 1.5 : 1,
    ),
  );

  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    colorScheme: const ColorScheme.light(
      primary: redVF,
      secondary: gold,
      surface: surface,
      onPrimary: Colors.white,
      onSurface: black,
    ),
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: black,
      displayColor: black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bgWhite,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.cairo(
        color: black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: redLight,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: greyLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: greyLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: redVF, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: GoogleFonts.cairo(color: grey),
    ),
  );

  static ThemeData get darkTheme => theme;
}

/// حدود بتدرج لوني
class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;
  const GradientBoxBorder({required this.gradient, this.width = 1});

  @override
  BorderSide get bottom => BorderSide.none;
  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection, BoxShape shape = BoxShape.rectangle, BorderRadius? borderRadius}) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    if (shape == BoxShape.circle) {
      canvas.drawCircle(rect.center, rect.shortestSide / 2 - width / 2, paint);
    } else {
      final RRect rrect = (borderRadius ?? BorderRadius.zero)
          .toRRect(rect)
          .deflate(width / 2);
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  ShapeBorder scale(double t) => this;

  @override
  BoxBorder add(ShapeBorder other, {bool reversed = false}) => this;
}
