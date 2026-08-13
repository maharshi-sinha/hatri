import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/event_repository.dart';
import 'events_event.dart';
import 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventRepository repository;

  EventsBloc({required this.repository}) : super(EventsInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<SetDiscoveryFilter>(_onSetDiscoveryFilter);
    on<SetCategoryFilter>(_onSetCategoryFilter);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final events = await repository.getEvents();
      emit(EventsLoaded(events));
    } catch (e) {
      emit(EventsError(e.toString()));
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
