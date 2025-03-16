import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fotobox_frontend/src/camera_view.dart';
import 'package:fotobox_frontend/src/manager/session_manager.dart';
import 'package:fotobox_frontend/src/service/button_box_service.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

class HomeView extends StatelessWidget {
  HomeView({
    super.key,
  });

  static const routeName = '/';
  final sessionManager = di<SessionManager>();

  @override
  Widget build(BuildContext context) {
    ButtonBoxService buttonBoxService = di<ButtonBoxService>();
    buttonBoxService.currentScreen('home_view');

    return MainScaffold(
      child: FutureBuilder(
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

          sessionManager.currentCamera = snapshot.data![0];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: MainContentView(),
          );
        },
      ),
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fotobox',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset('assets/images/Elefant_ohneFlaeche.png'),
        ),
        leadingWidth: 80,
      ),
      body: child,
    );
  }
}

class MainContentView extends StatelessWidget with WatchItMixin {
  MainContentView({super.key});

  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var manager = di<SessionManager>();

    focusNode.requestFocus();

    return KeyboardListener(
      focusNode: focusNode,
      onKeyEvent: (value) {
        if (value.logicalKey == LogicalKeyboardKey.enter) {
          manager.startNewSessionCommand();
        }
      },
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
            context.go(CameraSessionView.routeName);
          },
        ),
      ),
    );
  }
}
