class Track {
  final String id;
  final String name;
  final String artistName;
  final String albumName;
  final String uri;
  final String? albumImageUrl;
  final int durationMs;

  Track({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    required this.uri,
    required this.durationMs,
    this.albumImageUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      artistName: (json['artists'] as List).isNotEmpty
          ? json['artists'][0]['name']
          : '',
      albumName: json['album']?['name'] ?? '',
      uri: json['uri'] ?? '',
      durationMs: json['duration_ms'] ?? 0,
      albumImageUrl: json['album']?['images']?[0]?['url'],
    );
  }
}
