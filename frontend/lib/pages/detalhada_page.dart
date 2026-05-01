import 'package:flutter/material.dart';
import 'package:frontend/models/startup.dart';

class PaginaDetalhadaNaoInvestidor extends StatefulWidget{
  @override 
  //const PaginaDetalhadaNaoInvestidor({super.key});
  State<PaginaDetalhadaNaoInvestidor> createState()=> _PaginaDetalhadaState();
}

class _PaginaDetalhadaState extends State<PaginaDetalhadaNaoInvestidor> { 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          "DETALHES",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 16),
            _description(),
            const SizedBox(height: 12),
            _tags(),
            const SizedBox(height: 20),
            _stats(),
            const SizedBox(height: 20),
            _sectionCard(
              title: "Sumário executivo",
              child: const Text(
                "Focada no mercado B2C, a FinNova utiliza algoritmos de processamento de linguagem natural para categorizar gastos bancários com precisão de 98%.",
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: "Estrutura societária",
              child: Column(
                children: [
                  _ownerTile("Thiago Mendes", "CEO & Founder", "58%"),
                  _ownerTile("Thiago Mendes", "CEO & Founder", "58%"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Icon(Icons.account_balance, size: 36, color: Colors.indigo),
        const SizedBox(width: 10),
        const Text(
          "FinNova",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          "\$FNOVA",
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.bubble_chart, color: Colors.white),
        )
      ],
    );
  }

  Widget _description() {
    return const Text(
      "FinNova é uma plataforma que ajuda usuários a gerenciar finanças pessoais com análises baseadas em IA, sugestões de orçamento e metas de investimento automatizadas. Integra contas bancárias, cartões e investimentos para fornecer uma visão consolidada e recomendações personalizadas.",
      style: TextStyle(fontSize: 14),
    );
  }

  Widget _tags() {
    final tags = ["Fintech", "Gestão financeira", "IA"];

    return Wrap(
      spacing: 8,
      children: tags
          .map(
            (tag) => Chip(
              label: Text(tag),
              shape: StadiumBorder(
                side: BorderSide(color: Colors.indigo.shade200),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _stats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _StatCard(title: "R\$ 280k", subtitle: "Captado"),
        _StatCard(title: "95.0K", subtitle: "Tokens"),
        _StatCard(title: "1.2K", subtitle: "Investidores"),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _ownerTile(String name, String role, String percent) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(role, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const Spacer(),
          Text(
            percent,
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}