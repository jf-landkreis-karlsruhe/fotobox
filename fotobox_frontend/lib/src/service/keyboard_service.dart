import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

abstract class KeyboardService {
  Future<void> currentScreen(String screenId);
}

class KeyboardServiceImplementation implements KeyboardService {
  String? _baseUrl;

  Future<String> _init() async {
    print('KeyboardServiceImplementation: _init');
    var configFile = await rootBundle.loadString('assets/config.json');
    print('KeyboardServiceImplementation: _init2');
    var config = jsonDecode(configFile);
    print('KeyboardServiceImplementation: _init3');
    print('KeyboardServiceImplementation: _init: ${config['keyboardUrl']}');

    _baseUrl = config['keyboardUrl'];
    return config['keyboardUrl'];
  }

  Future<void> currentScreen(String screenId) async {
    try {
      if (_baseUrl == null) {
        await _init();
      }
      print('KeyboardServiceImplementation');
      var url = Uri.http(_baseUrl!, '/api/v1/scene/$screenId');
      print('KeyboardServiceImplementation: currentScreen: $_baseUrl');
      var response = await http.post(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Fehler beim Erstellen der Szene: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fehler beim Erstellen der Szene: $e');
    }
  }
}
