import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? httpClient, this.tokenProvider})
      : _http = httpClient ?? http.Client();

  final http.Client _http;
  final Future<String?> Function()? tokenProvider;

  Future<Map<String, dynamic>> get(
    String path, {
    bool auth = false,
  }) {
    return _send('GET', path, auth: auth);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) {
    return _send('POST', path, body: body, auth: auth);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (auth) {
      final token = await tokenProvider?.call();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    late http.Response response;
    try {
      if (method == 'GET') {
        response = await _http.get(uri, headers: headers).timeout(ApiConfig.timeout);
      } else {
        response = await _http
            .post(
              uri,
              headers: headers,
              body: body == null ? null : jsonEncode(body),
            )
            .timeout(ApiConfig.timeout);
      }
    } on Exception {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Inténtalo de nuevo.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{'data': decoded};
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _messageFromBody(response.body, response.statusCode),
    );
  }

  String _messageFromBody(String body, int statusCode) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {}

    switch (statusCode) {
      case 400:
        return 'Revisa los datos e inténtalo de nuevo.';
      case 401:
        return 'Correo o contraseña incorrectos.';
      case 403:
        return 'Esta cuenta no tiene acceso.';
      case 409:
        return 'Este correo ya está registrado.';
      case 429:
        return 'Demasiados intentos. Espera un momento.';
      default:
        return 'Ocurrió un error. Inténtalo de nuevo.';
    }
  }
}
