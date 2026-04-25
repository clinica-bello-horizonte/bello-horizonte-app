import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/core_providers.dart';

final appointmentRatingProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, appointmentId) async {
  final api = ref.watch(apiClientProvider);
  try {
    final data = await api.get(ApiEndpoints.getAppointmentRating(appointmentId));
    return data as Map<String, dynamic>?;
  } catch (_) {
    return null;
  }
});

final doctorRatingsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, doctorId) async {
  final api = ref.watch(apiClientProvider);
  try {
    final data = await api.get(ApiEndpoints.doctorRatings(doctorId));
    return (data as List?) ?? [];
  } catch (_) {
    return [];
  }
});

class RatingNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  RatingNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> submitRating(String appointmentId, int stars, String? comment) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(apiClientProvider).post(
        ApiEndpoints.rateAppointment(appointmentId),
        body: {
          'stars': stars,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

final ratingNotifierProvider =
    StateNotifierProvider<RatingNotifier, AsyncValue<void>>(
  (ref) => RatingNotifier(ref),
);
