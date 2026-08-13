enum EventCategory { fest, openMic, clubNight, market, workshop, meetup, other }

extension EventCategoryX on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.fest:
        return 'Fest';
      case EventCategory.openMic:
        return 'Open Mic';
      case EventCategory.clubNight:
        return 'Club Night';
      case EventCategory.market:
        return 'Market';
      case EventCategory.workshop:
        return 'Workshop';
      case EventCategory.meetup:
        return 'Meetup';
      case EventCategory.other:
        return 'Other';
    }
  }

  /// Palette hex per category — keeps the visual language coherent.
  String get colorHex {
    switch (this) {
      case EventCategory.fest:
        return '#FF2E9A'; // fuchsia
      case EventCategory.openMic:
        return '#CFFF04'; // lime
      case EventCategory.clubNight:
        return '#5D00FF'; // indigo
      case EventCategory.market:
        return '#FF7A00'; // orange
      case EventCategory.workshop:
        return '#FFD400'; // yellow
      case EventCategory.meetup:
        return '#2D7DFF'; // blue
      case EventCategory.other:
        return '#89849C';
    }
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final String organizer;
  final String? organizerId; // links to a CreatorProfile
  final DateTime date;
  final String time;
  final String venue;
  final EventCategory category;
  final int rsvpCount;
  final int interestedCount;
  final String colorHex;
  final bool isFree;

  // Discovery signals
  final bool isHot;
  final bool isTrending;
  final bool isWeekend;
  final bool isNewlyAdded;

  // Location for map view
  final double? lat;
  final double? lng;

  // Optional external maps link (e.g. https://maps.app.goo.gl/…)
  final String? mapsUrl;

  // Trust
  final bool isSafeVenue;

  // Creators performing / hosting — links to CreatorProfile ids
  final List<String> lineup;

  // Lightweight attendee sample for "who's going"
  final List<Attendee> attendees;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.organizer,
    this.organizerId,
    required this.date,
    required this.time,
    required this.venue,
    required this.category,
    required this.rsvpCount,
    this.interestedCount = 0,
    this.colorHex = '#FF2E9A',
    this.isFree = true,
    this.isHot = false,
    this.isTrending = false,
    this.isWeekend = false,
    this.isNewlyAdded = false,
    this.lat,
    this.lng,
    this.mapsUrl,
    this.isSafeVenue = false,
    this.lineup = const [],
    this.attendees = const [],
  });
}

enum CommunityType { neighborhood, college, interest, creator }

extension CommunityTypeX on CommunityType {
  String get label {
    switch (this) {
      case CommunityType.neighborhood:
        return 'Neighborhood';
      case CommunityType.college:
        return 'College';
      case CommunityType.interest:
        return 'Interest';
      case CommunityType.creator:
        return 'Creator hub';
    }
  }

  /// Accent color per type — keeps the taxonomy visually consistent.
  String get colorHex {
    switch (this) {
      case CommunityType.neighborhood:
        return '#5D00FF'; // indigo
      case CommunityType.college:
        return '#FF7A00'; // orange
      case CommunityType.interest:
        return '#FF2E9A'; // fuchsia
      case CommunityType.creator:
        return '#CFFF04'; // lime
    }
  }
}

class Community {
  final String id;
  final String name;
  final String description;
  final String coverUrl;
  final int memberCount;
  final String emoji;
  final String colorHex;

  // v2 fields (meetup-first taxonomy)
  final CommunityType type;
  final String? hostId;         // links to CreatorProfile
  final String? nextEventId;    // links to Event
  final String? location;       // "Civil Lines", "NIT Raipur", etc.
  final List<Attendee> memberAvatars;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.memberCount,
    this.emoji = '🌟',
    this.colorHex = '#FF2E9A',
    this.type = CommunityType.interest,
    this.hostId,
    this.nextEventId,
    this.location,
    this.memberAvatars = const [],
  });
}

/// In-memory joined-communities set for the session.
class AppCommunities {
  AppCommunities._();
  static final Set<String> joinedIds = <String>{};
}

class Post {
  final String id;
  final String communityId;
  final String authorName;
  final String content;
  final String timeAgo;
  final int likesCount;

  Post({
    required this.id,
    required this.communityId,
    required this.authorName,
    required this.content,
    required this.timeAgo,
    required this.likesCount,
  });
}

class User {
  String name;
  List<String> interests;
  String bio;
  String profileImage;

  User({
    this.name = '',
    this.interests = const [],
    this.bio = '',
    this.profileImage = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
  });
}

/// Global mutable state for MVP onboarding flow.
final currentUser = User();

/// Public profile for an organizer OR a performer / creator.
/// One primitive powers both — the marketplace-supply seed.
class CreatorProfile {
  final String id;
  final String name;
  final String handle;
  final String bio;
  final String category; // "Photographer", "DJ", "Cafe", ...
  final String avatarUrl;
  final bool isVerified;
  final double rating;
  final int followerCount;
  final List<String> upcomingEventIds;
  final List<String> pastEventIds;

  CreatorProfile({
    required this.id,
    required this.name,
    required this.handle,
    required this.bio,
    required this.category,
    required this.avatarUrl,
    this.isVerified = false,
    this.rating = 0,
    this.followerCount = 0,
    this.upcomingEventIds = const [],
    this.pastEventIds = const [],
  });
}

/// Lightweight attendee — for "who's going" faces.
class Attendee {
  final String id;
  final String name;
  final String avatarUrl;

  const Attendee({required this.id, required this.name, required this.avatarUrl});
}

/// Group plan around an event.
class Plan {
  final String id;
  final String eventId;
  final String hostId;
  final List<String> invitedIds;
  final List<String> confirmedIds;
  final String? note;
  final DateTime createdAt;

  Plan({
    required this.id,
    required this.eventId,
    required this.hostId,
    this.invitedIds = const [],
    this.confirmedIds = const [],
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// In-memory plan store. Persists across screens for the session; resets on
/// app restart. A real backend swaps this out later.
class AppPlans {
  AppPlans._();
  static final List<Plan> mine = [];
}
