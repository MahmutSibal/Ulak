import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api_client.dart';
import '../services/auth_api.dart';
import '../services/auth_storage.dart';
import '../services/transfers_api.dart';

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(authStorageProvider);
  return ApiClient(storage: storage);
});

final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.read(apiClientProvider);
  return AuthApi(client.dio);
});

final transfersApiProvider = Provider<TransfersApi>((ref) {
  final client = ref.read(apiClientProvider);
  return TransfersApi(client.dio);
});
