


import 'package:image_picker/image_picker.dart';

/// Stubbed TFLite service for web/unsupported platforms.
/// Provides the same API but no-ops so the app compiles and runs on web.
class TFLiteService {
  bool get isModelLoaded => false;
  bool get isLoading => false;
  String? get lastError => 'TFLite not supported on this platform';

  Future<bool> loadModel() async {
    return false;
  }

  Future<Map<String, dynamic>> runInference(XFile imageFile) async {
    return {'error': 'TFLite is not supported on Web. Please use the mobile app for disease detection.'};
  }

  void dispose() {}
}
