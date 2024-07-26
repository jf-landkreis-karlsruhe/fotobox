import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fotobox_frontend/src/camera_view.dart';
import 'package:fotobox_frontend/src/manager/session_manager.dart';
import 'package:watch_it/watch_it.dart';

/// Displays a list of SampleItems.
class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
  });

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fotobox'),
      ),
      body: FutureBuilder(
        future: availableCameras(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error: No cameras found / camera access denied',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: MainContentView(
              cameras: snapshot.data!,
            ),
          );
        },
      ),
    );
  }
}

class MainContentView extends StatelessWidget with WatchItMixin {
  const MainContentView({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    var manager = watchIt<SessionManager>();
    var currentSession = manager.currentSession;

    return Stack(
      children: [
        Visibility(
          visible: currentSession != null,
          child: CameraSessionView(
            cameras: cameras,
          ),
        ),
        Visibility(
          visible: currentSession == null,
          child: Center(
              child: ElevatedButton.icon(
            icon: const Icon(Icons.cameraswitch_outlined),
            label: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'New Session',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
            ),
            style: const ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.all(20)),
              iconSize: WidgetStatePropertyAll(60),
              backgroundColor: WidgetStatePropertyAll(Colors.blue),
              iconColor: WidgetStatePropertyAll(Colors.white),
            ),
            onPressed: () {
              manager.startNewSessionCommand();
            },
          )),
        ),
      ],
    );
  }
}
