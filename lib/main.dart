import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/tts_controller.dart';
import 'theme/liquid_glass_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final ttsController = TtsController();
  await ttsController.initialize();

  runApp(RepeatSpeakerApp(ttsController: ttsController));
}

class RepeatSpeakerApp extends StatefulWidget {
  final TtsController ttsController;

  const RepeatSpeakerApp({super.key, required this.ttsController});

  @override
  State<RepeatSpeakerApp> createState() => _RepeatSpeakerAppState();
}

class _RepeatSpeakerAppState extends State<RepeatSpeakerApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    // Restore persistent theme mode (light by default for the new pearlescent Liquid Glass UI)
    final savedMode = StorageService.getThemeMode(defaultMode: 'light');
    _themeMode = savedMode == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
    StorageService.saveThemeMode(
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  @override
  void dispose() {
    widget.ttsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repeat Speaker',
      debugShowCheckedModeBanner: false,
      theme: LiquidGlassTheme.getLightTheme(),
      darkTheme: LiquidGlassTheme.getDarkTheme(),
      themeMode: _themeMode,
      home: HomeScreen(
        ttsController: widget.ttsController,
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}
