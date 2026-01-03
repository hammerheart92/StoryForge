import 'package:flutter/material.dart';
import '../models/story_info.dart';
import '../widgets/story_card.dart';

class StorySelectionScreen extends StatelessWidget {
  const StorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Your Story',
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
                      ? SingleChildScrollView(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _buildStoryCards(context),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _buildStoryCards(context),
                        );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStoryCards(BuildContext context) {
    return StoryInfo.all.map((story) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: StoryCard(
          story: story,
          onSelect: () => _handleStorySelection(context, story),
        ),
      );
    }).toList();
  }

  void _handleStorySelection(BuildContext context, StoryInfo story) {
    print('Story selected: ${story.title} (ID: ${story.id})');

    // Return the selected story ID to HomeScreen
    Navigator.pop(context, story.id);
  }
}
