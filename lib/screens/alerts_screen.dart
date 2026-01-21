import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hydrobot_provider.dart';
import '../models/alert.dart';
import '../theme/app_theme.dart';
import 'alert_detail_screen.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<HydrobotProvider>(
          builder: (context, provider, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Alerts'),
                if (provider.unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.redStatus,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${provider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.gray300,
            height: 1,
          ),
        ),
      ),
      body: Consumer<HydrobotProvider>(
        builder: (context, provider, child) {
          if (provider.alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 48,
                    color: AppTheme.gray400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alerts yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.gray400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'System is monitoring...',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.gray400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.alerts.length,
            itemBuilder: (context, index) {
              final alert = provider.alerts[index];
              return _AlertCard(
                alert: alert,
                onTap: () {
                  provider.markAlertAsRead(alert.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlertDetailScreen(alert: alert),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onTap;

  const _AlertCard({
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWaterQuality = alert.type == AlertType.waterQuality;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: alert.read ? AppTheme.gray300 : AppTheme.blue500,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isWaterQuality
                    ? AppTheme.blue500.withOpacity(0.1)
                    : AppTheme.orange500.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isWaterQuality ? Icons.water_drop : Icons.pest_control,
                color: isWaterQuality ? AppTheme.blue500 : AppTheme.orange500,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        alert.typeDisplayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.gray900,
                        ),
                      ),
                      Text(
                        _formatTime(alert.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.gray400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.messagePreview,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.gray700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!alert.read) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tap to view details',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.blue500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
