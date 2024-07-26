import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';

class SessionModel extends ChangeNotifier {
  Guid sessionCode = Guid.newGuid;
  List<XFile> images = [];
}
