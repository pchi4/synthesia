import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/spotify_service.dart';
import '../entities/user.dart';

final getUserProfileUseCaseProvider = Provider((ref) {
  return GetUserProfileUseCase(ref.read(spotifyServiceProvider));
});

class GetUserProfileUseCase {
  final SpotifyService _spotifyService;

  GetUserProfileUseCase(this._spotifyService);

  Future<User> call() async {
    final userData = await _spotifyService.fetchUserProfile();
    return User.fromJson(userData);
  }
}
