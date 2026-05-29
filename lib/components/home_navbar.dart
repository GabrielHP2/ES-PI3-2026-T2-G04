// João Pedro Panza Mainieri - 25006642;
import 'package:flutter/material.dart';

class HomeNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;

  const HomeNavbar({super.key, this.currentIndex = 0, this.onIndexChanged});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: <Widget>[
        NavigationDestination(
          icon: Icon(Icons.trending_up),
          label: 'Dashboard',
        ),
        NavigationDestination(icon: Icon(Icons.storage), label: 'Catalogo'),
        NavigationDestination(icon: Icon(Icons.storefront), label: 'Balcão'),
        NavigationDestination(
          icon: Icon(Icons.account_circle),
          label: 'Perfil',
        ),
      ],
      selectedIndex: currentIndex,
      onDestinationSelected: (int index) {
        if (onIndexChanged != null) onIndexChanged!(index);
      },
    );
  }
}
