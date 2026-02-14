import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hydrobot_provider.dart';
import '../models/sensor_data.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
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

          if (provider.sensorDataHistory.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 48,
                    color: AppTheme.gray400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No data history yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.gray400,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Processed data will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.gray400,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group by date
          final groupedData = _groupByDate(provider.sensorDataHistory);
          final dates = groupedData.keys.toList();

          return RefreshIndicator(
            onRefresh: provider.refreshHistoryData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final dataForDate = groupedData[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.gray500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.gray600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Data Cards for that date
                    ...dataForDate.map((data) => _SensorDataCard(data: data)),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Map<String, List<SensorData>> _groupByDate(List<SensorData> data) {
    final grouped = <String, List<SensorData>>{};

    for (final item in data) {
      final dateKey =
          DateFormat('MMM d, yyyy').format(item.timestamp.toLocal());
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(item);
    }

    return grouped;
  }
}

class _SensorDataCard extends StatelessWidget {
  final SensorData data;

  const _SensorDataCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with time and quality badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('HH:mm:ss').format(data.timestamp.toLocal()),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray500,
                ),
              ),
              _QualityBadge(qualityCode: data.qualityCode),
            ],
          ),
          const SizedBox(height: 12),

          // Sensor readings grid
          Row(
            children: [
              Expanded(
                child: _SensorValue(
                  label: 'Temperature',
                  value: '${data.temperature.toStringAsFixed(1)}°C',
                ),
              ),
              Expanded(
                child: _SensorValue(
                  label: 'pH',
                  value: data.ph.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SensorValue(
                  label: 'Turbidity',
                  value: data.turbidity.toStringAsFixed(1),
                ),
              ),
              Expanded(
                child: _SensorValue(
                  label: 'Ammonia',
                  value: data.ammonia.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SensorValue(
            label: 'Dissolved O₂',
            value: data.dissolvedOxygen.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }
}

class _SensorValue extends StatelessWidget {
  final String label;
  final String value;

  const _SensorValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.gray500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.gray900,
          ),
        ),
      ],
    );
  }
}

class _QualityBadge extends StatelessWidget {
  final int qualityCode;

  const _QualityBadge({required this.qualityCode});

  @override
  Widget build(BuildContext context) {
    late String text;
    late Color bgColor;
    late Color textColor;

    switch (qualityCode) {
      case 0:
        text = 'Excellent';
        bgColor = AppTheme.green500.withValues(alpha: 0.1);
        textColor = AppTheme.green500;
        break;
      case 1:
        text = 'Good';
        bgColor = AppTheme.amber500.withValues(alpha: 0.1);
        textColor = AppTheme.amber500;
        break;
      default:
        text = 'Poor';
        bgColor = AppTheme.red500.withValues(alpha: 0.1);
        textColor = AppTheme.red500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
