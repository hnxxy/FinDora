import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'Tambah_item.dart';
import 'barang_screen.dart';
import 'saya_.screen.dart';
import 'barang_detail.dart';
import '../services/marker_cache.dart';
import '../data/item_locations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  LocationData? currentLocation;
  final Location _location = Location();
  Set<Circle> _circles = {};

  bool deviceNotification = true;
  bool batteryNotification = true;
  int _currentIndex = 0;

  // Lokasi barang (ambil dari store sehingga konsisten antar layar)
  LatLng get barangLocation => ItemLocations.get('KEY');

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
    setState(() {});
    // Try to fit bounds after we have an initial location
    _maybeFitBounds();

    _location.onLocationChanged.listen((newLoc) {
      setState(() {
        currentLocation = newLoc;
      });
      // Animate camera to include both user and barang when location updates
      _maybeFitBounds();
    });
  }

  void _maybeFitBounds() {
    try {
      if (_controller == null) return;
      final LatLng item = barangLocation;

      if (currentLocation == null ||
          currentLocation!.latitude == null ||
          currentLocation!.longitude == null) {
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: item, zoom: 16),
          ),
        );
        return;
      }

      final LatLng device = LatLng(
        currentLocation!.latitude!,
        currentLocation!.longitude!,
      );

      final double south = (item.latitude < device.latitude)
          ? item.latitude
          : device.latitude;
      final double north = (item.latitude > device.latitude)
          ? item.latitude
          : device.latitude;
      final double west = (item.longitude < device.longitude)
          ? item.longitude
          : device.longitude;
      final double east = (item.longitude > device.longitude)
          ? item.longitude
          : device.longitude;

      final LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(south, west),
        northeast: LatLng(north, east),
      );

      _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } catch (e) {
      try {
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: barangLocation, zoom: 16),
          ),
        );
      } catch (_) {}
    }
  }

  void _highlightItem(LatLng position) {
    final CircleId id = const CircleId('highlight');
    final Circle c = Circle(
      circleId: id,
      center: position,
      radius: 30, // meters — visual emphasis
      fillColor: Colors.pink.withOpacity(0.2),
      strokeColor: Colors.pink.withOpacity(0.6),
      strokeWidth: 3,
    );
    setState(() {
      _circles = {c};
    });
    // remove highlight after short delay
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
                    markers: {
                      // barang marker (use photo icon if available)
                      Marker(
                        markerId: const MarkerId('barang'),
                        position: barangLocation,
                        infoWindow: const InfoWindow(title: 'KEY'),
                        icon:
                            MarkerCache.getMarker('KEY') ??
                            BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                      ),
                    },
                    circles: _circles,
                    onMapCreated: (controller) async {
                      _controller = controller;
                      // Ensure map shows both barang and device when possible
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _maybeFitBounds();
                      });

                      // If location wasn't available earlier, try to obtain once and fit bounds
                      if (currentLocation == null) {
                        try {
                          final LocationData locData = await _location
                              .getLocation();
                          if (locData.latitude != null &&
                              locData.longitude != null) {
                            setState(() {
                              currentLocation = locData;
                            });
                            _maybeFitBounds();
                          }
                        } catch (e) {
                          // ignore if location not available now
                        }
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        // highlight item briefly on the map
                                        _highlightItem(barangLocation);
                                        // animate camera to show both user and item
                                        _maybeFitBounds();
                                        // short delay so user sees the highlight
                                        await Future.delayed(
                                          const Duration(milliseconds: 600),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BarangDetailScreen(
                                              title: 'KEY',
                                              location: barangLocation,
                                              // Jika Home sudah punya currentLocation, teruskan ke detail
                                              deviceLocation:
                                                  currentLocation != null
                                                  ? LatLng(
                                                      currentLocation!
                                                          .latitude!,
                                                      currentLocation!
                                                          .longitude!,
                                                    )
                                                  : null,
                                              address: 'Jl. DS Ekowisata',
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
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.1,
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
                                                            color:
                                                                Colors.black54,
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
                                          builder: (context) =>
                                              const TambahItem(),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF8B4C5C,
                                        ),
                                        minimumSize: const Size(
                                          double.infinity,
                                          56,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
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
                MaterialPageRoute(
                  builder: (context) => BarangScreen(),
                ), // ✅ tanpa const
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
                MaterialPageRoute(
                  builder: (context) => const SayaScreen(),
                ), // ✅ tanpa const
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
