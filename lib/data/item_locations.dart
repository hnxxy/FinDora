import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Simple in-memory store for item locations.
<<<<<<< HEAD
/// Mostly deprecated in favor of Firestore real-time updates.
/// Kept for compatibility only.
class ItemLocations {
  // Tidak ada hardcoded default location - semuanya dari GPS IoT
  // Jika IoT belum update, gunakan null untuk menandakan "waiting for GPS data"
  static LatLng? defaultLocation;

  static final Map<String, LatLng> _locations = {};

  static LatLng? get(String id) {
    return _locations[id] ?? defaultLocation;
=======
/// Currently used for the example item with id 'KEY'.
class ItemLocations {
  static final Map<String, LatLng> _locations = {
    // Updated to Tugu Yogyakarta (Tugu Jogja) per user request
    'KEY': const LatLng(-7.797068, 110.370529),
  };

  static LatLng get(String id) {
    return _locations[id]!;
>>>>>>> e89f8af8ef25e0991779b477d20a0b99a9eb2a66
  }

  static void set(String id, LatLng loc) {
    _locations[id] = loc;
  }

<<<<<<< HEAD
  static void setDefaultLocation(LatLng loc) {
    defaultLocation = loc;
  }

  static bool contains(String id) => _locations.containsKey(id);

  static void clear() {
    _locations.clear();
  }
=======
  static bool contains(String id) => _locations.containsKey(id);
>>>>>>> e89f8af8ef25e0991779b477d20a0b99a9eb2a66
}
