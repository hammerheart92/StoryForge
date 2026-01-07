import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget that displays a looping video as character background.
///
/// Features:
/// - Auto-plays video when widget is created
/// - Loops infinitely for seamless background effect
/// - Mutes audio (videos should be silent backgrounds)
/// - Shows loading indicator while video initializes
/// - Fallback to static image if video fails to load
/// - Proper disposal to prevent memory leaks
///
/// Usage:
/// ```dart
/// AnimatedCharacterBackground(
///   videoPath: 'assets/videos/isla_animation.mp4',
///   fallbackImagePath: 'assets/images/scenes/pirate_ship_navigation_room.png',
/// )
/// ```
class AnimatedCharacterBackground extends StatefulWidget {
  /// Asset path to the video file (e.g., 'assets/videos/isla_animation.mp4')
  final String videoPath;

  /// Optional static image to show if video fails to load
  final String? fallbackImagePath;

  const AnimatedCharacterBackground({
    super.key,
    required this.videoPath,
    this.fallbackImagePath,
  });

  @override
  State<AnimatedCharacterBackground> createState() =>
      _AnimatedCharacterBackgroundState();
}

class _AnimatedCharacterBackgroundState
    extends State<AnimatedCharacterBackground> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// Initialize video player and start playback
  Future<void> _initializeVideo() async {
    try {
      // Create controller from asset
      _controller = VideoPlayerController.asset(widget.videoPath);

      // Initialize the video
      await _controller.initialize();

      // Configure playback settings
      _controller.setLooping(true); // ⭐ Loop infinitely
      _controller.setVolume(0.0); // ⭐ Mute audio
      _controller.play(); // ⭐ Auto-play

      // Trigger rebuild when ready
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Log error and set error flag
      debugPrint('❌ Error loading video ${widget.videoPath}: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // ⭐ Critical: Dispose controller to prevent memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ERROR STATE: Show fallback static image
    if (_hasError && widget.fallbackImagePath != null) {
      return Image.asset(
        widget.fallbackImagePath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          // If even fallback fails, show black screen
          return Container(
            color: Colors.black,
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.white54,
                size: 48,
              ),
            ),
          );
        },
      );
    }

    // ERROR STATE (no fallback): Show error indicator
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off,
                color: Colors.white54,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Video unavailable',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // LOADING STATE: Show progress indicator
    if (!_controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white54,
          ),
        ),
      );
    }

    // SUCCESS STATE: Display video
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover, // Fill screen, crop if needed (like background image)
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}