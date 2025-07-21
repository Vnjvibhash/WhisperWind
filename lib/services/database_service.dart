import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:whisperwind/models/chat_message.dart';
import 'package:whisperwind/models/bluetooth_device_model.dart';
import 'package:whisperwind/models/chat_session.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'whisperwind.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        isFromCurrentUser INTEGER NOT NULL,
        deviceId TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE devices(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        connectionStatus INTEGER NOT NULL,
        customName TEXT,
        lastConnected INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_sessions(
        deviceId TEXT PRIMARY KEY,
        deviceName TEXT NOT NULL,
        lastMessageTime INTEGER NOT NULL,
        lastMessage TEXT,
        unreadCount INTEGER DEFAULT 0
      )
    ''');
  }

  // Message operations
  Future<int> insertMessage(ChatMessage message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<ChatMessage>> getMessages(String deviceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => ChatMessage.fromMap(maps[i]));
  }

  Future<void> deleteMessages(String deviceId) async {
    final db = await database;
    await db.delete('messages', where: 'deviceId = ?', whereArgs: [deviceId]);
  }

  // Device operations
  Future<void> insertOrUpdateDevice(BluetoothDeviceModel device) async {
    final db = await database;
    await db.insert(
      'devices',
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BluetoothDeviceModel>> getDevices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('devices');
    return List.generate(maps.length, (i) => BluetoothDeviceModel.fromMap(maps[i]));
  }

  Future<BluetoothDeviceModel?> getDevice(String deviceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'devices',
      where: 'id = ?',
      whereArgs: [deviceId],
    );
    if (maps.isNotEmpty) {
      return BluetoothDeviceModel.fromMap(maps.first);
    }
    return null;
  }

  // Chat session operations
  Future<void> insertOrUpdateChatSession(ChatSession session) async {
    final db = await database;
    await db.insert(
      'chat_sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatSession>> getChatSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_sessions',
      orderBy: 'lastMessageTime DESC',
    );
    return List.generate(maps.length, (i) => ChatSession.fromMap(maps[i]));
  }

  Future<void> deleteChatSession(String deviceId) async {
    final db = await database;
    await db.delete('chat_sessions', where: 'deviceId = ?', whereArgs: [deviceId]);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}