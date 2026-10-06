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

/// A purchasable ticket tier for a paid event.
class TicketTier {
  final String id;
  final String name; // "EARLY BIRD"
  final int priceRupees;
  final String? perk; // "First 100 only" / "Includes free tote" etc.
  final bool isPopular; // highlights the tier in the picker
  final bool soldOut;

  const TicketTier({
    required this.id,
    required this.name,
    required this.priceRupees,
    this.perk,
    this.isPopular = false,
    this.soldOut = false,
  });
}

class Event {
  final String id;
  final String slug;
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

  // Rupee price (paid events). null → falls back to isFree/paid label.
  final int? priceRupees;

  // Capacity — null means unlimited. Set via organizer dashboard.
  final int? capacity;
  final int ticketCount;

  // Purchasable tiers for paid events. null/empty → single-tier fallback.
  final List<TicketTier> tiers;

  Event({
    required this.id,
    this.slug = '',
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
    this.priceRupees,
    this.tiers = const [],
    this.capacity,
    this.ticketCount = 0,
  });

  bool get isSoldOut => capacity != null && ticketCount >= capacity!;

  /// Label used in bottom CTA — "FREE", "₹250", or "PAID" fallback.
  String get priceLabel {
    if (isFree) return 'FREE';
    if (priceRupees != null) return '₹$priceRupees';
    return 'PAID';
  }

  /// Label for the "FROM" pill on event details. For tiered paid events it
  /// shows the cheapest available tier price so users see the true entry
  /// point, not whatever the fallback [priceRupees] happens to be.
  String get startingPriceLabel {
    if (isFree) return 'FREE';
    if (tiers.isNotEmpty) {
      final available = tiers.where((t) => !t.soldOut).toList();
      final pool = available.isNotEmpty ? available : tiers;
      final min = pool.map((t) => t.priceRupees).reduce((a, b) => a < b ? a : b);
      return '₹$min';
    }
    if (priceRupees != null) return '₹$priceRupees';
    return 'PAID';
  }
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

/// A community's lifecycle stage. Dormant = seed placeholder waiting for a host.
enum CommunityStatus { active, dormant }

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
  final String? hostId;         // primary host — links to CreatorProfile
  final List<String> coHostIds; // co-hosts — up to 3
  final String? nextEventId;    // links to Event
  final String? location;
  final List<Attendee> memberAvatars;

  // ─── Scene model (Community v3) ───────────────────────────────────────
  final HostedWeekly? hostedWeekly;          // the anchor "we meet Sundays at 6"
  final List<String> upcomingEventIds;       // events tied to this community
  final List<WallPhoto> wallPhotos;          // memory wall (auto-populated)
  final CommunityDrop? weeklyDrop;           // host's editorial note this week
  final bool chatterEnabled;                 // host toggles the light chat on/off
  final List<ChatterMessage> chatter;        // rolling stream, auto-purge 7d

  // ─── Vibe check — 3 quick tags describing personality ────────────────
  final List<String> vibeTags;               // e.g. ["🌅 morning people", "☕ chai first"]

  // ─── First-timer guide — kills solo-attend anxiety ───────────────────
  final FirstTimerGuide? firstTimerGuide;

  // ─── Member vibes — one-liner testimonials, Airbnb-style ─────────────
  final List<MemberVibe> memberVibes;

  // ─── Scene stats — proof of aliveness ────────────────────────────────
  final int eventsThisMonth;                 // "12 events this month"
  final double? rating;                      // 4.8
  final int reviewCount;                     // 146
  final int newMembersThisWeek;              // "↑ 8 new this week"

  // ─── Dormant scenes (cold-start) ──────────────────────────────────────
  final CommunityStatus status;              // active OR dormant
  final int interestedCount;                 // how many users have signalled interest (dormant only)

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
    this.coHostIds = const [],
    this.nextEventId,
    this.location,
    this.memberAvatars = const [],
    this.hostedWeekly,
    this.upcomingEventIds = const [],
    this.wallPhotos = const [],
    this.weeklyDrop,
    this.chatterEnabled = false,
    this.chatter = const [],
    this.vibeTags = const [],
    this.firstTimerGuide,
    this.memberVibes = const [],
    this.eventsThisMonth = 0,
    this.rating,
    this.reviewCount = 0,
    this.newMembersThisWeek = 0,
    this.status = CommunityStatus.active,
    this.interestedCount = 0,
  });

  bool get isDormant => status == CommunityStatus.dormant;
}

