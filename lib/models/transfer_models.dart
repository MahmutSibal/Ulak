enum TransferStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled,
  failed,
}

TransferStatus transferStatusFromApi(String value) {
  switch (value) {
    case 'pending':
      return TransferStatus.pending;
    case 'accepted':
      return TransferStatus.accepted;
    case 'rejected':
      return TransferStatus.rejected;
    case 'in_progress':
      return TransferStatus.inProgress;
    case 'completed':
      return TransferStatus.completed;
    case 'cancelled':
      return TransferStatus.cancelled;
    case 'failed':
      return TransferStatus.failed;
    default:
      return TransferStatus.pending;
  }
}

String transferStatusLabel(TransferStatus status) {
  switch (status) {
    case TransferStatus.pending:
      return 'Bekliyor';
    case TransferStatus.accepted:
      return 'Kabul edildi';
    case TransferStatus.rejected:
      return 'Reddedildi';
    case TransferStatus.inProgress:
      return 'Aktarımda';
    case TransferStatus.completed:
      return 'Tamamlandı';
    case TransferStatus.cancelled:
      return 'İptal';
    case TransferStatus.failed:
      return 'Hata';
  }
}

class TransferSession {
  TransferSession({
    required this.id,
    required this.senderUserId,
    required this.receiverUserId,
    required this.receiverIp,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
    required this.checksumSha256,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String senderUserId;
  final String? receiverUserId;
  final String? receiverIp;

  final String fileName;
  final int fileSize;
  final String? fileType;
  final String checksumSha256;

  final TransferStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TransferSession.fromJson(Map<String, dynamic> json) {
    return TransferSession(
      id: json['id'] as String,
      senderUserId: json['sender_user_id'] as String,
      receiverUserId: json['receiver_user_id'] as String?,
      receiverIp: json['receiver_ip'] as String?,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as int,
      fileType: json['file_type'] as String?,
      checksumSha256: json['checksum_sha256'] as String,
      status: transferStatusFromApi(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
