// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/storyforge_theme.dart';

void main() {
  runApp(
    // Wrap with ProviderScope for Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode from provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'StoryForge',
      debugShowCheckedModeBanner: false,
      // Theme configuration
      theme: StoryForgeTheme.lightTheme,
      darkTheme: StoryForgeTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
      routes: {
        '/tasks': (context) => const TasksScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
