// lib/src/presentation/pages/explore_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthesia/src/domain/entities/playlist.dart';
import 'package:synthesia/src/presentation/pages/playlist_detail_page.dart';
import '../../domain/usecases/get_featured_playlists_usecase.dart';

// Criar um AsyncNotifierProvider para gerenciar o estado
final featuredPlaylistsProvider =
    AsyncNotifierProvider<FeaturedPlaylistsNotifier, List<Playlist>>(() {
      return FeaturedPlaylistsNotifier();
    });

class FeaturedPlaylistsNotifier extends AsyncNotifier<List<Playlist>> {
  @override
  Future<List<Playlist>> build() async {
    return ref.read(getUserPlaylistsUseCaseProvider).call();
  }
}

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o estado das playlists
    final playlistsAsync = ref.watch(featuredPlaylistsProvider);

    return Scaffold(
      body: playlistsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Erro ao carregar playlists: $err')),
        data: (playlists) {
          if (playlists.isEmpty) {
            return const Center(
              child: Text('Nenhuma playlist em destaque encontrada.'),
            );
          }

          // Exibe as playlists em um GridView
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 itens por linha
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8, // Ajuste o aspecto para que a imagem caiba
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return _PlaylistCard(playlist: playlist);
            },
          );
        },
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    // 1. Envolver o Card com o InkWell para capturar o toque
    return InkWell(
      onTap: () {
        // 2. Ação de navegação para a tela de detalhes (UI-004)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlaylistDetailPage(playlist: playlist),
          ),
        );
      },
      // O InkWell deve ter um material ancestor, o Card já fornece isso.
      child: Card(
        clipBehavior: Clip.antiAlias,
        // O restante da sua coluna de widgets vai aqui
        child: Column(
          // ... (O resto do seu código da coluna)
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem da Playlist
            Expanded(
              child: playlist.imageUrl != null
                  ? Image.network(
                      playlist.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : const Center(child: Icon(Icons.music_note, size: 40)),
            ),
            // Detalhes da Playlist
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                playlist.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ).copyWith(bottom: 8),
              child: Text(
                '${playlist.totalTracks} faixas',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
