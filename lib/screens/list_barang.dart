import 'package:flutter/material.dart';

class Barang {
  String nama;
  double harga;

  Barang({required this.nama, required this.harga});
}

class ListBarangPage extends StatefulWidget {
  const ListBarangPage({super.key});

  @override
  State<ListBarangPage> createState() => _ListBarangPageState();
}

class _ListBarangPageState extends State<ListBarangPage> {
  List<Barang> daftarBarang = [
    Barang(nama: 'Kunci Rumah', harga: 0),
    Barang(nama: 'Dompet Coklat', harga: 0),
    Barang(nama: 'Tas Hitam', harga: 0),
  ];

  // Fungsi hapus barang
  void hapusBarang(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text(
            'Apakah kamu yakin ingin menghapus "${daftarBarang[index].nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                daftarBarang.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Barang berhasil dihapus!')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Fungsi edit barang
  void editBarangDialog(int index) {
    final namaController = TextEditingController(text: daftarBarang[index].nama);
    final hargaController =
        TextEditingController(text: daftarBarang[index].harga.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Barang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Barang'),
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: 'Harga (opsional)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              setState(() {
                daftarBarang[index].nama = namaController.text;
                daftarBarang[index].harga =
                    double.tryParse(hargaController.text) ?? 0;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Barang berhasil diubah!')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // Tampilan utama daftar barang
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang'),
        backgroundColor: Colors.pink[200],
      ),
      body: ListView.builder(
        itemCount: daftarBarang.length,
        itemBuilder: (context, index) {
          final barang = daftarBarang[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                barang.nama,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: barang.harga > 0
                  ? Text('Rp ${barang.harga.toStringAsFixed(0)}')
                  : const Text('Tidak ada harga'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => editBarangDialog(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => hapusBarang(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
