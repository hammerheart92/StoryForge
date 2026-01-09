// lib/providers/save_providers.dart
// Riverpod providers for story save management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/save_info.dart';
import '../services/save_service.dart';

/// Provider for all saved stories
/// Use ref.invalidate(saveListProvider) to refresh after changes
final saveListProvider = FutureProvider<List<SaveInfo>>((ref) async {
  return SaveService.getAllSaves();
});

/// Provider for a specific story's save data
/// Usage: ref.watch(saveForStoryProvider('observatory'))
final saveForStoryProvider = FutureProvider.family<SaveInfo?, String>((ref, storyId) async {
  return SaveService.getSaveForStory(storyId);
});

/// Provider to check if any saves exist
final hasAnySavesProvider = FutureProvider<bool>((ref) async {
  return SaveService.hasAnySaves();
});
