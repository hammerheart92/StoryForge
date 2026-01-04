// lib/providers/narrative_notifier.dart
// Business logic for narrative state management
// ⭐ SESSION 21: Added storyId support for multi-story system

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/narrative_service.dart';
import '../services/story_state_service.dart';
import '../models/narrative_message.dart';
import '../models/narrative_response.dart';
import '../models/choice.dart';
import 'narrative_state.dart';

class NarrativeNotifier extends StateNotifier<NarrativeState> {
  final NarrativeService _service;

  NarrativeNotifier(this._service) : super(NarrativeState.initial());

  /// Send a message and get narrative response with choices
  /// ⭐ UPDATED: Added storyId parameter
  Future<void> sendMessage(String message, String speaker, String storyId) async {
    // Set loading state
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      print('📤 Sending message: "$message" to $speaker');

      // ⭐ UPDATED: Call API with storyId
      final response = await _service.speak(message, speaker, storyId);

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
      print('💾 NarrativeNotifier: Saving state after sendMessage (${newHistory.length} messages)');
      await StoryStateService.saveState(
        messages: newHistory,
        lastCharacter: response.speaker,
        storyId: storyId,
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
  /// ⭐ UPDATED: Added storyId parameter
  Future<void> selectChoice(Choice choice, String storyId) async {
    print('🎯 User selected choice: "${choice.label}" -> ${choice.nextSpeaker}');

    // Set loading state
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Add user's choice to history
      final choiceMessage = NarrativeMessage.userChoice(choice.label);

      // ⭐ UPDATED: Call API with storyId
      final response = await _service.choose(choice, storyId);

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
      print('💾 NarrativeNotifier: Saving state after selectChoice (${newHistory.length} messages)');
      await StoryStateService.saveState(
        messages: newHistory,
        lastCharacter: response.speaker,
        storyId: storyId,
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
  /// Optionally set the initial speaker to prevent portrait flash
  void reset({String? initialSpeaker}) {
    print('🔄 Resetting narrative state');
    state = NarrativeState(currentSpeaker: initialSpeaker ?? 'narrator');
  }

  /// Restore conversation from saved messages (for "Continue Story")
  /// Messages appear instantly without animation
  void restoreFromMessages(List<NarrativeMessage> messages, String lastCharacter) {
    if (messages.isEmpty) return;

    print('✅ Restoring ${messages.length} messages');

    // Find the last message with choices (should be the last AI message)
    NarrativeMessage? lastMessageWithChoices;
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].hasChoices) {
        lastMessageWithChoices = messages[i];
        break;
      }
    }

    // Reconstruct NarrativeResponse from the last message with choices
    // This is CRITICAL for displaying choice buttons after restore
    NarrativeResponse? currentResponse;
    if (lastMessageWithChoices != null) {
      currentResponse = NarrativeResponse(
        speakerName: lastMessageWithChoices.speakerName,
        speaker: lastMessageWithChoices.speaker,
        dialogue: lastMessageWithChoices.dialogue,
        actionText: lastMessageWithChoices.actionText,
        mood: lastMessageWithChoices.mood,
        choices: lastMessageWithChoices.choices!,
      );
      print('✅ Restored ${lastMessageWithChoices.choices!.length} choices from last message');
    }

    state = state.copyWith(
      history: messages,
      currentSpeaker: lastCharacter,
      currentResponse: currentResponse,  // Restore choices for display
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