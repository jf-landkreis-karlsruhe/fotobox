import 'package:http/http.dart' as http;
import 'package:fotobox_frontend/src/service/config_service.dart';

abstract class ButtonBoxService {
  Future currentScreen(String screenId);
}

class ButtonBoxServiceImplementation implements ButtonBoxService {
  late final ConfigService configService;

  ButtonBoxServiceImplementation(this.configService);

  @override
  Future currentScreen(String screenId) async {
    try {
      var baseUrl = await configService.getButtonBoxUrl();
      var url = Uri.http(baseUrl, '/api/v1/scene/$screenId');
      print('ButtonBoxService: currentScreen: $screenId');
      var response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception(
            'Fehler beim Erstellen der Szene: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fehler beim Erstellen der Szene: $e');
    }
  }
}

class TestButtonBoxService implements ButtonBoxService {
  @override
  Future currentScreen(String screenId) async {
    // return nothing for tests
  }
}
