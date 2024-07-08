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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.photo_camera_outlined),
              )
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FutureBuilder(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return CameraApp(
                    cameras: snapshot.data!,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
