// lib/src/services/auth_service.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

import '../core/app_config.dart';
import '../core/helpers/pkce_helper.dart';
import 'secure_storage_service.dart';

// Provider
final authServiceProvider = Provider((ref) => AuthService(ref));

class AuthService {
  final Ref _ref;
  final Dio _dio = Dio();
  final AppLinks _appLinks = AppLinks();

  AuthService(this._ref);

  // URLs do Spotify
  static const String _authorizeUrl = AppConfig.spotifyAuthorizeUrl;
  static const String _tokenUrl = AppConfig.spotifyTokenUrl;

  // Fluxo PKCE
  Future<void> login() async {
    final codeVerifier = PKCEHelper.generateCodeVerifier();
    final codeChallenge = PKCEHelper.generateCodeChallenge(codeVerifier);

    final scope = AppConfig.spotifyScopes.join(' ');
    final authUrl = Uri.parse(_authorizeUrl).replace(queryParameters: {
      'client_id': AppConfig.spotifyClientId,
      'response_type': 'code',
      'redirect_uri': AppConfig.redirectUri,
      'scope': scope,
      'code_challenge_method': 'S256',
      'code_challenge': codeChallenge,
      'show_dialog': 'true',
    });

    // Listener do deep link
    final completer = Completer<String>();
    StreamSubscription<Uri>? sub;

    sub = _appLinks.uriLinkStream.listen((Uri uri) {
    if (uri.scheme == AppConfig.redirectUriScheme) {
        completer.complete(uri.toString());
        sub?.cancel();
    }
    });
    // Abrir navegador
    try {
      final opened = await launchUrl(
        authUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        sub?.cancel();
        throw Exception('Não foi possível abrir o navegador.');
      }
    } catch (e) {
      sub?.cancel();
      rethrow;
    }

    // Esperar deep link
    final redirectUrl = await completer.future.timeout(
      const Duration(minutes: 1),
      onTimeout: () {
        sub?.cancel();
        throw TimeoutException('Login cancelado ou tempo excedido.');
      },
    );

    // Extrai `code`
    final code = Uri.parse(redirectUrl).queryParameters['code'];

    if (code == null) {
      throw Exception('Código de autorização não retornado.');
    }

    await _exchangeCodeForToken(code, codeVerifier);
  }

  // Troca código por tokens
  Future<void> _exchangeCodeForToken(
      String code, String codeVerifier) async {
    try {
      final response = await _dio.post(
        _tokenUrl,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': AppConfig.redirectUri,
          'client_id': AppConfig.spotifyClientId,
          'code_verifier': codeVerifier,
        },
      );

      final data = response.data;

      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];

      final storage = _ref.read(secureStorageServiceProvider);
      await storage.saveTokens(accessToken, refreshToken);

      print('Login OK — tokens armazenados.');
    } on DioException catch (e) {
      print('Erro ao trocar token: ${e.response?.data}');
      throw Exception('Falha ao obter tokens.');
    }
  }
}
