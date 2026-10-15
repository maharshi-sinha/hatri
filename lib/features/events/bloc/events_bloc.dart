import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../domain/repositories/event_repository.dart';
import '../domain/usecases/get_events.dart';
import 'events_event.dart';
import 'events_state.dart';

/// Bloc for the discovery feed.
///
/// PR #3 of the clean-arch migration: the bloc now talks to the Either-
/// returning [EventRepository] through the [GetEvents] use case. State
/// shape is unchanged (EventsInitial / EventsLoading / EventsLoaded /
/// EventsError) so no UI call site needs to change.
///
/// Failures are translated to the existing EventsError message surface
/// via [_messageFor]. Later PRs will carry the typed Failure into state
/// so the UI can pick different copy per failure type.
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetEvents _getEvents;

  EventsBloc({required GetEvents getEvents})
      : _getEvents = getEvents,
        super(EventsInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadMoreEvents>(_onLoadMoreEvents);
    on<SetDiscoveryFilter>(_onSetDiscoveryFilter);
    on<SetCategoryFilter>(_onSetCategoryFilter);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    // Preserved from the pre-migration bloc: a short delay gives shimmer
    // skeletons time to breathe on fast connections so the feed does not
    // pop in jarringly. See the UX decision in the shimmer-skeletons work.
    await Future.delayed(const Duration(milliseconds: 400));
    final result = await _getEvents(const GetEventsParams());
    result.fold(
      (failure) => emit(EventsError(_messageFor(failure))),
      (page) => emit(EventsLoaded(page.events, nextCursor: page.nextCursor)),
    );
  }

  Future<void> _onLoadMoreEvents(
    LoadMoreEvents event,
    Emitter<EventsState> emit,
  ) async {
    final current = state;
    if (current is! EventsLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));
    final result = await _getEvents(GetEventsParams(cursor: current.nextCursor));
    result.fold(
      (_) {
        // On load-more failure, keep the user's existing list and stop the
        // spinner. They can scroll back up and down to retry. We deliberately
        // do not drop into EventsError since the current page is still useful.
        emit(current.copyWith(isLoadingMore: false));
      },
      (page) => emit(current.copyWith(
        events: [...current.events, ...page.events],
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        isLoadingMore: false,
      )),
    );
  }

  void _onSetDiscoveryFilter(
    SetDiscoveryFilter event,
    Emitter<EventsState> emit,
  ) {
    final s = state;
    if (s is EventsLoaded) emit(s.copyWith(filter: event.filter));
  }

  void _onSetCategoryFilter(
    SetCategoryFilter event,
    Emitter<EventsState> emit,
  ) {
    final s = state;
    if (s is EventsLoaded) {
      emit(s.copyWith(
        category: event.category,
        clearCategory: event.category == null,
      ));
    }
  }

  /// Translate a Failure to the string the existing EventsError carries.
  /// Keeps the UI surface identical during the migration.
  String _messageFor(Failure f) => switch (f) {
        NetworkFailure() => 'No internet. Pull to retry.',
        AuthFailure() => 'Please sign in to continue.',
        NotFoundFailure() => 'Nothing to show here yet.',
        ValidationFailure() => f.message,
        ServerFailure() => 'Server hiccup. Try again in a moment.',
        CacheFailure() => f.message,
        UnknownFailure() => 'Something went wrong.',
      };
}
