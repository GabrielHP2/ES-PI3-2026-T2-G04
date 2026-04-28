import 'package:flutter/material.dart';
import 'package:frontend/components/home_navbar.dart';
import 'package:frontend/pages/catalogo_page.dart';
import 'package:frontend/pages/dashboard_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'token_market_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CatalogoPage(),
    DashboardPage(),
    TokenMarketPage(),
    ProfilePage(),
  ];

  void _onIndexChanged(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: HomeNavbar(
        currentIndex: _currentIndex,
        onIndexChanged: _onIndexChanged,
      ),
    );
  }
}
