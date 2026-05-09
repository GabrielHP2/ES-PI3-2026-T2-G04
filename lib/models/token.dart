class Token {
  final String startupId;
  final String ticker;
  final String nome;
  final double precoAtual;
  final double variacao;
  final List<double> historicoPrecos;

  const Token({
    required this.startupId,
    required this.ticker,
    required this.nome,
    required this.precoAtual,
    required this.variacao,
    required this.historicoPrecos,
  });
}