// lib/src/domain/usecases/get_playlist_tracks_usecase.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthesia/src/domain/entities/track.dart';
import '../../services/spotify_service.dart';

final getPlaylistTracksUseCaseProvider = Provider<GetPlaylistTracksUseCase>((
  ref,
) {
  return GetPlaylistTracksUseCase(ref.read(spotifyServiceProvider));
});

class GetPlaylistTracksUseCase {
  final SpotifyService _spotifyService;

  GetPlaylistTracksUseCase(this._spotifyService);

  Future<List<Track>> call(String playlistId) async {
    return await _spotifyService.fetchPlaylistTracks(playlistId);
  }
}
