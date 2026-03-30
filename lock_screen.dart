import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../animations/app_animations.dart';
import 'home_screen.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final List<String> _pin = [];
  final int _pinLength = 4;
  bool _isError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final authService = ref.read(authServiceProvider);
    final biometricEnabled = await authService.isBiometricEnabled();
    
    if (biometricEnabled) {
      await _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final authService = ref.read(authServiceProvider);
    final success = await authService.authenticateWithBiometrics();
    
    if (success && mounted) {
      _navigateToHome();
    }
  }

  void _onKeyPressed(String key) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin.add(key);
        _isError = false;
      });

      if (_pin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final authService = ref.read(authServiceProvider);
    final success = await authService.verifyPin(_pin.join());

    if (success) {
      _navigateToHome();
    } else {
      setState(() {
        _isError = true;
        _errorMessage = 'Incorrect PIN. Please try again.';
        _pin.clear();
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
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

              // Header
              _buildHeader(),

              const SizedBox(height: 40),

              // PIN dots
              _buildPinDots(),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(),
              ],

              const Spacer(),

              // Keypad
              _buildKeypad(),

              const SizedBox(height: 24),

              // Biometric button
              _buildBiometricButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outline,
            size: 40,
            color: AppTheme.primaryColor,
          ),
        )
            .animate()
            .scale(duration: 500.ms, curve: Curves.elasticOut)
            .fadeIn(),

        const SizedBox(height: 24),

        Text(
          'Enter PIN',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 8),

        Text(
          'Enter your 4-digit PIN to unlock',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final isFilled = index < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? AppTheme.primaryColor
                : Colors.transparent,
            border: Border.all(
              color: _isError
                  ? AppTheme.errorColor
                  : AppTheme.primaryColor.withValues(alpha: isFilled ? 1 : 0.3),
              width: 2,
            ),
          ),
        )
            .animate(target: _isError ? 1 : 0)
            .shake(duration: 400.ms, hz: 4);
      }),
    );
  }

  Widget _buildErrorMessage() {
    return Text(
      _errorMessage!,
      style: TextStyle(
        color: AppTheme.errorColor,
        fontSize: 14,
      ),
    ).animate().fadeIn().shake(duration: 400.ms);
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'backspace'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 80, height: 80);
            }
            return _buildKey(key);
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildKey(String key) {
    final isBackspace = key == 'backspace';

    return AnimatedPress(
      onPressed: () {
        if (isBackspace) {
          _onBackspace();
        } else {
          _onKeyPressed(key);
        }
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: isBackspace
              ? Icon(
                  Icons.backspace_outlined,
                  color: AppTheme.textSecondary,
                  size: 24,
                )
              : Text(
                  key,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return FutureBuilder<bool>(
      future: ref.read(authServiceProvider).isBiometricAvailable(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();

        return TextButton.icon(
          onPressed: _authenticateWithBiometrics,
          icon: const Icon(Icons.fingerprint),
          label: const Text('Use Fingerprint'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
          ),
        ).animate().fadeIn(delay: 500.ms);
      },
    );
  }
}
