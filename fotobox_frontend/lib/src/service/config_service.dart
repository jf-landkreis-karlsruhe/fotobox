import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;


abstract class ConfigService {
  Future<String> getBackendUrl();
  Future<String> getButtonBoxUrl();
  Future<String> getToken();
}

class ConfigServiceImplementation implements ConfigService {
  String? _buttonBoxUrl;
  String? _backendUrl;
  String? _token;

  @override
  Future<String> getBackendUrl() async {
    if (_backendUrl == null) {
      _backendUrl = await rootBundle.loadString('assets/textfiles/backend-url.txt');
    }
    return _backendUrl!;
  }

  @override
  Future<String> getButtonBoxUrl() async {
    if (_buttonBoxUrl == null) {
      _buttonBoxUrl = await rootBundle.loadString('assets/textfiles/button-box-url.txt');
    }
    return _buttonBoxUrl!;
  }

  @override
  Future<String> getToken() async {
    if (_token == null) {
      _token = await rootBundle.loadString('assets/textfiles/token.txt');
    }
    return _token!;
  }


}
