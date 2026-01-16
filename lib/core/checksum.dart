import 'dart:typed_data';

import 'package:crypto/crypto.dart';

String sha256Hex(Uint8List bytes) {
  final digest = sha256.convert(bytes);
  return digest.toString();
}
