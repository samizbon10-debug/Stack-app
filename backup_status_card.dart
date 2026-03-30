import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class BackupStatusCard extends ConsumerWidget {
  const BackupStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupStatus = ref.watch(backupStatusProvider);

    return backupStatus.when(
      data: (status) => _buildCard(context, ref, status),
      loading: () => _buildLoadingCard(),
      error: (_, __) => _buildErrorCard(),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, dynamic status) {
    final isBackedUp = status.isBackedUp;
    final isBackingUp = status.isBackingUp;
    final lastBackup = status.lastBackupTime;
    final recordsCount = status.totalRecordsBackedUp;
    final imagesCount = status.totalImagesBackedUp;

    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (isBackingUp) {
      statusText = 'Backing up...';
      statusIcon = Icons.cloud_upload;
      statusColor = AppTheme.warningColor;
    } else if (isBackedUp) {
      statusText = 'All data backed up';
      statusIcon = Icons.cloud_done;
      statusColor = AppTheme.successColor;
    } else if (status.hasError) {
      statusText = 'Backup failed';
      statusIcon = Icons.cloud_off;
      statusColor = AppTheme.errorColor;
    } else {
      statusText = 'No backup yet';
      statusIcon = Icons.cloud_queue;
      statusColor = AppTheme.textSecondary;
    }

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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isBackingUp
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(statusColor),
                          ),
                        )
                      : Icon(
                          statusIcon,
                          color: statusColor,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Drive Backup',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isBackingUp)
                  TextButton(
                    onPressed: () => _triggerBackup(ref),
                    child: const Text('Backup Now'),
                  ),
              ],
            ),
            if (lastBackup != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    icon: Icons.access_time,
                    label: 'Last backup',
                    value: DateFormat('MMM d, h:mm a').format(lastBackup),
                  ),
                  _buildInfoItem(
                    icon: Icons.description,
                    label: 'Records',
                    value: recordsCount.toString(),
                  ),
                  _buildInfoItem(
                    icon: Icons.image,
                    label: 'Images',
                    value: imagesCount.toString(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Checking backup status...',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor),
            const SizedBox(width: 12),
            Text(
              'Unable to check backup status',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerBackup(WidgetRef ref) async {
    final driveService = ref.read(googleDriveServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);

    await notificationService.showBackupNotification(
      title: 'Backup Started',
      body: 'Backing up your dental records to Google Drive...',
    );

    final result = await driveService.backupAllData();

    if (result.success) {
      await notificationService.showBackupNotification(
        title: 'Backup Complete',
        body: '${result.recordsBackedUp} records and ${result.imagesBackedUp} images backed up.',
      );
    } else {
      await notificationService.showBackupNotification(
        title: 'Backup Failed',
        body: result.message,
      );
    }
  }
}
