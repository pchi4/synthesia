class AppConfig {
  static const String spotifyClientId = 'cea445ad26da4fd68157651f50ce4406';

  static const String redirectUriScheme = 'synthesia';
  static const String redirectUriHost = 'callback';

  static const String redirectUri = '$redirectUriScheme://$redirectUriHost';

  static const String spotifyAuthorizeUrl =
      'https://accounts.spotify.com/authorize';

  static const String spotifyTokenUrl =
      'https://accounts.spotify.com/api/token';

  static const List<String> spotifyScopes = [
    'user-read-email',
    'user-read-private',
    'playlist-read-private',
    'playlist-modify-public',
    'playlist-modify-private',
    'user-modify-playback-state',
    'user-read-currently-playing',
    'user-read-playback-state',
  ];
}
