import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class TreatmentCard extends StatelessWidget {
  final TreatmentModel treatment;
  final Color? color;
  final VoidCallback? onTap;

  const TreatmentCard({
    super.key,
    required this.treatment,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = color ?? _getCategoryColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          treatment.category.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(treatment.date),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (treatment.toothNumber != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tooth ${treatment.toothNumber}',
                        style: TextStyle(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              // Diagnosis
              if (treatment.diagnosis.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  treatment.diagnosis,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Treatment notes
              if (treatment.treatmentNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  treatment.treatmentNotes,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Materials
              if (treatment.materialsUsed.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: treatment.materialsUsed.map((material) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        material,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Images preview
              if (treatment.images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: treatment.images.length,
                    itemBuilder: (context, index) {
                      final image = treatment.images[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: image.url,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  color: Colors.black54,
                                  child: Text(
                                    image.labelDisplay,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (treatment.category) {
      case TreatmentCategory.orthodontics:
        return AppTheme.orthodonticsColor;
      case TreatmentCategory.fillings:
        return AppTheme.fillingsColor;
      case TreatmentCategory.scalingPolishing:
        return AppTheme.scalingColor;
    }
  }

  IconData _getCategoryIcon() {
    switch (treatment.category) {
      case TreatmentCategory.orthodontics:
        return Icons.straighten;
      case TreatmentCategory.fillings:
        return Icons.healing;
      case TreatmentCategory.scalingPolishing:
        return Icons.clean_hands;
    }
  }
}
