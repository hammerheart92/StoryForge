import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin/story_dto.dart';
import '../../services/admin/story_admin_service.dart';

/// Singleton service provider
final storyAdminServiceProvider = Provider<StoryAdminService>((ref) {
  return StoryAdminService();
});

/// Stories list provider - use .when() in UI for data/loading/error
final storiesListProvider = FutureProvider<List<StoryDto>>((ref) async {
  final service = ref.watch(storyAdminServiceProvider);
  return await service.getCreatorStories();
});
