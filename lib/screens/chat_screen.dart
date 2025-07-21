import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisperwind/providers/message_provider.dart';
import 'package:whisperwind/providers/bluetooth_provider.dart';
import 'package:whisperwind/widgets/message_bubble.dart';
import 'package:whisperwind/widgets/chat_input_field.dart';
import 'package:whisperwind/models/bluetooth_device_model.dart';

class ChatScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;

  const ChatScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadMessagesForDevice(
        widget.deviceId,
        widget.deviceName,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MessageProvider, BluetoothProvider>(
      builder: (context, messageProvider, bluetoothProvider, child) {
        // Auto-scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (messageProvider.messages.isNotEmpty) {
            _scrollToBottom();
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.deviceName),
                Text(
                  _getConnectionStatusText(bluetoothProvider),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getConnectionStatusColor(bluetoothProvider),
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, messageProvider),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear Chat'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Rename Device'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: _buildMessagesList(messageProvider),
              ),
              ChatInputField(
                controller: _textController,
                onSendMessage: (message) => _sendMessage(message, messageProvider),
                isConnected: bluetoothProvider.connectionStatus.toString().contains('connected'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessagesList(MessageProvider messageProvider) {
    if (messageProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messageProvider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to start the conversation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messageProvider.messages.length,
      itemBuilder: (context, index) {
        final message = messageProvider.messages[index];
        return MessageBubble(message: message);
      },
    );
  }

  Future<void> _sendMessage(String content, MessageProvider messageProvider) async {
    if (content.trim().isEmpty) return;

    await messageProvider.sendMessage(content, widget.deviceId, widget.deviceName);
    _textController.clear();
  }

  String _getConnectionStatusText(BluetoothProvider bluetoothProvider) {
    switch (bluetoothProvider.connectionStatus) {
      case BluetoothDeviceConnectionStatus.connected:
        return 'Connected';
      case BluetoothDeviceConnectionStatus.connecting:
        return 'Connecting...';
      case BluetoothDeviceConnectionStatus.disconnected:
        return 'Disconnected';
      case BluetoothDeviceConnectionStatus.error:
        return 'Connection Error';
    }
  }

  Color _getConnectionStatusColor(BluetoothProvider bluetoothProvider) {
    switch (bluetoothProvider.connectionStatus) {
      case BluetoothDeviceConnectionStatus.connected:
        return Colors.green;
      case BluetoothDeviceConnectionStatus.connecting:
        return Colors.orange;
      case BluetoothDeviceConnectionStatus.disconnected:
        return Colors.red;
      case BluetoothDeviceConnectionStatus.error:
        return Colors.red;
    }
  }

  void _handleMenuAction(String action, MessageProvider messageProvider) {
    switch (action) {
      case 'clear':
        _showClearChatDialog(messageProvider);
        break;
      case 'rename':
        _showRenameDeviceDialog();
        break;
    }
  }

  void _showClearChatDialog(MessageProvider messageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await messageProvider.clearChatHistory(widget.deviceId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat history cleared')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showRenameDeviceDialog() {
    final TextEditingController nameController = TextEditingController(text: widget.deviceName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Device'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Device Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != widget.deviceName) {
                Navigator.pop(context);
                await context.read<BluetoothProvider>().updateDeviceCustomName(
                  widget.deviceId,
                  newName,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Device renamed to "$newName"')),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}