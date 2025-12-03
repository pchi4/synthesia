// lib/src/presentation/pages/explore_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synthesia/src/domain/entities/playlist.dart';
import 'package:synthesia/src/presentation/pages/playlist_detail_page.dart';
import '../../domain/usecases/get_featured_playlists_usecase.dart';

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
    final playlistsAsync = ref.watch(featuredPlaylistsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // BACKGROUND GRADIENT + MESH
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D0D12),
                    Color(0xFF13131D),
                    Color(0xFF0E0D1A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDA2BAA),
              ),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),

          playlistsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            ),
            error: (err, stack) => Center(
              child: Text(
                'Erro ao carregar playlists: $err',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            data: (playlists) {
              if (playlists.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma playlist encontrada.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  // APPBAR PROFISSIONAL
                  SliverAppBar(
                    backgroundColor: Colors.black.withOpacity(0.1),
                    elevation: 0,
                    floating: true,
                    snap: true,
                    centerTitle: false,
                    titleSpacing: 20,
                    flexibleSpace: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    title: const Text(
                      "Explorar Playlists",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // GRID DE PLAYLISTS
                  SliverPadding(
                    padding: const EdgeInsets.all(18),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final playlist = playlists[index];
                        return PlaylistCard(playlist: playlist);
                      }, childCount: playlists.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 18,
                            childAspectRatio: 0.72,
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// CARD PROFISSIONAL
class PlaylistCard extends StatelessWidget {
  final Playlist playlist;

  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlaylistDetailPage(playlist: playlist),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: 'playlist_${playlist.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: playlist.imageUrl != null
                      ? Image.network(
                          playlist.imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              playlist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Text(
              "${playlist.totalTracks} músicas",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
