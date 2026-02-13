import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/admin/story_dto.dart';
import '../../models/admin/story_requests.dart';
import '../../providers/admin/stories_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin/story_admin_service.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/storyforge_theme.dart';

class StoryFormScreen extends ConsumerStatefulWidget {
  final StoryDto? story;

  const StoryFormScreen({super.key, this.story});

  bool get isEditing => story != null;

  @override
  ConsumerState<StoryFormScreen> createState() => _StoryFormScreenState();
}

class _StoryFormScreenState extends ConsumerState<StoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverImageUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.story != null) {
      _titleController.text = widget.story!.title;
      _descriptionController.text = widget.story!.description ?? '';
      _coverImageUrlController.text = widget.story!.coverImageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coverImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(storyAdminServiceProvider);

      if (widget.isEditing) {
        final request = UpdateStoryRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          coverImageUrl: _coverImageUrlController.text.trim().isEmpty
              ? null
              : _coverImageUrlController.text.trim(),
        );
        await service.updateStory(widget.story!.id, request);
        if (mounted) _showSnackbar('Story updated successfully!');
      } else {
        final request = CreateStoryRequest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          coverImageUrl: _coverImageUrlController.text.trim().isEmpty
              ? null
              : _coverImageUrlController.text.trim(),
        );
        await service.createStory(request);
        if (mounted) _showSnackbar('Story created successfully!');
      }

      ref.invalidate(storiesListProvider);
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
    } on StoryAdminException catch (e) {
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
          widget.isEditing ? 'Edit Story' : 'Create Story',
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
            'Saving story...',
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
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration(
                    isDark: isDark,
                    labelText: 'Title *',
                    hintText: 'Enter story title',
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

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: _inputDecoration(
                    isDark: isDark,
                    labelText: 'Description',
                    hintText: 'Enter story description',
                    prefixIcon: Icons.description,
                  ),
                  style: TextStyle(
                    color: isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText,
                  ),
                  maxLines: 4,
                  maxLength: 2000,
                ),
                const SizedBox(height: DesignSpacing.md),

                // Cover Image URL field
                TextFormField(
                  controller: _coverImageUrlController,
                  decoration: _inputDecoration(
                    isDark: isDark,
                    labelText: 'Cover Image URL',
                    hintText: 'https://example.com/cover.jpg',
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
                      widget.isEditing ? 'Update Story' : 'Create Story',
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
