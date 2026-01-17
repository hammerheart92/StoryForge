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

    return Scaffold(
      backgroundColor: DesignColors.dBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: DesignColors.dPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${storyInfo?.title ?? 'Story'} Endings',
          style: TextStyle(
            fontFamily: 'Merriweather',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DesignColors.dPrimaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(storyInfo),
    );
  }

  Widget _buildBody(StoryInfo? storyInfo) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: DesignColors.highlightTeal),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_endings == null || _endings!.isEmpty) {
      return _buildEmpty();
    }

    return _buildEndingsList(storyInfo);
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: DesignColors.dDanger),
          SizedBox(height: DesignSpacing.md),
          Text(
            'Failed to load endings',
            style: TextStyle(color: DesignColors.dPrimaryText, fontSize: 16),
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off,
            size: StoryForgeTheme.iconSizeXL,
            color: DesignColors.dSecondaryText,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'No endings available yet',
            style: TextStyle(
              color: DesignColors.dSecondaryText,
              fontSize: 16,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            'Play the story to discover endings!',
            style: TextStyle(
              color: DesignColors.dSecondaryText.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndingsList(StoryInfo? storyInfo) {
    final discovered = _endings!.where((e) => e.discovered).length;
    final total = _endings!.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressBanner(discovered, total, storyInfo),
          SizedBox(height: DesignSpacing.lg),
          ..._endings!.map(
            (ending) => Padding(
              padding: EdgeInsets.only(bottom: DesignSpacing.md),
              child: _EndingCard(ending: ending),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBanner(int discovered, int total, StoryInfo? storyInfo) {
    final progress = total > 0 ? discovered / total : 0.0;
    final accentColor = storyInfo?.accentColor ?? DesignColors.highlightTeal;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.dSurfaces,
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
                  color: DesignColors.dPrimaryText,
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
              backgroundColor: DesignColors.dBackground,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 8,
            ),
          ),
          if (discovered == total && total > 0) ...[
            SizedBox(height: DesignSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 16, color: DesignColors.dSuccess),
                SizedBox(width: DesignSpacing.xs),
                Text(
                  'All endings discovered!',
                  style: TextStyle(
                    color: DesignColors.dSuccess,
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

  const _EndingCard({required this.ending});

  @override
  Widget build(BuildContext context) {
    if (ending.discovered) {
      return _buildDiscoveredCard();
    } else {
      return _buildUndiscoveredCard();
    }
  }

  Widget _buildDiscoveredCard() {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.dSurfaces,
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        border: Border.all(
          color: DesignColors.dSuccess.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 20, color: DesignColors.dSuccess),
              SizedBox(width: DesignSpacing.sm),
              Expanded(
                child: Text(
                  ending.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: DesignColors.dPrimaryText,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            ending.description,
            style: TextStyle(
              color: DesignColors.dSecondaryText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (ending.discoveredAt != null) ...[
            SizedBox(height: DesignSpacing.sm),
            Text(
              'Discovered: ${_formatDate(ending.discoveredAt!)}',
              style: TextStyle(
                color: DesignColors.dSecondaryText.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUndiscoveredCard() {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.dSurfaces.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(StoryForgeTheme.cardRadius),
        border: Border.all(
          color: DesignColors.dSecondaryText.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock,
            size: StoryForgeTheme.iconSizeMedium,
            color: DesignColors.dSecondaryText,
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
                    color: DesignColors.dSecondaryText,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  'Continue playing to discover this ending',
                  style: TextStyle(
                    color: DesignColors.dSecondaryText.withValues(alpha: 0.7),
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
