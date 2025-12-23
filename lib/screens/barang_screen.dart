import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'barang_detail.dart';
import '../widgets/battery_indicator.dart';
import 'home_screen.dart';
import 'saya_.screen.dart';

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
  Set<Marker> _markers = {};

  // Default location dari GPS (akan diupdate saat location service berjalan)
  // Dimulai dengan null dan diisi setelah GPS ready
  LatLng? _defaultLocation;

  // Firestore dan Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initLocationService();
    _listenItems();
  }

  // ================= FIRESTORE LISTENER =================
  // Mendengarkan real-time update dari IoT device di Firestore
  // Ketika IoT update lat/lng, marker akan otomatis berubah
  void _listenItems() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('items')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          final Set<Marker> markers = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();

            // Ambil koordinat dari IoT device
            // Fallback: gunakan lokasi user jika ada, atau default Jakarta
            final double lat =
                (data['lat'] as num?)?.toDouble() ??
                _defaultLocation?.latitude ??
                -6.2088;
            final double lng =
                (data['lng'] as num?)?.toDouble() ??
                _defaultLocation?.longitude ??
                106.8456;

            final LatLng position = LatLng(lat, lng);

            markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: position,
                infoWindow: InfoWindow(
                  title: data['nama'] ?? 'Unknown Item',
                  snippet: 'Device ID: ${data['deviceId'] ?? 'N/A'}',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRose,
                ),
                onTap: () => _highlightItem(position),
              ),
            );
          }

          setState(() {
            _markers = markers;
          });
        });
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
      setState(() {
        _currentLocation = locData;
        // Inisialisasi default location dari GPS user
        // Ini akan menjadi fallback jika IoT device belum punya koordinat
        _defaultLocation = LatLng(
          locData.latitude ?? -6.2088,
          locData.longitude ?? 106.8456,
        );
      });

      // Listening to real-time location changes
      _locationSubscription = _location.onLocationChanged.listen((
        loc.LocationData newLoc,
      ) {
        setState(() {
          _currentLocation = newLoc;
          // Update default location seiring device bergerak
          _defaultLocation = LatLng(
            newLoc.latitude ?? _defaultLocation?.latitude ?? -6.2088,
            newLoc.longitude ?? _defaultLocation?.longitude ?? 106.8456,
          );
        });
      });
    } catch (e) {
      // Fallback jika GPS permission/service error
      setState(() {
        _defaultLocation = const LatLng(-6.2088, 106.8456);
      });
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
                      target:
                          _defaultLocation ?? const LatLng(-6.2088, 106.8456),
                      zoom: 16,
                    ),
                    markers: _markers,
                    circles: _circles,
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
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('items')
                              .where(
                                'userId',
                                isEqualTo: _auth.currentUser?.uid,
                              )
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final docs = snapshot.data!.docs;

                            return ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              children: [
                                ...docs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  final double lat =
                                      (data['lat'] as num?)?.toDouble() ??
                                      _defaultLocation?.latitude ??
                                      -6.2088;
                                  final double lng =
                                      (data['lng'] as num?)?.toDouble() ??
                                      _defaultLocation?.longitude ??
                                      106.8456;

                                  final LatLng position = LatLng(lat, lng);

                                  return GestureDetector(
                                    onTap: () async {
                                      // briefly highlight the item on the map
                                      _highlightItem(position);
                                      _controller?.animateCamera(
                                        CameraUpdate.newLatLngZoom(
                                          position,
                                          16,
                                        ),
                                      );
                                      await Future.delayed(
                                        const Duration(milliseconds: 600),
                                      );
                                      // Buka halaman detail untuk item
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BarangDetailScreen(
                                            id: doc.id,
                                            title: data['nama'],
                                            location: position,
                                            deviceLocation:
                                                _currentLocation != null
                                                ? LatLng(
                                                    _currentLocation!.latitude!,
                                                    _currentLocation!
                                                        .longitude!,
                                                  )
                                                : null,
                                            address: 'Alamat tidak tersedia',
                                            statusText: 'Dengan anda',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
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
                                                child: data['imageUrl'] != null
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              50,
                                                            ),
                                                        child: Image.network(
                                                          data['imageUrl'],
                                                          fit: BoxFit.cover,
                                                          width: 28,
                                                          height: 28,
                                                        ),
                                                      )
                                                    : const Icon(
                                                        Icons.image,
                                                        color: Colors.pink,
                                                        size: 28,
                                                      ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data['nama'] ?? 'N/A',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'Device: ${data['deviceId'] ?? 'N/A'}',
                                                    style: const TextStyle(
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
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'Dengan anda',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.bold,
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
                                  );
                                }).toList(),
                              ],
                            );
                          },
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
