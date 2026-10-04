import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/recommendation_response.dart';
import 'api_provider.dart';

class SavedNotifier extends StateNotifier<AsyncValue<List<RecommendationResponseDTO>>> {
  final Ref _ref;

  SavedNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadSaved();
  }

  Future<void> loadSaved() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(recommendationServiceProvider);
      final list = await service.getSavedRecommendations();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveRecommendation(int id, {String notes = ''}) async {
    try {
      final service = _ref.read(recommendationServiceProvider);
      await service.saveRecommendation(id, notes: notes);
      await loadSaved();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unsaveRecommendation(int id) async {
    try {
      final service = _ref.read(recommendationServiceProvider);
      await service.unsaveRecommendation(id);
      // Remove optimistically from state
      state.whenData((list) {
        state = AsyncValue.data(list.where((item) => item.requestId != id).toList());
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadSaved();
  }
}

final savedProvider = StateNotifierProvider.autoDispose<SavedNotifier, AsyncValue<List<RecommendationResponseDTO>>>((ref) {
  return SavedNotifier(ref);
});
