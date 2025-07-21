import 'package:flutter/material.dart';
import 'package:whisperwind/models/bluetooth_device_model.dart';
import 'package:whisperwind/services/bluetooth_service.dart';
import 'package:whisperwind/services/database_service.dart';

class BluetoothProvider with ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();
  final DatabaseService _databaseService = DatabaseService();

  List<BluetoothDeviceModel> _discoveredDevices = [];
  BluetoothDeviceModel? _connectedDevice;
  BluetoothDeviceConnectionStatus _connectionStatus = BluetoothDeviceConnectionStatus.disconnected;
  bool _isScanning = false;
  String? _error;

  List<BluetoothDeviceModel> get discoveredDevices => _discoveredDevices;
  BluetoothDeviceModel? get connectedDevice => _connectedDevice;
  BluetoothDeviceConnectionStatus get connectionStatus => _connectionStatus;
  bool get isScanning => _isScanning;
  String? get error => _error;

  BluetoothProvider() {
    _bluetoothService.devicesStream.listen((devices) {
      _discoveredDevices = devices;
      notifyListeners();
    });

    _bluetoothService.connectionStatusStream.listen((status) {
      _connectionStatus = status;
      if (status == BluetoothDeviceConnectionStatus.connected) {
        _connectedDevice = _bluetoothService.connectedDevice;
      } else if (status == BluetoothDeviceConnectionStatus.disconnected) {
        _connectedDevice = null;
      }
      notifyListeners();
    });
  }

  Future<bool> requestPermissions() async {
    try {
      return await _bluetoothService.requestPermissions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> isBluetoothEnabled() async {
    return await _bluetoothService.isBluetoothEnabled();
  }

  Future<void> startScanning() async {
    try {
      _isScanning = true;
      _error = null;
      notifyListeners();
      
      await _bluetoothService.startScanning();
    } catch (e) {
      _error = e.toString();
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScanning() async {
    await _bluetoothService.stopScanning();
    _isScanning = false;
    notifyListeners();
  }

  Future<bool> connectToDevice(BluetoothDeviceModel device) async {
    try {
      _error = null;
      notifyListeners();
      
      bool success = await _bluetoothService.connectToDevice(device);
      if (success) {
        await _databaseService.insertOrUpdateDevice(device.copyWith(
          connectionStatus: BluetoothDeviceConnectionStatus.connected,
          lastConnected: DateTime.now(),
        ));
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnect() async {
    await _bluetoothService.disconnect();
  }

  Future<void> updateDeviceCustomName(String deviceId, String customName) async {
    if (_connectedDevice?.id == deviceId) {
      _connectedDevice = _connectedDevice!.copyWith(customName: customName);
      notifyListeners();
    }
    
    final device = await _databaseService.getDevice(deviceId);
    if (device != null) {
      await _databaseService.insertOrUpdateDevice(
        device.copyWith(customName: customName),
      );
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }
}