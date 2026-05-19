import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medident/core/models/delivery/delivery-track-model.dart';

class OsrmRouteService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<List<DeliveryTrackPoint>> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/$originLng,$originLat;$destLng,$destLat'
      '?geometries=geojson&overview=full&steps=false',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('OSRM error ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;

      if (routes == null || routes.isEmpty) {
        throw Exception('OSRM: sin rutas');
      }

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List;

      final now = DateTime.now();
      final totalDuration = (route['duration'] as num?)?.toDouble() ?? 60;
      final pointCount = coordinates.length;
      final interval = (totalDuration / pointCount * 1000).round();

      final points = <DeliveryTrackPoint>[];
      for (var i = 0; i < coordinates.length; i++) {
        final coord = coordinates[i] as List;
        points.add(DeliveryTrackPoint(
          latitude: (coord[1] as num).toDouble(),
          longitude: (coord[0] as num).toDouble(),
          timestamp: now.add(Duration(milliseconds: i * interval)),
        ));
      }

      return points;
    } on TimeoutException {
      throw Exception('OSRM: timeout');
    } catch (e) {
      throw Exception('OSRM: ${e.toString()}');
    }
  }
}
