class ChatMessage {
  final int? id;
  final String content;
  final DateTime timestamp;
  final bool isFromCurrentUser;
  final String deviceId;

  ChatMessage({
    this.id,
    required this.content,
    required this.timestamp,
    required this.isFromCurrentUser,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isFromCurrentUser': isFromCurrentUser ? 1 : 0,
      'deviceId': deviceId,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isFromCurrentUser: map['isFromCurrentUser'] == 1,
      deviceId: map['deviceId'],
    );
  }

  ChatMessage copyWith({
    int? id,
    String? content,
    DateTime? timestamp,
    bool? isFromCurrentUser,
    String? deviceId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}