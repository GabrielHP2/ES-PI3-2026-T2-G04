import 'package:flutter/foundation.dart';

final ValueNotifier<int> portfolioRefreshNotifier = ValueNotifier<int>(0);

void requestPortfolioRefresh() {
  portfolioRefreshNotifier.value++;
}