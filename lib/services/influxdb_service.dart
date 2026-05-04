import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/sensor_data.dart';

class InfluxDBService {
  final String _baseUrl = ApiConfig.influxUrl;
  final String _token = ApiConfig.influxToken;
  final String _org = ApiConfig.influxOrg;

  Map<String, String> get _queryHeaders => {
        'Authorization': 'Token $_token',
        'Content-Type': 'application/vnd.flux',
        'Accept': 'application/csv',
      };

  /// Execute Flux query and return parsed results
  Future<List<Map<String, dynamic>>> _executeQuery(String fluxQuery) async {
    final uri = Uri.parse('$_baseUrl/api/v2/query?org=$_org');

    try {
      final response = await http.post(
        uri,
        headers: _queryHeaders,
        body: fluxQuery,
      );

      if (response.statusCode == 200) {
        return _parseCSVResponse(response.body);
      } else {
        print(
            'InfluxDB query failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('InfluxDB connection error: $e');
      return [];
    }
  }

  /// Parse CSV response from InfluxDB
  List<Map<String, dynamic>> _parseCSVResponse(String csvData) {
    final lines = csvData.split('\n').where((line) => line.isNotEmpty).toList();
    if (lines.isEmpty) return [];

    final results = <Map<String, dynamic>>[];
    List<String>? headers;

    for (final line in lines) {
      if (line.startsWith('#') || line.trim().isEmpty) continue;

      final values = _parseCSVLine(line);

      if (headers == null) {
        headers = values;
        continue;
      }

      if (values.length == headers.length) {
        final row = <String, dynamic>{};
        for (var i = 0; i < headers.length; i++) {
          row[headers[i]] = values[i];
        }
        results.add(row);
      }
    }

    return results;
  }

  List<String> _parseCSVLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString().trim());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString().trim());
    return result;
  }

  /// Get unprocessed raw sensor data (where taken = 0)
  Future<List<RawSensorPoint>> getUnprocessedRawData() async {
    const query = '''
from(bucket: "${ApiConfig.bucketRaw}")
  |> range(start: -1h)
  |> filter(fn: (r) => r["_measurement"] == "water_quality")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> filter(fn: (r) => r["taken"] == 0 or r["taken"] == 0.0)
  |> sort(columns: ["_time"], desc: false)
''';

    final results = await _executeQuery(query);
    return results
        .map((row) => _mapToRawSensorPoint(row))
        .whereType<RawSensorPoint>()
        .toList();
  }

  /// Get latest processed sensor data for dashboard
  Future<SensorData?> getLatestProcessedData() async {
    const query = '''
from(bucket: "${ApiConfig.bucketProcessed}")
  |> range(start: -24h)
  |> filter(fn: (r) => r["_measurement"] == "prediction")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> sort(columns: ["_time"], desc: true)
  |> limit(n: 1)
''';

    final results = await _executeQuery(query);
    if (results.isEmpty) return null;

    return _mapToSensorData(results.first);
  }

  /// Get sensor data history for History page
  Future<List<SensorData>> getProcessedDataHistory({
    Duration range = const Duration(hours: 24),
    int limit = 50,
  }) async {
    final rangeStr = '-${range.inHours}h';

    final query = '''
from(bucket: "${ApiConfig.bucketProcessed}")
  |> range(start: $rangeStr)
  |> filter(fn: (r) => r["_measurement"] == "prediction")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> sort(columns: ["_time"], desc: true)
  |> limit(n: $limit)
''';

    final results = await _executeQuery(query);
    return results
        .map((row) => _mapToSensorData(row))
        .whereType<SensorData>()
        .toList();
  }

  RawSensorPoint? _mapToRawSensorPoint(Map<String, dynamic> row) {
    try {
      DateTime timestamp;
      if (row['_time'] != null) {
        timestamp = DateTime.parse(row['_time'].toString());
      } else {
        return null;
      }

      final timestampNano = _parseNanoseconds(row['_time']) ??
          (timestamp.microsecondsSinceEpoch * 1000);

      return RawSensorPoint(
        temperature: _parseDouble(row['temperature']) ?? 0,
        ph: _parseDouble(row['ph']) ?? 0,
        turbidity: _parseDouble(row['turbidity']) ?? 0,
        taken: _parseDouble(row['taken'])?.toInt() ?? 0,
        timestamp: timestamp,
        timestampNano: timestampNano,
      );
    } catch (e) {
      print('Error mapping raw sensor point: $e');
      return null;
    }
  }

  int? _parseNanoseconds(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  SensorData? _mapToSensorData(Map<String, dynamic> row) {
    try {
      DateTime timestamp;
      if (row['_time'] != null) {
        timestamp = DateTime.parse(row['_time'].toString());
      } else {
        timestamp = DateTime.now();
      }

      final temperature = _parseDouble(row['temperature']) ?? 25.0;
      final turbidity = _parseDouble(row['turbidity']) ?? 15.0;
      final ph = _parseDouble(row['ph']) ?? 7.0;
      final ammonia = _parseDouble(row['ammonia']) ?? 0.2;
      // 'do' is the field name in InfluxDB for dissolved oxygen
      final dissolvedOxygen = _parseDouble(row['do']) ?? 6.0;
      final qualityCode = _parseDouble(row['quality_code'])?.toInt() ?? 0;

      return SensorData(
        id: timestamp.millisecondsSinceEpoch,
        temperature: temperature,
        turbidity: turbidity,
        ph: ph,
        ammonia: ammonia,
        dissolvedOxygen: dissolvedOxygen,
        qualityCode: qualityCode,
        taken: 1,
        timestamp: timestamp,
      );
    } catch (e) {
      print('Error mapping sensor data: $e');
      return null;
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$_baseUrl/ping');
      final response = await http.get(uri);
      return response.statusCode == 204;
    } catch (e) {
      print('InfluxDB ping failed: $e');
      return false;
    }
  }
}

/// Raw sensor point from raw_sensors bucket
class RawSensorPoint {
  final double temperature;
  final double ph;
  final double turbidity;
  final int taken;
  final DateTime timestamp;
  final int timestampNano;

  RawSensorPoint({
    required this.temperature,
    required this.ph,
    required this.turbidity,
    required this.taken,
    required this.timestamp,
    required this.timestampNano,
  });
}
