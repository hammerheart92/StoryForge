// lib/widgets/gem_counter_widget.dart
// Compact gem balance display widget for AppBar

import 'package:flutter/material.dart';

/// Displays user's gem balance with diamond icon.
/// Designed for use in AppBar actions.
///
/// Usage:
/// ```dart
/// AppBar(
///   actions: [
///     Padding(
///       padding: EdgeInsets.only(right: 16),
///       child: Center(child: GemCounterWidget(gemBalance: 100)),
///     ),
///   ],
/// )
/// ```
class GemCounterWidget extends StatelessWidget {
  final int gemBalance;

  const GemCounterWidget({required this.gemBalance, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.diamond,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '$gemBalance',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
