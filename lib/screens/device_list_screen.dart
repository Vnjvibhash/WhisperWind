import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisperwind/providers/bluetooth_provider.dart';
import 'package:whisperwind/widgets/device_list_tile.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    final bluetoothProvider = context.read<BluetoothProvider>();
    
    if (!await bluetoothProvider.isBluetoothEnabled()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable Bluetooth to discover devices'),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    if (!await bluetoothProvider.requestPermissions()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bluetooth permissions are required'),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    await bluetoothProvider.startScanning();
  }

  @override
  void dispose() {
    context.read<BluetoothProvider>().stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, bluetoothProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Available Devices'),
            actions: [
              if (bluetoothProvider.isScanning)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _startScanning,
                ),
            ],
          ),
          body: Column(
            children: [
              if (bluetoothProvider.isScanning)
                const LinearProgressIndicator(),
              
              if (bluetoothProvider.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bluetoothProvider.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => bluetoothProvider.clearError(),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: _buildDeviceList(bluetoothProvider),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Make sure the other device is discoverable and running WhisperWind',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceList(BluetoothProvider bluetoothProvider) {
    if (bluetoothProvider.discoveredDevices.isEmpty && !bluetoothProvider.isScanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No devices found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap refresh to scan again',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (bluetoothProvider.discoveredDevices.isEmpty && bluetoothProvider.isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Scanning for devices...'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bluetoothProvider.discoveredDevices.length,
      itemBuilder: (context, index) {
        final device = bluetoothProvider.discoveredDevices[index];
        return DeviceListTile(
          device: device,
          onTap: () => _connectToDevice(device, bluetoothProvider),
        );
      },
    );
  }

  Future<void> _connectToDevice(device, BluetoothProvider bluetoothProvider) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Connecting to ${device.displayName}...'),
          ],
        ),
      ),
    );

    bool success = await bluetoothProvider.connectToDevice(device);
    
    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to ${device.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Go back to home screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to ${device.displayName}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}