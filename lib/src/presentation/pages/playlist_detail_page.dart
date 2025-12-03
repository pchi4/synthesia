// lib/src/presentation/pages/playlist_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthesia/src/domain/usecases/player_usecase.dart';
import '../../domain/usecases/get_playlist_tracks_usecase.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/playlist.dart'; // Para exibir os detalhes da playlist

// Provedor para gerenciar o estado das faixas (depende do ID)
final playlistTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  playlistId,
) async {
  return ref.read(getPlaylistTracksUseCaseProvider).call(playlistId);
});

class PlaylistDetailPage extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailPage({required this.playlist, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o estado das faixas para o ID desta playlist
    final tracksAsync = ref.watch(playlistTracksProvider(playlist.id));

    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: tracksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Erro ao carregar faixas: $err')),
        data: (tracks) {
          if (tracks.isEmpty) {
            return const Center(
              child: Text('Esta playlist não possui faixas.'),
            );
          }

          // Lista de faixas
          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(track.name),
                subtitle: Text('${track.artistName} - ${track.albumName}'),
                onTap: () {
                  ref.read(playerProvider.notifier).playTrack(track.uri);
                  print('Tentando tocar faixa: ${track.name}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
