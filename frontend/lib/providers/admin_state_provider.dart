import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AdminSection {
  stories,
  gallery,
}

/// Selected section in the admin panel
final selectedAdminSectionProvider = StateProvider<AdminSection>((ref) {
  return AdminSection.stories;
});
