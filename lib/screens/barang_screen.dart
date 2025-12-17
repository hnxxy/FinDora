import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/material.dart';
import 'barang_detail.dart';
import '../services/marker_cache.dart';
import '../widgets/battery_indicator.dart';
import 'home_screen.dart';
import 'saya_.screen.dart';
import '../data/item_locations.dart';

class BarangScreen extends StatefulWidget {
  const BarangScreen({super.key});

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  GoogleMapController? _controller;

  // device location
  final loc.Location _location = loc.Location();
  loc.LocationData? _currentLocation;
  StreamSubscription<loc.LocationData>? _locationSubscription;
  int _currentIndex = 1; // default aktif di halaman Barang
  int batteryLevel = 95; // contoh persentase baterai untuk daftar
  Set<Circle> _circles = {};

  // Lokasi barang (ambil dari store sehingga konsisten antar layar)
  LatLng get barangLocation => ItemLocations.get('KEY');

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      var permission = await _location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != loc.PermissionStatus.granted) return;
      }

      final loc.LocationData locData = await _location.getLocation();
      setState(() => _currentLocation = locData);

      _locationSubscription = _location.onLocationChanged.listen((
        loc.LocationData newLoc,
      ) {
        setState(() => _currentLocation = newLoc);
        // update highlight bounds if any
        if (_circles.isNotEmpty) {
          // no-op for now; leave circle visible while updating location
        }
      });
    } catch (e) {
      // ignore errors
    }
  }

  void _highlightItem(LatLng position) {
    final CircleId id = const CircleId('highlight');
    final Circle c = Circle(
      circleId: id,
      center: position,
      radius: 30,
      fillColor: Colors.pink.withOpacity(0.2),
      strokeColor: Colors.pink.withOpacity(0.6),
      strokeWidth: 3,
    );
    setState(() {
      _circles = {c};
    });
    Timer(const Duration(seconds: 1), () {
      if (mounted)
        setState(() => _circles.removeWhere((e) => e.circleId == id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.pink[200],
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'BARANG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Map dan bottom sheet
            Expanded(
              child: Stack(
                children: [
                  // Google Map
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: barangLocation,
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("barang"),
                        position: barangLocation,
                        infoWindow: const InfoWindow(title: "Key"),
                        icon:
                            MarkerCache.getMarker('KEY') ??
                            BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                      ),
                    },
                    onMapCreated: (controller) {
                      _controller = controller;
                      if (_currentLocation != null &&
                          _currentLocation!.latitude != null &&
                          _currentLocation!.longitude != null) {
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                _currentLocation!.latitude!,
                                _currentLocation!.longitude!,
                              ),
                              zoom: 17,
                            ),
                          ),
                        );
                      }
                    },
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),

                  // Draggable bottom sheet
                  DraggableScrollableSheet(
                    initialChildSize: 0.35,
                    minChildSize: 0.35,
                    maxChildSize: 0.8,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.pink[200],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              // Handle bar
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 20,
                                ),
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // Daftar barang (contoh sederhana)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        // briefly highlight the item on the map
                                        _highlightItem(barangLocation);
                                        _controller?.animateCamera(
                                          CameraUpdate.newLatLngZoom(
                                            barangLocation,
                                            16,
                                          ),
                                        );
                                        await Future.delayed(
                                          const Duration(milliseconds: 600),
                                        );
                                        // Buka halaman detail untuk item KEY
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BarangDetailScreen(
                                              id: 'KEY',
                                              title: 'KEY',
                                              location: barangLocation,
                                              address: 'Alamat tidak tersedia',
                                              statusText: 'Dengan anda',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.08,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.pink[100],
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  child: const Icon(
                                                    Icons.vpn_key,
                                                    color: Colors.pink,
                                                    size: 28,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      'KEY',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Lokasi Terakhir',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.pink[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'Dengan anda',
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Battery indicator widget
                                                BatteryIndicator(
                                                  level: batteryLevel,
                                                  width: 28,
                                                  height: 12,
                                                  fillColor: Colors.black,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              // Already on BarangScreen, do nothing
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SayaScreen()),
              );
              break;
          }
        },
        backgroundColor: Colors.pink[200],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
