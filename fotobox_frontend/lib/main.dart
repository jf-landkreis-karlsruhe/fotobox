import 'package:flutter/material.dart';
import 'package:fotobox_frontend/src/manager/session_manager.dart';
import 'package:watch_it/watch_it.dart';
import 'src/app.dart';

void setup() {
  di.registerSingleton<SessionManager>(SessionManagerImplementation());
}

void main() async {
  setup();
  // Run the app.
  runApp(const MainWidget());
}
