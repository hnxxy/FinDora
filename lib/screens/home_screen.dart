import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'Tambah_item.dart';
import 'barang_screen.dart';
import 'saya_.screen.dart';
import 'barang_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  LocationData? currentLocation;
  final Location _location = Location();

  bool deviceNotification = true;
  bool batteryNotification = true;
  int _currentIndex = 0;

  // Lokasi barang (contoh: Jl. Affandi, Yogyakarta)
  final LatLng barangLocation = const LatLng(-7.7828, 110.3671);

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool localDeviceNotification = deviceNotification;
        bool localBatteryNotification = batteryNotification;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Notifikasi perangkat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifikasi perangkat',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      Switch(
                        value: localDeviceNotification,
                        onChanged: (value) {
                          setDialogState(() {
                            localDeviceNotification = value;
                          });
                          setState(() {
                            deviceNotification = value;
                          });
                        },
                        activeThumbColor: Colors.pink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifikasi Baterai',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      Switch(
                        value: localBatteryNotification,
                        onChanged: (value) {
                          setDialogState(() {
                            localBatteryNotification = value;
                          });
                          setState(() {
                            batteryNotification = value;
                          });
                        },
                        activeThumbColor: Colors.pink,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    await _location.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
      distanceFilter: 5,
    );

    currentLocation = await _location.getLocation();
    _location.onLocationChanged.listen((newLoc) {
      setState(() {
        currentLocation = newLoc;
      });
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(newLoc.latitude!, newLoc.longitude!),
            zoom: 17,
          ),
        ),
      );
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
                    onPressed: _showNotificationDialog,
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Map and draggable bottom sheet
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
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    markers: currentLocation != null
                        ? {
                            Marker(
                              markerId: const MarkerId("me"),
                              position: LatLng(
                                currentLocation!.latitude!,
                                currentLocation!.longitude!,
                              ),
                              infoWindow: const InfoWindow(title: "Saya"),
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed,
                              ),
                            ),
                          }
                        : {},
                    onMapCreated: (controller) {
                      _controller = controller;
                      if (currentLocation != null) {
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                currentLocation!.latitude!,
                                currentLocation!.longitude!,
                              ),
                              zoom: 17,
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  // Draggable bottom sheet
                  DraggableScrollableSheet(
                    initialChildSize: 0.3,
                    minChildSize: 0.3,
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
                              Container(
                                margin: const EdgeInsets.only(top: 10, bottom: 20),
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
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
                                          vertical: 18,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromRGBO(0, 0, 0, 0.1),
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
                                                  padding:
                                                      const EdgeInsets.all(10),
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
                                                  children: [
                                                    const Text(
                                                      'KEY',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: const [
                                                        Icon(
                                                          Icons.circle,
                                                          color: Colors.green,
                                                          size: 10,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          'Online',
                                                          style: TextStyle(
                                                            color: Colors.black54,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: const [
                                                Icon(
                                                  Icons.battery_full,
                                                  color: Colors.green,
                                                  size: 26,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  '95%',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.pink,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const TambahItem(),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF8B4C5C),
                                        minimumSize:
                                            const Size(double.infinity, 56),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
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
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
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

      // ✅ Bottom navigation bar diperbaiki
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          print('=== BOTTOM NAV DIKLIK ===');
          print('Index yang diklik: $index');
          print('Current Index sebelum: $_currentIndex');

          setState(() {
            _currentIndex = index;
          });

          print('Current Index sesudah: $_currentIndex');

          // Navigasi barang screen
          if (index == 1) {
            print('>>> Navigasi ke barang screen');
            try {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BarangScreen()), // ✅ tanpa const
              );
              print('>>> Berhasil navigasi ke ListBarangPage');
            } catch (e) {
              print('ERROR navigasi ListBarangPage: $e');
            }
          }

          // Navigasi ke ProfilPage
          if (index == 2) {
            print('>>> Navigasi ke ProfilPage');
            try {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SayaScreen()), // ✅ tanpa const
              );
              print('>>> Berhasil navigasi ke ProfilPage');
            } catch (e) {
              print('ERROR navigasi ProfilPage: $e');
            }
          }

          if (index == 0) {
            print('>>> Tetap di Home');
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
}
