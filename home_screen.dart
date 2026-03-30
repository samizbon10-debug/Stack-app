import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../animations/app_animations.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/upcoming_appointments_card.dart';
import '../widgets/backup_status_card.dart';
import '../widgets/search_bar_widget.dart';
import 'patients_screen.dart';
import 'treatments_screen.dart';
import 'appointments_screen.dart';
import 'case_gallery_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          PatientsScreen(),
          AppointmentsScreen(),
          CaseGalleryScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends ConsumerStatefulWidget {
  const _DashboardTab();

  @override
  ConsumerState<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<_DashboardTab> {
  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientsProvider);
    final upcomingAppointments = ref.watch(upcomingAppointmentsProvider);

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          backgroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.medical_services,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dental Case Manager',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),

        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBarWidget(
              onSearch: (query) {
                ref.read(searchQueryProvider.notifier).state = query;
              },
            ),
          ),
        ),

        // Quick Stats
        SliverToBoxAdapter(
          child: _buildQuickStats(patients),
        ),

        // Dashboard Cards Grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            delegate: SliverChildListDelegate([
              _buildDashboardCard(
                title: 'Patients',
                icon: Icons.people,
                color: AppTheme.primaryColor,
                count: patients.length,
                onTap: () => _navigateToPatients(),
                index: 0,
              ),
              _buildDashboardCard(
                title: 'Orthodontics',
                icon: Icons.straighten,
                color: AppTheme.orthodonticsColor,
                count: 0, // Will be updated with actual count
                onTap: () => _navigateToTreatments(TreatmentCategory.orthodontics),
                index: 1,
              ),
              _buildDashboardCard(
                title: 'Fillings',
                icon: Icons.healing,
                color: AppTheme.fillingsColor,
                count: 0,
                onTap: () => _navigateToTreatments(TreatmentCategory.fillings),
                index: 2,
              ),
              _buildDashboardCard(
                title: 'Scaling & Polishing',
                icon: Icons.clean_hands,
                color: AppTheme.scalingColor,
                count: 0,
                onTap: () => _navigateToTreatments(TreatmentCategory.scalingPolishing),
                index: 3,
              ),
            ]),
          ),
        ),

        // Upcoming Appointments
        SliverToBoxAdapter(
          child: upcomingAppointments.when(
            data: (appointments) {
              if (appointments.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: UpcomingAppointmentsCard(appointments: appointments.take(3).toList()),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),

        // Backup Status
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const BackupStatusCard(),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildQuickStats(List<PatientModel> patients) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.people,
            label: 'Total Patients',
            value: patients.length.toString(),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          upcomingAppointmentsWidget(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget upcomingAppointmentsWidget() {
    return Consumer(
      builder: (context, ref, child) {
        final upcoming = ref.watch(upcomingAppointmentsProvider);
        return upcoming.when(
          data: (appointments) => _buildStatItem(
            icon: Icons.calendar_today,
            label: 'Upcoming',
            value: appointments.length.toString(),
          ),
          loading: () => _buildStatItem(
            icon: Icons.calendar_today,
            label: 'Upcoming',
            value: '...',
          ),
          error: (_, __) => _buildStatItem(
            icon: Icons.calendar_today,
            label: 'Upcoming',
            value: '0',
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
    required int index,
  }) {
    return AppAnimations.animatedCard(
      delay: Duration(milliseconds: index * 100),
      onTap: onTap,
      child: DashboardCard(
        title: title,
        icon: icon,
        color: color,
        count: count,
      ),
    );
  }

  void _navigateToPatients() {
    setState(() => _currentIndex = 1);
  }

  void _navigateToTreatments(TreatmentCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TreatmentsScreen(category: category),
      ),
    );
  }
}
