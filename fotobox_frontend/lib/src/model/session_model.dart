import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class SessionModel extends ChangeNotifier {
  List<XFile> images = [];

  void addImage(XFile image) {
    images.add(image);
    notifyListeners();
  }
}
