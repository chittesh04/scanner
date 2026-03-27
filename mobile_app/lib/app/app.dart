import 'package:flutter/material.dart';
import 'package:smartscan/features/document/presentation/document_list_page.dart';

class SmartScanApp extends StatelessWidget {
  const SmartScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF4F46E5);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      contrastLevel: 0.3,
    );

    return MaterialApp(
      title: 'SmartScan',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: const Duration(milliseconds: 250),
      themeAnimationCurve: Curves.easeOutCubic,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFF000000), // OLED Black
        canvasColor: const Color(0xFF000000), // OLED Black
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
          centerTitle: false,
        ),
        textTheme: Typography.whiteMountainView.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF111111), // Dark enough for OLED contrast
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
        ),
        iconTheme: IconThemeData(
          color: scheme.onSurfaceVariant,
          size: 22,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF151A2A),
          hintStyle: TextStyle(color: scheme.onSurfaceVariant),
          prefixIconColor: scheme.onSurfaceVariant,
          suffixIconColor: scheme.onSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.primary, width: 1.4),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF1A1F32),
          selectedColor: scheme.primary.withValues(alpha: 0.28),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          labelStyle: TextStyle(color: scheme.onSurface),
          secondaryLabelStyle: TextStyle(color: scheme.onSurface),
          brightness: Brightness.dark,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF171C2C),
            foregroundColor: scheme.onSurface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minVerticalPadding: 10,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF181D2D),
          contentTextStyle: TextStyle(color: scheme.onSurface),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const DocumentListPage(),
    );
  }
}
