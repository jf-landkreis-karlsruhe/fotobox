import 'dart:async';
import 'dart:io';
import 'package:animated_countdown/animated_countdown.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fotobox_frontend/src/home_view.dart';
import 'package:fotobox_frontend/src/manager/session_manager.dart';
import 'package:fotobox_frontend/src/model/session_model.dart';
import 'package:fotobox_frontend/src/qr_view.dart';
import 'package:fotobox_frontend/src/thumbnail_images_view.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';
import 'package:fotobox_frontend/src/service/button_box_service.dart';

class CameraApp extends StatefulWidget with WatchItStatefulWidgetMixin {
  /// Default Constructor
  const CameraApp({
    super.key,
    required this.camera,
    required this.currentSession,
  });

  final CameraDescription camera;
  final SessionModel currentSession;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with WidgetsBindingObserver {
  late CameraController controller;
  String error = '';
  Timer? timer;
  bool pictureButtonWasPressed = false;

  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializeCameraController(widget.camera);

    focusNode.requestFocus();
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
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
    } on CameraException {
      return null;
    }
  }

  void saveSession() {
    final SessionManager manager = di<SessionManager>();

    manager.saveCurrentSessionCommand();

    context.go(QrView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    ButtonBoxService buttonBoxService = di<ButtonBoxService>();
    buttonBoxService.currentScreen('camera_view');
    var lastImage =
        watchPropertyValue((SessionManager manager) => manager.lastImage);
    final SessionManager manager = di<SessionManager>();

    bool maxPicturesReached = widget.currentSession.images.length >= 10;
    bool noPictureTaken = widget.currentSession.images.isEmpty;

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

    Widget? image = lastImage != null
        ? Center(
            child: kIsWeb
                ? Image.network(lastImage.path)
                : Image.file(File(lastImage.path)),
          )
        : null;

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
                      manager.endCurrentSessionCommand();
                      context.go(HomeView.routeName);
                    },
              icon: const Icon(Icons.close),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: pictureButtonWasPressed || maxPicturesReached
                  ? null
                  : () {
                      setState(() {
                        pictureButtonWasPressed = true;
                      });
                    },
              icon: const Icon(Icons.photo_camera_outlined),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: pictureButtonWasPressed
                  ? null
                  : () {
                      saveSession();
                    },
              icon: const Icon(Icons.save_outlined),
            ),
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

    List<Widget> stackChildren = [image ?? preview];
    if (countDown != null) {
      stackChildren.add(countDown);
    }

    focusNode.requestFocus();

    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (value) {
        switch (value.logicalKey) {
          case LogicalKeyboardKey.enter:
            if (pictureButtonWasPressed || noPictureTaken) {
              return;
            }
            saveSession();
            break;
          case LogicalKeyboardKey.keyX:
            if (pictureButtonWasPressed) {
              return;
            }
            buttonBoxService.currentScreen('home_view');
            manager.endCurrentSessionCommand();
            context.go(HomeView.routeName);
            break;
          case LogicalKeyboardKey.space:
            if (pictureButtonWasPressed || maxPicturesReached) {
              return;
            }
            setState(() {
              pictureButtonWasPressed = true;
            });
            break;
          default:
        }
      },
      child: Stack(
        children: stackChildren,
      ),
    );
  }
}

class CameraSessionView extends StatelessWidget with WatchItMixin {
  const CameraSessionView({super.key});

  static const routeName = '/camera';

  @override
  Widget build(BuildContext context) {
    var manager = watchIt<SessionManager>();
    var currentSession = manager.currentSession;

    if (currentSession == null || manager.currentCamera == null) {
      return const Center(
        child: Text('No session active!'),
      );
    }

    return MainScaffold(
      child: Column(
        children: [
          Expanded(
            child: CameraApp(
              camera: manager.currentCamera!,
              currentSession: currentSession,
            ),
          ),
          const SizedBox(height: 10),
          ThumbnailImagesView(currentSession: currentSession),
        ],
      ),
    );
  }
}
