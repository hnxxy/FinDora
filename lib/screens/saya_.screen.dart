import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'home_screen.dart';
import 'barang_screen.dart';

class SayaScreen extends StatefulWidget {
  const SayaScreen({Key? key}) : super(key: key);

  @override
  State<SayaScreen> createState() => _SayaScreenState();
}

class _SayaScreenState extends State<SayaScreen> {
  // Map controller currently not needed; remove to avoid analyzer unused-field warning.
  bool shareLocation = true;
  final LatLng sampleLocation = const LatLng(-7.7828, 110.3671);
  final Location _location = Location();
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  String _currentAddress = 'Mengambil lokasi...';
  String _deviceName = 'Perangkat ini';
  String selectedLabel = 'Rumah';
  bool isCustom = false;
  String customLabel = '';
  List<String> labelOptions = ['Rumah', 'Kantor', 'Sekolah', 'Lainnya'];

  void _showLabelDialog(BuildContext context) {
    String tempSelectedLabel = selectedLabel;
    bool tempIsCustom = isCustom;
    String tempCustomLabel = customLabel;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pilih Label'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...labelOptions.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: tempSelectedLabel,
                      onChanged: (value) {
                        setState(() {
                          tempSelectedLabel = value!;
                          if (value == 'Lainnya') {
                            tempIsCustom = true;
                          } else {
                            tempIsCustom = false;
                            tempCustomLabel = '';
                          }
                        });
                      },
                    );
                  }),
                  if (tempIsCustom) ...[
                    const SizedBox(height: 8),
                    TextField(
                      onChanged: (value) => tempCustomLabel = value,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan label khusus',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedLabel = tempIsCustom && tempCustomLabel.isNotEmpty
                          ? tempCustomLabel
                          : tempSelectedLabel;
                      isCustom = tempIsCustom;
                      customLabel = tempCustomLabel;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Label disimpan!')),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[200],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
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
    _initLocationService();
    _initDeviceName();
  }

  Future<void> _initDeviceName() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final String model = androidInfo.model;
        final String alt = '${androidInfo.manufacturer} ${androidInfo.device}'
            .trim();
        setState(() {
          _deviceName = model.isNotEmpty ? model : alt;
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final String? name = iosInfo.name;
        final String uts = iosInfo.utsname.machine ?? '';
        setState(() {
          _deviceName = (name != null && name.isNotEmpty)
              ? name
              : (uts.isNotEmpty ? uts : 'iPhone');
        });
      }
    } catch (e) {
      // ignore and keep default
    }
  }

  Future<void> _initLocationService() async {
    try {
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

      final LocationData loc = await _location.getLocation();
      setState(() {
        _currentLocation = loc;
      });

      // update readable address from coordinates
      _updateAddressFromLocation(loc.latitude, loc.longitude);

      _locationSubscription = _location.onLocationChanged.listen((locData) {
        setState(() => _currentLocation = locData);
        _updateAddressFromLocation(locData.latitude, locData.longitude);
      });
    } catch (e) {
      // ignore errors
    }
  }

  Future<void> _updateAddressFromLocation(
    double? latitude,
    double? longitude,
  ) async {
    if (latitude == null || longitude == null) return;
    try {
      final List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final geocoding.Placemark p = placemarks.first;
        final String addr = [
          if (p.street != null && p.street!.isNotEmpty) p.street,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode,
          if (p.country != null && p.country!.isNotEmpty) p.country,
        ].whereType<String>().join(', ');
        setState(
          () => _currentAddress = addr.isNotEmpty
              ? addr
              : '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
        );
        return;
      }
    } catch (e) {
      // ignore geocoding errors
    }

    // fallback to coordinates
    setState(
      () => _currentAddress =
          '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              color: Colors.pink[200],
              width: double.infinity,
              child: const Text(
                'Saya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Map area
            Expanded(
              child: Stack(
                children: [
                  // Map
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation != null
                          ? LatLng(
                              _currentLocation!.latitude!,
                              _currentLocation!.longitude!,
                            )
                          : sampleLocation,
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: {},
                    onMapCreated: (controller) async {
                      // ensure camera centers to current location if available
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
                  ),

                  // Draggable sheet
                  DraggableScrollableSheet(
                    initialChildSize: 0.35,
                    minChildSize: 0.25,
                    maxChildSize: 0.85,
                    builder: (context, controller) => Container(
                      decoration: BoxDecoration(
                        color: Colors.pink[200],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Small title
                              const Text(
                                'Saya',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Card
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.pink[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.send, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Lokasi Saya',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Lokasi (dynamic)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Lokasi',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              _currentAddress,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Label
                                    GestureDetector(
                                      onTap: () => _showLabelDialog(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Label',
                                              style: TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  selectedLabel,
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.edit,
                                                  size: 16,
                                                  color: Colors.black54,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Dari (device name)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Dari',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            _deviceName,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Share toggle
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Bagikan Lokasi Saya',
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Switch(
                                            value: shareLocation,
                                            onChanged: (v) => setState(
                                              () => shareLocation = v,
                                            ),
                                            activeColor: Colors.pink,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Bottom padding so content can scroll
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Assuming SayaScreen is the third item (index 2)
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BarangScreen()),
              );
              break;
            case 2:
              // Already on SayaScreen, do nothing
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
    super.dispose();
  }
}
