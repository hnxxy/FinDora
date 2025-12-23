import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Simple in-memory cache mapping an item id to a BitmapDescriptor.
/// This is process-local and not persisted across app restarts.
class MarkerCache {
  static final Map<String, BitmapDescriptor> _cache = {};

  static void setMarker(String id, BitmapDescriptor icon) {
    _cache[id] = icon;
  }

  static BitmapDescriptor? getMarker(String id) {
    return _cache[id];
  }

  static void removeMarker(String id) {
    _cache.remove(id);
  }

  static void clear() {
    _cache.clear();
  }
}
