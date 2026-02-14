import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/alert.dart';

/// Fish Health Detection Service
/// Handles communication with FHD backend for fish disease detection
class FHDService {
  final String _baseUrl = ApiConfig.fhdBaseUrl;

  /// Send empty request to Fish Health Detection endpoint
  /// Returns list of alerts from the response (one for each non-empty alert_msg)
  Future<List<Alert>> getFishHealthPredictions() async {
    final uri = Uri.parse('$_baseUrl${ApiConfig.fhdEndpoint}');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({}), // Empty payload as required
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final alerts = <Alert>[];
        final baseTimestamp = DateTime.now();

        // Parse all alert_msg fields from response
        // Keys are like: alert_msg1, alert_msg2, ..., alert_msgN
        final sortedKeys = data.keys
            .where((key) => key.startsWith('alert_msg'))
            .toList()
          ..sort((a, b) {
            final numA = int.tryParse(a.replaceAll('alert_msg', '')) ?? 0;
            final numB = int.tryParse(b.replaceAll('alert_msg', '')) ?? 0;
            return numA.compareTo(numB);
          });

        for (int i = 0; i < sortedKeys.length; i++) {
          final key = sortedKeys[i];
          final message = data[key] as String?;

          // Only create alert for non-empty messages
          if (message != null && message.trim().isNotEmpty) {
            alerts.add(Alert(
              id: baseTimestamp.millisecondsSinceEpoch + i,
              type: AlertType.fishHealth,
              message: message.trim(),
              timestamp: baseTimestamp.add(Duration(milliseconds: i)),
              read: false,
            ));
          }
        }

        return alerts;
      } else {
        print('FHD request failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('FHD connection error: $e');
    }

    return [];
  }

  /// Test FHD backend connection
  Future<bool> testConnection() async {
    try {
      // Send empty POST request to test connection
      final uri = Uri.parse('$_baseUrl${ApiConfig.fhdEndpoint}');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('FHD backend connection test failed: $e');
      return false;
    }
  }
}
