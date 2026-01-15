import 'package:flutter/material.dart';
import '../models/character_info.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/storyforge_theme.dart';

class CharacterCard extends StatelessWidget {
  final CharacterInfo character;
  final VoidCallback onSelect;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: StoryForgeTheme.characterCardWidth,
      height: StoryForgeTheme.characterCardHeight,
      decoration: BoxDecoration(
        color: DesignColors.dSurfaces,
        borderRadius: BorderRadius.circular(StoryForgeTheme.heroCardRadius),
        border: Border.all(
          color: character.accentColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: DesignShadows.glowIntense(character.accentColor),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          children: [
            _buildCharacterIcon(),
            SizedBox(height: DesignSpacing.md),
            Expanded(
              child: _buildCharacterInfo(),
            ),
            SizedBox(height: DesignSpacing.md),
            _buildTraits(),
            SizedBox(height: DesignSpacing.md),
            _buildSelectButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterIcon() {
    // If character has a portrait, show image
    if (character.portraitPath != null) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: character.accentColor.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: DesignShadows.glowSoft(character.accentColor),
        ),
        child: ClipOval(
          child: Image.asset(
            character.portraitPath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to icon on error
              return Container(
                color: character.accentColor.withOpacity(0.1),
                child: Icon(character.icon, size: 50, color: character.accentColor),
              );
            },
          ),
        ),
      );
    }

    // Fallback: original icon-based display
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: character.accentColor.withOpacity(0.1),
        border: Border.all(
          color: character.accentColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: DesignShadows.glowSoft(character.accentColor),
      ),
      child: Icon(
        character.icon,
        size: 50,
        color: character.accentColor,
      ),
    );
  }

  Widget _buildCharacterInfo() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            character.name,
            style: TextStyle(
              fontFamily: 'Merriweather',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: DesignColors.dPrimaryText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            character.tagline,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: character.accentColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            character.description,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              height: 1.5,
              color: DesignColors.dSecondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTraits() {
    return Wrap(
      spacing: DesignSpacing.sm,
      runSpacing: DesignSpacing.sm,
      alignment: WrapAlignment.center,
      children: character.traits.map((trait) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm + 4, vertical: DesignSpacing.xs + 2), // 12, 6
          decoration: BoxDecoration(
            color: character.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
            border: Border.all(
              color: character.accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            trait,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: character.accentColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectButton() {
    return ElevatedButton(
      onPressed: onSelect,
      style: ElevatedButton.styleFrom(
        backgroundColor: character.accentColor,
        foregroundColor: Colors.black,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoryForgeTheme.buttonRadius),
        ),
        elevation: 0,
        shadowColor: character.accentColor.withOpacity(0.5),
      ),
      child: Text(
        'Select ${character.name}',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}