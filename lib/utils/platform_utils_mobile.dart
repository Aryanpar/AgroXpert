
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:share_plus/share_plus.dart';

Widget platformImage(String path, {double? width, double? height, BoxFit? fit}) {
  if (path.startsWith('http') || path.startsWith('https') || path.startsWith('blob:')) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
    );
  }
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
  );
}

ImageProvider platformImageProvider(String path) {
  if (path.startsWith('http') || path.startsWith('https') || path.startsWith('blob:')) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}

Future<void> platformUpload(Reference ref, dynamic xfile) async {
  await ref.putFile(File(xfile.path));
}

Future<void> platformBackup(String fileName, String content) async {
  final directory = await path_provider.getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(content);
  await Share.shareXFiles([XFile(file.path)]);
}
