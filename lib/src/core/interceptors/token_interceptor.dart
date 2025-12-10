
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
    final accessToken = await _ref
        .read(secureStorageServiceProvider)
        .getAccessToken();

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    print('[TOKEN INTERCEPTOR] Token atual => $accessToken');
    print('[TOKEN INTERCEPTOR] URL => ${options.uri}');

    return handler.next(options);
  }

}
