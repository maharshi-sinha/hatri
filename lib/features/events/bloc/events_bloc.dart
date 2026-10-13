import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/event_repository.dart';
import 'events_event.dart';
import 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventRepository repository;

  EventsBloc({required this.repository}) : super(EventsInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadMoreEvents>(_onLoadMoreEvents);
    on<SetDiscoveryFilter>(_onSetDiscoveryFilter);
    on<SetCategoryFilter>(_onSetCategoryFilter);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final page = await repository.getEvents();
      emit(EventsLoaded(page.events, nextCursor: page.nextCursor));
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreEvents(
    LoadMoreEvents event,
    Emitter<EventsState> emit,
  ) async {
    final current = state;
    if (current is! EventsLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;
    emit(current.copyWith(isLoadingMore: true));
    try {
      final page = await repository.getEvents(cursor: current.nextCursor);
      emit(current.copyWith(
        events: [...current.events, ...page.events],
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        isLoadingMore: false,
      ));
    } catch (_) {
      // On load-more failure, keep the user's existing list and stop the
      // spinner. They can scroll back up and down to retry. We deliberately
      // don't drop them into an EventsError state since the current page is
      // still useful.
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  void _onSetDiscoveryFilter(SetDiscoveryFilter event, Emitter<EventsState> emit) {
    final s = state;
    if (s is EventsLoaded) emit(s.copyWith(filter: event.filter));
  }

  void _onSetCategoryFilter(SetCategoryFilter event, Emitter<EventsState> emit) {
    final s = state;
    if (s is EventsLoaded) {
      emit(s.copyWith(category: event.category, clearCategory: event.category == null));
    }
  }
}
