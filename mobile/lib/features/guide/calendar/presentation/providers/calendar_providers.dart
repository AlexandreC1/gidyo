import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/supabase_client.dart';
import '../../data/datasources/calendar_datasource.dart';
import '../../domain/entities/calendar_entities.dart';

// Datasource Provider
final calendarDatasourceProvider = Provider<CalendarDatasource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return CalendarDatasource(supabase);
});

// Selected Month Provider
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Calendar Days Provider
final guideAvailabilityProvider =
    FutureProvider.family<List<CalendarDayEntity>, DateTime>((ref, month) async {
  final datasource = ref.watch(calendarDatasourceProvider);
  return await datasource.getMonthCalendar(month);
});

// Calendar Actions Controller
final calendarActionsProvider =
    StateNotifierProvider<CalendarActionsController, AsyncValue<void>>((ref) {
  return CalendarActionsController(ref);
});

class CalendarActionsController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  CalendarActionsController(this._ref) : super(const AsyncValue.data(null));

  Future<void> blockDates({
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    try {
      final datasource = _ref.read(calendarDatasourceProvider);
      await datasource.blockDateRange(
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );

      // Refresh calendar
      _ref.invalidate(guideAvailabilityProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> saveRecurringAvailability({
    required int dayOfWeek,
    required List<TimeRange> timeRanges,
  }) async {
    state = const AsyncValue.loading();

    try {
      final datasource = _ref.read(calendarDatasourceProvider);
      await datasource.saveRecurringAvailability(
        dayOfWeek: dayOfWeek,
        timeRanges: timeRanges,
      );

      _ref.invalidate(guideAvailabilityProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
