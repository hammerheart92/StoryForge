// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storyforge_frontend/providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
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
    // Watch auth state
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'StoryForge',
      debugShowCheckedModeBanner: false,
      // Theme configuration
      theme: StoryForgeTheme.lightTheme,
      darkTheme: StoryForgeTheme.darkTheme,
      themeMode: themeMode,
      // Initial route based on auth state
      home: authState.isAuthenticated
          ? const HomeScreen()  // Your actual home screen widget
          : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/tasks': (context) => const TasksScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
