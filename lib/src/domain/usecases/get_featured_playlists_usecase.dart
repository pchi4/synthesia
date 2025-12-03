// lib/src/domain/usecases/get_user_playlists_usecase.dart

import '../entities/playlist.dart';
import '../../services/spotify_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getUserPlaylistsUseCaseProvider = Provider<GetUserPlaylistsUseCase>((
  ref,
) {
  final spotifyService = ref.read(spotifyServiceProvider);
  return GetUserPlaylistsUseCase(spotifyService);
});

class GetUserPlaylistsUseCase {
  final SpotifyService _service;

  GetUserPlaylistsUseCase(this._service);

  Future<List<Playlist>> call() async {
    final raw = await _service.fetchUserPlaylists();
    return raw.map((json) => Playlist.fromJson(json)).toList();
  }
}
