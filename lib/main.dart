import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KollektivoApp());
}

/// Root widget for the KollektivO application.
class KollektivoApp extends StatefulWidget {
  const KollektivoApp({super.key});

  @override
  State<KollektivoApp> createState() => _KollektivoAppState();
}

class _KollektivoAppState extends State<KollektivoApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _updateThemeMode(ThemeMode newMode) {
    setState(() {
      _themeMode = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KollektivO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: LoginScreen(
        currentThemeMode: _themeMode,
        onThemeModeChanged: _updateThemeMode,
      ),
    );
  }
}
