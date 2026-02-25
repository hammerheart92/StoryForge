import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin/gallery_item_dto.dart';
import '../../models/admin/gallery_item_requests.dart';
import '../../providers/admin/gallery_items_provider.dart';
import '../../providers/admin/stories_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin/gallery_admin_service.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/storyforge_theme.dart';

class GalleryItemFormScreen extends ConsumerStatefulWidget {
  final GalleryItemDto? item;

  const GalleryItemFormScreen({super.key, this.item});

  bool get isEditing => item != null;

  @override
  ConsumerState<GalleryItemFormScreen> createState() => _GalleryItemFormScreenState();
}

class _GalleryItemFormScreenState extends ConsumerState<GalleryItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unlockCostController = TextEditingController();
  final _contentUrlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final _displayOrderController = TextEditingController();
  final _contentCategoryController = TextEditingController();
  bool _isLoading = false;

  String? _selectedStoryId;
  String? _selectedContentType;
  String? _selectedRarity;

  static const _contentTypes = ['scene', 'character', 'lore', 'extra'];
  static const _contentTypeLabels = {'scene': 'Scene', 'character': 'Character', 'lore': 'Lore', 'extra': 'Extra'};
  static const _rarities = ['common', 'rare', 'epic', 'legendary'];
  static const _rarityLabels = {'common': 'Common', 'rare': 'Rare', 'epic': 'Epic', 'legendary': 'Legendary'};

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _selectedStoryId = widget.item!.storyId;
      _selectedContentType = widget.item!.contentType;
      _titleController.text = widget.item!.title;
      _descriptionController.text = widget.item!.description ?? '';
      _unlockCostController.text = widget.item!.unlockCost.toString();
      _selectedRarity = widget.item!.rarity;
      _contentUrlController.text = widget.item!.contentUrl ?? '';
      _thumbnailUrlController.text = widget.item!.thumbnailUrl ?? '';
      _displayOrderController.text = widget.item!.displayOrder.toString();
      _contentCategoryController.text = widget.item!.contentCategory ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _unlockCostController.dispose();
    _contentUrlController.dispose();
    _thumbnailUrlController.dispose();
    _displayOrderController.dispose();
    _contentCategoryController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(galleryAdminServiceProvider);

      if (widget.isEditing) {
        final request = UpdateGalleryItemRequest(
          contentType: _selectedContentType,
          contentCategory: _contentCategoryController.text.trim().isEmpty
              ? null
              : _contentCategoryController.text.trim(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          unlockCost: int.parse(_unlockCostController.text.trim()),
          rarity: _selectedRarity,
          unlockCondition: null,
          contentUrl: _contentUrlController.text.trim().isEmpty
              ? null
              : _contentUrlController.text.trim(),
          thumbnailUrl: _thumbnailUrlController.text.trim().isEmpty
              ? null
              : _thumbnailUrlController.text.trim(),
          displayOrder: _displayOrderController.text.trim().isEmpty
              ? null
              : int.parse(_displayOrderController.text.trim()),
        );
        await service.updateGalleryItem(widget.item!.contentId, request);
        if (mounted) _showSnackbar('Gallery item updated successfully!');
      } else {
        final request = CreateGalleryItemRequest(
          storyId: _selectedStoryId!,
          contentType: _selectedContentType!,
          contentCategory: _contentCategoryController.text.trim().isEmpty
              ? null
              : _contentCategoryController.text.trim(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          unlockCost: int.parse(_unlockCostController.text.trim()),
          rarity: _selectedRarity,
          unlockCondition: null,
          contentUrl: _contentUrlController.text.trim().isEmpty
              ? null
              : _contentUrlController.text.trim(),
          thumbnailUrl: _thumbnailUrlController.text.trim().isEmpty
              ? null
              : _thumbnailUrlController.text.trim(),
          displayOrder: _displayOrderController.text.trim().isEmpty
              ? null
              : int.parse(_displayOrderController.text.trim()),
        );
        await service.createGalleryItem(request);
        if (mounted) _showSnackbar('Gallery item created successfully!');
      }

      ref.invalidate(galleryItemsListProvider);
      if (mounted) Navigator.pop(context, true);
    } on UnauthorizedException {
      if (mounted) {
        _showSnackbar('Session expired. Please login again.', isError: true);
        ref.read(authProvider.notifier).logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } on ForbiddenException {
      if (mounted) {
        _showSnackbar('You do not have permission to perform this action.', isError: true);
      }
    } on NetworkException catch (e) {
      if (mounted) _showSnackbar(e.message, isError: true);
    } on GalleryAdminException catch (e) {
      if (mounted) _showSnackbar(e.message, isError: true);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      if (mounted) _showSnackbar('An unexpected error occurred.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? StoryForgeTheme.errorColor : StoryForgeTheme.successColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 5 : 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: StoryForgeTheme.getPrimaryTextColor(brightness),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Edit Gallery Item' : 'Create Gallery Item',
          style: TextStyle(
            fontFamily: 'Merriweather',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: StoryForgeTheme.getPrimaryTextColor(brightness),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: StoryForgeTheme.getGradientColors(brightness),
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingState(isDark)
              : _buildForm(isDark, brightness),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(DesignColors.highlightTeal),
          ),
          const SizedBox(height: DesignSpacing.md),
          Text(
            'Saving gallery item...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isDark, Brightness brightness) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Story Selector
                _buildStorySelector(isDark),
                const SizedBox(height: DesignSpacing.md),

                // 2. Content Type
                _buildContentTypeSelector(isDark),
                const SizedBox(height: DesignSpacing.md),

                // 3. Title
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration(
                    isDark: isDark,
                    labelText: 'Title *',
                    hintText: 'Enter item title',
                    prefixIcon: Icons.title,
                  ),
                  style: TextStyle(
                    color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                  ),
                  maxLength: 255,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    if (value.length > 255) {
                      return 'Title must be less than 255 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DesignSpacing.md),

                // 4. Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(
                    isDark: isDark,
                    labelText: 'Description',
                    hintText: 'Enter item description',
                    prefixIcon: Icons.description,
                  ),
                  style: TextStyle(
                    color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                  ),
                  maxLines: 4,
                  maxLength: 2000,
                ),
                const SizedBox(height: DesignSpacing.md),

                // 5. Unlock Cost
                TextFormField(
                  controller: _unlockCostController,
                  decoration: _inputDecoration(
                    isDark: isDark,
                    labelText: 'Unlock Cost (gems) *',
                    hintText: '50',
                    prefixIcon: Icons.diamond_outlined,
                  ),
                  style: TextStyle(
                    color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Unlock cost is required';
                    }
                    final cost = int.tryParse(value.trim());
                    if (cost == null) {
                      return 'Must be a number';
                    }
                    if (cost < 0) {
                      return 'Must be 0 or greater';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DesignSpacing.md),

                // 6. Rarity
                _buildRaritySelector(isDark),
                const SizedBox(height: DesignSpacing.md),

                // 7. Content URL
                TextFormField(
                  controller: _contentUrlController,
                  decoration: _inputDecoration(
                    isDark: isDark,
                    labelText: 'Content URL',
                    hintText: 'https://example.com/scene.jpg',
                    prefixIcon: Icons.link,
                  ),
                  style: TextStyle(
                    color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final uri = Uri.tryParse(value);
                      if (uri == null || !uri.hasAbsolutePath) {
                        return 'Invalid URL format';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DesignSpacing.md),

                // 8. Thumbnail URL
                TextFormField(
                  controller: _thumbnailUrlController,
                  decoration: _inputDecoration(
                    isDark: isDark,
                    labelText: 'Thumbnail URL',
                    hintText: 'https://example.com/thumb.jpg',
                    prefixIcon: Icons.image_outlined,
                  ),
                  style: TextStyle(
                    color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final uri = Uri.tryParse(value);
                      if (uri == null || !uri.hasAbsolutePath) {
                        return 'Invalid URL format';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DesignSpacing.md),

                // 9. Display Order
                TextFormField(
                  controller: _displayOrderController,
                  decoration: _inputDecoration(
                    isDark: isDark,
                    labelText: 'Display Order',
                    hintText: '0',
                    prefixIcon: Icons.sort,
                  ),
                  style: TextStyle(
                    color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (int.tryParse(value.trim()) == null) {
                        return 'Must be a number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DesignSpacing.md),

                // 10. Content Category
                TextFormField(
                  controller: _contentCategoryController,
                  decoration: _inputDecoration(
                    isDark: isDark,
                    labelText: 'Content Category',
                    hintText: 'e.g. opening, boss_fight',
                    prefixIcon: Icons.category_outlined,
                  ),
                  style: TextStyle(
                    color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                  ),
                ),
                const SizedBox(height: DesignSpacing.xl),

                // Submit button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StoryForgeTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(StoryForgeTheme.buttonRadius),
                      ),
                      disabledBackgroundColor:
                          StoryForgeTheme.primaryColor.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      widget.isEditing ? 'Update Gallery Item' : 'Create Gallery Item',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStorySelector(bool isDark) {
    final storiesAsync = ref.watch(storiesListProvider);

    return storiesAsync.when(
      data: (stories) {
        return DropdownButtonFormField<String>(
          value: _selectedStoryId,
          decoration: _inputDecoration(
            isDark: isDark,
            labelText: 'Story *',
            hintText: 'Select a story',
            prefixIcon: Icons.book,
          ),
          dropdownColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
          style: TextStyle(
            color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
          ),
          items: stories.map((story) => DropdownMenuItem(
            value: story.storyId,
            child: Text(story.title),
          )).toList(),
          onChanged: widget.isEditing ? null : (value) {
            setState(() => _selectedStoryId = value);
          },
          validator: (value) => value == null ? 'Story is required' : null,
        );
      },
      loading: () => TextFormField(
        enabled: false,
        decoration: _inputDecoration(
          isDark: isDark,
          labelText: 'Story *',
          hintText: 'Loading stories...',
          prefixIcon: Icons.book,
        ),
      ),
      error: (_, __) => TextFormField(
        enabled: false,
        decoration: _inputDecoration(
          isDark: isDark,
          labelText: 'Story *',
          hintText: 'Failed to load stories',
          prefixIcon: Icons.book,
        ),
      ),
    );
  }

  Widget _buildContentTypeSelector(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedContentType,
      decoration: _inputDecoration(
        isDark: isDark,
        labelText: 'Content Type *',
        hintText: 'Select content type',
        prefixIcon: Icons.category,
      ),
      dropdownColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
      style: TextStyle(
        color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
      ),
      items: _contentTypes.map((type) => DropdownMenuItem(
        value: type,
        child: Text(_contentTypeLabels[type]!),
      )).toList(),
      onChanged: (value) {
        setState(() => _selectedContentType = value);
      },
      validator: (value) => value == null ? 'Content type is required' : null,
    );
  }

  Widget _buildRaritySelector(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedRarity,
      decoration: _inputDecoration(
        isDark: isDark,
        labelText: 'Rarity',
        hintText: 'Select rarity (default: common)',
        prefixIcon: Icons.star_outline,
      ),
      dropdownColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
      style: TextStyle(
        color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
      ),
      items: _rarities.map((r) => DropdownMenuItem(
        value: r,
        child: Text(_rarityLabels[r]!),
      )).toList(),
      onChanged: (value) {
        setState(() => _selectedRarity = value);
      },
    );
  }

  InputDecoration _inputDecoration({
    required bool isDark,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(
        color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
      ),
      hintStyle: TextStyle(
        color: isDark
            ? DesignColors.dSecondaryText.withValues(alpha: 0.5)
            : DesignColors.lSecondaryText.withValues(alpha: 0.5),
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: StoryForgeTheme.iconSizeMedium,
        color: isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText,
      ),
      filled: true,
      fillColor: isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
        borderSide: const BorderSide(
          color: StoryForgeTheme.primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
        borderSide: BorderSide(
          color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StoryForgeTheme.inputRadius),
        borderSide: BorderSide(
          color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
          width: 2,
        ),
      ),
    );
  }
}
