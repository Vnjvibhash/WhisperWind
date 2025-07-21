class ChatSession {
  final String deviceId;
  final String deviceName;
  final DateTime lastMessageTime;
  final String? lastMessage;
  final int unreadCount;

  ChatSession({
    required this.deviceId,
    required this.deviceName,
    required this.lastMessageTime,
    this.lastMessage,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      deviceId: map['deviceId'],
      deviceName: map['deviceName'],
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime']),
      lastMessage: map['lastMessage'],
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  ChatSession copyWith({
    String? deviceId,
    String? deviceName,
    DateTime? lastMessageTime,
    String? lastMessage,
    int? unreadCount,
  }) {
    return ChatSession(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}