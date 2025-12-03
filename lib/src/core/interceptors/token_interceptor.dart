// lib/src/core/interceptors/token_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/secure_storage_service.dart';

class TokenInterceptor extends Interceptor {
  final Ref _ref;

  TokenInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Obtém o Access Token do Secure Storage
    final accessToken = await _ref
        .read(secureStorageServiceProvider)
        .getAccessToken();

    // 2. Se o token existir, injeta-o no cabeçalho
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    print('[TOKEN INTERCEPTOR] Token atual => $accessToken');
    print('[TOKEN INTERCEPTOR] URL => ${options.uri}');

    // 3. Permite que a requisição siga seu curso
    return handler.next(options);
  }

  // TODO: Em sprints futuras, implementaremos a lógica de refreshToken no onError.
}
