import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/storyforge_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await ref.read(authProvider.notifier).register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration successful! Please sign in.'),
          backgroundColor: StoryForgeTheme.successColor,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Registration failed'),
          backgroundColor: StoryForgeTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brightness = Theme.of(context).brightness;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DesignSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Title
                      Icon(
                        Icons.auto_stories,
                        size: StoryForgeTheme.iconSizeXL,
                        color: StoryForgeTheme.primaryColor,
                      ),
                      const SizedBox(height: DesignSpacing.md),
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? DesignColors.dPrimaryText
                              : DesignColors.lPrimaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignSpacing.sm),
                      Text(
                        'Start your storytelling journey',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? DesignColors.dSecondaryText
                              : DesignColors.lSecondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DesignSpacing.xl),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(
                            color: isDark
                                ? DesignColors.dSecondaryText
                                : DesignColors.lSecondaryText,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outlined,
                            size: StoryForgeTheme.iconSizeMedium,
                            color: isDark
                                ? DesignColors.dSecondaryText
                                : DesignColors.lSecondaryText,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? DesignColors.dSurfaces
                              : DesignColors.lSurfaces,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                StoryForgeTheme.inputRadius),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                StoryForgeTheme.inputRadius),
                            borderSide: const BorderSide(
                              color: StoryForgeTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                StoryForgeTheme.inputRadius),
                            borderSide: BorderSide(
                              color: isDark
                                  ? DesignColors.dDanger
                                  : DesignColors.lDanger,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: isDark
                              ? DesignColors.dPrimaryText
                              : DesignColors.lPrimaryText,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username is required';
                          }
                          if (value.trim().length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: DesignSpacing.md),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: isDark
                                ? DesignColors.dSecondaryText
                                : DesignColors.lSecondaryText,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            size: StoryForgeTheme.iconSizeMedium,
                            color: isDark
                                ? DesignColors.dSecondaryText
                                : DesignColors.lSecondaryText,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? DesignColors.dSurfaces
                              : DesignColors.lSurfaces,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                StoryForgeTheme.inputRadius),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                StoryForgeTheme.inputRadius),
                            borderSide: const BorderSide(
                              color: StoryForgeTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                StoryForgeTheme.inputRadius),
                            borderSide: BorderSide(
                              color: isDark
                                  ? DesignColors.dDanger
                                  : DesignColors.lDanger,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: isDark
                              ? DesignColors.dPrimaryText
                              : DesignColors.lPrimaryText,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: DesignSpacing.md),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: isDark
                                ? DesignColors.dSecondaryText
                                : DesignColors.lSecondaryText,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            size: StoryForgeTheme.iconSizeMedium,
                            color: isDark
                                ? DesignColors.dSecondaryText
                                : DesignColors.lSecondaryText,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: StoryForgeTheme.iconSizeMedium,
                              color: isDark
                                  ? DesignColors.dSecondaryText
                                  : DesignColors.lSecondaryText,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: isDark
                              ? DesignColors.dSurfaces
                              : DesignColors.lSurfaces,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                StoryForgeTheme.inputRadius),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                StoryForgeTheme.inputRadius),
                            borderSide: const BorderSide(
                              color: StoryForgeTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                StoryForgeTheme.inputRadius),
                            borderSide: BorderSide(
                              color: isDark
                                  ? DesignColors.dDanger
                                  : DesignColors.lDanger,
                              width: 2,
                            ),
                          ),
                          helperText: 'At least 8 characters',
                          helperStyle: TextStyle(
                            color: isDark
                                ? DesignColors.dSecondaryText
                                : DesignColors.lSecondaryText,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark
                              ? DesignColors.dPrimaryText
                              : DesignColors.lPrimaryText,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: DesignSpacing.lg),

                      // Register Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              authState.isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StoryForgeTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  StoryForgeTheme.buttonRadius),
                            ),
                            disabledBackgroundColor:
                                StoryForgeTheme.primaryColor.withValues(alpha: 0.5),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: DesignSpacing.lg),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: isDark
                                  ? DesignColors.dSecondaryText
                                  : DesignColors.lSecondaryText,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: StoryForgeTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
