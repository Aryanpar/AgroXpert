
import 'package:flutter/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';

Widget platformImage(String path, {double? width, double? height, BoxFit? fit}) {
  return Image.network(
    path,
    width: width,
    height: height,
    fit: fit,
  );
}

ImageProvider platformImageProvider(String path) {
  return NetworkImage(path);
}

Future<void> platformUpload(Reference ref, dynamic xfile) async {
  final bytes = await xfile.readAsBytes();
  await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
}

Future<void> platformBackup(String fileName, String content) async {
  debugPrint('Backup not supported on web');
}
