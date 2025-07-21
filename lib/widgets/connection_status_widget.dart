import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisperwind/providers/bluetooth_provider.dart';
import 'package:whisperwind/models/bluetooth_device_model.dart';

class ConnectionStatusWidget extends StatelessWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildStatusIcon(bluetoothProvider.connectionStatus),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(bluetoothProvider),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusSubtitle(bluetoothProvider),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusIndicator(bluetoothProvider.connectionStatus),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(BluetoothDeviceConnectionStatus status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case BluetoothDeviceConnectionStatus.connected:
        iconData = Icons.bluetooth_connected;
        iconColor = Colors.green;
        break;
      case BluetoothDeviceConnectionStatus.connecting:
        iconData = Icons.bluetooth_searching;
        iconColor = Colors.orange;
        break;
      case BluetoothDeviceConnectionStatus.disconnected:
        iconData = Icons.bluetooth_disabled;
        iconColor = Colors.grey;
        break;
      case BluetoothDeviceConnectionStatus.error:
        iconData = Icons.bluetooth_disabled;
        iconColor = Colors.red;
        break;
    }

    return Icon(iconData, color: iconColor, size: 32);
  }

  Widget _buildStatusIndicator(BluetoothDeviceConnectionStatus status) {
    Widget indicator;

    switch (status) {
      case BluetoothDeviceConnectionStatus.connected:
        indicator = Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        );
        break;
      case BluetoothDeviceConnectionStatus.connecting:
        indicator = const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        break;
      case BluetoothDeviceConnectionStatus.disconnected:
        indicator = Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        );
        break;
      case BluetoothDeviceConnectionStatus.error:
        indicator = Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        );
        break;
    }

    return indicator;
  }

  String _getStatusTitle(BluetoothProvider bluetoothProvider) {
    switch (bluetoothProvider.connectionStatus) {
      case BluetoothDeviceConnectionStatus.connected:
        return bluetoothProvider.connectedDevice?.displayName ?? 'Connected';
      case BluetoothDeviceConnectionStatus.connecting:
        return 'Connecting...';
      case BluetoothDeviceConnectionStatus.disconnected:
        return 'Not Connected';
      case BluetoothDeviceConnectionStatus.error:
        return 'Connection Error';
    }
  }

  String _getStatusSubtitle(BluetoothProvider bluetoothProvider) {
    switch (bluetoothProvider.connectionStatus) {
      case BluetoothDeviceConnectionStatus.connected:
        return 'Ready to chat';
      case BluetoothDeviceConnectionStatus.connecting:
        return 'Establishing connection...';
      case BluetoothDeviceConnectionStatus.disconnected:
        return 'Find and connect to a device';
      case BluetoothDeviceConnectionStatus.error:
        return bluetoothProvider.error ?? 'Failed to connect';
    }
  }
}