import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:download/download.dart';
import 'package:flutter/foundation.dart';
import 'package:fotobox_frontend/src/model/session_model.dart';
import 'package:fotobox_frontend/src/service/session_dto.dart';
import 'package:http/http.dart' as http;

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

Future<String?> _saveToRest(SessionModel model) async {
  List<List<int>> images = [];
  for (var entry in model.images) {
    var imageInBytes = await entry.readAsBytes();
    images.add(imageInBytes);
  }
  var dto = SessionDto()
    ..sessionCode = model.sessionCode.toString()
    ..images = images;

  var json = jsonEncode(dto);
  var response = await http.post(
    Uri.http("127.0.0.1:5000", "/savesession"), // TODO: correct endpoint
    body: json,
  );

  if (response.statusCode != 200) {
    return null;
  }

  return response.body;
}
