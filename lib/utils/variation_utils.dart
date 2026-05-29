// João Pedro Panza Mainieri - 25006642;
double calcularVariacaoPercentual(double base, double atual) {
  if (base == 0.0) return 0.0;
  return ((atual - base) / base) * 100.0;
}
