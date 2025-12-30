// lib/widgets/typewriter_text.dart
// Character-by-character text reveal animation
// Used for immersive storytelling typewriter effect

import 'package:flutter/material.dart';

/// Reveals text character by character like a typewriter
///
/// Features:
/// - Configurable typing speed (msPerCharacter)
/// - onComplete callback for chaining animations
/// - Linear animation for consistent typing rhythm
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int msPerCharacter;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.msPerCharacter = 20, // ~50 chars/second
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();

    // Calculate total duration based on text length and speed
    final totalDuration = Duration(
      milliseconds: widget.text.length * widget.msPerCharacter,
    );

    _controller = AnimationController(
      duration: totalDuration,
      vsync: this,
    );

    // Animate from 0 characters to full text length
    _characterCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear, // Constant typing speed
    ));

    // Start animation and call onComplete when done
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        // Show only the revealed portion of text
        final displayedText = widget.text.substring(
          0,
          _characterCount.value,
        );

        return Text(
          displayedText,
          style: widget.style,
        );
      },
    );
  }
}