/// First-timer guide — what to expect, what to bring, solo-friendly signal.
/// Reduces the "am I going to feel weird walking in alone?" barrier.
class FirstTimerGuide {
  final List<String> whatToExpect;    // 3-5 short bullets
  final String dressVibe;              // "casual · whatever you want"
  final List<String> whatToBring;      // ["water bottle", "camera if you have"]
  final bool soloFriendly;             // yes/no explicit
  final int soloLastTime;              // "7 people came solo last week"

  const FirstTimerGuide({
    required this.whatToExpect,
    this.dressVibe = 'casual · whatever you want',
    this.whatToBring = const [],
    this.soloFriendly = true,
    this.soloLastTime = 0,
  });
}

/// One-line member testimonial for the scene page. Airbnb-review meets BeReal.
class MemberVibe {
  final String quote;
  final String byName;
  final String? byAvatarUrl;
  const MemberVibe({
    required this.quote,
    required this.byName,
    this.byAvatarUrl,
  });
}

/// The community's signature recurring event — the "we meet on X" anchor.
class HostedWeekly {
  final String dayLabel;   // "SUNDAYS", "FRIDAY NIGHTS", "1ST SUNDAY OF MONTH"
  final String timeLabel;  // "6:00 AM", "9:00 PM"
  final String venueLabel; // "MARINE DRIVE, TELIBANDHA"
  final String description;// short line, "morning run + chai after"
  final String? nextInstanceEventId; // event id for THIS coming instance

  const HostedWeekly({
    required this.dayLabel,
    required this.timeLabel,
    required this.venueLabel,
    this.description = '',
    this.nextInstanceEventId,
  });
}

/// A photo shown on a community's Memory Wall.
/// Sourced from post-event moments (BeReal-style drops) or host uploads.
class WallPhoto {
  final String id;
  final String photoUrl;
  final DateTime attendedAt;
  final String eventTitle;      // "Sunday Run · Aug 17"
  final String byUserName;      // "Ravi"
  final String? byUserAvatarUrl;
  final String? caption;         // "golden hour hit different"
  final int likes;               // 12
  final bool youAreIn;           // for the "just you" filter — mock

  const WallPhoto({
    required this.id,
    required this.photoUrl,
    required this.attendedAt,
    required this.eventTitle,
    required this.byUserName,
    this.byUserAvatarUrl,
    this.caption,
    this.likes = 0,
    this.youAreIn = false,
  });
}

/// A single message in a community's rolling chatter stream.
class ChatterMessage {
  final String id;
  final String byUserName;
  final String? byUserAvatarUrl;
  final String text;
  final DateTime at;
  final bool isMe;

  const ChatterMessage({
    required this.id,
    required this.byUserName,
    required this.text,
    required this.at,
    this.byUserAvatarUrl,
    this.isMe = false,
  });
}

/// A host-published weekly editorial note. One per community per week.
class CommunityDrop {
  final String id;
  final String hostName;
  final String? hostAvatarUrl;
  final DateTime publishedAt;
  final String headline;            // "THIS WEEK: PURANI BASTI @ GOLDEN HOUR"
  final String body;                // 1-3 short sentences
  final List<String> linkedEventIds;

  const CommunityDrop({
    required this.id,
    required this.hostName,
    required this.publishedAt,
    required this.headline,
    required this.body,
    this.hostAvatarUrl,
    this.linkedEventIds = const [],
  });
}

/// In-memory joined-communities set for the session.
class AppCommunities {
  AppCommunities._();
  static final Set<String> joinedIds = <String>{};
}

class User {
  String name;
  List<String> interests;
  String bio;
  String profileImage;
  String email;
  bool emailVerified;
  String instagram; // "@handle" (no url)
  String x;         // "@handle" (no url)
  String website;   // full URL
  String birthday;
  String gender;
  String energy; // 'Introvert' | 'Extrovert' | 'Ambivert'

  User({
    this.name = '',
    this.interests = const [],
    this.bio = '',
    this.profileImage = '',
    this.email = '',
    this.emailVerified = false,
    this.instagram = '',
    this.x = '',
    this.website = '',
    this.birthday = '',
    this.gender = '',
    this.energy = '',
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
