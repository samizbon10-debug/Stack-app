import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'lock_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate minimum splash time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check auth state
    final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) {
        if (user != null) {
          // Check if PIN/biometric lock is enabled
          _checkLockAndNavigate(user);
        } else {
          _navigateToAuth();
        }
      },
      loading: () {
        // Still loading, wait
      },
      error: (_, __) {
        _navigateToAuth();
      },
    );
  }

  Future<void> _checkLockAndNavigate(user) async {
    final authService = ref.read(authServiceProvider);
    final hasPin = await authService.hasPinLock();
    final biometricEnabled = await authService.isBiometricEnabled();

    if (hasPin || biometricEnabled) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LockScreen()),
        );
      }
    } else {
      _navigateToHome();
    }
  }

  void _navigateToAuth() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 60,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.5, 0.5),
                )
                .fadeIn(duration: 300.ms),

            const SizedBox(height: 24),

            // App Name
            Text(
              'Dental Case Manager',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Your Dental Records, Securely Managed',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms)
                .scale(begin: const Offset(0.5, 0.5), duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
