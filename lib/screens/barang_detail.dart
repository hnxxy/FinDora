import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../services/marker_cache.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;
import '../widgets/battery_indicator.dart';
import 'home_screen.dart';
import 'saya_.screen.dart';

class BarangDetailScreen extends StatefulWidget {
  final String title;
  final LatLng location;
  final LatLng? deviceLocation;
  final String address;
  final String statusText;

  const BarangDetailScreen({
    Key? key,
    required this.title,
    required this.location,
    this.deviceLocation,
    required this.address,
    this.statusText = 'Dengan anda',
  }) : super(key: key);

  @override
  State<BarangDetailScreen> createState() => _BarangDetailScreenState();
}

class _BarangDetailScreenState extends State<BarangDetailScreen> {
  GoogleMapController? _controller;
  final loc.Location _locationService = loc.Location();
  loc.LocationData? _deviceLocationData;
  StreamSubscription<loc.LocationData?>? _locationSubscription;
  bool notificationEnabled = true;
  int _currentIndex = 1;
  int batteryLevel = 95;
  File? _lockImage;
  BitmapDescriptor? _barangIcon;
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _nameController;
  late String _currentTitle;
  late String _currentAddress;

  // Fungsi popup konfirmasi hapus
  void _showDeleteConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Yakin ingin menghapus barang?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // tutup popup
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.title} berhasil dihapus'),
                            backgroundColor: Colors.pink[300],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[300],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Ya'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Tidak'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    _currentAddress = widget.address;
    _nameController = TextEditingController(text: _currentTitle);
    // load any cached custom marker for this item so it appears immediately
    try {
      final cached = MarkerCache.getMarker(_currentTitle);
      if (cached != null) {
        _barangIcon = cached;
      }
    } catch (_) {}

    _initLocationService();
  }

  Future<void> _initLocationService() async {
    try {
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) return;
      }

      var permission = await _locationService.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await _locationService.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Izin lokasi ditolak. Aktifkan izin untuk melihat lokasi perangkat.',
                ),
              ),
            );
          }
          return;
        }
      }
      if (permission == loc.PermissionStatus.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin ditolak permanen. Silakan aktifkan di pengaturan aplikasi.',
              ),
            ),
          );
        }
        return;
      }

      // Ambil lokasi saat ini
      final loc.LocationData current = await _locationService.getLocation();
      setState(() {
        _deviceLocationData = current;
      });

      // Jika map sudah dibuat, pusatkan kamera ke lokasi device segera
      if (_controller != null &&
          current.latitude != null &&
          current.longitude != null) {
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(current.latitude!, current.longitude!),
              zoom: 17,
            ),
          ),
        );
      }

      // Listen perubahan lokasi untuk update marker dan pusatkan kamera seperti di Home
      _locationSubscription = _locationService.onLocationChanged
          .handleError((err) {
            // ignore errors silently
          })
          .listen((loc.LocationData? newLoc) {
            if (newLoc == null) return;
            setState(() => _deviceLocationData = newLoc);
            // if both controller and device location available, try to fit map to show both
            if (_controller != null &&
                newLoc.latitude != null &&
                newLoc.longitude != null) {
              _maybeFitBounds();
            }
          });
    } catch (e) {
      // Jika error, biarkan UI tetap berjalan tanpa lokasi
      // bisa log atau tampilkan pesan jika perlu
    }
  }

  void _maybeFitBounds() {
    try {
      final LatLng item = widget.location;
      LatLng? device;
      if (widget.deviceLocation != null) {
        device = widget.deviceLocation;
      } else if (_deviceLocationData != null &&
          _deviceLocationData!.latitude != null &&
          _deviceLocationData!.longitude != null) {
        device = LatLng(
          _deviceLocationData!.latitude!,
          _deviceLocationData!.longitude!,
        );
      }

      if (device == null) {
        // no device location available yet — center on item
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: item, zoom: 16),
          ),
        );
        return;
      }

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

      // Add padding so markers are comfortably visible
      _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } catch (e) {
      // newLatLngBounds can throw if map not ready or size not known; fallback to center on item
      try {
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: widget.location, zoom: 16),
          ),
        );
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _controller?.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _lockImage = File(picked.path);
      });
      // create custom marker from picked image
      await _setCustomMarkerFromFile(_lockImage!);
    }
  }

  Future<Uint8List> _getBytesFromFile(File file, int width) async {
    final Uint8List data = await file.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(
      data,
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  Future<void> _setCustomMarkerFromFile(File file) async {
    try {
      final Uint8List bytes = await _getBytesFromFile(file, 140);
      setState(() {
        _barangIcon = BitmapDescriptor.fromBytes(bytes);
      });
      // register the marker for this item so other pages can reuse it while app runs
      try {
        if (_barangIcon != null)
          MarkerCache.setMarker(_currentTitle, _barangIcon!);
      } catch (_) {}
    } catch (e) {
      // if anything goes wrong, keep default marker
    }
  }

  Future<void> _openMapsDirections() async {
    // require device location to calculate directions
    final loc.LocationData? src = _deviceLocationData;
    if (src == null || src.latitude == null || src.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi perangkat belum tersedia')),
      );
      return;
    }

    final double srcLat = src.latitude!;
    final double srcLng = src.longitude!;
    final double dstLat = widget.location.latitude;
    final double dstLng = widget.location.longitude;

    // Try to open Google Maps app first using navigation scheme
    final Uri googleScheme = Uri.parse('google.navigation:q=$dstLat,$dstLng');
    try {
      if (await canLaunchUrl(googleScheme)) {
        await launchUrl(googleScheme);
        return;
      }
    } catch (_) {}

    // Fallback to Google Maps directions in browser
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$srcLat,$srcLng&destination=$dstLat,$dstLng&travelmode=driving',
    );
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tidak dapat membuka aplikasi peta')),
    );
  }

  void _openEditSheet(BuildContext context) {
    _nameController.text = _currentTitle;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 6,
                        margin: const EdgeInsets.only(top: 8, bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Edit Barang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Stack(
                        children: [
                          // Jika ada gambar kunci yang dipilih, tampilkan gambarnya.
                          // Kalau tidak, gunakan gaya yang sama dengan di home: lingkaran pink dengan ikon kunci.
                          if (_lockImage != null)
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              backgroundImage: FileImage(_lockImage!),
                            )
                          else
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.pink[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.vpn_key,
                                  color: Colors.pink,
                                  size: 36,
                                ),
                              ),
                            ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () async {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (c) => SafeArea(
                                    child: Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons.photo_library,
                                          ),
                                          title: const Text(
                                            'Pilih dari Galeri',
                                          ),
                                          onTap: () {
                                            Navigator.of(c).pop();
                                            _pickImage(ImageSource.gallery);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt),
                                          title: const Text('Ambil Foto'),
                                          onTap: () {
                                            Navigator.of(c).pop();
                                            _pickImage(ImageSource.camera);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.black87,
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nama Barang',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Alamat Barang',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(text: _currentAddress),
                      enabled: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black87,
                            ),
                            child: const Text('Batalkan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentTitle =
                                    _nameController.text.trim().isEmpty
                                    ? _currentTitle
                                    : _nameController.text.trim();
                              });
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: const Text('Perubahan disimpan'),
                                  backgroundColor: Colors.pink[300],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                            ),
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.pink[200],
              child: const Row(
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
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          widget.deviceLocation ??
                          (_deviceLocationData != null
                              ? LatLng(
                                  _deviceLocationData!.latitude ??
                                      widget.location.latitude,
                                  _deviceLocationData!.longitude ??
                                      widget.location.longitude,
                                )
                              : widget.location),
                      zoom: 16,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: {
                      Marker(
                        markerId: const MarkerId('barang_detail'),
                        position: widget.location,
                        infoWindow: InfoWindow(title: widget.title),
                        // use custom image if user provided one, otherwise show a red pin
                        icon:
                            _barangIcon ??
                            BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                      ),
                    },
                    onMapCreated: (c) {
                      _controller = c;
                      // Try to fit map to show both the item and the device (if available).
                      // This will keep the user's location visible while showing the item.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _maybeFitBounds();
                      });
                    },
                    zoomControlsEnabled: false,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () {
                        if (_deviceLocationData != null) {
                          final lat = _deviceLocationData!.latitude!;
                          final lng = _deviceLocationData!.longitude!;
                          _controller?.animateCamera(
                            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lokasi perangkat belum tersedia'),
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.36,
                    minChildSize: 0.36,
                    maxChildSize: 0.85,
                    builder: (context, controller) {
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
                          controller: controller,
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 12,
                                ),
                                width: 48,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    12,
                                    14,
                                    12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            '🔑',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  widget.address,
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                Navigator.of(context).pop(),
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: Colors.black12,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.close,
                                                  size: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Text(
                                            'Online',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          BatteryIndicator(
                                            level: batteryLevel,
                                            width: 26,
                                            height: 12,
                                            fillColor: Colors.black,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      ElevatedButton(
                                        onPressed: () => _openMapsDirections(),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 0,
                                          minimumSize: const Size.fromHeight(
                                            64,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.navigation,
                                                  size: 30,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            const Expanded(
                                              child: Text(
                                                'Petunjuk Arah',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
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
                                            Text(
                                              'Notifikasi untuk ${widget.title}',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Switch(
                                              value: notificationEnabled,
                                              onChanged: (v) => setState(
                                                () => notificationEnabled = v,
                                              ),
                                              activeColor: Colors.pink,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // 🔥 Tombol Hapus + Popup
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: _showDeleteConfirmation,
                                              child: Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 14,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.pink[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'Hapus Barang ini',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            GestureDetector(
                                              onTap: () =>
                                                  _openEditSheet(context),
                                              child: Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 14,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.pink[50],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'Edit Barang ini',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
            return;
          }
          // navigate to profile page when tapping person icon
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SayaScreen()),
            );
            return;
          }
          setState(() => _currentIndex = index);
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
