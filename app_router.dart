import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_service.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/patients/presentation/pages/patient_list_page.dart';
import '../../features/patients/presentation/pages/patient_detail_page.dart';
import '../../features/patients/presentation/pages/patient_form_page.dart';
import '../../features/treatments/presentation/pages/treatment_form_page.dart';
import '../../features/gallery/presentation/pages/case_gallery_page.dart';

/// App Router Configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/splash';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute && state.matchedLocation != '/splash') {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // Patients
      GoRoute(
        path: '/patients',
        name: 'patients',
        builder: (context, state) => const PatientListPage(),
        routes: [
          // New Patient
          GoRoute(
            path: 'new',
            name: 'new_patient',
            builder: (context, state) => const PatientFormPage(),
          ),
          // Patient Detail
          GoRoute(
            path: ':patientId',
            name: 'patient_detail',
            builder: (context, state) {
              final patientId = state.pathParameters['patientId']!;
              return PatientDetailPage(patientId: patientId);
            },
            routes: [
              // Edit Patient
              GoRoute(
                path: 'edit',
                name: 'edit_patient',
                builder: (context, state) {
                  final patientId = state.pathParameters['patientId']!;
                  return PatientFormPage(patientId: patientId);
                },
              ),
              // New Treatment for Patient
              GoRoute(
                path: 'treatments/new',
                name: 'new_treatment',
                builder: (context, state) {
                  final patientId = state.pathParameters['patientId']!;
                  return TreatmentFormPage(patientId: patientId);
                },
              ),
            ],
          ),
        ],
      ),

      // Gallery
      GoRoute(
        path: '/gallery',
        name: 'gallery',
        builder: (context, state) => const CaseGalleryPage(),
      ),

      // Search
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});

// Placeholder pages for routes not yet fully implemented
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search patients, treatments...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
      ),
      body: _searchQuery.isEmpty
          ? const Center(child: Text('Start typing to search'))
          : const Center(child: Text('Search results')),
    );
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // User info
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(user?.displayName ?? 'User'),
            subtitle: Text(user?.email ?? ''),
          ),
          const Divider(),

          // Backup settings
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Google Drive Backup'),
            subtitle: const Text('Not connected'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          // Biometric lock
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Lock'),
            subtitle: const Text('Use fingerprint to unlock app'),
            value: false,
            onChanged: (value) {},
          ),

          // Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text('Appointment reminders'),
            value: true,
            onChanged: (value) {},
          ),

          const Divider(),

          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text('Sign Out',
                style: TextStyle(color: AppTheme.errorColor)),
            onTap: () async {
              final authService = ref.read(authServiceProvider);
              await authService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
