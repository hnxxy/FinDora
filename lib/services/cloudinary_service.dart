import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> uploadImageToCloudinary(File imageFile) async {
  const cloudName = 'dbtus5u2p';
  const uploadPreset = 'portal_berita_unsigned';

  final uri = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );

  final request = http.MultipartRequest('POST', uri);
  request.fields['upload_preset'] = uploadPreset;
  request.files.add(
    await http.MultipartFile.fromPath('file', imageFile.path),
  );

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);
    return data['secure_url'];
  } else {
    return null;
  }
}
