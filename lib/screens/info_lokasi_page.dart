import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class InfoLokasiPage extends StatefulWidget {
  const InfoLokasiPage({super.key});

  @override
  State<InfoLokasiPage> createState() => _InfoLokasiPageState();
}

class _InfoLokasiPageState extends State<InfoLokasiPage> {
  GoogleMapController? _controller;
  LocationData? currentLocation;
  final Location _location = Location();

  String selectedLokasi = 'Rumah';
  String namaLokasi = 'Rumah';
  String alamat = '';
  String city = '';
  bool isLokasiSayaActive = true;

  final List<String> lokasiOptions = [
    'Rumah',
    'Kantor',
    'Sekolah',
    'Gimnasium',
    'Tidak Ada',
  ];

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

    currentLocation = await _location.getLocation();
    setState(() {});

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

  void _showLokasiDialog() {
    String tempSelected = selectedLokasi;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.pink[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batalkan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Edit Nama',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Lokasi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Lokasi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // Nama Lokasi
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nama Lokasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Dropdown Lokasi
                ...lokasiOptions.map((lokasi) {
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        tempSelected = lokasi;
                      });
                      setState(() {
                        selectedLokasi = lokasi;
                        namaLokasi = lokasi;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lokasi,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          if (tempSelected == lokasi)
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),

                // Tombol Tambah Lokasi Navigasi
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur dalam pengembangan')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pink[800],
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Tambah Lokasi Navigasi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _editNamaLokasi() {
    final controller = TextEditingController(text: namaLokasi);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nama Lokasi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nama Lokasi',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              setState(() {
                namaLokasi = controller.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nama lokasi berhasil diubah!')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _editAlamat() {
    final controller = TextEditingController(text: alamat);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Lokasi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Alamat',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              setState(() {
                alamat = controller.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alamat berhasil diubah!')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _editCity() {
    final controller = TextEditingController(text: city);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Kota'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Kota',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              setState(() {
                city = controller.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kota berhasil diubah!')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SAYA',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink[200],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation != null
                  ? LatLng(
                      currentLocation!.latitude!,
                      currentLocation!.longitude!,
                    )
                  : const LatLng(-6.2088, 106.8456), // Default Jakarta
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
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

          // Bottom Sheet Info
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pink[200]?.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Saya
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.pink[800],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Saya',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const Divider(color: Colors.white54, thickness: 1),
                  const SizedBox(height: 15),

                  // Lokasi Saya
                  _buildInfoRow(
                    label: 'Lokasi Saya',
                    value: '',
                    hasSwitch: true,
                    switchValue: isLokasiSayaActive,
                    onSwitchChanged: (value) {
                      setState(() {
                        isLokasiSayaActive = value;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // Lokasi
                  _buildInfoRow(
                    label: 'Lokasi',
                    value: alamat,
                    onTap: _editAlamat,
                  ),

                  const SizedBox(height: 10),

                  // City
                  _buildInfoRow(label: 'City', value: city, onTap: _editCity),

                  const SizedBox(height: 15),

                  // Bagian Lokasi Saya
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.pink[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bagian Lokasi Saya',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            GestureDetector(
                              onTap: _showLokasiDialog,
                              child: Row(
                                children: [
                                  Text(
                                    namaLokasi,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: true,
                          onChanged: (value) {
                            setState(() {});
                          },
                          activeColor: Colors.green,
                          activeTrackColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    VoidCallback? onTap,
    bool hasSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                if (value.isNotEmpty) const SizedBox(height: 3),
                if (value.isNotEmpty)
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: Colors.green,
                activeTrackColor: Colors.white,
              )
            else
              const Icon(Icons.edit, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
