import 'package:flutter/material.dart';
import 'package:whisperwind/models/bluetooth_device_model.dart';

class DeviceListTile extends StatelessWidget {
  final BluetoothDeviceModel device;
  final VoidCallback onTap;

  const DeviceListTile({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDeviceColor(device.name),
          child: Icon(
            _getDeviceIcon(device.name),
            color: Colors.white,
          ),
        ),
        title: Text(
          device.displayName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              device.address,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getConnectionStatusIcon(),
                  size: 16,
                  color: _getConnectionStatusColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  _getConnectionStatusText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getConnectionStatusColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getDeviceColor(String deviceName) {
    // Generate a consistent color based on device name
    int hash = deviceName.hashCode;
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.red,
    ];
    return colors[hash.abs() % colors.length];
  }

  IconData _getDeviceIcon(String deviceName) {
    String lowerName = deviceName.toLowerCase();
    
    if (lowerName.contains('phone') || lowerName.contains('mobile')) {
      return Icons.phone_android;
    } else if (lowerName.contains('tablet')) {
      return Icons.tablet;
    } else if (lowerName.contains('laptop') || lowerName.contains('computer')) {
      return Icons.laptop;
    } else if (lowerName.contains('watch')) {
      return Icons.watch;
    } else if (lowerName.contains('headphone') || lowerName.contains('earbud')) {
      return Icons.headphones;
    } else if (lowerName.contains('speaker')) {
      return Icons.speaker;
    } else {
      return Icons.bluetooth;
    }
  }

  IconData _getConnectionStatusIcon() {
    switch (device.connectionStatus) {
      case BluetoothDeviceConnectionStatus.connected:
        return Icons.check_circle;
      case BluetoothDeviceConnectionStatus.connecting:
        return Icons.access_time;
      case BluetoothDeviceConnectionStatus.disconnected:
        return Icons.radio_button_unchecked;
      case BluetoothDeviceConnectionStatus.error:
        return Icons.error;
    }
  }

  Color _getConnectionStatusColor() {
    switch (device.connectionStatus) {
      case BluetoothDeviceConnectionStatus.connected:
        return Colors.green;
      case BluetoothDeviceConnectionStatus.connecting:
        return Colors.orange;
      case BluetoothDeviceConnectionStatus.disconnected:
        return Colors.grey;
      case BluetoothDeviceConnectionStatus.error:
        return Colors.red;
    }
  }

  String _getConnectionStatusText() {
    switch (device.connectionStatus) {
      case BluetoothDeviceConnectionStatus.connected:
        return 'Connected';
      case BluetoothDeviceConnectionStatus.connecting:
        return 'Connecting...';
      case BluetoothDeviceConnectionStatus.disconnected:
        return 'Available';
      case BluetoothDeviceConnectionStatus.error:
        return 'Error';
    }
  }
}