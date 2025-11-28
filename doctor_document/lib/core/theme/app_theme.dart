import 'package:flutter/material.dart';

class AppTheme {
  // Полностью красная цветовая палитра
  static const Color primaryDark = Color(
    0xFF600000,
  ); // тёмно-красный вместо синего
  static const Color secondaryDark = Color(
    0xFF8B0000,
  ); // чуть светлее для градиента
  static const Color accentRed = Color(0xFFF02024); // основной акцент
  static const Color accentPink = Color(
    0xFFFF5C5C,
  ); // светлый акцент для градиента
  static const Color cardBackground = Color(0xFF700000); // фон карточек
  static const Color surfaceColor = Color(0xFF800000); // для поверхностей
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFDDDDDD);
  static const Color borderColor = Color(0xFF990000);

  // Градиенты
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, secondaryDark],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentRed, accentPink],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentRed, Color(0xFFB22222)], // второстепенный красный градиент
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardBackground, surfaceColor],
  );

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: primaryDark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentRed,
      brightness: Brightness.dark,
      primary: accentRed,
      secondary: accentPink,
      surface: cardBackground,
      background: primaryDark,
      onPrimary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentRed, // кнопки красные
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerTheme: DividerThemeData(color: borderColor, thickness: 1),
  );

  // Стеклянный эффект
  static BoxDecoration glassEffect({Color? color, BorderRadius? borderRadius}) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(0.1),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    );
  }

  // Градиентный контейнер
  static Container gradientContainer({
    required Widget child,
    LinearGradient? gradient,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? primaryGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? accentRed).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
