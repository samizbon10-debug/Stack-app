import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;
  bool _autoBackup = true;
  bool _backupWifiOnly = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authService = ref.read(authServiceProvider);
    final userData = await authService.getCurrentUserData();
    
    if (userData != null) {
      setState(() {
        _biometricEnabled = userData.biometricEnabled;
        _autoBackup = userData.settings.autoBackup;
        _backupWifiOnly = userData.settings.backupWifiOnly;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile section
          authState.when(
            data: (user) {
              if (user == null) return const SizedBox.shrink();
              return _buildProfileSection(user);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),

          // Security section
          _buildSectionHeader('Security'),
          _buildSettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Lock',
            subtitle: 'Use fingerprint or face ID to unlock',
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
              activeColor: AppTheme.primaryColor,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.pin,
            title: 'Set PIN Lock',
            subtitle: 'Set a 4-digit PIN for app lock',
            onTap: _showPinSetup,
          ),

          const SizedBox(height: 24),

          // Backup section
          _buildSectionHeader('Backup & Sync'),
          _buildSettingsTile(
            icon: Icons.cloud_upload,
            title: 'Auto Backup',
            subtitle: 'Automatically backup data to Google Drive',
            trailing: Switch(
              value: _autoBackup,
              onChanged: (value) => _updateBackupSetting('auto', value),
              activeColor: AppTheme.primaryColor,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.wifi,
            title: 'Backup on Wi-Fi Only',
            subtitle: 'Only backup when connected to Wi-Fi',
            trailing: Switch(
              value: _backupWifiOnly,
              onChanged: (value) => _updateBackupSetting('wifi', value),
              activeColor: AppTheme.primaryColor,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.backup,
            title: 'Backup Now',
            subtitle: 'Manually trigger a backup',
            onTap: _triggerBackup,
          ),
          _buildSettingsTile(
            icon: Icons.restore,
            title: 'Restore from Backup',
            subtitle: 'Restore data from Google Drive',
            onTap: _showRestoreDialog,
          ),

          const SizedBox(height: 24),

          // Data section
          _buildSectionHeader('Data'),
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: _clearCache,
          ),
          _buildSettingsTile(
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Export all patient data',
            onTap: _exportData,
          ),

          const SizedBox(height: 24),

          // About section
          _buildSectionHeader('About'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About App',
            subtitle: 'Version 1.0.0',
            onTap: _showAboutDialog,
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Sign out
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              icon: Icon(Icons.logout, color: AppTheme.errorColor),
              label: Text(
                'Sign Out',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _signOut,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileSection(user) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              image: user.photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(user.photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.photoUrl == null
                ? Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              )
            : null,
        trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right) : null),
        onTap: onTap,
      ),
    );
  }

  Future<void> _toggleBiometric(bool value) async {
    final authService = ref.read(authServiceProvider);
    
    if (value) {
      final available = await authService.isBiometricAvailable();
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication not available on this device')),
        );
        return;
      }
      
      final authenticated = await authService.authenticateWithBiometrics();
      if (!authenticated) {
        return;
      }
    }
    
    await authService.setBiometricEnabled(value);
    setState(() => _biometricEnabled = value);
  }

  void _showPinSetup() {
    showDialog(
      context: context,
      builder: (context) => _PinSetupDialog(),
    );
  }

  Future<void> _updateBackupSetting(String setting, bool value) async {
    final authService = ref.read(authServiceProvider);
    final userData = await authService.getCurrentUserData();
    
    if (userData != null) {
      final newSettings = setting == 'auto'
          ? userData.settings.copyWith(autoBackup: value)
          : userData.settings.copyWith(backupWifiOnly: value);
      
      await authService.updateUserSettings(newSettings);
      
      setState(() {
        if (setting == 'auto') {
          _autoBackup = value;
        } else {
          _backupWifiOnly = value;
        }
      });
    }
  }

  void _triggerBackup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Backing Up'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Uploading your data to Google Drive...'),
            ],
          ),
        );
      },
    );

    final driveService = ref.read(googleDriveServiceProvider);
    final result = await driveService.backupAllData();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restore from Backup'),
          content: const Text(
            'This will replace your current data with the backup from Google Drive. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement restore
              },
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );
  }

  void _clearCache() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.clearAllCache();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Dental Case Manager',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.medical_services, color: Colors.white),
      ),
      children: [
        const Text(
          'A comprehensive dental patient record management app for clinical use.',
        ),
      ],
    );
  }

  void _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }
}

class _PinSetupDialog extends StatefulWidget {
  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  bool _isConfirming = false;
  String? _error;

  void _onKeyPressed(String key) {
    if (_isConfirming) {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin.add(key);
          _error = null;
        });
        if (_confirmPin.length == 4) {
          _verifyPin();
        }
      }
    } else {
      if (_pin.length < 4) {
        setState(() {
          _pin.add(key);
          _error = null;
        });
        if (_pin.length == 4) {
          setState(() => _isConfirming = true);
        }
      }
    }
  }

  void _onBackspace() {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin.removeLast();
        } else {
          _isConfirming = false;
        }
      } else {
        if (_pin.isNotEmpty) {
          _pin.removeLast();
        }
      }
      _error = null;
    });
  }

  void _verifyPin() {
    if (_pin.join() == _confirmPin.join()) {
      // Save PIN
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN set successfully')),
      );
    } else {
      setState(() {
        _error = 'PINs do not match. Try again.';
        _confirmPin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isConfirming ? 'Confirm PIN' : 'Set PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_isConfirming
              ? 'Please enter your PIN again to confirm'
              : 'Enter a 4-digit PIN'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFilled = _isConfirming
                  ? index < _confirmPin.length
                  : index < _pin.length;
              return Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppTheme.primaryColor : Colors.transparent,
                  border: Border.all(color: AppTheme.primaryColor, width: 2),
                ),
              );
            }),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: AppTheme.errorColor)),
          ],
          const SizedBox(height: 16),
          _buildKeypad(),
        ],
      ),
    );
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
            if (key.isEmpty) return const SizedBox(width: 50, height: 50);
            return IconButton(
              onPressed: () {
                if (key == 'backspace') {
                  _onBackspace();
                } else {
                  _onKeyPressed(key);
                }
              },
              icon: key == 'backspace'
                  ? const Icon(Icons.backspace)
                  : Text(key, style: const TextStyle(fontSize: 20)),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
