class ChatModel {
  final String id;
  final String type;
  final String message;
  final String isRead;
  final String createdTs;

  ChatModel({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdTs,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['c_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['is_read']?.toString() ?? '',
      createdTs: json['created_ts']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'c_id': id,
      'type': type,
      'message': message,
      'is_read': isRead,
      'created_ts': createdTs
    };
  }
}
