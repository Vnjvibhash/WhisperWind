import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whisperwind/models/bluetooth_device_model.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final StreamController<List<BluetoothDeviceModel>> _devicesController = 
      StreamController<List<BluetoothDeviceModel>>.broadcast();
  final StreamController<String> _messageController = 
      StreamController<String>.broadcast();
  final StreamController<BluetoothDeviceConnectionStatus> _connectionStatusController =
      StreamController<BluetoothDeviceConnectionStatus>.broadcast();

  Stream<List<BluetoothDeviceModel>> get devicesStream => _devicesController.stream;
  Stream<String> get messageStream => _messageController.stream;
  Stream<BluetoothDeviceConnectionStatus> get connectionStatusStream => 
      _connectionStatusController.stream;

  List<BluetoothDeviceModel> _discoveredDevices = [];
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;

  static const String serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String writeCharacteristicUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String readCharacteristicUuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";

  Future<bool> requestPermissions() async {
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.locationWhenInUse.isDenied) {
      await Permission.locationWhenInUse.request();
    }

    return await Permission.bluetoothScan.isGranted &&
           await Permission.bluetoothConnect.isGranted &&
           await Permission.locationWhenInUse.isGranted;
  }

  Future<bool> isBluetoothEnabled() async {
    return await FlutterBluePlus.isOn;
  }

  Future<void> startScanning() async {
    if (!await requestPermissions()) {
      throw Exception('Bluetooth permissions not granted');
    }

    if (!await isBluetoothEnabled()) {
      throw Exception('Bluetooth is not enabled');
    }

    _discoveredDevices.clear();
    
    FlutterBluePlus.scanResults.listen((results) {
      _discoveredDevices.clear();
      for (ScanResult result in results) {
        if (result.device.platformName.isNotEmpty) {
          _discoveredDevices.add(BluetoothDeviceModel(
            id: result.device.remoteId.toString(),
            name: result.device.platformName,
            address: result.device.remoteId.toString(),
          ));
        }
      }
      _devicesController.add(List.from(_discoveredDevices));
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
  }

  Future<bool> connectToDevice(BluetoothDeviceModel deviceModel) async {
    try {
      _connectionStatusController.add(BluetoothDeviceConnectionStatus.connecting);
      
      final device = BluetoothDevice.fromId(deviceModel.id);
      await device.connect();
      _connectedDevice = device;

      List<fbp.BluetoothService> services = await device.discoverServices();
      
      for (fbp.BluetoothService service in services) {
        if (service.uuid.toString().toUpperCase() == serviceUuid.toUpperCase()) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toUpperCase() == writeCharacteristicUuid.toUpperCase()) {
              _writeCharacteristic = characteristic;
            }
            if (characteristic.uuid.toString().toUpperCase() == readCharacteristicUuid.toUpperCase()) {
              _readCharacteristic = characteristic;
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  String message = utf8.decode(value);
                  _messageController.add(message);
                }
              });
            }
          }
        }
      }

      _connectionStatusController.add(BluetoothDeviceConnectionStatus.connected);
      return true;
    } catch (e) {
      _connectionStatusController.add(BluetoothDeviceConnectionStatus.error);
      return false;
    }
  }

  Future<bool> sendMessage(String message) async {
    if (_writeCharacteristic == null || _connectedDevice == null) {
      return false;
    }

    try {
      List<int> bytes = utf8.encode(message);
      await _writeCharacteristic!.write(bytes);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _writeCharacteristic = null;
      _readCharacteristic = null;
      _connectionStatusController.add(BluetoothDeviceConnectionStatus.disconnected);
    }
  }

  BluetoothDeviceModel? get connectedDevice {
    if (_connectedDevice != null) {
      return BluetoothDeviceModel(
        id: _connectedDevice!.remoteId.toString(),
        name: _connectedDevice!.platformName,
        address: _connectedDevice!.remoteId.toString(),
        connectionStatus: BluetoothDeviceConnectionStatus.connected,
      );
    }
    return null;
  }

  void dispose() {
    _devicesController.close();
    _messageController.close();
    _connectionStatusController.close();
  }
}