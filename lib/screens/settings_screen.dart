import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hydrobot_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Notifications Toggle
                _buildSettingsCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Enable Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.gray700,
                        ),
                      ),
                      Switch(
                        value: provider.notificationsEnabled,
                        onChanged: (value) {
                          provider.setNotificationsEnabled(value);
                        },
                        activeThumbColor: AppTheme.gray900,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Polling Interval
                _buildSettingsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Polling Interval',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.gray100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.gray300),
                        ),
                        child: DropdownButton<int>(
                          value: provider.pollingIntervalSeconds,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1 second')),
                            DropdownMenuItem(
                                value: 3, child: Text('3 seconds')),
                            DropdownMenuItem(
                                value: 5, child: Text('5 seconds')),
                            DropdownMenuItem(
                                value: 10, child: Text('10 seconds')),
                            DropdownMenuItem(
                                value: 15, child: Text('15 seconds (Default)')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              provider.setPollingInterval(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'How often to check for new sensor data',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // System Status
                _buildSettingsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'System Status',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.gray600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _StatusRow(
                        label: 'WQM Service',
                        isConnected: provider.wqmConnected,
                      ),
                      const SizedBox(height: 8),
                      _StatusRow(
                        label: 'InfluxDB',
                        isConnected: provider.influxConnected,
                      ),
                      const SizedBox(height: 8),
                      _StatusRow(
                        label: 'FHD Service',
                        isConnected: provider.fhdConnected,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // About Section
                _buildSettingsCard(
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.gray600,
                        ),
                      ),
                      SizedBox(height: 12),
                      _AboutRow(label: 'App Name', value: 'HydroBot'),
                      SizedBox(height: 8),
                      _AboutRow(label: 'Version', value: '1.0.0'),
                      SizedBox(height: 8),
                      _AboutRow(label: 'Build', value: '2026.01.21'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray300),
      ),
      child: child,
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool isConnected;

  const _StatusRow({
    required this.label,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.gray700,
          ),
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isConnected ? AppTheme.green500 : AppTheme.red500,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(
                fontSize: 14,
                color: isConnected ? AppTheme.green500 : AppTheme.red500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.gray700,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.gray500,
          ),
        ),
      ],
    );
  }
}
