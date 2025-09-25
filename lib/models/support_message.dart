import 'package:equatable/equatable.dart';

class SupportMessage extends Equatable {
  const SupportMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
    this.status,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;
  final String? status;

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory SupportMessage.fromFirestore(String id, Map<String, dynamic> data) {
    return SupportMessage(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
      status: data['status'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, senderId, senderName, body, createdAt, status];
}
