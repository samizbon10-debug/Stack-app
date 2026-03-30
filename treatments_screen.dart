import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/treatment_card.dart';

class TreatmentsScreen extends ConsumerWidget {
  final TreatmentCategory category;

  const TreatmentsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatments = ref.watch(treatmentsByCategoryProvider(category));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: _getCategoryColor(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(),
                      _getCategoryColor().withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(),
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          treatments.when(
            data: (list) {
              if (list.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return TreatmentCard(
                        treatment: list[index],
                        color: _getCategoryColor(),
                      ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
                    },
                    childCount: list.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (category) {
      case TreatmentCategory.orthodontics:
        return AppTheme.orthodonticsColor;
      case TreatmentCategory.fillings:
        return AppTheme.fillingsColor;
      case TreatmentCategory.scalingPolishing:
        return AppTheme.scalingColor;
    }
  }

  IconData _getCategoryIcon() {
    switch (category) {
      case TreatmentCategory.orthodontics:
        return Icons.straighten;
      case TreatmentCategory.fillings:
        return Icons.healing;
      case TreatmentCategory.scalingPolishing:
        return Icons.clean_hands;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _getCategoryColor().withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(),
              size: 50,
              color: _getCategoryColor(),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'No ${category.displayName} Cases',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            'Add treatments to see them here',
            style: TextStyle(color: AppTheme.textSecondary),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
