import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

import '../services/cloudinary_service.dart';

class TambahItem extends StatefulWidget {
  const TambahItem({super.key});

  @override
  State<TambahItem> createState() => _TambahItemState();
}

class _TambahItemState extends State<TambahItem> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isLoading = false;

  // ================= SIMPAN FILE GAMBAR =================
  Future<File> _saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}';
    final savedImage = File('${directory.path}/$fileName');
    return File(imagePath).copy(savedImage.path);
  }

  // ================= PILIH GAMBAR =================
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
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
                'Pilih Sumber Gambar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.pink),
                title: const Text('Ambil dari Kamera'),
                onTap: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                  );
                  if (picked != null) {
                    final saved = await _saveImagePermanently(picked.path);
                    setState(() {
                      _imageFile = saved;
                    });
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.pink),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  final picked = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );
                  if (picked != null) {
                    final saved = await _saveImagePermanently(picked.path);
                    setState(() {
                      _imageFile = saved;
                    });
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= SIMPAN KE FIRESTORE =================
  Future<void> _tambahItem() async {
    if (_nameController.text.isEmpty || _deviceIdController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      if (_imageFile != null) {
        imageUrl = await uploadImageToCloudinary(_imageFile!);
      }

      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('items').add({
        'nama': _nameController.text,
        'deviceId': _deviceIdController.text,
        'imageUrl': imageUrl,
        'userId': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil ditambahkan')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan barang: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3C4C4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  const Text(
                    'Tambah Barang',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // FOTO BARANG (FIX FINAL)
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD88B8B),
                    shape: BoxShape.circle,
                  ),
                  child: _imageFile == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white,
                        )
                      : ClipOval(
                          child: Image.file(
                            _imageFile!,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // NAMA BARANG
              _label('Nama Barang'),
              _inputField(_nameController, 'Masukkan nama barang'),

              const SizedBox(height: 20),

              // ID DEVICE
              _label('ID Device'),
              _inputField(_deviceIdController, 'Masukkan ID device'),

              const SizedBox(height: 40),

              // BUTTON TAMBAH
              ElevatedButton(
                onPressed: _isLoading ? null : _tambahItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B2B2B),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Tambah',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= WIDGET BANTU =================
  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD97D7D),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
