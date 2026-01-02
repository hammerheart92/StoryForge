import 'package:flutter/material.dart';

class CharacterInfo {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final List<String> traits;
  final Color accentColor;
  final IconData icon;

  const CharacterInfo({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.traits,
    required this.accentColor,
    required this.icon,
  });

  static final CharacterInfo narrator = CharacterInfo(
    id: 'narrator',
    name: 'Narrator',
    tagline: 'Ancient voice of eternal tales',
    description: 'The Narrator observes all, speaking with the weight of countless ages. Their words paint worlds and shape destinies with calm, measured precision.',
    traits: ['Wise', 'Observant', 'Timeless', 'Impartial'],
    accentColor: Color(0xFF30B2A3),
    icon: Icons.auto_stories,
  );

  static final CharacterInfo ilyra = CharacterInfo(
    id: 'ilyra',
    name: 'Ilyra',
    tagline: 'Mystic stargazer of cosmic truths',
    description: 'Ilyra reads the heavens with eyes that have witnessed the fall of kingdoms. Exiled but unbroken, she guards celestial secrets with fierce dedication.',
    traits: ['Mystical', 'Passionate', 'Exiled', 'Devoted'],
    accentColor: Color(0xFFA88ED9),
    icon: Icons.star,
  );

  static List<CharacterInfo> get all => [narrator, ilyra];
}