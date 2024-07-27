import 'dart:io';
import 'package:camera/camera.dart';
import 'package:download/download.dart';
import 'package:flutter/foundation.dart';
import 'package:fotobox_frontend/src/model/session_model.dart';

abstract class SessionService {
  Future<String> saveSession(SessionModel session);
}

class SessionServiceImplementation implements SessionService {
  @override
  Future<String> saveSession(SessionModel session) async {
    await _saveSession(session);
    return session.sessionCode.toString();
  }

  Future _saveSession(SessionModel session) async {
    var images = session.images;

    if (kIsWeb) {
      for (var i = 0; i < images.length; i++) {
        var image = images[i];
        await _saveSingleFileForWeb(image, session.sessionCode.toString(), i);
      }
    } else {
      var directory = Directory(session.sessionCode.toString());
      if (!await directory.exists()) {
        try {
          directory.create();
        } on Exception {
          return 'Error during save';
        }
      }

      for (var i = 0; i < images.length; i++) {
        var image = images[i];
        try {
          await image.saveTo('${session.sessionCode.toString()}/$i.jpeg');
        } on Exception {
          return 'Error during save';
        }
      }
    }
  }

  Future _saveSingleFileForWeb(
      XFile file, String sessionCode, int count) async {
    if (!kIsWeb) {
      return;
    }

    var image = await file.readAsBytes();
    var imageAsStream = Stream.fromIterable(image);
    download(imageAsStream, '${sessionCode}_$count.jpeg');
  }
}
