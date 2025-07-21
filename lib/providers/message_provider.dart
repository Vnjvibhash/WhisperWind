import 'package:flutter/material.dart';
import 'package:whisperwind/models/chat_message.dart';
import 'package:whisperwind/models/chat_session.dart';
import 'package:whisperwind/services/bluetooth_service.dart';
import 'package:whisperwind/services/database_service.dart';

class MessageProvider with ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();
  final DatabaseService _databaseService = DatabaseService();

  List<ChatMessage> _messages = [];
  List<ChatSession> _chatSessions = [];
  String? _currentDeviceId;
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  List<ChatSession> get chatSessions => _chatSessions;
  String? get currentDeviceId => _currentDeviceId;
  bool get isLoading => _isLoading;

  MessageProvider() {
    _bluetoothService.messageStream.listen((message) {
      if (_currentDeviceId != null) {
        _addReceivedMessage(message, _currentDeviceId!);
      }
    });
    _loadChatSessions();
  }

  Future<void> _loadChatSessions() async {
    _isLoading = true;
    notifyListeners();
    
    _chatSessions = await _databaseService.getChatSessions();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessagesForDevice(String deviceId, String deviceName) async {
    _currentDeviceId = deviceId;
    _isLoading = true;
    notifyListeners();

    _messages = await _databaseService.getMessages(deviceId);
    
    // Mark messages as read by resetting unread count
    await _updateChatSession(deviceId, deviceName, null, 0);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String content, String deviceId, String deviceName) async {
    if (content.trim().isEmpty || deviceId.isEmpty) return;

    final message = ChatMessage(
      content: content.trim(),
      timestamp: DateTime.now(),
      isFromCurrentUser: true,
      deviceId: deviceId,
    );

    // Send via Bluetooth
    bool success = await _bluetoothService.sendMessage(content.trim());
    
    if (success) {
      // Add to database
      await _databaseService.insertMessage(message);
      
      // Add to current message list if viewing this device
      if (_currentDeviceId == deviceId) {
        _messages.add(message);
        notifyListeners();
      }

      // Update chat session
      await _updateChatSession(deviceId, deviceName, content.trim(), 0);
    }
  }

  Future<void> _addReceivedMessage(String content, String deviceId) async {
    final message = ChatMessage(
      content: content,
      timestamp: DateTime.now(),
      isFromCurrentUser: false,
      deviceId: deviceId,
    );

    // Add to database
    await _databaseService.insertMessage(message);

    // Add to current message list if viewing this device
    if (_currentDeviceId == deviceId) {
      _messages.add(message);
      notifyListeners();
    }

    // Update chat session with unread count increment
    final existingSession = _chatSessions.firstWhere(
      (session) => session.deviceId == deviceId,
      orElse: () => ChatSession(
        deviceId: deviceId,
        deviceName: 'Unknown Device',
        lastMessageTime: DateTime.now(),
      ),
    );

    int newUnreadCount = _currentDeviceId == deviceId ? 0 : existingSession.unreadCount + 1;
    
    await _updateChatSession(
      deviceId,
      existingSession.deviceName,
      content,
      newUnreadCount,
    );
  }

  Future<void> _updateChatSession(String deviceId, String deviceName, String? lastMessage, int unreadCount) async {
    final session = ChatSession(
      deviceId: deviceId,
      deviceName: deviceName,
      lastMessageTime: DateTime.now(),
      lastMessage: lastMessage,
      unreadCount: unreadCount,
    );

    await _databaseService.insertOrUpdateChatSession(session);

    // Update local sessions list
    final index = _chatSessions.indexWhere((s) => s.deviceId == deviceId);
    if (index >= 0) {
      _chatSessions[index] = session;
    } else {
      _chatSessions.insert(0, session);
    }

    // Sort by last message time
    _chatSessions.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    
    notifyListeners();
  }

  Future<void> clearChatHistory(String deviceId) async {
    await _databaseService.deleteMessages(deviceId);
    
    if (_currentDeviceId == deviceId) {
      _messages.clear();
      notifyListeners();
    }

    await _databaseService.deleteChatSession(deviceId);
    _chatSessions.removeWhere((session) => session.deviceId == deviceId);
    notifyListeners();
  }

  void clearCurrentChat() {
    _currentDeviceId = null;
    _messages.clear();
    notifyListeners();
  }

  int getTotalUnreadCount() {
    return _chatSessions.fold(0, (total, session) => total + session.unreadCount);
  }
}