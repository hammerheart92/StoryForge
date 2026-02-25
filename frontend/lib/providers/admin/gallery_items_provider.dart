import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin/gallery_item_dto.dart';
import '../../services/admin/gallery_admin_service.dart';

/// Singleton service provider
final galleryAdminServiceProvider = Provider<GalleryAdminService>((ref) {
  return GalleryAdminService();
});

/// Gallery items list provider - use .when() in UI for data/loading/error
final galleryItemsListProvider = FutureProvider<List<GalleryItemDto>>((ref) async {
  final service = ref.watch(galleryAdminServiceProvider);
  return await service.getCreatorGalleryItems();
});
