// lib/src/domain/usecases/get_playlist_tracks_usecase.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthesia/src/domain/entities/track.dart';
import '../../services/spotify_service.dart';

// Provider para o Use Case (disponível globalmente)
final getPlaylistTracksUseCaseProvider = Provider<GetPlaylistTracksUseCase>((
  ref,
) {
  return GetPlaylistTracksUseCase(ref.read(spotifyServiceProvider));
});

class GetPlaylistTracksUseCase {
  final SpotifyService _spotifyService;

  GetPlaylistTracksUseCase(this._spotifyService);

  Future<List<Track>> call(String playlistId) async {
    final rawTracks = await _spotifyService.fetchPlaylistTracks(playlistId);

    // Mapeamos os itens. O Track.fromJson já lida com o envelope 'track'.
    return List<Track>.from(rawTracks);
  }
}
