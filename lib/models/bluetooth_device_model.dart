enum BluetoothDeviceConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class BluetoothDeviceModel {
  final String id;
  final String name;
  final String address;
  final BluetoothDeviceConnectionStatus connectionStatus;
  final String? customName;
  final DateTime? lastConnected;

  BluetoothDeviceModel({
    required this.id,
    required this.name,
    required this.address,
    this.connectionStatus = BluetoothDeviceConnectionStatus.disconnected,
    this.customName,
    this.lastConnected,
  });

  String get displayName => customName ?? name;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'connectionStatus': connectionStatus.index,
      'customName': customName,
      'lastConnected': lastConnected?.millisecondsSinceEpoch,
    };
  }

  factory BluetoothDeviceModel.fromMap(Map<String, dynamic> map) {
    return BluetoothDeviceModel(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      connectionStatus: BluetoothDeviceConnectionStatus.values[map['connectionStatus']],
      customName: map['customName'],
      lastConnected: map['lastConnected'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastConnected'])
          : null,
    );
  }

  BluetoothDeviceModel copyWith({
    String? id,
    String? name,
    String? address,
    BluetoothDeviceConnectionStatus? connectionStatus,
    String? customName,
    DateTime? lastConnected,
  }) {
    return BluetoothDeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      customName: customName ?? this.customName,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }
}