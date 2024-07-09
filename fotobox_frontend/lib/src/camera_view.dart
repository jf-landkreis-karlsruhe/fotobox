import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  String error = '';

  @override
  void initState() {
    super.initState();
    controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.max,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        error = '';
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            setState(() {
              error = "Error: Access to camera denied";
            });
            break;
          default:
            setState(() {
              error = "Error during camera initialization";
            });
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      if (error.isNotEmpty) {
        return Center(
          child: Text(
            error,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error.isNotEmpty) {
      return Center(
        child: Text(
          error,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return CameraPreview(controller);
  }
}
