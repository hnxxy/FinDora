import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'barang_detail.dart';
import '../widgets/battery_indicator.dart';

class BarangScreen extends StatefulWidget {
  const BarangScreen({super.key});

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  GoogleMapController? _controller;

  int _currentIndex = 1; // default aktif di halaman Barang
  int batteryLevel = 95; // contoh persentase baterai untuk daftar

  // Lokasi barang (contoh: Jl. Affandi, Yogyakarta)
  final LatLng barangLocation = const LatLng(-7.7828, 110.3671);

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
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    },
                    onMapCreated: (controller) {
                      _controller = controller;
                    },
                    zoomControlsEnabled: false,
                    myLocationEnabled: false,
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
                                      onTap: () {
                                        // Buka halaman detail untuk item KEY
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BarangDetailScreen(
                                              title: 'KEY',
                                              location: barangLocation,
                                              address:
                                                  'Jl. DS Nologaten no.ct 14/47 kb. Sleman, Yogyakarta',
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
          if (index == 0) {
            final currentRoute = ModalRoute.of(context)?.settings.name;
            if (currentRoute != '/home') {
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
            return;
          }

          if (index == 1) {
            // tetap di halaman barang
            setState(() {
              _currentIndex = index;
            });
            return;
          }

          // index lain (profil)
          setState(() {
            _currentIndex = index;
          });
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
}
