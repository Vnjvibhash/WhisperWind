import 'package:whisperwind/models/chat_message.dart';

class MessageService {
  static List<ChatMessage> generateSampleMessages(String deviceId) {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: 1,
        content: "Hey! I see you're using WhisperWind too 👋",
        timestamp: now.subtract(const Duration(minutes: 15)),
        isFromCurrentUser: false,
        deviceId: deviceId,
      ),
      ChatMessage(
        id: 2,
        content: "Yes! This Bluetooth chat is pretty cool. No internet needed!",
        timestamp: now.subtract(const Duration(minutes: 14)),
        isFromCurrentUser: true,
        deviceId: deviceId,
      ),
      ChatMessage(
        id: 3,
        content: "Exactly! Perfect for when you're offline or in areas with poor connectivity",
        timestamp: now.subtract(const Duration(minutes: 13)),
        isFromCurrentUser: false,
        deviceId: deviceId,
      ),
      ChatMessage(
        id: 4,
        content: "The message history is stored locally too, which is great for privacy",
        timestamp: now.subtract(const Duration(minutes: 12)),
        isFromCurrentUser: true,
        deviceId: deviceId,
      ),
      ChatMessage(
        id: 5,
        content: "True! And the real-time messaging works really well",
        timestamp: now.subtract(const Duration(minutes: 10)),
        isFromCurrentUser: false,
        deviceId: deviceId,
      ),
    ];
  }

  static bool isValidMessage(String content) {
    return content.trim().isNotEmpty && content.length <= 1000;
  }

  static String sanitizeMessage(String content) {
    return content.trim();
  }

  static String formatMessagePreview(String content, {int maxLength = 50}) {
    if (content.length <= maxLength) {
      return content;
    }
    return '${content.substring(0, maxLength)}...';
  }
}