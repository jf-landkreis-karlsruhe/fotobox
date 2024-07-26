import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:fotobox_frontend/src/model/session_model.dart';

abstract class SessionManager extends ChangeNotifier {
  late Command<void, SessionModel> startNewSessionCommand;
  late Command<void, void> endCurrentSessionCommand;
  late Command<void, void> saveCurrentSessionCommand;

  SessionModel? get currentSession;
  XFile? lastImage;

  void addImage(XFile image);
}

class SessionManagerImplementation extends ChangeNotifier
    implements SessionManager {
  @override
  late Command<void, SessionModel> startNewSessionCommand;
  @override
  late Command<void, void> endCurrentSessionCommand;
  @override
  late Command<void, void> saveCurrentSessionCommand;

  SessionModel? _currentSession;
  @override
  SessionModel? get currentSession => _currentSession;
  set currentSession(SessionModel? newSession) {
    _currentSession = newSession;
    notifyListeners();
  }

  XFile? _lastImage;
  @override
  XFile? get lastImage => _lastImage;
  @override
  set lastImage(XFile? image) {
    _lastImage = image;
    notifyListeners();
  }

  SessionManagerImplementation() {
    startNewSessionCommand = Command.createAsyncNoParam(
      _startNewSession,
      initialValue: SessionModel(),
    );

    endCurrentSessionCommand = Command.createAsyncNoParamNoResult(
      _endCurrentSession,
    );

    saveCurrentSessionCommand = Command.createAsyncNoParamNoResult(
      _saveCurrentSession,
    );
  }

  Future<SessionModel> _startNewSession() async {
    //TODO: save old session
    var newSession = SessionModel();
    currentSession = newSession;
    return newSession;
  }

  Future _endCurrentSession() async {
    currentSession = null;
  }

  Future _saveCurrentSession() async {
    //TODO: save session
    currentSession = null;
  }

  @override
  void addImage(XFile image) {
    if (currentSession == null) {
      return;
    }

    lastImage = image;
    currentSession!.addImage(image);
  }
}
