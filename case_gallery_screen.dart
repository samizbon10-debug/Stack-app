import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../animations/app_animations.dart';

class CaseGalleryScreen extends ConsumerStatefulWidget {
  const CaseGalleryScreen({super.key});

  @override
  ConsumerState<CaseGalleryScreen> createState() => _CaseGalleryScreenState();
}

class _CaseGalleryScreenState extends ConsumerState<CaseGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Case Gallery',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 50),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'Orthodontics'),
                  Tab(text: 'Fillings'),
                  Tab(text: 'Scaling'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGalleryTab(TreatmentCategory.orthodontics),
            _buildGalleryTab(TreatmentCategory.fillings),
            _buildGalleryTab(TreatmentCategory.scalingPolishing),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryTab(TreatmentCategory category) {
    final treatments = ref.watch(treatmentsByCategoryProvider(category));

    return treatments.when(
      data: (list) {
        // Filter treatments that have both before and after images
        final casesWithBeforeAfter = list.where((t) {
          return t.beforeImages.isNotEmpty && t.afterImages.isNotEmpty;
        }).toList();

        if (casesWithBeforeAfter.isEmpty) {
          return _buildEmptyState(category);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: casesWithBeforeAfter.length,
          itemBuilder: (context, index) {
            final treatment = casesWithBeforeAfter[index];
            return _buildCaseCard(treatment, index);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text('Error loading gallery'),
      ),
    );
  }

  Widget _buildCaseCard(TreatmentModel treatment, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Before/After comparison
          GestureDetector(
            onTap: () => _openComparison(treatment),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _buildBeforeAfterComparison(treatment),
            ),
          ),

          // Case info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(treatment.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        treatment.category.displayName,
                        style: TextStyle(
                          color: _getCategoryColor(treatment.category),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (treatment.toothNumber != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Tooth ${treatment.toothNumber}',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  treatment.diagnosis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to view full comparison',
                  style: TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 100))
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }

  Widget _buildBeforeAfterComparison(TreatmentModel treatment) {
    final beforeImage = treatment.beforeImages.first;
    final afterImage = treatment.afterImages.first;

    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: Row(
            children: [
              // Before image
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: beforeImage.url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[200]),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BEFORE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 2, color: Colors.white),
              // After image
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: afterImage.url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[200]),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'AFTER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(TreatmentCategory category) {
    switch (category) {
      case TreatmentCategory.orthodontics:
        return AppTheme.orthodonticsColor;
      case TreatmentCategory.fillings:
        return AppTheme.fillingsColor;
      case TreatmentCategory.scalingPolishing:
        return AppTheme.scalingColor;
    }
  }

  Widget _buildEmptyState(TreatmentCategory category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 50,
              color: _getCategoryColor(category),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'No ${category.displayName} Cases',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Add treatments with before and after\nphotos to see them here',
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  void _openComparison(TreatmentModel treatment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ComparisonScreen(treatment: treatment),
      ),
    );
  }
}

class _ComparisonScreen extends StatefulWidget {
  final TreatmentModel treatment;

  const _ComparisonScreen({required this.treatment});

  @override
  State<_ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<_ComparisonScreen> {
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    final beforeImage = widget.treatment.beforeImages.first;
    final afterImage = widget.treatment.afterImages.first;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.treatment.category.displayName),
      ),
      body: Column(
        children: [
          // Comparison slider
          Expanded(
            child: Stack(
              children: [
                // After image (full)
                CachedNetworkImage(
                  imageUrl: afterImage.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                // Before image (clipped)
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _sliderValue,
                    child: CachedNetworkImage(
                      imageUrl: beforeImage.url,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: double.infinity,
                    ),
                  ),
                ),
                // Slider line
                Positioned(
                  left: MediaQuery.of(context).size.width * _sliderValue - 2,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    color: Colors.white,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.compare_arrows),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Slider control
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'BEFORE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'AFTER',
                      style: TextStyle(
                        color: Colors.green.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    thumbColor: Colors.white,
                    activeTrackColor: Colors.white.withValues(alpha: 0.5),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _sliderValue,
                    onChanged: (value) {
                      setState(() => _sliderValue = value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
