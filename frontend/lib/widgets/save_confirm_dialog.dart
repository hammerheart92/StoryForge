// lib/widgets/save_confirm_dialog.dart
// Confirmation dialog for starting new game when save exists

import 'package:flutter/material.dart';
import '../theme/tokens/colors.dart';

class SaveConfirmDialog extends StatelessWidget {
  final String storyTitle;
  final VoidCallback onConfirm;

  const SaveConfirmDialog({
    super.key,
    required this.storyTitle,
    required this.onConfirm,
  });

  /// Show the dialog and return true if user confirms
  static Future<bool> show({
    required BuildContext context,
    required String storyTitle,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SaveConfirmDialog(
        storyTitle: storyTitle,
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DesignColors.dSurfaces,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DesignColors.dWarning.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: DesignColors.dWarning,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Start New Game?',
            style: TextStyle(
              fontFamily: 'Merriweather',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignColors.dPrimaryText,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your current progress in',
            style: TextStyle(
              color: DesignColors.dSecondaryText,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '"$storyTitle"',
            style: TextStyle(
              color: DesignColors.dPrimaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'will be lost. This cannot be undone.',
            style: TextStyle(
              color: DesignColors.dSecondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
      actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignColors.dSecondaryText,
                  side: BorderSide(
                    color: DesignColors.dSecondaryText.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Cancel'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.dWarning,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Start New',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
