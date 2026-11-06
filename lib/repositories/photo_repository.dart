import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// From the Cloudinary dashboard. Copy them exactly. They are case sensitive.
const cloudName = 'du9m48axh';
const uploadPreset = 'sawa_unsigned';

// The only class that talks to Cloudinary.
class PhotoRepository {
  Future<String> upload(File photo) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', photo.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Photo upload failed (${response.statusCode}): $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }
}
