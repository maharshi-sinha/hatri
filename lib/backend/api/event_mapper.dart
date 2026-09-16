import 'package:intl/intl.dart';

import '../../core/models/models.dart';
import '../models/event_models.dart';

/// Converts backend event shapes to the app's domain `Event` model.
///
/// The two shapes diverge deliberately: API models are strictly what the
/// server sends, domain models carry UI-only affordances (discovery flags,
/// price label, etc). This is the one place that bridges them.
class EventMapper {
  static Event fromCard(ApiEventCard c) {
    final priceR = c.priceMin ~/ 100; // paise → rupees
    return Event(
      id: c.id,
      title: c.title,
      description: '', // detail-only field
      coverUrl: c.coverUrl ?? _fallbackCover(c.category),
      organizer: 'Hatri', // filled from detail; card doesn't carry organizer
      date: c.startAt,
      time: DateFormat('h:mm a').format(c.startAt),
      venue: c.venueName ?? '',
      category: _mapCategory(c.category),
      rsvpCount: c.saves,
      colorHex: '#FF2E9A',
      isFree: c.priceMin == 0,
      isHot: c.popularityScore >= 150,
      isTrending: c.popularityScore >= 100,
      isWeekend: _isWeekend(c.startAt),
      isNewlyAdded: DateTime.now().difference(c.startAt).inDays.abs() <= 7,
      priceRupees: c.priceMin == 0 ? null : priceR,
    );
  }

  static Event fromDetail(ApiEventDetail d) {
    final priceR = d.priceMin ~/ 100;
    return Event(
      id: d.id,
      title: d.title,
      description: d.description ?? '',
      coverUrl: d.coverUrl ?? _fallbackCover(d.category),
      organizer: d.maker?.name ?? 'Hatri',
      organizerId: d.maker?.id,
      date: d.startAt,
      time: DateFormat('h:mm a').format(d.startAt),
      venue: d.venueName ?? '',
      category: _mapCategory(d.category),
      rsvpCount: d.saves,
      interestedCount: d.views,
      colorHex: '#FF2E9A',
      isFree: d.priceMin == 0,
      isHot: d.popularityScore >= 150,
      isTrending: d.popularityScore >= 100,
      isWeekend: _isWeekend(d.startAt),
      isNewlyAdded: DateTime.now().difference(d.createdAt).inDays.abs() <= 7,
      lat: d.latitude,
      lng: d.longitude,
      priceRupees: d.priceMin == 0 ? null : priceR,
      capacity: d.capacity,
      ticketCount: d.ticketCount,
    );
  }

  static EventCategory _mapCategory(String s) {
    switch (s) {
      case 'OPEN_MIC':
        return EventCategory.openMic;
      case 'FESTIVAL':
      case 'COLLEGE_EVENT':
        return EventCategory.fest;
      case 'WORKSHOP':
        return EventCategory.workshop;
      case 'MEETUP':
      case 'COMMUNITY_MEETUP':
        return EventCategory.meetup;
      case 'MARKET':
        return EventCategory.market;
      case 'MUSIC':
        return EventCategory.clubNight;
      case 'EXHIBITION':
      case 'ACTIVITY':
      case 'GAMING':
      case 'WELLNESS':
      default:
        return EventCategory.other;
    }
  }

  static bool _isWeekend(DateTime d) =>
      d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

  /// When the backend hasn't set a cover, use a category-tinted stock image.
  /// Sprint 3c/uploads will replace this with real event covers.
  static String _fallbackCover(String category) {
    // A deterministic placeholder so the same event always looks the same.
    return 'https://picsum.photos/seed/${Uri.encodeComponent(category)}/800/1000';
  }
}
