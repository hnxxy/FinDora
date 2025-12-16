import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'Tambah_item.dart';
import 'barang_screen.dart';
import 'barang_detail.dart';
import 'saya_.screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  LocationData? currentLocation;
  final Location _location = Location();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  int _currentIndex = 0;

  // ================= NOTIFICATION STATE =================
  bool deviceNotification = true;
  bool batteryNotification = true;

  @override
  void initState() {
    super.initState();
    _checkUser();
    getCurrentLocation();
    _listenItems();
  }

  // ================= AUTH CHECK =================
  void _checkUser() {
    final user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // ================= LOCATION =================
  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    currentLocation = await _location.getLocation();
    setState(() {});

    _location.onLocationChanged.listen((loc) {
      setState(() {
        currentLocation = loc;
      });
    });
  }

  // ================= FIRESTORE LISTENER =================
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

            final LatLng position = LatLng(
              (data['lat'] ?? currentLocation?.latitude ?? -6.2088).toDouble(),
              (data['lng'] ?? currentLocation?.longitude ?? 106.8456)
                  .toDouble(),
            );

            markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: position,
                infoWindow: InfoWindow(
                  title: data['nama'],
                  snippet: 'Device ID: ${data['deviceId']}',
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

  // ================= MAP EFFECT =================
  void _highlightItem(LatLng position) {
    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId('highlight'),
          center: position,
          radius: 30,
          fillColor: Colors.pink.withOpacity(0.2),
          strokeColor: Colors.pink,
          strokeWidth: 2,
        ),
      };
    });

    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _circles.clear());
      }
    });
  }

  // ================= NOTIFICATION DIALOG =================
  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notifikasi Perangkat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Notifikasi Perangkat'),
              value: deviceNotification,
              activeColor: Colors.pink,
              onChanged: (val) {
                setState(() => deviceNotification = val);
              },
            ),

            SwitchListTile(
              title: const Text('Notifikasi Baterai'),
              value: batteryNotification,
              activeColor: Colors.pink,
              onChanged: (val) {
                setState(() => batteryNotification = val);
              },
            ),

            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.pink[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HOME',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _showNotificationDialog,
                  ),
                ],
              ),
            ),

            // ================= MAP =================
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: currentLocation != null
                          ? LatLng(
                              currentLocation!.latitude!,
                              currentLocation!.longitude!,
                            )
                          : const LatLng(-6.2088, 106.8456),
                      zoom: 16,
                    ),
                    myLocationEnabled: true,
                    markers: _markers,
                    circles: _circles,
                    onMapCreated: (c) => _controller = c,
                  ),

                  // ================= BOTTOM SHEET =================
                  DraggableScrollableSheet(
                    initialChildSize: 0.35,
                    minChildSize: 0.3,
                    maxChildSize: 0.8,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.pink[200],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
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

                                  return GestureDetector(
                                    onTap: () {
                                      final LatLng pos = LatLng(
                                        (data['lat'] ??
                                                currentLocation?.latitude ??
                                                -6.2088)
                                            .toDouble(),
                                        (data['lng'] ??
                                                currentLocation?.longitude ??
                                                106.8456)
                                            .toDouble(),
                                      );

                                      _highlightItem(pos);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BarangDetailScreen(
                                            title: data['nama'],
                                            location: pos,
                                            deviceLocation:
                                                currentLocation != null
                                                ? LatLng(
                                                    currentLocation!.latitude!,
                                                    currentLocation!.longitude!,
                                                  )
                                                : null,
                                            address: '-',
                                            statusText: 'Online',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor: Colors.pink[100],
                                            backgroundImage:
                                                data['imageUrl'] != null
                                                ? NetworkImage(data['imageUrl'])
                                                : null,
                                            child: data['imageUrl'] == null
                                                ? const Icon(
                                                    Icons.image,
                                                    color: Colors.pink,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['nama'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Device: ${data['deviceId']}',
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const TambahItem(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B4C5C),
                                    minimumSize: const Size(
                                      double.infinity,
                                      56,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Tambahkan Barang',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.pink[200],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BarangScreen()),
            );
          }
          if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SayaScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
