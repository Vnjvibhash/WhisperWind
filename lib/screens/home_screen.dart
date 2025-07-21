import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisperwind/providers/bluetooth_provider.dart';
import 'package:whisperwind/providers/message_provider.dart';
import 'package:whisperwind/providers/settings_provider.dart';
import 'package:whisperwind/screens/device_list_screen.dart';
import 'package:whisperwind/screens/settings_screen.dart';
import 'package:whisperwind/screens/chat_screen.dart';
import 'package:whisperwind/widgets/connection_status_widget.dart';
import 'package:whisperwind/models/bluetooth_device_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final bluetoothProvider = context.read<BluetoothProvider>();
    
    // Request permissions on app start
    await bluetoothProvider.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<BluetoothProvider, MessageProvider, SettingsProvider>(
      builder: (context, bluetoothProvider, messageProvider, settingsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('WhisperWind'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ConnectionStatusWidget(),
                const SizedBox(height: 24),
                
                if (bluetoothProvider.connectedDevice != null) ...[
                  _buildConnectedDeviceCard(bluetoothProvider.connectedDevice!),
                  const SizedBox(height: 16),
                ] else ...[
                  _buildScanSection(bluetoothProvider),
                  const SizedBox(height: 24),
                ],

                Text(
                  'Recent Chats',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: _buildChatSessionsList(messageProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectedDeviceCard(BluetoothDeviceModel device) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bluetooth_connected, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Connected to ${device.displayName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () => _openChat(device),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.read<BluetoothProvider>().disconnect(),
                    child: const Text('Disconnect'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanSection(BluetoothProvider bluetoothProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bluetooth Devices',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: bluetoothProvider.isScanning ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DeviceListScreen()),
                      );
                    },
                    icon: Icon(bluetoothProvider.isScanning ? Icons.hourglass_empty : Icons.search),
                    label: Text(bluetoothProvider.isScanning ? 'Scanning...' : 'Find Devices'),
                  ),
                ),
              ],
            ),
            if (bluetoothProvider.error != null) ...[
              const SizedBox(height: 8),
              Text(
                bluetoothProvider.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatSessionsList(MessageProvider messageProvider) {
    if (messageProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messageProvider.chatSessions.isEmpty) {
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
              'No chats yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connect to a device to start chatting',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: messageProvider.chatSessions.length,
      itemBuilder: (context, index) {
        final session = messageProvider.chatSessions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              session.deviceName[0].toUpperCase(),
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          title: Text(session.deviceName),
          subtitle: Text(
            session.lastMessage ?? 'No messages',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: session.unreadCount > 0
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    session.unreadCount.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                )
              : null,
          onTap: () => _openChatFromSession(session.deviceId, session.deviceName),
        );
      },
    );
  }

  void _openChat(BluetoothDeviceModel device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          deviceId: device.id,
          deviceName: device.displayName,
        ),
      ),
    );
  }

  void _openChatFromSession(String deviceId, String deviceName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          deviceId: deviceId,
          deviceName: deviceName,
        ),
      ),
    );
  }
}