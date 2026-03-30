import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../animations/app_animations.dart';
import '../widgets/treatment_card.dart';
import 'add_treatment_screen.dart';
import 'add_patient_screen.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  final PatientModel patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  ConsumerState<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PatientModel _patient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _patient = widget.patient;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final treatments = ref.watch(patientTreatmentsProvider(_patient.id));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            _buildInfoSection(),
            _buildTabBar(),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildTreatmentsTab(treatments),
            _buildGalleryTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTreatment,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'patient_photo_${_patient.id}',
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.3),
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ],
                  image: _patient.profilePhotoUrl != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(_patient.profilePhotoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _patient.profilePhotoUrl == null
                    ? Center(
                        child: Text(
                          _patient.initials,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _editPatient,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share patient info
          },
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            Text(
              _patient.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInfoChip(Icons.phone, _patient.phone),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.cake, '${_patient.age} years'),
                const SizedBox(width: 8),
                _buildInfoChip(
                  _patient.gender == Gender.male
                      ? Icons.male
                      : _patient.gender == Gender.female
                          ? Icons.female
                          : Icons.person,
                  _patient.genderDisplay,
                ),
              ],
            ),
            if (_patient.allergies.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _patient.allergies.map((allergy) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 14,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          allergy,
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            if (_patient.smokingStatus) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.smoking_rooms,
                      size: 14,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Smoker',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Treatments'),
            Tab(text: 'Gallery'),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_patient.medicalHistory.isNotEmpty) ...[
            _buildSection(
              'Medical History',
              Icons.medical_information,
              _patient.medicalHistory,
            ),
            const SizedBox(height: 16),
          ],
          if (_patient.notes.isNotEmpty) ...[
            _buildSection(
              'Notes',
              Icons.notes,
              _patient.notes,
            ),
            const SizedBox(height: 16),
          ],
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, String content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Treatment',
                Icons.add_circle,
                AppTheme.primaryColor,
                _addTreatment,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Book Appointment',
                Icons.calendar_today,
                AppTheme.accentColor,
                () {
                  // Navigate to appointment
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTreatmentsTab(AsyncValue<List<TreatmentModel>> treatments) {
    return treatments.when(
      data: (list) {
        if (list.isEmpty) {
          return _buildEmptyState('No treatments yet', Icons.healing);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return TreatmentCard(
              treatment: list[index],
              onTap: () {
                // Navigate to treatment detail
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildEmptyState('Error loading treatments', Icons.error),
    );
  }

  Widget _buildGalleryTab() {
    return Consumer(
      builder: (context, ref, child) {
        final treatments = ref.watch(patientTreatmentsProvider(_patient.id));
        
        return treatments.when(
          data: (list) {
            final images = list
                .expand((t) => t.images)
                .toList();

            if (images.isEmpty) {
              return _buildEmptyState('No photos yet', Icons.photo_library);
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return AppAnimations.galleryGridItem(
                  index: index,
                  child: GestureDetector(
                    onTap: () {
                      // Open full screen image
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: image.url,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              color: Colors.black54,
                              child: Text(
                                image.labelDisplay,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildEmptyState('Error loading photos', Icons.error),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _addTreatment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTreatmentScreen(patientId: _patient.id),
        fullscreenDialog: true,
      ),
    );
  }

  void _editPatient() async {
    final result = await Navigator.of(context).push<PatientModel>(
      MaterialPageRoute(
        builder: (_) => AddPatientScreen(patient: _patient),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      setState(() {
        _patient = result;
      });
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
