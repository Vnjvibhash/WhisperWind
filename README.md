# WhisperWind - Bluetooth Chat Application

WhisperWind is a Flutter application that enables real-time text messaging between devices via Bluetooth connection, requiring no internet access.

## Features

✅ **Implemented:**
- Bluetooth device discovery and scanning
- Device connection and disconnection management
- Real-time text messaging between connected devices
- Message history stored locally with SQLite
- Modern chat UI with sender/receiver distinction
- Message timestamps and delivery indicators
- Connection status display
- Device custom naming and management
- Chat history clearing
- Dark/Light theme support
- Settings management

## Key Components

### Models
- **ChatMessage**: Represents individual chat messages with timestamp and sender info
- **BluetoothDeviceModel**: Manages Bluetooth device information and connection status
- **ChatSession**: Tracks conversation sessions and unread counts

### Services
- **BluetoothService**: Handles all Bluetooth operations including scanning, connecting, and data transmission
- **DatabaseService**: Manages local SQLite database for message and device storage
- **SettingsService**: Manages user preferences using SharedPreferences
- **MessageService**: Utility functions for message validation and formatting

### Providers (State Management)
- **BluetoothProvider**: Manages Bluetooth connection state and device discovery
- **MessageProvider**: Handles message sending/receiving and chat session management
- **SettingsProvider**: Manages app settings and preferences

### Screens
- **HomeScreen**: Main dashboard showing connection status and recent chats
- **DeviceListScreen**: Bluetooth device discovery and connection interface
- **ChatScreen**: Real-time messaging interface
- **SettingsScreen**: App configuration and preferences

### Widgets
- **MessageBubble**: Chat message display with styling
- **DeviceListTile**: Device selection interface
- **ConnectionStatusWidget**: Real-time connection status indicator
- **ChatInputField**: Message composition interface

## Technical Stack

- **Flutter** - Cross-platform mobile framework
- **flutter_blue_plus** - Bluetooth Low Energy communication
- **provider** - State management
- **sqflite** - Local database storage
- **shared_preferences** - Settings persistence
- **intl** - Date/time formatting
- **permission_handler** - Bluetooth permissions management

## Permissions

### Android
- BLUETOOTH
- BLUETOOTH_ADMIN
- BLUETOOTH_SCAN
- BLUETOOTH_CONNECT
- BLUETOOTH_ADVERTISE
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION

### iOS
- NSBluetoothAlwaysUsageDescription
- NSBluetoothPeripheralUsageDescription

## Installation

1. Ensure Flutter SDK is installed
2. Clone the project
3. Run `flutter pub get` to install dependencies
4. Connect a physical device (Bluetooth requires real hardware)
5. Run `flutter run`

## Usage

1. **Grant Permissions**: Allow Bluetooth and location permissions when prompted
2. **Scan for Devices**: Tap "Find Devices" to discover nearby WhisperWind users
3. **Connect**: Select a device from the list to establish connection
4. **Chat**: Send and receive messages in real-time
5. **Manage**: Access settings to customize app behavior and manage devices

## Architecture

The app follows clean architecture principles with:
- Separation of concerns between UI, business logic, and data layers
- Provider pattern for reactive state management
- Repository pattern for data access
- Service layer for external integrations (Bluetooth, database)

## Future Enhancements

Potential features for future development:
- File sharing over Bluetooth
- Voice message recording/playback
- Message encryption for enhanced security
- Group chat support
- Message reactions and emojis
- Offline AI chat summary generation
- Custom notification sounds
- Message search functionality

## Development Notes

- Uses custom UUID for Bluetooth service identification
- Implements Nordic UART Service (NUS) protocol for data transmission
- Local database schema supports message history and device management
- Responsive UI adapts to different screen sizes
- Material Design 3 theming with custom color schemes

## Troubleshooting

**Connection Issues:**
- Ensure both devices have Bluetooth enabled
- Make sure devices are in close proximity (within 10 meters)
- Check that location permissions are granted on Android

**Message Delivery:**
- Verify stable Bluetooth connection
- Check that the receiving device is running WhisperWind
- Restart Bluetooth connection if messages aren't sending

**Scanning Problems:**
- Ensure location services are enabled on Android
- Try refreshing the device scan
- Check Bluetooth adapter compatibility
