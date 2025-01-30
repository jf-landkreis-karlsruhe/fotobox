import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fotobox_frontend/src/service/config_service.dart';

abstract class ButtonBoxService {
  Future<void> currentScreen(String screenId);
}

class ButtonBoxServiceImplementation implements ButtonBoxService {

  late final ConfigService configService;

  ButtonBoxServiceImplementation(this.configService);

  Future<void> currentScreen(String screenId) async {

    try {
      var baseUrl = await configService.getButtonBoxUrl();
      var url = Uri.http(baseUrl, '/api/v1/scene/$screenId');
      print('ButtonBoxService: currentScreen: $screenId');
      var response = await http.post(url);

      if (response.statusCode != 200) {
        throw Exception('Fehler beim Erstellen der Szene: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fehler beim Erstellen der Szene: $e');
    }
  }
}
