import 'package:flutter/material.dart';

class StoryInfo {
  final String id;
  final String title;
  final String tagline;
  final String description;
  final String theme;
  final Color accentColor;
  final List<String> characterIds;
  final IconData icon;

  const StoryInfo({
    required this.id,
    required this.title,
    required this.tagline,
    required this.description,
    required this.theme,
    required this.accentColor,
    required this.characterIds,
    required this.icon,
  });

  static final StoryInfo observatory = StoryInfo(
    id: 'observatory',
    title: 'The Ancient Observatory',
    tagline: 'A journey through cosmic mysteries',
    description:
        'Ancient stars whisper secrets to those brave enough to listen. High in the forgotten mountains, an observatory holds knowledge that transcends mortal understanding.',
    theme: 'Mystical',
    accentColor: Color(0xFF30B2A3),
    characterIds: ['narrator', 'ilyra'],
    icon: Icons.auto_stories,
  );

  static final StoryInfo illidan = StoryInfo(
    id: 'illidan',
    title: "The Betrayer's Path",
    tagline: 'Power demands sacrifice',
    description:
        "To defeat absolute evil, one must embrace powers the righteous dare not touch. Witness the transformation of Illidan Stormrage—hero to demon, savior to betrayer.",
    theme: 'Dark Fantasy',
    accentColor: Color(0xFF33CC33),
    characterIds: ['illidan', 'tyrande'],
    icon: Icons.whatshot,
  );

  // ⭐ SESSION 24: Pirates Story - The Pirate's Cove
  static final StoryInfo pirates = StoryInfo(
    id: 'pirates',
    title: "The Pirate's Cove",
    tagline: 'Romance and rivalry on the high seas',
    description:
    "Captain Nathaniel Blackwood commands the fastest ship on the seven seas, but his heart sails uncharted waters. His brilliant navigator Isla Hartwell charts every course—except the one toward his affections. A tale of adventure, unrequited love, and the treasures that truly matter.",
    theme: 'Pirate Adventure',
    accentColor: Color(0xFF1A5F7A),  // Deep ocean blue
    characterIds: ['blackwood', 'isla'],
    icon: Icons.sailing,
  );

  static List<StoryInfo> get all => [observatory, illidan, pirates];
}
