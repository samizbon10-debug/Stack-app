import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../animations/app_animations.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/patient_card.dart';
import 'patient_detail_screen.dart';
import 'add_patient_screen.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PatientModel> _filteredPatients = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final patients = ref.read(patientsProvider);

    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredPatients = patients.where((patient) {
        return patient.name.toLowerCase().contains(query) ||
            patient.phone.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientsProvider);
    final displayPatients = _isSearching ? _filteredPatients : patients;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Patients',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SearchBarWidget(
                onSearch: (_) {}, // Handled by listener
                hintText: 'Search by name or phone...',
              ),
            ),
          ),

          // Patient count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${displayPatients.length} patients',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Patient List
          displayPatients.isEmpty
              ? SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final patient = displayPatients[index];
                        return AppAnimations.animatedListItem(
                          index: index,
                          child: PatientCard(
                            patient: patient,
                            onTap: () => _navigateToPatient(patient),
                          ),
                        );
                      },
                      childCount: displayPatients.length,
                    ),
                  ),
                ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPatient,
        icon: const Icon(Icons.add),
        label: const Text('Add Patient'),
        heroTag: 'add_patient_fab',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSearching ? Icons.search_off : Icons.people_outline,
              size: 50,
              color: AppTheme.primaryColor,
            ),
          )
              .animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            _isSearching ? 'No patients found' : 'No patients yet',
            style: Theme.of(context).textTheme.titleLarge,
          )
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            _isSearching
                ? 'Try a different search term'
                : 'Tap the button below to add your first patient',
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  void _navigateToPatient(PatientModel patient) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(patient: patient),
      ),
    );
  }

  void _addPatient() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddPatientScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}
