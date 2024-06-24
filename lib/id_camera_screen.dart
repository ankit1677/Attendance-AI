import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class IdCameraScreen extends StatefulWidget {
  final String imageType;
  const IdCameraScreen({super.key, required this.imageType});

  @override
  IdCameraScreenState createState() => IdCameraScreenState();
}

class IdCameraScreenState extends State<IdCameraScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
    await _cameraController?.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isTakingPicture) {
      return;
    }
    setState(() {
      _isTakingPicture = true;
    });
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String pictureDirectory = '${appDirectory.path}/Pictures';
    await Directory(pictureDirectory).create(recursive: true);
    final String filePath = p.join(
      pictureDirectory,
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    try {
      final XFile file = await _cameraController!.takePicture();
      final File imageFile = File(file.path);
      final File savedImage = await imageFile.copy(filePath);

      if (mounted) {
        Navigator.pop(context, savedImage.path);
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
    } finally {
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture ${widget.imageType} Photo'),
      ),
      body: _isInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _isTakingPicture ? null : _captureImage,
                      child: const Text('Capture Photo'),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
