import 'package:flutter/material.dart';

class CharacterInfo {
  final String id;
  final String storyId;
  final String name;
  final String tagline;
  final String description;
  final List<String> traits;
  final Color accentColor;
  final IconData icon;

  const CharacterInfo({
    required this.id,
    required this.storyId,
    required this.name,
    required this.tagline,
    required this.description,
    required this.traits,
    required this.accentColor,
    required this.icon,
  });

  static final CharacterInfo narrator = CharacterInfo(
    id: 'narrator',
    storyId: 'observatory',
    name: 'Narrator',
    tagline: 'Ancient voice of eternal tales',
    description: 'The Narrator observes all, speaking with the weight of countless ages. Their words paint worlds and shape destinies with calm, measured precision.',
    traits: ['Wise', 'Observant', 'Timeless', 'Impartial'],
    accentColor: Color(0xFF30B2A3),
    icon: Icons.auto_stories,
  );

  static final CharacterInfo ilyra = CharacterInfo(
    id: 'ilyra',
    storyId: 'observatory',
    name: 'Ilyra',
    tagline: 'Mystic stargazer of cosmic truths',
    description: 'Ilyra reads the heavens with eyes that have witnessed the fall of kingdoms. Exiled but unbroken, she guards celestial secrets with fierce dedication.',
    traits: ['Mystical', 'Passionate', 'Exiled', 'Devoted'],
    accentColor: Color(0xFFA88ED9),
    icon: Icons.star,
  );

  static final CharacterInfo illidan = CharacterInfo(
    id: 'illidan',
    storyId: 'illidan',
    name: 'Illidan Stormrage',
    tagline: 'I have sacrificed everything. What have you given?',
    description:
        "Blinded but visionary, exiled but determined, Illidan Stormrage walks a path between light and shadow. Consumed by fel power from the Skull of Gul'dan, he became the demon he sought to destroy—wings of shadow, eyes of fel fire, and a will that bends to no master.",
    traits: ['Ruthless', 'Tormented', 'Driven', 'Arrogant'],
    accentColor: Color(0xFF33CC33),
    icon: Icons.whatshot,
  );

  static final CharacterInfo tyrande = CharacterInfo(
    id: 'tyrande',
    storyId: 'illidan',
    name: 'Tyrande Whisperwind',
    tagline: 'I freed you to save us, not to watch you damn yourself',
    description:
        'The High Priestess of Elune walks in silver moonlight, her faith unwavering even as she watches the one she freed embrace darkness. Tyrande freed Illidan from his prison, believing in redemption, in the power of second chances.',
    traits: ['Compassionate', 'Conflicted', 'Hopeful', 'Loyal'],
    accentColor: Color(0xFFC0C0C0),
    icon: Icons.nightlight,
  );

  static List<CharacterInfo> get all => [narrator, ilyra, illidan, tyrande];

  /// Get all characters for a specific story
  static List<CharacterInfo> forStory(String storyId) {
    return all.where((char) => char.storyId == storyId).toList();
  }
}