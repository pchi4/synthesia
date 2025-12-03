// lib/src/presentation/pages/player_page.dart

import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track.dart';
import '../../domain/usecases/player_usecase.dart';

/// PlayerPage - tela completa estilizada conforme o mockup (card reto).
/// - Usa `playerProvider` (Notifier) para controle de reprodução.
/// - Caso `track.albumImageUrl` seja null, usa a imagem fallback local.
class PlayerPage extends ConsumerStatefulWidget {
  final Track track;

  const PlayerPage({super.key, required this.track});

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // inicia atualização de posição simulada (mesma lógica sua)
    _startPositionUpdater();

    // solicita play assim que entrar na tela (mantém compatibilidade com seu Notifier)
    Future.microtask(() {
      ref.read(playerProvider.notifier).playTrack(widget.track);
    });
  }

  void _startPositionUpdater() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final player = ref.read(playerProvider);
      if (player.isPlaying) {
        final next = player.position + const Duration(seconds: 1);
        if (next < player.duration) {
          ref.read(playerProvider.notifier).setPosition(next);
        } else {
          // quando chega ao fim, zera (ou você pode avançar para próxima)
          ref.read(playerProvider.notifier).setPosition(Duration.zero);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final current = player.currentTrack ?? widget.track;

    // fallback para a imagem que você enviou (local)
    const fallbackLocal = '/mnt/data/28fd17de-044f-4a33-baa4-e94e28b5e103.png';
    final imageUrl = current.albumImageUrl ?? fallbackLocal;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.86; // responsivo

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // BACKDROP: imagem do álbum cobrindo tudo (blurred)
          Positioned.fill(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),
          ),

          // filtro blur + overlay escuro
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          ),

          // CONTEÚDO
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Espaçamento superior
                    const SizedBox(height: 36),

                    // CARD PRINCIPAL (reto, sem tilt)
                    Container(
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0B0B),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // CAPA (ocupando a metade superior visual do card)
                          SizedBox(
                            height: 300,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: Colors.grey[900]),
                                ),
                                // overlay gradient suave sobre a capa
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.28),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // CONTEÚDO INFERIOR DO CARD
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // TÍTULO (cor lilás similar ao mockup)
                                Text(
                                  current.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFB38CFF),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // ARTISTA + SUBTÍTULO menor
                                Text(
                                  current.artistName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // SLIDER
                                Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderThemeData(
                                        thumbColor: const Color(0xFFB38CFF),
                                        activeTrackColor: const Color(
                                          0xFFB38CFF,
                                        ),
                                        inactiveTrackColor: Colors.white24,
                                        trackHeight: 3.5,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 7,
                                        ),
                                      ),
                                      child: Slider(
                                        min: 0,
                                        max: player.duration.inSeconds
                                            .toDouble(),
                                        value: player.position.inSeconds
                                            .toDouble()
                                            .clamp(
                                              0,
                                              player.duration.inSeconds
                                                  .toDouble(),
                                            ),
                                        onChanged: (_) {
                                          // opcional: implementar seek
                                        },
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _format(player.position),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _format(player.duration),
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // CONTROLES: previous - play - next
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      iconSize: 32,
                                      color: Colors.white,
                                      icon: const Icon(Icons.skip_previous),
                                      onPressed: () => ref
                                          .read(playerProvider.notifier)
                                          .previous(),
                                    ),

                                    const SizedBox(width: 18),

                                    // botão play circular branco
                                    Material(
                                      color: Colors.white,
                                      shape: const CircleBorder(),
                                      elevation: 6,
                                      child: IconButton(
                                        iconSize: 36,
                                        color: Colors.black,
                                        icon: Icon(
                                          player.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                        ),
                                        onPressed: () {
                                          if (player.isPlaying) {
                                            ref
                                                .read(playerProvider.notifier)
                                                .pause();
                                          } else {
                                            ref
                                                .read(playerProvider.notifier)
                                                .resume();
                                          }
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: 18),

                                    IconButton(
                                      iconSize: 32,
                                      color: Colors.white,
                                      icon: const Icon(Icons.skip_next),
                                      onPressed: () => ref
                                          .read(playerProvider.notifier)
                                          .next(),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // ACTIONS (favorite / share / shuffle) - estilo sutil
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      iconSize: 20,
                                      color: Colors.white70,
                                      icon: const Icon(Icons.favorite_border),
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      iconSize: 20,
                                      color: Colors.white70,
                                      icon: const Icon(Icons.repeat),
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      iconSize: 20,
                                      color: Colors.white70,
                                      icon: const Icon(Icons.share),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // AppBar simples com botão de voltar sobreposto
          Positioned(
            top: 12,
            left: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
