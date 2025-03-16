import 'package:flutter/material.dart';
import 'package:fotobox_frontend/src/manager/session_manager.dart';
import 'package:fotobox_frontend/src/service/button_box_service.dart';
import 'package:fotobox_frontend/src/service/session_service.dart';
import 'package:fotobox_frontend/src/service/config_service.dart';
import 'package:watch_it/watch_it.dart';
import 'src/app.dart';

void setup() {
  ConfigService configService = ConfigServiceImplementation();

  di.registerSingleton<SessionService>(
      SessionServiceImplementation(configService));
  di.registerSingleton<ButtonBoxService>(
      ButtonBoxServiceImplementation(configService));
  //use the following for local tests without button box
  // di.registerSingleton<ButtonBoxService>(TestButtonBoxService());

  di.registerSingleton<SessionManager>(SessionManagerImplementation());
}

void main() async {
  setup();
  // Run the app.
  runApp(const MainWidget());
}
