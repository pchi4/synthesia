import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _OnboardingCard(
        title: 'Curadoria por IA',
        subtitle:
            'Recomendações adaptadas ao seu gosto com modelos inteligentes.',
        lottie: 'assets/lottie/login_decor.json',
      ),
      _OnboardingCard(
        title: 'Experiências Contextuais',
        subtitle: 'Playlists por humor, imagem ou momento do dia.',
        lottie: 'assets/lottie/login_decor.json',
      ),
      _OnboardingCard(
        title: 'Controles Naturais',
        subtitle: 'Use prompts de texto para buscar, criar e mixar músicas.',
        lottie: 'assets/lottie/login_decor.json',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) =>
                    Padding(padding: const EdgeInsets.all(20), child: pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  TextButton(onPressed: _complete, child: const Text('Pular')),
                  const Spacer(),
                  Row(
                    children: List.generate(pages.length, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _index == i ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _index == i
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_index == pages.length - 1) {
                        _complete();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.ease,
                        );
                      }
                    },
                    child: Text(
                      _index == pages.length - 1 ? 'Começar' : 'Próximo',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String lottie;
  const _OnboardingCard({
    required this.title,
    required this.subtitle,
    required this.lottie,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Lottie.asset(lottie, fit: BoxFit.contain)),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
