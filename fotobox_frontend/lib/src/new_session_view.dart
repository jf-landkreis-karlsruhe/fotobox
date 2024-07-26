import 'package:flutter/material.dart';
import 'package:fotobox_frontend/src/manager/session_manager.dart';
import 'package:watch_it/watch_it.dart';

class NewSessionView extends StatelessWidget with WatchItMixin {
  const NewSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    var manager = di<SessionManager>();
    return Center(
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
    );
  }
}
