// lib/widgets/typing_indicator.dart
// SESSION_45: Shows "[Character] is thinking..." during API calls

import 'package:flutter/material.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/typography.dart';

class TypingIndicator extends StatelessWidget {
  final String speakerName;

  const TypingIndicator({
    super.key,
    required this.speakerName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: DesignColors.highlightTeal,
            ),
          ),
          SizedBox(width: DesignSpacing.sm),
          Text(
            '$speakerName is thinking...',
            style: DesignTypography.playfulTag.copyWith(
              color: DesignColors.dSecondaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
