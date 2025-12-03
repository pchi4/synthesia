// lib/src/presentation/pages/playlist_detail_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthesia/src/presentation/pages/player_page.dart';
import '../../domain/usecases/get_playlist_tracks_usecase.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/usecases/player_usecase.dart';

// Constantes de Design
const Color _backgroundColor = Color(0xFF161622); // Cor de fundo escura do app
const Color _primaryColor = Color(
  0xFFE50074,
); // Cor de destaque (similar ao neon do header)

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
    final tracksAsync = ref.watch(playlistTracksProvider(playlist.id));

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: tracksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primaryColor),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Erro ao carregar faixas: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (tracks) {
          return CustomScrollView(
            slivers: [
              // 1. SliverAppBar - Cabeçalho Imersivo
              SliverAppBar(
                expandedHeight: 400, // Altura maior para o visual de destaque
                pinned: true,
                backgroundColor: _backgroundColor,
                elevation: 0,
                // Ícone de voltar e opções (três pontos)
                leading: Container(
                  margin: const EdgeInsets.only(left: 10, top: 10),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.white.withOpacity(0.15),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 10, top: 10),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: Colors.white.withOpacity(0.15),
                          child: IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: EdgeInsets.zero,
                  // O título aparece ao recolher a barra
                  title: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text(
                        playlist.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagem de Fundo (Hero Animation)
                      Hero(
                        tag: 'playlist_${playlist.id}',
                        child: playlist.imageUrl != null
                            ? Image.network(
                                playlist.imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(color: Colors.grey[900]),
                      ),
                      // Overlay de Gradiente
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                // Transparente no topo, escuro no meio e muito escuro na base
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.7),
                                _backgroundColor.withOpacity(1.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Conteúdo principal (Nome e descrição)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _HeaderContent(playlist: playlist),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. SliverToBoxAdapter - Título da Seção (Sugestão/Músicas)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                  child: Text(
                    'Sugestão (${tracks.length} Faixas)', // Adaptando o texto "Suggestion"
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // 3. SliverList - Lista de Faixas Numeradas
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final track = tracks[index];
                  final trackNumber = (index + 1).toString().padLeft(
                    2,
                    '0',
                  ); // 01, 02, 03...

                  return _TrackListItem(
                    track: track,
                    trackNumber: trackNumber,
                    onTap: () {
                      ref
                          .read(playerProvider.notifier)
                          .playPlaylist(tracks, index);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerPage(track: track),
                        ),
                      );
                    },
                  );
                }, childCount: tracks.length),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ), // Espaço no final
            ],
          );
        },
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

// Replicando o bloco de informações no header
class _HeaderContent extends StatelessWidget {
  final Playlist playlist;

  const _HeaderContent({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal (Come to me / Nome da Playlist)
          Text(
            playlist.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),

          // Subtítulo (Shawn Mendes / Criador da Playlist)
          Text(
            playlist.id ?? 'Usuário Spotify',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Descrição (Simulando o texto "Lorem ipsum...")
          Text(
            playlist.description.isNotEmpty
                ? playlist.description
                : 'Esta é uma playlist gerada por IA com base nas suas preferências musicais e características de áudio (energia, danceability, valence).',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// Replicando o ListTile com numeração lateral
// Replicando o ListTile com numeração lateral + imagem do álbum
class _TrackListItem extends StatelessWidget {
  final Track track;
  final String trackNumber;
  final VoidCallback onTap;

  const _TrackListItem({
    required this.track,
    required this.trackNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Número lateral (01, 02, 03...)
            Text(
              trackNumber,
              style: const TextStyle(
                color: _primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),

            /// Imagem do álbum
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                track.albumImageUrl!,
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            /// Conteúdo textual
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${track.artistName} • ${track.albumName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// Três pontinhos
            const Icon(Icons.more_vert, color: Colors.white54, size: 20),
          ],
        ),
      ),
    );
  }
}
