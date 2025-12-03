// lib/src/domain/usecases/player_usecase.dart

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

  Future<void> setDevice(String deviceId) async {
    state = state.copyWith(deviceId: deviceId);
  }

  Future<void> playTrack(Track track) async {
    await ensureDevice();
    if (state.deviceId == null) return;

    await _spotify.startPlayback(
      deviceId: state.deviceId!,
      trackUri: track.uri,
    );

    state = state.copyWith(
      currentTrack: track,
      playlist: [track],
      currentIndex: 0,
      isPlaying: true,
      duration: Duration(milliseconds: track.durationMs),
      position: Duration.zero,
    );
  }

  Future<void> ensureDevice() async {
    if (state.deviceId != null) return;

    final device = await _spotify.findActiveDevice();

    if (device == null) {
      print("Nenhum dispositivo Spotify ativo encontrado.");
      return;
    }

    state = state.copyWith(deviceId: device['id']);
  }

  Future<void> playPlaylist(List<Track> tracks, int index) async {
    await ensureDevice();

    final track = tracks[index];

    await _spotify.startPlayback(
      deviceId: state.deviceId!,
      trackUri: track.uri,
    );

    state = state.copyWith(
      playlist: tracks,
      currentIndex: index,
      currentTrack: track,
      duration: Duration(milliseconds: track.durationMs),
      position: Duration.zero,
      isPlaying: true,
    );
  }

  Future<void> next() async {
    if (state.deviceId == null) return;
    if (state.playlist.isEmpty) return;

    await _spotify.skipToNext(deviceId: state.deviceId!);

    final isLast = state.currentIndex >= state.playlist.length - 1;
    final newIndex = isLast ? state.currentIndex : state.currentIndex + 1;

    final newTrack = state.playlist[newIndex];

    state = state.copyWith(
      currentIndex: newIndex,
      currentTrack: newTrack,
      duration: Duration(milliseconds: newTrack.durationMs),
      position: Duration.zero,
      isPlaying: true,
    );
  }

  Future<void> previous() async {
    if (state.deviceId == null) return;
    if (state.playlist.isEmpty) return;

    await _spotify.skipToPrevious(deviceId: state.deviceId!);

    final isFirst = state.currentIndex == 0;
    final newIndex = isFirst ? 0 : state.currentIndex - 1;

    final newTrack = state.playlist[newIndex];

    state = state.copyWith(
      currentIndex: newIndex,
      currentTrack: newTrack,
      duration: Duration(milliseconds: newTrack.durationMs),
      position: Duration.zero,
      isPlaying: true,
    );
  }

  Future<void> pause() async {
    if (state.deviceId == null) return;

    await _spotify.pausePlayback(deviceId: state.deviceId!);

    state = state.copyWith(isPlaying: false);
  }

  Future<void> resume() async {
    if (state.deviceId == null) return;

    await _spotify.startPlayback(
      deviceId: state.deviceId!,
      trackUri: state.currentTrack?.uri,
    );

    state = state.copyWith(isPlaying: true);
  }

  void setPosition(Duration pos) {
    state = state.copyWith(position: pos);
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(
  PlayerNotifier.new,
);
