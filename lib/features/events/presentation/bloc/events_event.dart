import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();
  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventsEvent {}

/// Append the next page of events to the current list. No-op if we're
/// already fetching more or there's no `nextCursor` left.
class LoadMoreEvents extends EventsEvent {}

/// Set the active discovery filter (Tonight / Weekend / Free / Near Me / All).
class SetDiscoveryFilter extends EventsEvent {
  final DiscoveryFilter filter;
  const SetDiscoveryFilter(this.filter);
  @override
  List<Object?> get props => [filter];
}

/// Set the active category (null = all).
class SetCategoryFilter extends EventsEvent {
  final EventCategory? category;
  const SetCategoryFilter(this.category);
  @override
  List<Object?> get props => [category];
}

enum DiscoveryFilter { all, tonight, weekend, free, nearMe }

extension DiscoveryFilterX on DiscoveryFilter {
  String get label {
    switch (this) {
      case DiscoveryFilter.all:
        return 'All';
      case DiscoveryFilter.tonight:
        return 'Tonight';
      case DiscoveryFilter.weekend:
        return 'Weekend';
      case DiscoveryFilter.free:
        return 'Free';
      case DiscoveryFilter.nearMe:
        return 'Near Me';
    }
  }
}
