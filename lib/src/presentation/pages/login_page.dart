import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../pages/home_page.dart';

const Color _backgroundColor = Color(0xFF141414);

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.82);
    path.lineTo(size.width, size.height * 0.65);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 6,
      width: isActive ? 24 : 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screen.height * 0.6,
            child: ClipPath(
              clipper: _DiagonalClipper(),
              child: Image.asset(
                'assets/images/login_art.png',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.2),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),

          Positioned(
            top: screen.height * 0.45,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  const Text(
                    'Sua Música, \nNossa AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38, 
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const Spacer(flex: 1),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await ref.read(authServiceProvider).login();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao conectar com Spotify: $e'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.music_note_outlined, size: 28),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          'Conectar com Spotify',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF1DB954,
                        ), // Cor Verde Spotify
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed('/onboarding'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _backgroundColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18.0),
                        child: Text(
                          'Voltar para o Tour',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Ao prosseguir, você concorda com os ',
                          ),
                          TextSpan(
                            text: 'Termos de Serviço',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const TextSpan(text: ' e a '),
                          TextSpan(
                            text: 'Política de Privacidade',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const TextSpan(text: ' do Plano Completo.'),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
