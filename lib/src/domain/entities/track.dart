// lib/src/domain/entities/track.dart

class Track {
  final String id;
  final String name;
  final String artistName;
  final String albumName;
  final String uri; // Spotify URI para playback

  Track({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.uri,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    // Spotify API retorna a faixa dentro de uma chave 'track' quando é uma faixa de playlist.
    final trackData =
        json['track'] ??
        json; // Usa 'track' se for playlist item, senão usa o próprio json

    // Mapeamento seguro das informações
    final artistList = trackData['artists'] as List<dynamic>?;
    final artistName = artistList != null && artistList.isNotEmpty
        ? artistList.first['name'] as String
        : 'Artista Desconhecido';

    return Track(
      id: trackData['id'] as String? ?? '',
      name: trackData['name'] as String? ?? 'Faixa Desconhecida',
      artistName: artistName,
      albumName: trackData['album']?['name'] as String? ?? 'Álbum Desconhecido',
      uri: trackData['uri'] as String? ?? '',
    );
  }
}
