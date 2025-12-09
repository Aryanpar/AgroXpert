/// Stubbed Bluetooth service for web/unsupported platforms.
/// Provides the same API but no-ops so the app compiles and runs on web.
class BluetoothService {
  bool get isConnected => false;
  String? get connectedName => null;
  String? get connectedAddress => null;

  Future<void> connect({String? address, String? name}) async {}
  Future<void> send(String command) async {}
  Future<void> disconnect() async {}
}

