import 'package:flutter/material.dart';
import 'package:smartscan/features/document/presentation/document_list_page.dart';

class SmartScanApp extends StatelessWidget {
  const SmartScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0EA5E9);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      contrastLevel: 0.25,
    ).copyWith(
      surface: const Color(0xFF0B1220),
      surfaceContainer: const Color(0xFF111C30),
      surfaceContainerHighest: const Color(0xFF17253E),
      primary: const Color(0xFF22D3EE),
      secondary: const Color(0xFF38BDF8),
      tertiary: const Color(0xFFFB7185),
    );

    return MaterialApp(
      title: 'SmartScan',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeOutCubic,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF040814),
        canvasColor: const Color(0xFF040814),
        fontFamily: 'Roboto',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          },
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: scheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: scheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
              displayLarge: const TextStyle(fontWeight: FontWeight.w800),
              displayMedium: const TextStyle(fontWeight: FontWeight.w800),
              headlineLarge: const TextStyle(fontWeight: FontWeight.w700),
              titleLarge: const TextStyle(fontWeight: FontWeight.w700),
              titleMedium: const TextStyle(fontWeight: FontWeight.w600),
              bodyLarge: const TextStyle(height: 1.3),
              bodyMedium: const TextStyle(height: 1.3),
            ),
        cardTheme: CardThemeData(
          color: scheme.surfaceContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side:
                BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerHighest,
          hintStyle: TextStyle(color: scheme.onSurfaceVariant),
          prefixIconColor: scheme.onSurfaceVariant,
          suffixIconColor: scheme.onSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.35)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
        iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            backgroundColor: scheme.surfaceContainer,
            foregroundColor: scheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: const TextStyle(
                fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: scheme.surfaceContainerHighest,
          contentTextStyle: TextStyle(color: scheme.onSurface),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const DocumentListPage(),
    );
  }
}
