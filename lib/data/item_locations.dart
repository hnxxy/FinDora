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
}
  