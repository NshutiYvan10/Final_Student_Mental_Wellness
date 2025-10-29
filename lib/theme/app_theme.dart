import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'messaging_theme.dart'; // <-- Import the MessagingTheme extension

class AppTheme {
  // Design tokens aligned with previous project (todo_app)
  static const Color primaryColor = Color(0xFF6366F1); // Indigo 500
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple 500
  static const Color accentColor = Color(0xFF06B6D4); // Cyan 500
  static const Color successColor = Color(0xFF10B981); // Emerald 500
  static const Color warningColor = Color(0xFFF59E0B); // Amber 500
  static const Color errorColor = Color(0xFFEF4444); // Red 500

  // Subtle, calm scaffold background
  static const Color softBg = Color(0xFFF8FAFC); // Slate 50 (Light Mode)
  static const Color darkBg = Color(0xFF0F172A); // Slate 900 (Dark Mode)
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800 (Dark Mode Surface)

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: Colors.white, // Pure white for cards/surfaces
      background: softBg, // Soft background
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1E293B), // Dark text on light surfaces (Slate 800)
      onBackground: const Color(0xFF0F172A), // Darker text on background (Slate 900)
      onError: Colors.white,
      surfaceVariant: const Color(0xFFF1F5F9), // Lighter surface variant (Slate 100)
      outline: const Color(0xFFCBD5E1), // Outline color (Slate 300)
    );
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: softBg, // Use soft background
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme)
          .copyWith(
        // Use Poppins for Headers/Titles, Inter for Body/Labels
        displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: colorScheme.onBackground),
        displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: colorScheme.onBackground),
        displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: colorScheme.onBackground),
        headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onBackground),
        headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onBackground),
        headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        bodyLarge: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.9)),
        bodyMedium: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.8)),
        bodySmall: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.7)),
        labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colorScheme.primary), // Often used in buttons
        labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colorScheme.onSurface.withOpacity(0.6)),
      )
          .apply( // Ensure base colors are applied
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onBackground),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: false, // Align title left typically
        elevation: 0,
        backgroundColor: Colors.transparent, // Allow background color to show through
        foregroundColor: colorScheme.onBackground, // Dark text for title/icons
        titleTextStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20, // Adjust size as needed
            color: colorScheme.onBackground),
      ),
      // *** CORRECTED THIS LINE ***
      cardTheme: CardThemeData( // Use CardThemeData constructor
        elevation: 1, // Subtle elevation
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.white, // Prevent tinting on Material 3
        shadowColor: Colors.black.withOpacity(0.05), // Softer shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Consistent rounding
        ),
        color: Colors.white, // Card background
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant, // Use surface variant (e.g., Slate 100)
        hintStyle: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)), // Subtle border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)), // Subtle border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5), // Highlight focused
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Adjust padding
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1, // Subtle elevation
          shadowColor: colorScheme.primary.withOpacity(0.2),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20), // Adjusted padding
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          )
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          )
      ),
      filledButtonTheme: FilledButtonThemeData( // For secondary actions if needed
        style: FilledButton.styleFrom(
          elevation: 1,
          shadowColor: colorScheme.secondary.withOpacity(0.2),
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white, // Clean background for nav bar
        elevation: 2, // Slight elevation to separate
        indicatorColor: colorScheme.primary.withOpacity(0.1), // Subtle indicator background
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final color = states.contains(MaterialState.selected) ? colorScheme.primary : colorScheme.outline.withOpacity(0.8);
          return IconThemeData(color: color, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states){
          final color = states.contains(MaterialState.selected) ? colorScheme.primary : colorScheme.outline.withOpacity(0.8);
          final weight = states.contains(MaterialState.selected) ? FontWeight.w700 : FontWeight.w500;
          return GoogleFonts.inter(fontSize: 11, fontWeight: weight, color: color);
        }),

      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded chips
        backgroundColor: colorScheme.primary.withOpacity(0.1),
        labelStyle: GoogleFonts.inter(color: colorScheme.primary, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide.none, // No border needed with background color
      ),
      dividerTheme: DividerThemeData( // Style for dividers
        color: colorScheme.outline.withOpacity(0.5),
        thickness: 1,
        space: 1, // Minimal space occupied by the divider itself
      ),
      // --- ADD MESSAGING THEME EXTENSION ---
      extensions: const <ThemeExtension<dynamic>>[
        MessagingTheme.light,
      ],
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.dark(
      primary: primaryColor, // Keep primary vibrant
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: darkSurface, // Use specific dark surface (Slate 800)
      background: darkBg, // Use specific dark background (Slate 900)
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFE2E8F0), // Light text on dark surfaces (Slate 200)
      onBackground: const Color(0xFFF8FAFC), // Brighter text on main background (Slate 50)
      onError: Colors.white,
      surfaceVariant: const Color(0xFF334155), // Darker surface variant (Slate 700)
      outline: const Color(0xFF475569), // Outline color (Slate 600)
    );
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBg, // Use dark background
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme)
          .copyWith(
        // Copy styles from light theme, adjust colors
        displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: colorScheme.onBackground),
        displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: colorScheme.onBackground),
        displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: colorScheme.onBackground),
        headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onBackground),
        headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onBackground),
        headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        bodyLarge: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.9)),
        bodyMedium: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.8)),
        bodySmall: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.7)),
        labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colorScheme.primary), // Keep primary color for button text if needed
        labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, color: colorScheme.onSurface.withOpacity(0.6)),
      )
          .apply( // Ensure base colors are applied
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onBackground),
      appBarTheme: base.appBarTheme.copyWith(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground, // Light text for title/icons
        titleTextStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: colorScheme.onBackground),
      ),
      // *** CORRECTED THIS LINE ***
      cardTheme: CardThemeData( // Use CardThemeData constructor
        elevation: 1, // Keep subtle elevation
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        surfaceTintColor: darkSurface, // Prevent tinting
        shadowColor: Colors.black.withOpacity(0.2), // Slightly more visible shadow in dark mode
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outline.withOpacity(0.3)) // Subtle border in dark mode
        ),
        color: darkSurface, // Card background (Slate 800)
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBg, // Use main dark background for contrast (Slate 900)
        hintStyle: GoogleFonts.inter(color: colorScheme.onSurface.withOpacity(0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline), // Use outline color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Keep button themes similar, relying on ColorScheme for onPrimary etc.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          shadowColor: colorScheme.primary.withOpacity(0.3),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary, // Keep primary color outline/text
            side: BorderSide(color: colorScheme.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          )
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary, // Keep primary color text
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          )
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 1,
          shadowColor: colorScheme.secondary.withOpacity(0.3),
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface, // Use dark surface for nav bar
        elevation: 2,
        indicatorColor: colorScheme.primary.withOpacity(0.15), // Slightly more visible indicator
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final color = states.contains(MaterialState.selected) ? colorScheme.primary : colorScheme.outline.withOpacity(0.9);
          return IconThemeData(color: color, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states){
          final color = states.contains(MaterialState.selected) ? colorScheme.primary : colorScheme.outline.withOpacity(0.9);
          final weight = states.contains(MaterialState.selected) ? FontWeight.w700 : FontWeight.w500;
          return GoogleFonts.inter(fontSize: 11, fontWeight: weight, color: color);
        }),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.primary.withOpacity(0.15), // Slightly brighter background
        labelStyle: GoogleFonts.inter(color: colorScheme.primary, fontWeight: FontWeight.w600), // Keep primary label
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.3)), // Add subtle border in dark
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.7), // Use outline color
        thickness: 1,
        space: 1,
      ),
      // --- ADD MESSAGING THEME EXTENSION ---
      extensions: const <ThemeExtension<dynamic>>[
        MessagingTheme.dark,
      ],
    );
  }
}