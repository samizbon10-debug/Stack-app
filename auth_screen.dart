import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../animations/app_animations.dart';
import 'home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.signInWithGoogle();

      if (result.success) {
        // Initialize Google Drive service
        final driveService = ref.read(googleDriveServiceProvider);
        await driveService.signIn();

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo and branding
              _buildHeader(),

              const Spacer(flex: 2),

              // Sign in button
              _buildSignInButton(),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(),
              ],

              const Spacer(),

              // Terms and privacy
              _buildTermsText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services_rounded,
            size: 50,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(duration: 500.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 300.ms),

        const SizedBox(height: 24),

        // App name
        Text(
          'Dental Case Manager',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

        const SizedBox(height: 12),

        // Tagline
        Text(
          'Securely manage your dental practice',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

        const SizedBox(height: 32),

        // Features list
        _buildFeaturesList(),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.people, 'text': 'Patient Management'},
      {'icon': Icons.medication, 'text': 'Treatment Records'},
      {'icon': Icons.photo_library, 'text': 'Clinical Photos'},
      {'icon': Icons.cloud_upload, 'text': 'Auto Backup to Drive'},
    ];

    return Column(
      children: features
          .asMap()
          .entries
          .map((entry) => Animate(
                delay: Duration(milliseconds: 600 + (entry.key * 100)),
                effects: [
                  FadeEffect(duration: 400.ms),
                  SlideEffect(
                    begin: const Offset(-0.2, 0),
                    end: Offset.zero,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          entry.value['icon'] as IconData,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        entry.value['text'] as String,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSignInButton() {
    return AnimatedPress(
      onPressed: _isLoading ? () {} : _signInWithGoogle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              )
            else ...[
              // Google Logo
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://www.google.com/favicon.ico',
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Continue with Google',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    ).animate().shake(duration: 500.ms);
  }

  Widget _buildTermsText() {
    return Text(
      'By signing in, you agree to our Terms of Service\nand Privacy Policy',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textHint,
          ),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 1200.ms);
  }
}
