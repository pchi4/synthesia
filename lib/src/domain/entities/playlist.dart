// lib/src/domain/entities/playlist.dart

class Playlist {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int totalTracks;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.totalTracks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>? ?? [];

    return Playlist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: images.isNotEmpty ? images.first['url'] : null,
      totalTracks: (json['tracks'] is Map && json['tracks']['total'] != null)
          ? json['tracks']['total']
          : 0,
    );
  }
}
