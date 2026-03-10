// lib/widgets/chat_input_section.dart
// SESSION_45: Free-text chat input with AI suggestion chips

import 'package:flutter/material.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/shadows.dart';
import '../theme/tokens/typography.dart';
import 'narrative_suggestion_chip.dart';

class ChatInputSection extends StatefulWidget {
  final List<String> suggestions;
  final bool isLoading;
  final String characterName;
  final Function(String message) onSendMessage;

  const ChatInputSection({
    super.key,
    required this.suggestions,
    required this.isLoading,
    required this.characterName,
    required this.onSendMessage,
  });

  @override
  State<ChatInputSection> createState() => _ChatInputSectionState();
}

class _ChatInputSectionState extends State<ChatInputSection> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get _canSend =>
      _controller.text.trim().isNotEmpty && !widget.isLoading;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSuggestionTap(String suggestion) {
    setState(() {
      _controller.text = suggestion;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: suggestion.length),
      );
    });
    _focusNode.requestFocus();
  }

  void _onSend() {
    if (!_canSend) return;
    final message = _controller.text.trim();
    _controller.clear();
    widget.onSendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.dBackground,
        boxShadow: DesignShadows.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Suggestion chips — hidden during loading or if no suggestions
          if (!widget.isLoading && widget.suggestions.isNotEmpty)
            _buildSuggestions(),

          if (!widget.isLoading && widget.suggestions.isNotEmpty)
            SizedBox(height: DesignSpacing.sm),

          // Input row
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      children: widget.suggestions.map((suggestion) =>
        Padding(
          padding: EdgeInsets.only(bottom: DesignSpacing.sm),
          child: NarrativeSuggestionChip(
            text: suggestion,
            onTap: () => _onSuggestionTap(suggestion),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !widget.isLoading,
            maxLines: null,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _onSend(),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Message ${widget.characterName}...',
              hintStyle: DesignTypography.bodyRegular.copyWith(
                color: DesignColors.dDisabled,
              ),
              filled: true,
              fillColor: DesignColors.dSurfaces,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(StoryForgeTheme.pillRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.sm,
              ),
            ),
            style: DesignTypography.bodyRegular.copyWith(
              color: DesignColors.dPrimaryText,
            ),
          ),
        ),
        SizedBox(width: DesignSpacing.sm),
        IconButton(
          onPressed: _canSend ? _onSend : null,
          icon: const Icon(Icons.send_rounded),
          color: _canSend
              ? DesignColors.highlightTeal
              : DesignColors.dDisabled,
          iconSize: 28,
        ),
      ],
    );
  }
}
