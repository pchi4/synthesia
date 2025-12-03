// PlayerNotifier revisado com melhorias aplicadas
// Inclui validações, sincronização pós ações, ensureDevice fortalecido
// e fluxo mais estável sem depender de métodos ausentes no service.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/spotify_service.dart';
import '../../domain/entities/track.dart';

class PlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final Track? currentTrack;
  final List<Track> playlist;
  final int currentIndex;
  final String? deviceId;

  const PlayerState({
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.currentTrack,
    required this.playlist,
    required this.currentIndex,
    required this.deviceId,
  });

  factory PlayerState.initial() => const PlayerState(
        isPlaying: false,
        position: Duration.zero,
        duration: Duration.zero,
        currentTrack: null,
        playlist: [],
        currentIndex: 0,
        deviceId: null,
      );

  PlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    Track? currentTrack,
    List<Track>? playlist,
    int? currentIndex,
    String? deviceId,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentTrack: currentTrack ?? this.currentTrack,
      playlist: playlist ?? this.playlist,
      currentIndex: currentIndex ?? this.currentIndex,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}

class PlayerNotifier extends Notifier<PlayerState> {
  late final SpotifyService _spotify;

  @override
  PlayerState build() {
    _spotify = ref.read(spotifyServiceProvider);
    return PlayerState.initial();
  }

  Future<void> ensureDevice() async {
    final device = await _spotify.findActiveDevice();

    if (device == null) {
      print("Nenhum dispositivo Spotify ativo encontrado.");
      state = state.copyWith(deviceId: null);
      return;
    }

    state = state.copyWith(deviceId: device['id']);
  }

  Future<void> syncStateWithSpotify() async {
    final status = await _spotify.getPlayerStatus();
    if (status == null) return;

    final track = status.currentTrack != null
        ? Track(
            name: status.currentTrack!.name,
            uri: status.currentTrack!.uri,
            durationMs: status.currentTrack!.durationMs,
          )
        : null;

    state = state.copyWith(
      isPlaying: status.isPlaying,
      position: Duration(milliseconds: status.progressMs ?? 0),
      duration: Duration(milliseconds: status.currentTrack?.durationMs ?? 0),
      currentTrack: track,
    );
  }

  Future<void> playTrack(Track track) async {
    await ensureDevice();
    if (state.deviceId == null) return;

    await _spotify.startPlayback(
      deviceId: state.deviceId!,
      trackUri: track.uri,
    );

    await syncStateWithSpotify();

    state = state.copyWith(
      playlist: [track],
      currentIndex: 0,
      currentTrack: track,
      duration: Duration(milliseconds: track.durationMs),
      position: Duration.zero,
      isPlaying: true,
    );
  }

  Future<void> playPlaylist(List<Track> tracks, int index) async {
    await ensureDevice();
    if (state.deviceId == null) return;

    final track = tracks[index];

    await _spotify.startPlayback(
      deviceId: state.deviceId!,
      trackUri: track.uri,
    );

    await syncStateWithSpotify();

    state = state.copyWith(
      playlist: tracks,
      currentIndex: index,
      currentTrack: track,
      duration: Duration(milliseconds: track.durationMs),
      position: Duration.zero,
      isPlaying: true,
    );
  }

  Future<void> pause() async {
    await ensureDevice();
    if (state.deviceId == null) return;

    final caps = await _spotify.getPlayerCapabilities();
    if (caps?.disallowsPausing == true) {
      print("Spotify não permite pausar no momento.");
      return;
    }

    await _spotify.pausePlayback(deviceId: state.deviceId!);

    await syncStateWithSpotify();

    state = state.copyWith(isPlaying: false);
  }

  Future<void> resume() async {
    await ensureDevice();
    if (state.deviceId == null) return;

    await _spotify.resumePlayback(deviceId: state.deviceId!);

    await syncStateWithSpotify();

    state = state.copyWith(isPlaying: true);
  }

  Future<void> next() async {
    await ensureDevice();
    if (state.deviceId == null) return;

    await _spotify.skipToNext(deviceId: state.deviceId!);
    await syncStateWithSpotify();
  }

  Future<void> previous() async {
    await ensureDevice();
    if (state.deviceId == null) return;

    await _spotify.skipToPrevious(deviceId: state.deviceId!);
    await syncStateWithSpotify();
  }

  void setPosition(Duration pos) {
    state = state.copyWith(position: pos);
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);
