// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/narrative_screen.dart';
import 'theme/storyforge_theme.dart';

void main() {
  runApp(
    // Wrap with ProviderScope for Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryForge',
      debugShowCheckedModeBanner: false,
      theme: StoryForgeTheme.lightTheme,
      home: const NarrativeScreen(),  // Use NarrativeScreen
    );
  }
}