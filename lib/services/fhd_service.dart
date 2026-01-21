import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/alert.dart';
import '../models/sensor_data.dart';

/// Fish Health Detection Service (Reserved for future)
/// Will handle communication with FHD backend for fish disease detection
class FHDService {
  final String _baseUrl = ApiConfig.backendBaseUrl;

  /// Send data to Fish Health Detection endpoint
  /// TODO: Implement when FHD backend is ready
  Future<Alert?> getFishHealthPrediction({
    required SensorData sensorData,
    // Add image/video data parameters when camera integration is ready
  }) async {
    // Reserved for future implementation
    // Will handle fish health monitoring via camera feed
    print('FHD endpoint not yet implemented');
    return null;
  }

  /// Test FHD backend connection
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConfig.fhdEndpoint}');
      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (e) {
      print('FHD backend connection test failed: $e');
      return false;
    }
  }
}
