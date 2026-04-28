import 'package:flutter/material.dart';

class TokenMarketPage extends StatelessWidget {
  const TokenMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balcão de negociações'),
        automaticallyImplyLeading: false,
      ),
      body: Center(child: Text('Pagina do balcão em desenvolvimento')),
    );
  }
}
