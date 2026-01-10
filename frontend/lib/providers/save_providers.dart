// lib/providers/save_providers.dart
// Riverpod providers for story save management
// Session 28: Updated to use backend API via NarrativeService injection

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/save_info.dart';
import '../services/save_service.dart';
import 'narrative_provider.dart';

/// Provider for SaveService with backend integration
final saveServiceProvider = Provider<SaveService>((ref) {
  final narrativeService = ref.watch(narrativeServiceProvider);
  return SaveService(narrativeService);
});

/// Provider for all saved stories
/// Use ref.invalidate(saveListProvider) to refresh after changes
final saveListProvider = FutureProvider<List<SaveInfo>>((ref) async {
  final service = ref.watch(saveServiceProvider);
  return service.getAllSaves();
});

/// Provider for a specific story's save data
/// Usage: ref.watch(saveForStoryProvider('observatory'))
final saveForStoryProvider = FutureProvider.family<SaveInfo?, String>((ref, storyId) async {
  final service = ref.watch(saveServiceProvider);
  return service.getSaveForStory(storyId);
});

/// Provider to check if any saves exist
final hasAnySavesProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(saveServiceProvider);
  return service.hasAnySaves();
});
