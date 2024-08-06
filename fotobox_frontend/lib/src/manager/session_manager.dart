import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:fotobox_frontend/src/model/session_model.dart';
import 'package:fotobox_frontend/src/service/session_service.dart';
import 'package:watch_it/watch_it.dart';

abstract class SessionManager extends ChangeNotifier {
  late Command<void, SessionModel> startNewSessionCommand;
  late Command<void, void> endCurrentSessionCommand;
  late Command<void, String?> saveCurrentSessionCommand;

  SessionModel? get currentSession;
  XFile? lastImage;

  void addImage(XFile image);
}

class SessionManagerImplementation extends ChangeNotifier
    implements SessionManager {
  late final SessionService _sessionService;

  @override
  late Command<void, SessionModel> startNewSessionCommand;
  @override
  late Command<void, void> endCurrentSessionCommand;
  @override
  late Command<void, String?> saveCurrentSessionCommand;

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
    _sessionService = di<SessionService>();

    startNewSessionCommand = Command.createAsyncNoParam(
      _startNewSession,
      initialValue: SessionModel(),
    );

    endCurrentSessionCommand = Command.createAsyncNoParamNoResult(
      _endCurrentSession,
    );

    saveCurrentSessionCommand = Command.createAsyncNoParam(
      _saveCurrentSession,
      initialValue: null,
    );
  }

  Future<SessionModel> _startNewSession() async {
    var newSession = SessionModel();
    currentSession = newSession;
    return newSession;
  }

  Future _endCurrentSession() async {
    currentSession = null;
  }

  Future<String?> _saveCurrentSession() async {
    if (currentSession == null) {
      return null;
    }

    var result = await _sessionService.saveSession(currentSession!);
    currentSession = null;
    return result;
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
