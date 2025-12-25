import 'package:flutter/material.dart';
import 'package:storyforge_frontend/services/chat_service.dart';
import 'screens/chat_screen.dart';

void main() {
  // Show which API URL is being used (helpful for debugging)
  ChatService.printCurrentEnvironment();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScenarioChat',
      debugShowCheckedModeBanner: false,  // Removes debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        useMaterial3: true,
      ),
      home: const ChatScreen(),  // Our chat screen
    );
  }
}