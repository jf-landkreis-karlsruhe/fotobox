import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fotobox_frontend/src/manager/session_manager.dart';
import 'package:fotobox_frontend/src/service/keyboard_service.dart';
import 'package:watch_it/watch_it.dart';

class NewSessionView extends StatefulWidget with WatchItStatefulWidgetMixin {
  const NewSessionView({super.key});

  @override
  State<NewSessionView> createState() => _NewSessionViewState();
}

class _NewSessionViewState extends State<NewSessionView> {
  var focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    focusNode.requestFocus();
    KeyboardService keyboardService = di<KeyboardService>();
    keyboardService.currentScreen('newsession');
    super.initState();
  }

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
          },
        ),
      ),
    );
  }
}
