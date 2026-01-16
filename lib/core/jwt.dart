import 'dart:convert';

String? jwtSubject(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  final payload = parts[1];

  String normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
  switch (normalized.length % 4) {
    case 0:
      break;
    case 2:
      normalized += '==';
      break;
    case 3:
      normalized += '=';
      break;
    default:
      return null;
  }

  try {
    final decoded = utf8.decode(base64.decode(normalized));
    final map = jsonDecode(decoded);
    if (map is Map<String, dynamic>) {
      final sub = map['sub'];
      return sub is String ? sub : null;
    }
  } catch (_) {
    return null;
  }
  return null;
}
