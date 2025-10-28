import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login_selection_page.dart';
import 'pages/login_page.dart';
import 'pages/login_type_selection_page.dart';
import 'pages/org_registration_page.dart';
import 'pages/db_test_page.dart';
import 'pages/home_page.dart';
import 'pages/list_page.dart';
import 'utils/constants.dart';
import 'utils/supabase_service.dart';
import 'pages/profile_page.dart';
import 'utils/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.initialize(
      url: 'https://gvkrathyuspuvoofkhqm.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd2a3JhdGh5dXNwdXZvb2ZraHFtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAxNDQ5ODQsImV4cCI6MjA3NTcyMDk4NH0.Oaj0l9oDz-wYz5QmVX3urJhixVyPqOtXW_W9ltBuFeM',
    ).timeout(const Duration(seconds: 6));
  } catch (e) {
    debugPrint('Supabase init failed: ' + e.toString());
  }
  runApp(CareConnectApp());
}

class CareConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, themeMode, _) => MaterialApp(
        title: 'Care Connect',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          brightness: Brightness.light,
        ).copyWith(
          background: kAccent, // soft page background (pink variant)
          surface: Colors.white,
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: kAccent,
        canvasColor: Colors.white,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.black,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius),
          ),
        ),
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius),
          ),
          iconColor: kPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimary,
            side: BorderSide(color: kPrimary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kPrimary),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFFFE4EC),
          selectedColor: kPrimary.withOpacity(0.15),
          disabledColor: Colors.grey.shade200,
          secondarySelectedColor: kPrimary.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          labelStyle: const TextStyle(fontSize: 13),
          secondaryLabelStyle: const TextStyle(fontSize: 13),
          brightness: Brightness.light,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return kPrimary;
            return Colors.grey.shade400;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return kPrimary;
            return Colors.grey.shade500;
          }),
        ),
        switchTheme: SwitchThemeData(
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return kPrimary.withOpacity(0.5);
            return Colors.grey.shade300;
          }),
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return kPrimary;
            return Colors.grey.shade400;
          }),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: kPrimary,
          inactiveTrackColor: Color(0xFFFFE4EC),
          thumbColor: kPrimary,
          overlayColor: Color(0x33FF5A8F),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFF1F5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadius),
            borderSide: BorderSide.none,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(kRadius)),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: kPrimary,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0F12),
          cardTheme: const CardThemeData(
            elevation: 0,
          ),
          chipTheme: const ChipThemeData(
            backgroundColor: Color(0x33FFFFFF),
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
        home: SplashScreen(),
        routes: {
        '/loginSelect': (_) => LoginSelectionPage(),
        '/login': (_) => LoginPage(),
        '/loginType': (_) => LoginTypeSelectionPage(),
        '/orgRegister': (_) => OrgRegistrationPage(),
        '/home': (_) => HomePage(),
        '/list': (_) => ListPage(),
        '/dbtest': (_) => DbTestPage(),
        '/profile': (_) => const ProfilePage(),
        },
      ),
    );
  }
}
