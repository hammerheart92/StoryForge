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

  // ⭐ SESSION 24: Pirates Story Characters
  static final CharacterInfo blackwood = CharacterInfo(
    id: 'blackwood',
    storyId: 'pirates',
    name: 'Captain Nathaniel Blackwood',
    tagline: 'A legend haunted by what he cannot command',
    description:
    'Captain Blackwood commands the fastest ship and fiercest crew on the seven seas. Weathered by storms and battles, his graying beard and piercing eyes tell tales of countless victories. Yet the one treasure that eludes him is not gold or glory—it\'s the heart of his brilliant navigator, Isla Hartwell.',
    traits: ['Cunning', 'Melancholic', 'Romantic', 'Commanding'],
    accentColor: Color(0xFF1A5F7A),  // Deep ocean blue
    icon: Icons.sailing,
  );

  static final CharacterInfo isla = CharacterInfo(
    id: 'isla',
    storyId: 'pirates',
    name: 'Isla Hartwell',
    tagline: 'Charts every course—except the heart\'s',
    description:
    'Isla Hartwell is the finest navigator to sail the seven seas. Her sharp wit and sharper mind have guided Captain Blackwood\'s ship through the most treacherous waters. She values professionalism, competence, and boundaries—especially against the Captain\'s persistent romantic advances.',
    traits: ['Sharp-Witted', 'Professional', 'Pragmatic', 'Boundary-Keeper'],
    accentColor: Color(0xFFD4A574),  // Warm brass/gold (navigation tools)
    icon: Icons.explore,
  );

  static List<CharacterInfo> get all => [narrator, ilyra, illidan, tyrande, blackwood, isla];

  /// Get all characters for a specific story
  static List<CharacterInfo> forStory(String storyId) {
    return all.where((char) => char.storyId == storyId).toList();
  }
}