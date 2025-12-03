// lib/src/services/spotify_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthesia/src/domain/entities/track.dart';
import '../core/interceptors/token_interceptor.dart';

final spotifyServiceProvider = Provider<SpotifyService>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.spotify.com',
      contentType: 'application/json',
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(TokenInterceptor(ref));

  return SpotifyService(dio);
});

class SpotifyService {
  final Dio _dio;

  SpotifyService(this._dio);

  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final response = await _dio.get('/v1/me');
      return response.data;
    } on DioException catch (e) {
      print('Erro ao buscar perfil do Spotify: ${e.response?.data}');
      rethrow;
    }
  }

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
        queryParameters: {
          'fields': 'items(track(id,name,artists,album,uri,duration_ms))',
        },
      );

      final items = response.data['items'] as List<dynamic>? ?? [];

      final tracks = items
          .map((item) => item['track'])
          .where((t) => t != null)
          .map<Track>((trackJson) => Track.fromJson(trackJson))
          .toList();

      return tracks;
    } on DioException catch (e) {
      print('Erro ao buscar faixas: ${e.response?.data}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> findActiveDevice() async {
    try {
      final response = await _dio.get('/v1/me/player/devices');

      final devices = (response.data['devices'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      if (devices.isEmpty) return null;

      final active = devices.firstWhere(
        (d) => d['is_active'] == true,
        orElse: () => devices.first,
      );

      return active;
    } on DioException catch (e) {
      print('Erro ao buscar dispositivos: ${e.response?.data}');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAvailableDevices() async {
    try {
      final response = await _dio.get('/v1/me/player/devices');
      final items = response.data['devices'] as List<dynamic>?;
      return items?.cast<Map<String, dynamic>>() ?? [];
    } on DioException {
      rethrow;
    }
  }

  Future<void> startPlayback({required String deviceId, String? trackUri}) async {
    try {
      await _dio.put(
        '/v1/me/player/play',
        queryParameters: {'device_id': deviceId},
        data: trackUri != null ? {"uris": [trackUri]} : {},
      );
    } on DioException catch (e) {
      print("Erro ao iniciar playback: ${e.response?.data}");
      rethrow;
    }
  }

  Future<void> pausePlayback({required String deviceId}) async {
    try {
      await _dio.put('/v1/me/player/pause', queryParameters: {'device_id': deviceId});
    } on DioException {
      rethrow;
    }
  }

  Future<void> skipToNext({required String deviceId}) async {
    try {
      await _dio.post('/v1/me/player/next', queryParameters: {'device_id': deviceId});
    } on DioException {
      rethrow;
    }
  }

  Future<void> skipToPrevious({required String deviceId}) async {
    try {
      await _dio.post('/v1/me/player/previous', queryParameters: {'device_id': deviceId});
    } on DioException {
      rethrow;
    }
  }

  // Métodos adicionais

  Future<void> resumePlayback({required String deviceId}) async {
    try {
      await _dio.put('/v1/me/player/play', queryParameters: {'device_id': deviceId});
    } on DioException catch (e) {
      print("Erro ao retomar reprodução: ${e.response?.data}");
      rethrow;
    }
  }

  Future<void> seek(int positionMs, {required String deviceId}) async {
    try {
      await _dio.put(
        '/v1/me/player/seek',
        queryParameters: {
          'position_ms': positionMs,
          'device_id': deviceId,
        },
      );
    } on DioException catch (e) {
      print("Erro ao mudar posição da faixa: ${e.response?.data}");
      rethrow;
    }
  }

  Future<dynamic> getPlayerStatus() async {
    try {
      final response = await _dio.get('/v1/me/player');
      return response.data;
    } on DioException catch (e) {
      print('Erro ao obter status do player: ${e.response?.data}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPlayerCapabilities() async {
    try {
      final response = await _dio.get('/v1/me/player/capabilities');
      return response.data;
    } on DioException catch (e) {
      print('Erro ao obter capabilities: ${e.response?.data}');
      return null;
    }
  }
}