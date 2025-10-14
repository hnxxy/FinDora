import 'package:flutter/material.dart';

// Nama kelas tetap ProfilPage sesuai permintaan.
class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // State yang diperlukan untuk halaman ini
  bool _bagikanLokasi = true;
  String _lokasiSaya = 'Jl. Ds Nologaten No ...';
  String _dariPerangkat = 'iPhone Ini';

  @override
  Widget build(BuildContext context) {
    // Warna-warna yang digunakan dalam desain
    final Color primaryPink = Colors.pink.shade300;
    final Color softPink = Colors.pink.shade100;
    final Color secondaryPink = Colors.pink.shade600;
    final Color backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      // AppBar kustom yang lebih minimalis untuk meniru header gambar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
          color: primaryPink, // Warna header sesuai gambar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tambahkan tombol 'back' (silang) untuk kembali ke HomeScreen
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () {
                  // Menggunakan pop untuk kembali ke halaman sebelumnya (HomeScreen)
                  Navigator.pop(context); 
                },
              ),
              const Text(
                // Judul "Saya" di tengah atas
                'Saya',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Placeholder ikon status (jam 07:00, sinyal, baterai)
              Row(
                children: [
                  const Text('07:00', style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(width: 10),
                  Icon(Icons.wifi, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Icon(Icons.battery_full, color: Colors.white, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Bagian Peta
          Expanded(
            child: Stack(
              children: [
                // Placeholder Peta (Penting: Peta di sini harus sesuai dengan desain Anda, bukan GoogleMap real)
                Container(
                  color: Colors.grey[800], // Warna gelap untuk peta
                  child: Center(
                    child: Text(
                      'Peta\nJl. Affandi, Plaza Ambarrukmo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                // Pin Lokasi "Saya"
                Positioned(
                  top: 150,
                  left: 80,
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
                          ],
                        ),
                        child: const Text('Saya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                // Pin Lokasi "Key"
                Positioned(
                  top: 200,
                  left: 140,
                  child: Column(
                    children: [
                      Icon(Icons.location_on, color: secondaryPink, size: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3),
                          ],
                        ),
                        child: const Text('Key', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                // Pin Lokasi "Asrama" (seperti di gambar)
                Positioned(
                  top: 300,
                  right: 40,
                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
          ),
          // Bagian Informasi Lokasi (Kartu)
          Container(
            padding: const EdgeInsets.only(top: 20, bottom: 40, left: 20, right: 20),
            decoration: BoxDecoration(
              color: softPink, // Warna latar belakang kartu
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saya',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // Baris Lokasi Saya
                _buildLocationDetailRow(
                  icon: Icons.send,
                  label: 'Lokasi Saya',
                  value: '', // Nilai kosong untuk meniru desain
                  showArrow: false,
                ),
                const Divider(color: Colors.white70, height: 1),
                // Baris Lokasi
                _buildLocationDetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Lokasi',
                  value: _lokasiSaya,
                  showArrow: false,
                ),
                const Divider(color: Colors.white70, height: 1),
                // Baris Dari
                _buildLocationDetailRow(
                  icon: Icons.devices_other,
                  label: 'Dari',
                  value: _dariPerangkat,
                  showArrow: false,
                ),
                const Divider(color: Colors.white70, height: 1),
                // Baris Bagikan Lokasi Saya (Toggle Switch)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined, color: secondaryPink),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Bagikan Lokasi Saya',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Switch(
                        value: _bagikanLokasi,
                        onChanged: (bool value) {
                          setState(() {
                            _bagikanLokasi = value;
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar dihapus di sini agar tidak ganda dengan HomeScreen.
    );
  }

  // Widget pembantu untuk baris detail lokasi
  Widget _buildLocationDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool showArrow,
  }) {
    final Color secondaryPink = Colors.pink.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: secondaryPink),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: value.isEmpty ? secondaryPink : Colors.grey[700],
              fontWeight: value.isEmpty ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (showArrow)
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  // Hapus _buildNavBarItem karena Bottom Nav dihilangkan.
}