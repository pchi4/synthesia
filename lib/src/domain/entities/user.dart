// lib/src/domain/entities/user.dart (CORRIGIDO)

class User {
  final String id;
  final String displayName;
  final String? email; // 🚨 CORRIGIDO: Agora pode ser nulo
  final String? imageUrl;

  User({
    required this.id,
    required this.displayName,
    this.email, // 🚨 CORRIGIDO: Não é mais required no construtor
    this.imageUrl,
  });

  // Factory para criar a Entidade a partir do JSON da API
  factory User.fromJson(Map<String, dynamic> json) {
    // A API do Spotify retorna uma lista de imagens; pegamos a primeira (se houver)
    final images = json['images'] as List<dynamic>?;
    final imageUrl = images != null && images.isNotEmpty
        ? images[0]['url']
              as String? // 🚨 CORRIGIDO: O URL da imagem pode ser nulo
        : null;

    return User(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      email: json['email'] as String?, // 🚨 CORRIGIDO: Permite receber null
      imageUrl: imageUrl,
    );
  }
}
