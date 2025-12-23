import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Simple in-memory store for item locations.
/// Mostly deprecated in favor of Firestore real-time updates.
/// Kept for compatibility only.
class ItemLocations {
  // Tidak ada hardcoded default location - semuanya dari GPS IoT
  // Jika IoT belum update, gunakan null untuk menandakan "waiting for GPS data"
  static LatLng? defaultLocation;

  static final Map<String, LatLng> _locations = {};

  static LatLng? get(String id) {
    return _locations[id] ?? defaultLocation;
  }

  static void set(String id, LatLng loc) {
    _locations[id] = loc;
  }

  static void setDefaultLocation(LatLng loc) {
    defaultLocation = loc;
  }

  static bool contains(String id) => _locations.containsKey(id);

  static void clear() {
    _locations.clear();
  }
}
