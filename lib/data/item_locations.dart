import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Simple in-memory store for item locations.
/// Currently used for the example item with id 'KEY'.
class ItemLocations {
  static final Map<String, LatLng> _locations = {
    // Updated to Tugu Yogyakarta (Tugu Jogja) per user request
    'KEY': const LatLng(-7.797068, 110.370529),
  };

  static LatLng get(String id) {
    return _locations[id]!;
  }

  static void set(String id, LatLng loc) {
    _locations[id] = loc;
  }

  static bool contains(String id) => _locations.containsKey(id);
}
