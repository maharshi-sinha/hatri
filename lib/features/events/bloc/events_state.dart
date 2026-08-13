import 'package:equatable/equatable.dart';
import '../../../core/models/models.dart';
import 'events_event.dart';

abstract class EventsState extends Equatable {
  const EventsState();
  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Event> events;
  final DiscoveryFilter filter;
  final EventCategory? category;

  const EventsLoaded(
    this.events, {
    this.filter = DiscoveryFilter.all,
    this.category,
  });

  EventsLoaded copyWith({
    List<Event>? events,
    DiscoveryFilter? filter,
    EventCategory? category,
    bool clearCategory = false,
  }) {
    return EventsLoaded(
      events ?? this.events,
      filter: filter ?? this.filter,
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  /// Compute the filtered subset for display.
  List<Event> get filtered {
    final now = DateTime.now();
    Iterable<Event> out = events;

    switch (filter) {
      case DiscoveryFilter.all:
        break;
      case DiscoveryFilter.tonight:
        out = out.where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day);
        break;
      case DiscoveryFilter.weekend:
        out = out.where((e) => e.isWeekend ||
            e.date.weekday == DateTime.saturday ||
            e.date.weekday == DateTime.sunday);
        break;
      case DiscoveryFilter.free:
        out = out.where((e) => e.isFree);
        break;
      case DiscoveryFilter.nearMe:
        // Prototype: "Near Me" = anything with coords in the Raipur bbox.
        out = out.where((e) => e.lat != null && e.lng != null);
        break;
    }

    if (category != null) {
      out = out.where((e) => e.category == category);
    }

    return out.toList();
  }

  @override
  List<Object?> get props => [events, filter, category];
}

class EventsError extends EventsState {
  final String message;
  const EventsError(this.message);
  @override
  List<Object?> get props => [message];
}
