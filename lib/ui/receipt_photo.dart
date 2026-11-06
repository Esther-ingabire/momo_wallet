import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// The receipt chosen on this phone, or the one already saved online.
class ReceiptPhoto extends StatelessWidget {
  const ReceiptPhoto({
    super.key,
    required this.photo,
    required this.onPicked,
    this.savedUrl,
    this.busy = false,
  });

  final File? photo;
  final String? savedUrl;
  final void Function(File photo) onPicked;
  final bool busy;

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 70,
    );
    if (picked == null) return;
    onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (photo != null)
          Image.file(photo!, height: 180, fit: BoxFit.cover)
        else if (savedUrl != null && savedUrl!.isNotEmpty)
          Image.network(
            savedUrl!,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => const SizedBox(
              height: 180,
              child: Center(child: Icon(Icons.broken_image)),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
