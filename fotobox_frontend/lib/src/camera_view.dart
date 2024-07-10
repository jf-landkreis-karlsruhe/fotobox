import 'package:camera/camera.dart';
import 'package:download/download.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

    Future<XFile?> takePicture() async {
    final CameraController cameraController = controller;
    if (!cameraController.value.isInitialized) {
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      return null;
    }
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                takePicture().then((XFile? file) async {
                  if (mounted) {
                    if (file != null) {
                      var time = DateTime.now();
                      String formattedDate = DateFormat('ddMMyyyy_HHmmss').format(time);
                      var image = await file.readAsBytes();
                      var test = Stream.fromIterable(image);
                      download(test, 'Foto_$formattedDate.png');
                    }
                  }
                });
              },
              icon: const Icon(Icons.photo_camera_outlined),
            )
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: CameraPreview(controller),
          ),
        ),
      ],
    );
  }
}
