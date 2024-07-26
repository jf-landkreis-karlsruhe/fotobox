import 'dart:async';
import 'package:animated_countdown/animated_countdown.dart';
import 'package:camera/camera.dart';
import 'package:download/download.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fotobox_frontend/src/manager/session_manager.dart';
import 'package:intl/intl.dart';
import 'package:watch_it/watch_it.dart';

class CameraApp extends StatefulWidget with WatchItStatefulWidgetMixin {
  /// Default Constructor
  const CameraApp({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with WidgetsBindingObserver {
  late CameraController controller;
  String error = '';
  Timer? timer;
  bool pictureButtonWasPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeCameraController(widget.cameras[0]);
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: false,
      // imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {
          error = '';
        });
      }
      if (cameraController.value.hasError) {
        error = 'Camera error ${cameraController.value.errorDescription}';
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          error = 'You have denied camera access.';
        case 'AudioAccessDenied':
          error = 'You have denied audio access.';
        default:
          error = e.description ?? 'Error';
          break;
      }
    }

    if (mounted) {
      setState(() {
        error = '';
      });
    }
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    var lastImage =
        watchPropertyValue((SessionManager manager) => manager.lastImage);
    final SessionManager manager = di<SessionManager>();

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

    Widget? image =
        lastImage != null ? Center(child: Image.network(lastImage.path)) : null;

    Widget? countDown = pictureButtonWasPressed
        ? Center(
            child: CountDownWidget(
              textStyle: const TextStyle(color: Colors.red),
              totalDuration: 3,
              maxTextSize: 400,
              minTextSize: 100,
              onEnd: () {
                pictureButtonWasPressed = false;
                takePicture().then((XFile? file) async {
                  if (mounted) {
                    if (file != null) {
                      // var time = DateTime.now();
                      // String formattedDate =
                      //     DateFormat('ddMMyyyy_HHmmss').format(time);
                      // var image = await file.readAsBytes();
                      // var test = Stream.fromIterable(image);
                      // download(test, 'Foto_$formattedDate.png');

                      manager.addImage(file);
                      timer = Timer(const Duration(seconds: 3), () {
                        timer = null;
                        manager.lastImage = null;
                      });
                    }
                  }
                });
              },
            ),
          )
        : null;

    var preview = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: pictureButtonWasPressed
                  ? null
                  : () {
                      setState(() {
                        pictureButtonWasPressed = true;
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

    List<Widget> stackChikdren = [preview];
    if (image != null) {
      stackChikdren.add(image);
    }
    if (countDown != null) {
      stackChikdren.add(countDown);
    }

    return Stack(
      children: stackChikdren,
    );
  }
}
