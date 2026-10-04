import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/recommendation_history.dart';
import 'api_provider.dart';

class HistoryNotifier extends StateNotifier<AsyncValue<List<RecommendationHistoryDTO>>> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(recommendationServiceProvider);
      final list = await service.getHistory();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadHistory();
  }
}

final historyProvider = StateNotifierProvider.autoDispose<HistoryNotifier, AsyncValue<List<RecommendationHistoryDTO>>>((ref) {
  return HistoryNotifier(ref);
});
