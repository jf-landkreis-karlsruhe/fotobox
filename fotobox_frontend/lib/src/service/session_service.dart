import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:download/download.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:fotobox_frontend/src/model/session_model.dart';
import 'package:fotobox_frontend/src/service/session_dto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

abstract class SessionService {
  Future<String?> saveSession(SessionModel session);
}

class SessionServiceImplementation implements SessionService {
  @override
  Future<String?> saveSession(SessionModel session) async {
    try {
      return await _saveToRest(session);
    } catch (e) {
      return await _saveSessionLocal(session);
    }
  }

  Future<String?> _saveSessionLocal(SessionModel session) async {
    var images = session.images;
    var sessionCode = Guid.newGuid.toString();

    if (kIsWeb) {
      try {
        for (var i = 0; i < images.length; i++) {
          var image = images[i];
          await _saveSingleFileForWeb(image, sessionCode, i);
        }
      } on Exception {
        return null;
      }
    } else {
      var directory = Directory(sessionCode);
      if (!await directory.exists()) {
        try {
          directory.create();
        } on Exception {
          return null;
        }
      }

      for (var i = 0; i < images.length; i++) {
        var image = images[i];
        try {
          await image.saveTo('$sessionCode/$i.jpeg');
        } on Exception {
          return null;
        }
      }
    }

    return sessionCode;
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
  var token = await rootBundle.loadString('assets/textfiles/Token.txt');

  List<List<int>> images = [];
  for (var entry in model.images) {
    var imageInBytes = await entry.readAsBytes();
    images.add(imageInBytes);
  }
  var dto = SessionDto()
    ..token = token
    ..images = images;

  var json = jsonEncode(dto);
  var headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  };
  var url = Uri.http("localhost:8080", "/savesession");
  var response = await http.post(
    url,
    body: json,
    headers: headers,
  );

  if (response.statusCode != 200) {
    return null;
  }

  return response.body;
}
