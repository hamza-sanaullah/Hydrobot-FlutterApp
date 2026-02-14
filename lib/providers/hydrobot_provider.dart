import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../models/alert.dart';
import '../services/influxdb_service.dart';
import '../services/wqm_service.dart';
import '../services/fhd_service.dart';

class HydrobotProvider extends ChangeNotifier {
  final InfluxDBService _influxService = InfluxDBService();
  final WQMService _wqmService = WQMService();
  final FHDService _fhdService = FHDService();

  List<SensorData> _sensorDataHistory = [];
  final List<Alert> _alerts = [];
  SensorData? _latestSensorData;
  Timer? _pollingTimer;

  bool _isLoading = false;
  String? _errorMessage;
  bool _influxConnected = false;
  bool _wqmConnected = false;
  bool _fhdConnected = false;

  // Settings
  int _pollingIntervalSeconds = 15;
  bool _notificationsEnabled = true;

  // Getters
  List<SensorData> get sensorDataHistory => _sensorDataHistory;
  List<Alert> get alerts => _alerts;
  SensorData? get latestSensorData => _latestSensorData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get influxConnected => _influxConnected;
  bool get wqmConnected => _wqmConnected;
  bool get fhdConnected => _fhdConnected;
  int get pollingIntervalSeconds => _pollingIntervalSeconds;
  bool get notificationsEnabled => _notificationsEnabled;

  int get unreadCount => _alerts.where((a) => !a.read).length;
  List<Alert> get recentAlerts => _alerts.take(2).toList();

  HydrobotProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    // Test connections
    _influxConnected = await _influxService.testConnection();
    _wqmConnected = await _wqmService.testConnection();
    _fhdConnected = await _fhdService.testConnection();

    // Load initial data
    await refreshDashboardData();
    await refreshHistoryData();

    // Start polling loop for raw sensor data
    _startPollingLoop();

    _isLoading = false;
    notifyListeners();
  }

  /// Start the forever polling loop to check raw_sensors bucket
  void _startPollingLoop() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: _pollingIntervalSeconds),
      (_) async {
        await _processUnprocessedRawData();
      },
    );
  }

  /// Check raw_sensors bucket for unprocessed data (taken=0) and send to WQM & FHD
  Future<void> _processUnprocessedRawData() async {
    try {
      // Get unprocessed raw data (taken = 0)
      final unprocessedData = await _influxService.getUnprocessedRawData();

      for (final rawPoint in unprocessedData) {
        // Send requests to both WQM and FHD services simultaneously
        final results = await Future.wait([
          _wqmService.getWaterQualityPrediction(
            temp: rawPoint.temperature,
            ph: rawPoint.ph,
            turbidity: rawPoint.turbidity,
            timestampNano: rawPoint.timestampNano,
          ),
          _fhdService.getFishHealthPredictions(),
        ]);

        // Process WQM alert (single alert)
        final wqmAlert = results[0] as Alert?;
        if (wqmAlert != null && _notificationsEnabled) {
          _alerts.insert(0, wqmAlert);
        }

        // Process FHD alerts (multiple alerts from response)
        final fhdAlerts = results[1] as List<Alert>;
        if (_notificationsEnabled) {
          for (final fhdAlert in fhdAlerts) {
            _alerts.insert(0, fhdAlert);
          }
        }

        // Rate Limit Protection:
        // Model Limit: 8000 TPM. Approx 1500 tokens/req => max ~5 req/min.
        // We wait 12 seconds between calls to be safe.
        await Future.delayed(const Duration(seconds: 12));

        // Backend will mark as processed (taken = 1) itself
      }

      // Refresh dashboard data after processing
      if (unprocessedData.isNotEmpty) {
        await refreshDashboardData();
        notifyListeners();
      }
    } catch (e) {
      print('Error in polling loop: $e');
    }
  }

  /// Refresh dashboard with latest processed data
  Future<void> refreshDashboardData() async {
    try {
      _latestSensorData = await _influxService.getLatestProcessedData();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch dashboard data: $e';
      notifyListeners();
    }
  }

  /// Refresh history data from processed_results bucket
  Future<void> refreshHistoryData() async {
    try {
      _sensorDataHistory = await _influxService.getProcessedDataHistory(
        range: const Duration(hours: 24),
        limit: 50,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch history data: $e';
      notifyListeners();
    }
  }

  /// Mark an alert as read
  void markAlertAsRead(int alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(read: true);
      notifyListeners();
    }
  }

  /// Mark ALL alerts as read
  void markAllAlertsAsRead() {
    for (var i = 0; i < _alerts.length; i++) {
      if (!_alerts[i].read) {
        _alerts[i] = _alerts[i].copyWith(read: true);
      }
    }
    notifyListeners();
  }

  /// Set polling interval
  void setPollingInterval(int seconds) {
    _pollingIntervalSeconds = seconds;
    _startPollingLoop();
    notifyListeners();
  }

  /// Toggle notifications
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Manual refresh
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    _influxConnected = await _influxService.testConnection();
    _wqmConnected = await _wqmService.testConnection();
    _fhdConnected = await _fhdService.testConnection();
    await refreshDashboardData();
    await refreshHistoryData();

    _isLoading = false;
    notifyListeners();
  }

  /// Reserved: Add Fish Health alert when FHD backend is ready
  void addFishHealthAlert(Alert alert) {
    if (_notificationsEnabled) {
      _alerts.insert(0, alert);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
