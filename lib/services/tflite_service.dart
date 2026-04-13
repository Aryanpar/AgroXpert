
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;
  bool _isLoading = false;
  String? _lastError;

  bool get isModelLoaded => _isModelLoaded;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<bool> loadModel() async {
    if (_isLoading || _isModelLoaded) return _isModelLoaded;
    
    _isLoading = true;
    _lastError = null;
    
    try {
      debugPrint('Loading TFLite model...');
      
      // Load model with optimized settings
      _interpreter = await Interpreter.fromAsset(
        'assets/plant_disease_model.tflite',
        options: InterpreterOptions()
          ..threads = 4
          ..useNnApiForAndroid = true,
      );

      // Get input and output tensor details
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();

      debugPrint('Model loaded successfully!');
      debugPrint('Input tensors: ${inputTensors.length}');
      for (int i = 0; i < inputTensors.length; i++) {
        debugPrint('Input $i: ${inputTensors[i].type} ${inputTensors[i].shape}');
      }

      debugPrint('Output tensors: ${outputTensors.length}');
      for (int i = 0; i < outputTensors.length; i++) {
        debugPrint('Output $i: ${outputTensors[i].type} ${outputTensors[i].shape}');
      }

      // Load and validate labels
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .map((label) => label.trim())
          .toList();
          
      if (_labels.isEmpty) {
        throw Exception('No labels found in labels.txt');
      }

      debugPrint('Labels loaded: ${_labels.length} labels');
      debugPrint('TFLite model loaded successfully with ${_labels.length} labels');
      _isModelLoaded = true;
      return true;
    } catch (e, stackTrace) {
      _lastError = 'Failed to load model: $e\n$stackTrace';
      debugPrint(_lastError);
      _isModelLoaded = false;
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<Map<String, dynamic>> runInference(XFile imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      final loaded = await loadModel();
      if (!loaded) {
        return {'error': 'Model not loaded: $_lastError'};
      }
    }

    try {
      debugPrint('Running inference on image: ${imageFile.path}');
      
      final imageData = await imageFile.readAsBytes();
      final image = img.decodeImage(imageData);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final input = _preprocessImage(image);
      final output = _createOutputBuffer();

      final stopwatch = Stopwatch()..start();
      debugPrint('Input tensor shape: ${input.length}x${input[0].length}x${input[0][0].length}x${input[0][0][0].length}');
      _interpreter!.run(input, output);
      stopwatch.stop();

      debugPrint('Output tensor shape: ${output.length}x${output[0].length}');
      debugPrint('Inference completed in ${stopwatch.elapsedMilliseconds}ms');

      final results = _processOutput(output[0]);
      if (results.isEmpty) {
        return {'error': 'No valid predictions'};
      }

      // Return top prediction and all predictions for better handling
      return {
        'label': results.first['label'],
        'confidence': results.first['confidence'],
        'allPredictions': results,
        'inferenceTimeMs': stopwatch.elapsedMilliseconds,
        'topPredictions': results.take(3).toList(), // Return top 3 predictions
      };
    } catch (e, stackTrace) {
      _lastError = 'Inference failed: $e\n$stackTrace';
      debugPrint(_lastError);
      return {'error': _lastError};
    }
  }

  List<Map<String, dynamic>> _processOutput(List<double> output) {
    if (output.isEmpty) {
      debugPrint('Output is empty');
      return [];
    }
    
    // Handle case where output length doesn't match labels length
    if (output.length != _labels.length) {
      debugPrint('Output length (${output.length}) does not match number of labels (${_labels.length})');
      // Adjust output or labels to match
      if (output.length > _labels.length) {
        output = output.sublist(0, _labels.length);
      } else {
        // If we have more labels than outputs, we'll only use the labels we have outputs for
        debugPrint('Using only the first ${output.length} labels');
      }
    }

    debugPrint('Raw model output: ${output.take(5).toList()}...'); // Show first 5 values

    final probabilities = _softmax(output);

    debugPrint('After softmax - first 5 probabilities: ${probabilities.take(5).toList()}');

    final predictions = <Map<String, dynamic>>[];
    for (int i = 0; i < math.min(probabilities.length, _labels.length); i++) {
      final confidence = probabilities[i];
      // Include all predictions regardless of confidence
      predictions.add({
        'label': _labels[i],
        'confidence': double.parse(confidence.toStringAsFixed(4)),
        'rawScore': output[i],
      });
    }

    debugPrint('Found ${predictions.length} predictions');

    // Sort by confidence (descending)
    predictions.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

    // Apply confidence boosting for similar predictions
    return _boostConfidence(predictions);
  }

  List<double> _softmax(List<double> logits) {
    // For numerical stability, subtract the maximum logit
    final maxLogit = logits.reduce(math.max);
    final expLogits = logits.map((e) => math.exp(e - maxLogit)).toList();
    final sumExp = expLogits.reduce((a, b) => a + b);
    return expLogits.map((e) => e / sumExp).toList();
  }

  List<Map<String, dynamic>> _boostConfidence(List<Map<String, dynamic>> predictions) {
    if (predictions.isEmpty) return [];

    // Find the maximum confidence
    final maxConfidence = predictions.first['confidence'] as double;
    
    // Apply boosting factor based on the difference from max confidence
    return predictions.map((pred) {
      final confidence = pred['confidence'] as double;
      final rawScore = pred['rawScore'] as double;
      
      // Calculate boosting factor (more boost for closer scores)
      final diffFromMax = (maxConfidence - confidence).abs();
      final boostFactor = math.max(0.1, 1.0 - (diffFromMax * 2));
      
      // Apply boosting (but don't exceed 0.99)
      double boostedConfidence = (confidence * (1.0 + boostFactor * 0.3)).clamp(0.0, 0.99);
      
      // Ensure at least 5% difference between consecutive predictions
      final index = predictions.indexOf(pred);
      if (index > 0) {
        final prevConfidence = predictions[index-1]['confidence'] as double;
        boostedConfidence = math.min(
          boostedConfidence, 
          (prevConfidence - 0.05).clamp(0.0, 1.0)
        );
      }
      
      return {
        'label': pred['label'],
        'confidence': double.parse(boostedConfidence.toStringAsFixed(4)),
      };
    }).toList();
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    try {
      // Create a new RGB image (this will remove any alpha channel)
      final rgbImage = img.Image.from(image, noAnimation: false);

      // Convert to RGB if it has an alpha channel (by checking if the format is not RGB)
      if (rgbImage.format != img.Format.uint8) {
        rgbImage.convert(format: img.Format.uint8);
      }

      // Resize maintaining aspect ratio and then center crop
      final resized = _resizeAndCrop(rgbImage, 224, 224);

      debugPrint('Preprocessing image: ${resized.width}x${resized.height}, format: ${resized.format}');

      // Normalize pixel values to [0, 1] for better model performance (most models expect this range)
      final input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) => List.generate(3, (c) {
              final pixel = resized.getPixel(x, y);
              // Get RGB values and normalize to [0, 1]
              final value = c == 0 ? pixel.r
                         : c == 1 ? pixel.g
                         : pixel.b;
              return value / 255.0;
            }),
          ),
        ),
      );

      return input;
    } catch (e) {
      debugPrint('Error in preprocessing: $e');
      // Fallback: try a simpler preprocessing approach
      return _preprocessImageSimple(image);
    }
  }

  List<List<List<List<double>>>> _preprocessImageSimple(img.Image image) {
    // Simple preprocessing as fallback
    final resized = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.cubic,
    );

    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) => List.generate(3, (c) {
            final pixel = resized.getPixel(x, y);
            final value = c == 0 ? pixel.r
                       : c == 1 ? pixel.g
                       : pixel.b;
            return value / 255.0;
          }),
        ),
      ),
    );

    return input;
  }

  img.Image _resizeAndCrop(img.Image image, int width, int height) {
    // Calculate aspect ratios
    final srcAspect = image.width / image.height;
    final dstAspect = width / height;

    int newWidth, newHeight;

    // Resize maintaining aspect ratio
    if (srcAspect > dstAspect) {
      // Source is wider than destination
      newHeight = height;
      newWidth = (height * srcAspect).toInt();
    } else {
      // Source is taller than destination
      newWidth = width;
      newHeight = (width / srcAspect).toInt();
    }

    // Resize
    final resized = img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.cubic,
    );

    // Center crop
    final x = (resized.width - width) ~/ 2;
    final y = (resized.height - height) ~/ 2;

    return img.copyCrop(
      resized,
      x: x,
      y: y,
      width: width,
      height: height,
    );
  }

  List<List<double>> _createOutputBuffer() {
    // Create output buffer with the correct shape based on model output
    // Most classification models output [1, num_classes]
    return [List.filled(_labels.length, 0.0)];
  }

  void dispose() {
    try {
      _interpreter?.close();
    } catch (e) {
      debugPrint('Error disposing TFLite interpreter: $e');
    } finally {
      _interpreter = null;
      _isModelLoaded = false;
      _labels = [];
    }
  }
}