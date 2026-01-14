import 'package:flutter/material.dart';
import '../models/character_info.dart';
import '../theme/tokens/colors.dart';
import '../widgets/character_card.dart';

class CharacterSelectionScreen extends StatelessWidget {
  final String storyId;

  const CharacterSelectionScreen({
    super.key,
    required this.storyId,
  });

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
            colors: DesignColors.appGradient,
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
                      ? SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildCharacterCards(context),
                    ),
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
    final storyCharacters = CharacterInfo.forStory(storyId);

    return storyCharacters.map((character) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: CharacterCard(
          character: character,
          onSelect: () => _handleCharacterSelection(context, character),
        ),
      );
    }).toList();
  }

  void _handleCharacterSelection(BuildContext context, CharacterInfo character) {
    print('🎭 User selected: ${character.name} (ID: ${character.id})');

    // Return the selected character ID to HomeScreen
    // HomeScreen will handle navigation to NarrativeScreen
    Navigator.pop(context, character.id);
  }
}