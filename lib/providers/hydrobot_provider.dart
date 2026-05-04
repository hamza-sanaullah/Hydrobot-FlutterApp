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
  int _pollingIntervalSeconds = 180; // 3 minutes default
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
    _initializeAsync(); // Don't await - let it run in background
  }

  /// Initialize asynchronously without blocking UI
  void _initializeAsync() {
    _isLoading = true;
    notifyListeners();

    // Fire off initialization in background
    _runInitialization();
  }

  /// Run initialization without blocking
  Future<void> _runInitialization() async {
    try {
      // Test connections in parallel
      final results = await Future.wait([
        _influxService.testConnection(),
        _wqmService.testConnection(),
        _fhdService.testConnection(),
      ]);

      _influxConnected = results[0];
      _wqmConnected = results[1];
      _fhdConnected = results[2];

      print(
        'Connections - InfluxDB: $_influxConnected, WQM: $_wqmConnected, FHD: $_fhdConnected',
      );

      // Load initial data
      await refreshDashboardData();
      await refreshHistoryData();

    } catch (e) {
      print('Initialization error: $e');
      _errorMessage = 'Failed to initialize: $e';
    }

    _isLoading = false;
    notifyListeners();

    // Start polling loop after initialization
    _startPollingLoop();
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

  /// Check raw_sensors bucket for unprocessed data (taken=0) and send to WQM & FHD sequentially
  /// Flow: WQM (immediate render) → FHD (render immediately) → new polling cycle
  Future<void> _processUnprocessedRawData() async {
    try {
      if (!_influxConnected) {
        print('Skipping polling: InfluxDB is disconnected.');
        return;
      }

      // Get unprocessed raw data (taken = 0)
      final unprocessedData = await _influxService.getUnprocessedRawData();

      if (unprocessedData.isEmpty) {
        print('No unprocessed raw data found.');
      }

      for (final rawPoint in unprocessedData) {
        if (!_notificationsEnabled) continue;

        try {
          // Step 1: Send to WQM and wait for response
          final wqmAlert = await _wqmService.getWaterQualityPrediction(
            temp: rawPoint.temperature,
            ph: rawPoint.ph,
            turbidity: rawPoint.turbidity,
            timestampNano: rawPoint.timestampNano,
          );

          // Step 2: Add WQM alert immediately if it exists
          if (wqmAlert != null) {
            _alerts.insert(0, wqmAlert);
            notifyListeners(); // Render immediately
            print('[WQM] Alert rendered immediately');
          }

          // Refresh dashboard and history as soon as WQM returns
          await refreshDashboardData();
          await refreshHistoryData();

          // Small delay to respect rate limiting
          await Future.delayed(const Duration(seconds: 2));

          // Step 3: Send to FHD
          final fhdAlerts = await _fhdService.getFishHealthPredictions();

          // Step 4: Add FHD alerts immediately as they arrive
          if (fhdAlerts.isNotEmpty) {
            for (final fhdAlert in fhdAlerts) {
              _alerts.insert(0, fhdAlert);
            }
            notifyListeners(); // Render immediately
            print('[FHD] ${fhdAlerts.length} alert(s) rendered immediately');
          }

          // Step 5: FHD response processed above

          // Rate Limit Protection: Wait before next data point
          await Future.delayed(const Duration(seconds: 12));
        } catch (e) {
          print('Error processing raw point: $e');
        }
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
