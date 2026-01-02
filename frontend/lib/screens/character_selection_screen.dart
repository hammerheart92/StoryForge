import 'package:flutter/material.dart';
import '../models/character_info.dart';

class CharacterSelectionScreen extends StatelessWidget {
  const CharacterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Your Guide',
          style: TextStyle(
            fontFamily: 'Merriweather',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF121417),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  return isMobile
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildCharacterCards(context),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildCharacterCards(context),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCharacterCards(BuildContext context) {
    return CharacterInfo.all.map((character) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: _buildPlaceholderCard(character),
      );
    }).toList();
  }

  Widget _buildPlaceholderCard(CharacterInfo character) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Color(0xFF23272C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: character.accentColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(character.icon, size: 80, color: character.accentColor),
            SizedBox(height: 16),
            Text(
              character.name,
              style: TextStyle(
                fontFamily: 'Merriweather',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}