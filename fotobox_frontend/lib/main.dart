import 'package:flutter/material.dart';
import 'package:fotobox_frontend/src/manager/session_manager.dart';
import 'package:fotobox_frontend/src/service/keyboard_service.dart';
import 'package:fotobox_frontend/src/service/session_service.dart';
import 'package:watch_it/watch_it.dart';
import 'src/app.dart';

void setup() {
  di.registerSingleton<SessionService>(SessionServiceImplementation());
  di.registerSingleton<KeyboardService>(KeyboardServiceImplementation());

  di.registerSingleton<SessionManager>(SessionManagerImplementation());
}

void main() async {
  setup();
  // Run the app.
  runApp(const MainWidget());
}
