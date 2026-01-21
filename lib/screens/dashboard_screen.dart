import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/hydrobot_provider.dart';
import '../theme/app_theme.dart';
import '../models/sensor_data.dart';
import '../models/alert.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HydroBot'),
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
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Water Quality Status Card
                  _buildStatusCard(provider.latestSensorData),
                  const SizedBox(height: 16),

                  // Factor Contribution Pie Chart
                  _buildPieChartCard(provider.latestSensorData),
                  const SizedBox(height: 16),

                  // Recent Alerts Preview
                  if (provider.recentAlerts.isNotEmpty)
                    _buildRecentAlertsCard(context, provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(SensorData? data) {
    final quality = _getWaterQualityStatus(data);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray300, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Water Quality Status',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 16),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: quality.color,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              quality.status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (data != null)
            Text(
              'Last updated: ${_formatTime(data.timestamp)}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.gray500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(SensorData? data) {
    final pieData = _getPieChartData(data);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Factor Contribution',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 16),

          // Pie Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: pieData.map((item) {
                  return PieChartSectionData(
                    value: item['value'] as double,
                    color: item['color'] as Color,
                    title: '',
                    radius: 80,
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: pieData.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.gray600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAlertsCard(BuildContext context, HydrobotProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Alerts',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.gray600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate handled by parent
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.blue500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...provider.recentAlerts.map((alert) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: alert.type == AlertType.waterQuality
                          ? AppTheme.blue500
                          : AppTheme.orange500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert.messagePreview,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  ({String status, Color color}) _getWaterQualityStatus(SensorData? data) {
    if (data == null) {
      return (status: 'Unknown', color: AppTheme.gray500);
    }

    final phOk = data.ph >= 6.8 && data.ph <= 7.5;
    final tempOk = data.temperature >= 24 && data.temperature <= 28;
    final turbidityOk = data.turbidity < 20;

    if (phOk && tempOk && turbidityOk) {
      return (status: 'Excellent', color: AppTheme.greenStatus);
    } else if (phOk || tempOk) {
      return (status: 'Good', color: AppTheme.yellowStatus);
    } else {
      return (status: 'Poor', color: AppTheme.redStatus);
    }
  }

  List<Map<String, dynamic>> _getPieChartData(SensorData? data) {
    if (data == null) {
      return [
        {'name': 'pH', 'value': 20.0, 'color': AppTheme.blue500},
        {'name': 'Temperature', 'value': 20.0, 'color': AppTheme.red500},
        {'name': 'Turbidity', 'value': 20.0, 'color': AppTheme.amber500},
        {'name': 'Dissolved O₂', 'value': 20.0, 'color': AppTheme.green500},
        {'name': 'Ammonia', 'value': 20.0, 'color': AppTheme.purple500},
      ];
    }

    return [
      {'name': 'pH', 'value': (7.2 - data.ph).abs() * 10, 'color': AppTheme.blue500},
      {'name': 'Temperature', 'value': (26 - data.temperature).abs() * 2, 'color': AppTheme.red500},
      {'name': 'Turbidity', 'value': data.turbidity / 2, 'color': AppTheme.amber500},
      {'name': 'Dissolved O₂', 'value': (7 - data.dissolvedOxygen).abs() * 3, 'color': AppTheme.green500},
      {'name': 'Ammonia', 'value': data.ammonia * 20, 'color': AppTheme.purple500},
    ];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
