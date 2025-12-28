// lib/providers/narrative_state.dart
// Immutable state class for narrative screen

import '../models/narrative_response.dart';
import '../models/narrative_message.dart';

class NarrativeState {
  final List<NarrativeMessage> history;      // All past messages
  final NarrativeResponse? currentResponse;  // Current response with choices
  final bool isLoading;                      // Loading indicator
  final String? error;                       // Error message
  final String currentSpeaker;               // Active character ID

  const NarrativeState({
    this.history = const [],
    this.currentResponse,
    this.isLoading = false,
    this.error,
    this.currentSpeaker = 'narrator',
  });

  /// Create initial state
  factory NarrativeState.initial() {
    return const NarrativeState();
  }

  /// Copy state with changes (immutability pattern)
  NarrativeState copyWith({
    List<NarrativeMessage>? history,
    NarrativeResponse? currentResponse,
    bool? isLoading,
    String? error,
    String? currentSpeaker,
    bool clearError = false,
    bool clearCurrentResponse = false,
  }) {
    return NarrativeState(
      history: history ?? this.history,
      currentResponse: clearCurrentResponse ? null : (currentResponse ?? this.currentResponse),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentSpeaker: currentSpeaker ?? this.currentSpeaker,
    );
  }

  /// Check if we have an active response
  bool get hasCurrentResponse => currentResponse != null;

  /// Check if we have any messages
  bool get hasHistory => history.isNotEmpty;

  /// Check if there's an error
  bool get hasError => error != null;

  @override
  String toString() {
    return 'NarrativeState('
        'history: ${history.length}, '
        'currentSpeaker: $currentSpeaker, '
        'isLoading: $isLoading, '
        'hasError: $hasError'
        ')';
  }
}