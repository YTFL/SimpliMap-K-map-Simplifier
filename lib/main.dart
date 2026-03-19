
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simplimap/state/kmap_provider.dart';
import 'package:simplimap/screens/solver_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => KMapProvider(),
      child: const SimpliMapApp(),
    ),
  );
}

class SimpliMapApp extends StatefulWidget {
  const SimpliMapApp({super.key});

  @override
  State<SimpliMapApp> createState() => _SimpliMapAppState();
}

class _SimpliMapAppState extends State<SimpliMapApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseLightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0F8B8D),
        brightness: Brightness.light,
      ),
    );

    final baseDarkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF53CFB0),
        brightness: Brightness.dark,
      ),
    );

    final lightTextTheme = GoogleFonts.spaceGroteskTextTheme(baseLightTheme.textTheme).copyWith(
      titleLarge: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700),
      bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w500),
      bodySmall: GoogleFonts.ibmPlexMono(fontSize: 12, fontWeight: FontWeight.w500),
    );

    final darkTextTheme = GoogleFonts.spaceGroteskTextTheme(baseDarkTheme.textTheme).copyWith(
      titleLarge: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700),
      bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w500),
      bodySmall: GoogleFonts.ibmPlexMono(fontSize: 12, fontWeight: FontWeight.w500),
    );

    final lightTheme = baseLightTheme.copyWith(
      textTheme: lightTextTheme,
      scaffoldBackgroundColor: const Color(0xFFF5FAF8),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF113230),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: lightTextTheme.titleLarge?.copyWith(color: const Color(0xFF113230)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.86),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.teal.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.teal.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0F8B8D), width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0F8B8D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF113230),
          side: BorderSide(color: Colors.teal.shade200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );

    final darkTheme = baseDarkTheme.copyWith(
      textTheme: darkTextTheme,
      scaffoldBackgroundColor: const Color(0xFF071A1A),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFE9FCF5),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: darkTextTheme.titleLarge?.copyWith(color: const Color(0xFFE9FCF5)),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0F2A2A).withValues(alpha: 0.88),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF133535),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2D6565)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2D6565)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF53CFB0), width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF3BB89A),
          foregroundColor: const Color(0xFF03201E),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD8FFF4),
          side: const BorderSide(color: Color(0xFF2F6F67)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );

    return MaterialApp(
      title: 'SimpliMap',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Duration.zero,
      themeAnimationCurve: Curves.linear,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: SolverScreen(
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleThemeMode,
      ),
    );
  }
}
