import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart'; // Import for Uint8List

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  int _selectedCameraIndex = 0;
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector();
  bool _isDetecting = false;
  bool _faceDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController =
        CameraController(_cameras[_selectedCameraIndex], ResolutionPreset.high);
    await _cameraController?.initialize();
    _cameraController?.startImageStream((CameraImage image) {
      if (_isDetecting) return;
      _isDetecting = true;
      _detectFaces(image);
    });
    setState(() {});
  }

  void _flipCamera() {
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      _initializeCamera();
    });
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.Rotation_0deg;
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      case 270:
        return InputImageRotation.Rotation_270deg;
      default:
        throw Exception("Invalid rotation value");
    }
  }

  Future<void> _detectFaces(CameraImage image) async {
    final allBytes = <int>[];
    for (Plane plane in image.planes) {
      allBytes.addAll(plane.bytes);
    }
    final bytes = Uint8List.fromList(allBytes);

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final InputImageRotation imageRotation = _rotationIntToImageRotation(
        _cameraController!.description.sensorOrientation);

    final InputImageFormat inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    final List<Face> faces = await _faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      final Face face = faces.first;
      final faceBoundingBox = face.boundingBox;
      final imageWidth = inputImageData.size.width;

      // Define acceptable size range for face bounding box
      final minFaceSize = imageWidth * 0.4; // Minimum acceptable face width
      final maxFaceSize = imageWidth * 0.6; // Maximum acceptable face width

      if (faceBoundingBox.width >= minFaceSize &&
          faceBoundingBox.width <= maxFaceSize) {
        setState(() {
          _faceDetected = true;
        });
      } else {
        setState(() {
          _faceDetected = false;
        });
      }
    } else {
      setState(() {
        _faceDetected = false;
      });
    }

    _isDetecting = false;
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String pictureDirectory = '${appDirectory.path}/Pictures';
    await Directory(pictureDirectory).create(recursive: true);
    final String filePath = path.join(
      pictureDirectory,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    try {
      await _cameraController?.stopImageStream();
      final XFile file = await _cameraController!.takePicture();
      final File imageFile = File(file.path);
      final File savedImage = await imageFile.copy(filePath);

      if (mounted) {
        Navigator.pop(context, savedImage.path);
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Image'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          _faceDetected
              ? Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    color: Colors.green,
                    padding: const EdgeInsets.all(10),
                    child: const Text('Face detected'),
                  ),
                )
              : Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    color: Colors.red,
                    padding: const EdgeInsets.all(10),
                    child: const Text('No face detected'),
                  ),
                ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _flipCamera,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.flip_camera_android),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _faceDetected ? _captureImage : null,
            backgroundColor: _faceDetected ? Colors.green : Colors.grey,
            child: const Icon(Icons.camera),
          ),
        ],
      ),
    );
  }
}
