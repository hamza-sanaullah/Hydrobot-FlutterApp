import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/alert.dart';

/// Water Quality Monitoring Service
/// Handles communication with WQM backend for water quality predictions
class WQMService {
  final String _baseUrl = ApiConfig.backendBaseUrl;

  /// Send sensor data to Water Quality Monitoring endpoint
  /// Returns alert message from ML pipeline
  Future<Alert?> getWaterQualityPrediction({
    required double temp,
    required double ph,
    required double turbidity,
    required int timestampNano,
  }) async {
    final uri = Uri.parse('$_baseUrl${ApiConfig.wqmEndpoint}');

    try {
      final payload = {
        'temp': temp,
        'ph': ph,
        'turbidity': turbidity,
        'timestamp': timestampNano,
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final alertMessage = data['alert'] as String?;

        if (alertMessage != null && alertMessage.isNotEmpty) {
          return Alert(
            id: DateTime.now().millisecondsSinceEpoch,
            type: AlertType.waterQuality,
            message: alertMessage,
            timestamp: DateTime.now(),
            read: false,
          );
        }
      } else {
        print('WQM request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('WQM connection error: $e');
    }

    return null;
  }

  /// Test WQM backend connection
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl/docs');
      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (e) {
      print('WQM backend connection test failed: $e');
      return false;
    }
  }
}
