import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales pour le thème clair uniquement
  static const Color lilacLight = Color(0xFFD8C2F3); // Lilas clair
  static const Color anisLight = Color(0xFFDCEDC2); // Anis clair
  static const Color textColor = Color(0xFF424242); // Texte en mode clair
  static const Color lightBackgroundColor = Color(0xFFFFFFF7); // Fond clair
  static const Color lightCardColor = Color(0xFFF5F5F5); // Cartes en mode clair

  // Couleurs pour le thème sombre
  static const Color lilacDark = Color(0xFFAF8DDF);
  static const Color anisDark = Color(0xFFBECE9D);
  static const Color darkTextColor = Color(0xFFEEEEEE);
  static const Color darkBackgroundColor = Color.fromRGBO(48, 48, 48, 1.0);
  static const Color darkCardColor = Color.fromARGB(255, 90, 90, 90);

  static ThemeData getLightTheme() {
    return ThemeData(
      primaryColor: lilacLight,
      colorScheme: ColorScheme.light(
        primary: lilacLight,
        secondary: anisLight,
        surface: lightCardColor,
        onPrimary: Colors.white,
        onSecondary: textColor,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: lilacLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: anisLight,
        foregroundColor: textColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lilacLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lilacLight,
          side: BorderSide(color: lilacLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return lilacLight;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: lilacLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      cardTheme: CardTheme(
        color: lightCardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: lightCardColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lilacLight, width: 2),
        ),
      ),
    );
  }

  // Thème sombre
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: lilacDark,
      colorScheme: ColorScheme.dark(
        primary: lilacDark,
        secondary: anisDark,
        surface: darkCardColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color.fromARGB(255, 132, 84, 128),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lilacDark,
        foregroundColor: darkTextColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lilacDark,
          foregroundColor: darkTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lilacDark,
          side: BorderSide(color: lilacDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return lilacDark;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(
          const Color.fromARGB(255, 70, 52, 52),
        ),
        side: BorderSide(color: const Color.fromARGB(255, 235, 229, 243)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      cardTheme: CardTheme(
        color: const Color.fromARGB(255, 219, 188, 222),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: darkCardColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lilacDark, width: 2),
        ),
        hintStyle: TextStyle(color: darkTextColor.withAlpha(60)),
      ),
      dividerColor: Colors.white12,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkCardColor,
        selectedItemColor: lilacDark,
        unselectedItemColor: darkTextColor.withAlpha(70),
      ),
      dialogTheme: DialogThemeData(backgroundColor: darkCardColor),
    );
  }
}
