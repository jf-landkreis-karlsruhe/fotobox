import 'package:flutter/material.dart';
import 'package:fotobox_frontend/src/camera_view.dart';
import 'package:fotobox_frontend/src/qr_view.dart';
import 'package:go_router/go_router.dart';
import 'home_view.dart';

/// The Widget that configures your application.
class MainWidget extends StatelessWidget {
  MainWidget({
    super.key,
  });

  final _router = GoRouter(
    routes: [
      GoRoute(
        path: HomeView.routeName,
        builder: (context, state) => HomeView(),
      ),
      GoRoute(
        path: CameraSessionView.routeName,
        builder: (context, state) => CameraSessionView(),
      ),
      GoRoute(
        path: QrView.routeName,
        builder: (context, state) => const QrView(),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Providing a restorationScopeId allows the Navigator built by the
      // MaterialApp to restore the navigation stack when a user leaves and
      // returns to the app after it has been killed while running in the
      // background.
      restorationScopeId: 'app',
      title: 'Fotobox',
      theme: ThemeData.dark(),
      routerConfig: _router,
    );
  }
}
