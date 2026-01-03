import 'package:flutter/material.dart';
import '../models/character_info.dart';

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
      width: 320,
      height: 480,
      decoration: BoxDecoration(
        color: Color(0xFF23272C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: character.accentColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: character.accentColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: character.accentColor.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCharacterIcon(),
            SizedBox(height: 16),
            Expanded(
              child: _buildCharacterInfo(),
            ),
            SizedBox(height: 16),
            _buildTraits(),
            SizedBox(height: 16),
            _buildSelectButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterIcon() {
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
        boxShadow: [
          BoxShadow(
            color: character.accentColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
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
              color: Color(0xFFF1F3F5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
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
          SizedBox(height: 16),
          Text(
            character.description,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              height: 1.5,
              color: Color(0xFFB0B3B8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTraits() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: character.traits.map((trait) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: character.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(12),
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