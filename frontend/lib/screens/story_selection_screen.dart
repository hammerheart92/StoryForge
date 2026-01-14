import 'package:flutter/material.dart';
import '../models/story_info.dart';
import '../theme/tokens/colors.dart';
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
        width: double.infinity,  // ⭐ Force full width
        height: double.infinity,  // ⭐ Force full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: DesignColors.appGradient,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              return isMobile
                  ? Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildStoryCards(context),
                    ),
                  ),
                ),
              )
                  : Center(  // ⭐ Center vertically
                child: SingleChildScrollView(
                  // ⭐ Horizontal scroll - no width constraint!
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildStoryCards(context),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStoryCards(BuildContext context) {
    print('🏴‍☠️ DEBUG: Building ${StoryInfo.all.length} story cards');
    for (var story in StoryInfo.all) {
      print('  📖 Story: ${story.title} (ID: ${story.id})');
    }

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