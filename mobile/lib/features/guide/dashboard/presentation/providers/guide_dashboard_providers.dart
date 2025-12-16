import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/supabase_client.dart';
import '../../data/datasources/guide_dashboard_datasource.dart';
import '../../domain/entities/guide_stats_entity.dart';

// Datasource Provider
final guideDashboardDatasourceProvider =
    Provider<GuideDashboardDatasource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return GuideDashboardDatasource(supabase);
});

// Guide Stats Provider
final guideStatsProvider = FutureProvider<GuideStatsEntity>((ref) async {
  final datasource = ref.watch(guideDashboardDatasourceProvider);
  return await datasource.getGuideStats();
});

// Today's Bookings Provider
final todayBookingsProvider =
    FutureProvider<List<TodayBookingEntity>>((ref) async {
  final datasource = ref.watch(guideDashboardDatasourceProvider);
  return await datasource.getTodayBookings();
});

// Pending Requests Provider
final pendingRequestsProvider =
    FutureProvider<List<PendingRequestEntity>>((ref) async {
  final datasource = ref.watch(guideDashboardDatasourceProvider);
  return await datasource.getPendingRequests();
});

// Upcoming Bookings Provider
final upcomingBookingsProvider =
    FutureProvider<List<UpcomingBookingEntity>>((ref) async {
  final datasource = ref.watch(guideDashboardDatasourceProvider);
  return await datasource.getUpcomingBookings();
});

// Booking Actions Controller
final bookingActionsProvider =
    StateNotifierProvider<BookingActionsController, AsyncValue<void>>((ref) {
  return BookingActionsController(ref);
});

class BookingActionsController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  BookingActionsController(this._ref) : super(const AsyncValue.data(null));

  Future<void> acceptBooking(String bookingId) async {
    state = const AsyncValue.loading();

    try {
      final datasource = _ref.read(guideDashboardDatasourceProvider);
      await datasource.acceptBookingRequest(bookingId);

      // Refresh providers
      _ref.invalidate(pendingRequestsProvider);
      _ref.invalidate(upcomingBookingsProvider);
      _ref.invalidate(guideStatsProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> declineBooking(String bookingId, String reason) async {
    state = const AsyncValue.loading();

    try {
      final datasource = _ref.read(guideDashboardDatasourceProvider);
      await datasource.declineBookingRequest(bookingId, reason);

      // Refresh providers
      _ref.invalidate(pendingRequestsProvider);
      _ref.invalidate(guideStatsProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
