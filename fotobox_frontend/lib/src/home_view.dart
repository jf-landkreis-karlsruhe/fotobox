import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fotobox_frontend/src/camera_view.dart';

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

          return CameraSessionView(
            cameras: snapshot.data!,
          );
        },
      ),
    );
  }
}
