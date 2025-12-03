// lib/src/domain/usecases/player_usecase.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/spotify_service.dart';
import '../entities/device.dart';

// Este notifier gerenciará o estado de qual dispositivo está sendo usado.
class PlayerNotifier extends StateNotifier<Device?> {
  final SpotifyService _spotifyService;

  PlayerNotifier(this._spotifyService) : super(null);

  // 1. Encontra e define um dispositivo ativo (preferencialmente o Spotify app no celular)
  Future<void> findAndSetDevice() async {
    try {
      final rawDevices = await _spotifyService.fetchAvailableDevices();
      final devices = rawDevices.map((json) => Device.fromJson(json)).toList();

      // Prioriza o dispositivo ativo (onde o usuário está ouvindo agora) ou o primeiro dispositivo.
      final activeDevice = devices.firstWhere(
        (d) => d.isActive,
        orElse: () => devices.isNotEmpty
            ? devices.first
            : Device(id: '', name: 'Nenhum', isActive: false),
      );

      state = activeDevice;
    } catch (e) {
      state = null;
    }
  }

  // 2. Toca uma faixa
  Future<void> playTrack(String trackUri) async {
    if (state?.id == null) {
      // Tenta encontrar o dispositivo se for null
      await findAndSetDevice();
      if (state?.id == null) return;
    }

    await _spotifyService.startPlayback(
      deviceId: state!.id,
      trackUri: trackUri,
    );
  }

  // 3. Pausa a reprodução
  Future<void> pause() async {
    if (state?.id == null) return;
    await _spotifyService.pausePlayback(deviceId: state!.id);
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, Device?>((ref) {
  return PlayerNotifier(ref.read(spotifyServiceProvider));
});
