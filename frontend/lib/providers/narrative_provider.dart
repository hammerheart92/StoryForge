// lib/providers/narrative_provider.dart
// Riverpod providers for narrative system

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/narrative_service.dart';
import 'narrative_state.dart';
import 'narrative_notifier.dart';

/// Provider for NarrativeService (singleton)
final narrativeServiceProvider = Provider<NarrativeService>((ref) {
  final service = NarrativeService();

  // Print environment info on startup
  NarrativeService.printCurrentEnvironment();

  // Dispose when provider is destroyed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for NarrativeState and NarrativeNotifier
/// This is what UI widgets will watch
final narrativeStateProvider = StateNotifierProvider<NarrativeNotifier, NarrativeState>((ref) {
  final service = ref.watch(narrativeServiceProvider);
  return NarrativeNotifier(service);
});

/// Convenience provider for just the loading state
final narrativeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(narrativeStateProvider.select((state) => state.isLoading));
});

/// Convenience provider for just the error state
final narrativeErrorProvider = Provider<String?>((ref) {
  return ref.watch(narrativeStateProvider.select((state) => state.error));
});

/// Convenience provider for just the current speaker
final currentSpeakerProvider = Provider<String>((ref) {
  return ref.watch(narrativeStateProvider.select((state) => state.currentSpeaker));
});

/// Convenience provider for message count
final messageCountProvider = Provider<int>((ref) {
  return ref.watch(narrativeStateProvider.select((state) => state.history.length));
});