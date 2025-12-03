// lib/src/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';

// Este Provider simplificado gerencia o estado da requisição de perfil.
final userProfileProvider = FutureProvider<User>((ref) async {
  final useCase = ref.watch(getUserProfileUseCaseProvider);
  return useCase.call();
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o estado do FutureProvider
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil Spotify')),
      body: Center(
        child: userProfileAsync.when(
          // 1. Loading
          loading: () =>
              const CircularProgressIndicator(color: Color(0xFF1DB954)),
          // 2. Erro
          error: (err, stack) {
            print(stack);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Erro ao carregar o perfil. Token inválido ou expirado?\nErro: $err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          },
          // 3. Dados (Sucesso)
          data: (user) => _buildProfileDetails(context, user),
        ),
      ),
    );
  }

  // Widget de detalhes do perfil
  Widget _buildProfileDetails(BuildContext context, User user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Imagem do Perfil (se houver)
        if (user.imageUrl != null)
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(user.imageUrl!),
          )
        else
          const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60)),
        const SizedBox(height: 20),
        Text(
          user.displayName,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          user.email ??
              'Email não disponível', // Se user.email for null, exibe 'Email não disponível'          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        const Text(
          'Sucesso! A autenticação e a chamada API funcionaram.',
          style: TextStyle(
            color: Color(0xFF1DB954),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
