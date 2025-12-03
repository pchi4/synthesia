// lib/src/presentation/pages/home_page.dart (NOVA IMPLEMENTAÇÃO DE UI-001)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_page.dart'; // Mantenha a ProfilePage
import 'explore_page.dart'; // Crie este arquivo stub
import 'library_page.dart'; // Crie este arquivo stub

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    ExplorePage(), // Índice 0
    LibraryPage(), // Índice 1
    ProfilePage(), // Índice 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Music Player'),
        centerTitle: false,
        // Futuramente, botões de ação (ex: Logout)
      ),
      // Exibe a página atualmente selecionada
      body: _pages.elementAt(_selectedIndex),

      // Barra de Navegação Inferior (BottomNavigationBar)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}
