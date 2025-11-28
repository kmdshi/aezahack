import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoDropboxTheme {
  // Красная цветовая палитра
  static const Color primary = Color(0xFFF02024); // основной красный
  static const Color primaryLight = Color(0xFFFF5C5C); // светлый красный
  static const Color primaryDark = Color(0xFFB0001B); // тёмно-красный

  // iOS System Colors
  static const Color background = Color(0xFFFFFFFF); // чистый белый
  static const Color secondaryBackground = Color(0xFFF2F2F7); // iOS secondary
  static const Color tertiaryBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6C6C70);
  static const Color textTertiary = Color(0xFF6C6C70);

  // System Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);

  // Neutral Colors
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray600 = Color(0xFF525252);

  // Card and Surface Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFE5E5E5);

  // Typography
  static const TextStyle largeTitleStyle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.4,
    height: 1.12,
  );

  static const TextStyle title1Style = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.14,
  );

  static const TextStyle title2Style = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.18,
  );

  static const TextStyle title3Style = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.2,
  );

  static const TextStyle headlineStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.4,
    height: 1.29,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    letterSpacing: -0.4,
    height: 1.29,
  );

  static const TextStyle calloutStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.31,
  );

  static const TextStyle subheadlineStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.33,
  );

  static const TextStyle footnoteStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: -0.1,
    height: 1.38,
  );

  static const TextStyle caption1Style = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0,
    height: 1.33,
  );

  static const TextStyle caption2Style = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    letterSpacing: 0.1,
    height: 1.27,
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 1,
      offset: const Offset(0, 0),
    ),
  ];

  static List<BoxShadow> get elevatedCardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withOpacity(0.25),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  // Border Radius
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(10),
  );
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(16),
  );

  // Spacing
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing6 = 6;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: primaryLight,
      surface: cardBackground,
      background: background,
      onPrimary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimary,
    ),
    textTheme: const TextTheme(
      displayLarge: largeTitleStyle,
      displayMedium: title1Style,
      displaySmall: title2Style,
      headlineMedium: title3Style,
      headlineSmall: headlineStyle,
      titleLarge: headlineStyle,
      titleMedium: subheadlineStyle,
      titleSmall: footnoteStyle,
      bodyLarge: bodyStyle,
      bodyMedium: calloutStyle,
      bodySmall: caption1Style,
      labelLarge: headlineStyle,
      labelMedium: subheadlineStyle,
      labelSmall: caption2Style,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: headlineStyle.copyWith(color: Colors.white),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: cardRadius),
    ),
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 0.5,
      space: 1,
    ),
  );

  // Helper Methods
  static BoxDecoration cardDecoration({
    Color? backgroundColor,
    List<BoxShadow>? shadows,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? cardBackground,
      borderRadius: borderRadius ?? cardRadius,
      border: border ?? Border.all(color: cardBorder, width: 0.5),
      boxShadow: shadows ?? cardShadow,
    );
  }

  static BoxDecoration primaryButtonDecoration({bool isPressed = false}) {
    return BoxDecoration(
      color: isPressed ? primaryDark : primary,
      borderRadius: buttonRadius,
      boxShadow: isPressed ? [] : buttonShadow,
    );
  }

  static BoxDecoration secondaryButtonDecoration({bool isPressed = false}) {
    return BoxDecoration(
      color: isPressed ? gray100 : background,
      borderRadius: buttonRadius,
      border: Border.all(color: gray300, width: 0.5),
    );
  }
}
