import 'package:dio/dio.dart';

import '../models/transfer_models.dart';

class TransfersApi {
  TransfersApi(this._dio);
  final Dio _dio;

  Future<List<TransferSession>> listSessions({int limit = 50, int offset = 0}) async {
    final res = await _dio.get(
      '/api/transfers/sessions',
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => TransferSession.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    return const [];
  }

  Future<TransferSession> createSession({
    required String fileName,
    required int fileSize,
    required String checksumSha256,
    String? fileType,
    String? receiverIp,
    String? receiverUserId,
  }) async {
    final res = await _dio.post(
      '/api/transfers/sessions',
      data: {
        'receiver_user_id': receiverUserId,
        'receiver_ip': receiverIp,
        'file_name': fileName,
        'file_size': fileSize,
        'file_type': fileType,
        'checksum_sha256': checksumSha256,
      },
    );

    return TransferSession.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> accept(String transferId) async {
    await _dio.post('/api/transfers/sessions/$transferId/accept');
  }

  Future<void> reject(String transferId) async {
    await _dio.post('/api/transfers/sessions/$transferId/reject');
  }

  Future<void> cancel(String transferId) async {
    await _dio.post('/api/transfers/sessions/$transferId/cancel');
  }
}
