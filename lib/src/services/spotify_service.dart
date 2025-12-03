// lib/src/services/spotify_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthesia/src/domain/entities/track.dart';
import '../core/interceptors/token_interceptor.dart'; // Importa o Interceptor

final spotifyServiceProvider = Provider<SpotifyService>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.spotify.com',
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Adiciona o TokenInterceptor para injetar o Access Token automaticamente
  dio.interceptors.add(TokenInterceptor(ref));

  return SpotifyService(dio);
});

class SpotifyService {
  final Dio _dio;

  SpotifyService(this._dio);

  // Método para buscar o perfil do usuário (API-002)
  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final response = await _dio.get('/v1/me');
      return response.data;
    } on DioException catch (e) {
      // Se for 401 (Unauthorized), significa que o token expirou ou é inválido.
      // O Interceptor deve cuidar disso futuramente.
      print('Erro ao buscar perfil do Spotify: ${e.response?.data}');
      rethrow;
    }
  }

  // lib/src/services/spotify_service.dart

  Future<List<Map<String, dynamic>>> fetchUserPlaylists() async {
    try {
      final response = await _dio.get(
        '/v1/me/playlists',
        queryParameters: {'limit': 20, 'offset': 0},
      );

      final items = response.data['items'] as List<dynamic>?;

      return items?.cast<Map<String, dynamic>>() ?? [];
    } on DioException catch (e) {
      print('Erro ao buscar playlists do usuário: ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<Track>> fetchPlaylistTracks(String playlistId) async {
    try {
      final response = await _dio.get(
        '/v1/playlists/$playlistId/tracks',
        queryParameters: {'fields': 'items(track(id,name,artists,album,uri))'},
      );

      final items = response.data['items'] as List<dynamic>? ?? [];

      return items.map((item) => Track.fromJson(item)).toList();
    } on DioException catch (e) {
      print('Erro ao buscar faixas: ${e.response?.data}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAvailableDevices() async {
    try {
      // Endpoint real: /v1/me/player/devices
      final response = await _dio.get('/me/player/devices');

      final items = response.data['devices'] as List<dynamic>?;
      return items?.cast<Map<String, dynamic>>() ?? [];
    } on DioException {
      rethrow;
    }
  }

  Future<void> startPlayback({
    required String deviceId,
    String?
    trackUri, // O URI da faixa que queremos tocar (ex: spotify:track:...)
  }) async {
    try {
      // Endpoint real: /v1/me/player/play
      await _dio.put(
        '/me/player/play',
        queryParameters: {'device_id': deviceId},
        data: trackUri != null
            ? {
                'uris': [trackUri],
              }
            : null,
      );
    } on DioException {
      rethrow;
    }
  }

  Future<void> pausePlayback({required String deviceId}) async {
    try {
      // Endpoint real: /v1/me/player/pause
      await _dio.put(
        '/me/player/pause',
        queryParameters: {'device_id': deviceId},
      );
    } on DioException {
      rethrow;
    }
  }

  // TODO: Outros métodos da API serão adicionados aqui (ex: search, recommendations)
}
