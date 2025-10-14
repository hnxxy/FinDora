import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
                      selectedLabel = tempIsCustom && tempCustomLabel.isNotEmpty ? tempCustomLabel : tempSelectedLabel;
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
                      target: sampleLocation,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('me'),
                        position: sampleLocation,
                        infoWindow: const InfoWindow(title: 'Saya'),
                      ),
                    },
                    // no-op onMapCreated for now
                    onMapCreated: (_) {},
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

                                    // Lokasi
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
                                        children: const [
                                          Text(
                                            'Lokasi',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              'Jl. Ds Nologaten No ...',
                                              textAlign: TextAlign.right,
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
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                const Icon(Icons.edit, size: 16, color: Colors.black54),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Dari
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
                                        children: const [
                                          Text(
                                            'Dari',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            'iPhone Ini',
                                            style: TextStyle(
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
}
