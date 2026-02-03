import 'package:flutter/material.dart';
import '../models/story_ending.dart';
import '../models/story_info.dart';
import '../services/story_completion_service.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/storyforge_theme.dart';

/// Screen displaying all endings for a story with discovery progress
class StoryEndingsScreen extends StatefulWidget {
  final String storyId;

  const StoryEndingsScreen({super.key, required this.storyId});

  @override
  State<StoryEndingsScreen> createState() => _StoryEndingsScreenState();
}

class _StoryEndingsScreenState extends State<StoryEndingsScreen> {
  final StoryCompletionService _service = StoryCompletionService();
  List<StoryEnding>? _endings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEndings();
  }

  Future<void> _loadEndings() async {
    try {
      final endings = await _service.getStoryEndingsSafe(widget.storyId);
      if (mounted) {
        setState(() {
          _endings = endings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Find story info by ID
  StoryInfo? _getStoryInfo() {
    try {
      return StoryInfo.all.firstWhere((s) => s.id == widget.storyId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyInfo = _getStoryInfo();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignColors.dBackground : DesignColors.lBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${storyInfo?.title ?? 'Story'} Endings',
          style: TextStyle(
            fontFamily: 'Merriweather',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(storyInfo, isDark),
    );
  }

  Widget _buildBody(StoryInfo? storyInfo, bool isDark) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: DesignColors.highlightTeal),
      );
    }

    if (_error != null) {
      return _buildError(isDark);
    }

    if (_endings == null || _endings!.isEmpty) {
      return _buildEmpty(isDark);
    }

    return _buildEndingsList(storyInfo, isDark);
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'Failed to load endings',
            style: TextStyle(
              color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
              fontSize: 16,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadEndings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.highlightTeal,
              foregroundColor: Colors.black,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off,
            size: StoryForgeTheme.iconSizeXL,
            color: secondaryText,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'No endings available yet',
            style: TextStyle(
              color: secondaryText,
              fontSize: 16,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            'Play the story to discover endings!',
            style: TextStyle(
              color: secondaryText.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndingsList(StoryInfo? storyInfo, bool isDark) {
    final discovered = _endings!.where((e) => e.discovered).length;
    final total = _endings!.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressBanner(discovered, total, storyInfo, isDark),
          SizedBox(height: DesignSpacing.lg),
          ..._endings!.map(
            (ending) => Padding(
              padding: EdgeInsets.only(bottom: DesignSpacing.md),
              child: _EndingCard(ending: ending, isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBanner(int discovered, int total, StoryInfo? storyInfo, bool isDark) {
    final progress = total > 0 ? discovered / total : 0.0;
    final accentColor = storyInfo?.accentColor ?? DesignColors.highlightTeal;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        boxShadow: DesignShadows.glowSoft(accentColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Endings Discovered',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              Text(
                '$discovered / $total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(StoryForgeTheme.chipRadius),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 8,
            ),
          ),
          if (discovered == total && total > 0) ...[
            SizedBox(height: DesignSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 16, color: successColor),
                SizedBox(width: DesignSpacing.xs),
                Text(
                  'All endings discovered!',
                  style: TextStyle(
                    color: successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual ending card widget
class _EndingCard extends StatelessWidget {
  final StoryEnding ending;
  final bool isDark;

  const _EndingCard({required this.ending, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (ending.discovered) {
      return _buildDiscoveredCard();
    } else {
      return _buildUndiscoveredCard();
    }
  }

  Widget _buildDiscoveredCard() {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        border: Border.all(
          color: successColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 20, color: successColor),
              SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: Text(
                  ending.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            ending.description,
            style: TextStyle(
              color: secondaryText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (ending.discoveredAt != null) ...[
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Discovered: ${_formatDate(ending.discoveredAt!)}',
              style: TextStyle(
                color: secondaryText.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUndiscoveredCard() {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        border: Border.all(
          color: secondaryText.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock,
            size: StoryForgeTheme.iconSizeMedium,
            color: secondaryText,
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '???',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: secondaryText,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  'Continue playing to discover this ending',
                  style: TextStyle(
                    color: secondaryText.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
