import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

/// Simple Bluetooth Classic service to talk to HC-05 over SPP
class BluetoothService {
  BluetoothConnection? _connection;
  BluetoothDevice? _device;

  bool get isConnected => _connection?.isConnected == true;
  String? get connectedName => _device?.name;
  String? get connectedAddress => _device?.address;

  /// Get already paired (bonded) devices; HC-05 should appear here once paired
  Future<List<BluetoothDevice>> getBondedDevices() async {
    await _ensurePermissions();
    return FlutterBluetoothSerial.instance.getBondedDevices();
  }

  /// Connect to a device by address or by name (e.g., 'HC-05')
  Future<void> connect({String? address, String? name}) async {
    if (isConnected) return;
    await _ensurePermissions();
    await FlutterBluetoothSerial.instance.requestEnable();

    BluetoothDevice? target;
    if (address == null && name != null) {
      final bonded = await getBondedDevices();
      try {
        target = bonded.firstWhere(
          (d) => (d.name ?? '').toUpperCase() == name.toUpperCase(),
        );
      } catch (_) {
        throw Exception(
          'Bluetooth device "$name" not paired. Pair it in system settings first.',
        );
      }
    }

    final targetAddress = address ?? target?.address;
    if (targetAddress == null) {
      throw Exception('No Bluetooth address resolved for connection.');
    }

    _device = target;
    _connection = await BluetoothConnection.toAddress(targetAddress);
  }

  /// Send a small ASCII command like 'A', 'B', 'C', 'D', 'L', 'l'
  Future<void> send(String command) async {
    if (!isConnected || _connection == null) {
      throw Exception('Bluetooth not connected');
    }
    final bytes = Uint8List.fromList(command.codeUnits);
    _connection!.output.add(bytes);
    await _connection!.output.allSent;
  }

  Future<void> disconnect() async {
    try {
      await _connection?.finish();
      _connection?.dispose();
    } catch (_) {}
    _connection = null;
    _device = null;
  }

  Future<void> _ensurePermissions() async {
    if (kIsWeb) return;
    final requests = <Permission>[
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.locationWhenInUse,
    ];
    for (final p in requests) {
      final status = await p.status;
      if (!status.isGranted) {
        await p.request();
      }
    }
  }
}
