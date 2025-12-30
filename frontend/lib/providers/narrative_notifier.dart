// lib/providers/narrative_notifier.dart
// Business logic for narrative state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/narrative_service.dart';
import '../services/story_state_service.dart';
import '../models/narrative_message.dart';
import '../models/choice.dart';
import 'narrative_state.dart';

class NarrativeNotifier extends StateNotifier<NarrativeState> {
  final NarrativeService _service;

  NarrativeNotifier(this._service) : super(NarrativeState.initial());

  /// Send a message and get narrative response with choices
  Future<void> sendMessage(String message, String speaker) async {
    // Set loading state
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      print('📤 Sending message: "$message" to $speaker');

      // Call API
      final response = await _service.speak(message, speaker);

      // Create history message from response
      final historyMessage = NarrativeMessage.fromResponse(response);

      // Update state with new response and add to history
      final newHistory = [...state.history, historyMessage];
      state = state.copyWith(
        currentResponse: response,
        history: newHistory,
        currentSpeaker: response.speaker,
        isLoading: false,
      );

      print('✅ Message sent successfully. Speaker: ${response.speakerName}, Choices: ${response.choices.length}');

      // Auto-save state in background
      await StoryStateService.saveState(
        messages: newHistory,
        lastCharacter: response.speaker,
      );
    } catch (e) {
      print('❌ Error sending message: $e');

      // Set error state
      state = state.copyWith(
        error: _getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  /// Select a choice and continue the narrative
  Future<void> selectChoice(Choice choice) async {
    print('🎯 User selected choice: "${choice.label}" -> ${choice.nextSpeaker}');

    // Set loading state
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Add user's choice to history
      final choiceMessage = NarrativeMessage.userChoice(choice.label);

      // Call API
      final response = await _service.choose(choice);

      // Create history message from response
      final responseMessage = NarrativeMessage.fromResponse(response);

      // Update state with new response and add both messages to history
      final newHistory = [...state.history, choiceMessage, responseMessage];
      state = state.copyWith(
        currentResponse: response,
        history: newHistory,
        currentSpeaker: response.speaker,
        isLoading: false,
      );

      print('✅ Choice processed. Switched to ${response.speakerName}');

      // Auto-save state in background
      await StoryStateService.saveState(
        messages: newHistory,
        lastCharacter: response.speaker,
      );
    } catch (e) {
      print('❌ Error selecting choice: $e');

      // Set error state
      state = state.copyWith(
        error: _getErrorMessage(e),
        isLoading: false,
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset the narrative (start over)
  void reset() {
    print('🔄 Resetting narrative state');
    state = NarrativeState.initial();
  }

  /// Restore conversation from saved messages (for "Continue Story")
  /// Messages appear instantly without animation
  void restoreFromMessages(List<NarrativeMessage> messages, String lastCharacter) {
    if (messages.isEmpty) return;

    print('✅ Restoring ${messages.length} messages');

    state = state.copyWith(
      history: messages,
      currentSpeaker: lastCharacter,
      isLoading: false,
    );
  }

  /// Check backend status
  Future<bool> checkBackendStatus() async {
    try {
      return await _service.checkStatus();
    } catch (e) {
      print('❌ Backend status check failed: $e');
      return false;
    }
  }

  /// Convert exceptions to user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error is NarrativeApiException) {
      switch (error.statusCode) {
        case 400:
          return 'Invalid request. Please try again.';
        case 404:
          return 'Character not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'Network error: ${error.message}';
      }
    } else if (error.toString().contains('SocketException')) {
      return 'Cannot connect to server. Is the backend running?';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'An error occurred: ${error.toString()}';
    }
  }
}