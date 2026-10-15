import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';
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
  /// Opaque cursor for the next page. Null means we've reached the end.
  final String? nextCursor;
  /// True while a LoadMoreEvents request is in flight. Used by the UI to
  /// render a trailing shimmer / spinner.
  final bool isLoadingMore;

  const EventsLoaded(
    this.events, {
    this.filter = DiscoveryFilter.all,
    this.category,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  EventsLoaded copyWith({
    List<Event>? events,
    DiscoveryFilter? filter,
    EventCategory? category,
    bool clearCategory = false,
    String? nextCursor,
    bool clearCursor = false,
    bool? isLoadingMore,
  }) {
    return EventsLoaded(
      events ?? this.events,
      filter: filter ?? this.filter,
      category: clearCategory ? null : (category ?? this.category),
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
