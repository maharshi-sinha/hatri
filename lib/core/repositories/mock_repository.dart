import '../models/models.dart';
import 'event_repository.dart';
import 'community_repository.dart';
import 'creator_repository.dart';

/// Central mock data store. All screens read through the repositories below;
/// swapping to a real backend later is a one-file change per repository.
class MockRepository {
  // ---------------- Attendees (used by "who's going") ----------------
  static const _attendees = <Attendee>[
    Attendee(id: 'u1', name: 'Priya', avatarUrl: 'https://i.pravatar.cc/100?img=47'),
    Attendee(id: 'u2', name: 'Rohan', avatarUrl: 'https://i.pravatar.cc/100?img=12'),
    Attendee(id: 'u3', name: 'Ananya', avatarUrl: 'https://i.pravatar.cc/100?img=32'),
    Attendee(id: 'u4', name: 'Kabir', avatarUrl: 'https://i.pravatar.cc/100?img=15'),
    Attendee(id: 'u5', name: 'Ishita', avatarUrl: 'https://i.pravatar.cc/100?img=45'),
    Attendee(id: 'u6', name: 'Arjun', avatarUrl: 'https://i.pravatar.cc/100?img=8'),
    Attendee(id: 'u7', name: 'Meera', avatarUrl: 'https://i.pravatar.cc/100?img=41'),
    Attendee(id: 'u8', name: 'Dev', avatarUrl: 'https://i.pravatar.cc/100?img=13'),
  ];

  // ---------------- Creators / Organizers ----------------
  static final List<CreatorProfile> mockCreators = [
    CreatorProfile(
      id: 'cr1',
      name: 'NIT Raipur',
      handle: '@nitraipur',
      bio: 'Central India\'s tech + culture powerhouse. Home of Eclectika.',
      category: 'College',
      avatarUrl: 'https://i.pravatar.cc/200?img=68',
      isVerified: true,
      rating: 4.8,
      followerCount: 12400,
      upcomingEventIds: ['e1'],
    ),
    CreatorProfile(
      id: 'cr2',
      name: 'The Poetry Club',
      handle: '@poetryclubcg',
      bio: 'Weekly open mics · poetry · spoken word · Raipur only.',
      category: 'Community',
      avatarUrl: 'https://i.pravatar.cc/200?img=32',
      isVerified: true,
      rating: 4.6,
      followerCount: 2340,
      upcomingEventIds: ['e2'],
    ),
    CreatorProfile(
      id: 'cr3',
      name: 'Aditi Sharma',
      handle: '@aditisings',
      bio: 'Indie singer-songwriter. Bilingual (Hindi/English). Loves cafes.',
      category: 'Performer',
      avatarUrl: 'https://i.pravatar.cc/200?img=45',
      isVerified: false,
      rating: 4.9,
      followerCount: 3820,
    ),
    CreatorProfile(
      id: 'cr4',
      name: 'Kabir Verma',
      handle: '@kabirshoots',
      bio: 'Event photographer · portraits · street. Available in Raipur.',
      category: 'Photographer',
      avatarUrl: 'https://i.pravatar.cc/200?img=15',
      isVerified: true,
      rating: 4.7,
      followerCount: 1580,
    ),
    CreatorProfile(
      id: 'cr5',
      name: 'DJ Mira',
      handle: '@djmira',
      bio: 'House · Techno · Bollywood mash. Resident @ Circuit.',
      category: 'DJ',
      avatarUrl: 'https://i.pravatar.cc/200?img=41',
      isVerified: false,
      rating: 4.5,
      followerCount: 2140,
    ),
    CreatorProfile(
      id: 'cr6',
      name: 'Raipur Organics',
      handle: '@raipurorganics',
      bio: 'Weekly farmers market · organic produce · local artisans.',
      category: 'Organizer',
      avatarUrl: 'https://i.pravatar.cc/200?img=25',
      isVerified: true,
      rating: 4.4,
      followerCount: 890,
      upcomingEventIds: ['e3'],
    ),
  ];

  // ---------------- Events ----------------
  static final List<Event> mockEvents = [
    Event(
      id: 'e1',
      title: 'Eclectika 2026',
      description:
          'The biggest cultural fest in Central India. Three days of music, art, hackathons and madness. 50+ college teams from across India.',
      coverUrl: 'https://picsum.photos/seed/hatri-fest/800/500',
      organizer: 'NIT Raipur',
      organizerId: 'cr1',
      date: DateTime.now().add(const Duration(days: 2)),
      time: '6:00 PM',
      venue: 'NIT Campus, Raipur',
      category: EventCategory.fest,
      rsvpCount: 4500,
      interestedCount: 6200,
      colorHex: '#FF2E9A',
      isFree: false,
      isHot: true,
      isTrending: true,
      isWeekend: true,
      lat: 21.2497,
      lng: 81.6047,
      isSafeVenue: true,
      lineup: ['cr3', 'cr5'],
      attendees: [_attendees[0], _attendees[1], _attendees[2], _attendees[3]],
    ),
    Event(
      id: 'e2',
      title: 'Neon Nights: Open Mic',
      description:
          'A platform for poets, musicians and storytellers to share their art under neon lights.',
      coverUrl:
          'https://images.unsplash.com/photo-1478147427282-58a87a120781?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      organizer: 'The Poetry Club',
      organizerId: 'cr2',
      date: DateTime.now().add(const Duration(days: 1)),
      time: '8:00 PM',
      venue: 'Mocha Cafe, Civil Lines',
      category: EventCategory.openMic,
      rsvpCount: 120,
      interestedCount: 280,
      colorHex: '#CFFF04',
      isHot: true,
      isTrending: false,
      isWeekend: false,
      lat: 21.2381,
      lng: 81.6337,
      isSafeVenue: true,
      lineup: ['cr3'],
      attendees: [_attendees[2], _attendees[4], _attendees[5]],
    ),
    Event(
      id: 'e3',
      title: 'Sunday Farmers Market',
      description: 'Fresh organic produce, local crafts and homemade baked goods.',
      coverUrl:
          'https://images.unsplash.com/photo-1533900298318-6b8da08a523e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      organizer: 'Raipur Organics',
      organizerId: 'cr6',
      date: DateTime.now().add(const Duration(days: 3)),
      time: '7:00 AM',
      venue: 'Marine Drive, Telibandha',
      category: EventCategory.market,
      rsvpCount: 340,
      interestedCount: 720,
      colorHex: '#FF7A00',
      isWeekend: true,
      isNewlyAdded: true,
      lat: 21.2312,
      lng: 81.6602,
      isSafeVenue: true,
      attendees: [_attendees[1], _attendees[6], _attendees[7]],
    ),
    Event(
      id: 'e4',
      title: 'Startups & Coffee',
      description: 'A casual meetup for founders, investors and tech enthusiasts.',
      coverUrl:
          'https://images.unsplash.com/photo-1556761175-5973dc0f32d7?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      organizer: 'Raipur Startups',
      date: DateTime.now().add(const Duration(days: 4)),
      time: '5:00 PM',
      venue: 'Starbucks, Magneto Mall',
      category: EventCategory.meetup,
      rsvpCount: 85,
      interestedCount: 210,
      colorHex: '#2D7DFF',
      isFree: false,
      isNewlyAdded: true,
      lat: 21.2205,
      lng: 81.6511,
      attendees: [_attendees[5], _attendees[7]],
    ),
    Event(
      id: 'e5',
      title: 'Circuit Techno Night',
      description: 'Underground techno till late. DJ Mira on decks.',
      coverUrl: 'https://picsum.photos/seed/hatri-club/800/500',
      organizer: 'Circuit Club',
      date: DateTime.now().add(const Duration(days: 2, hours: 22)),
      time: '10:00 PM',
      venue: 'Circuit, VIP Road',
      category: EventCategory.clubNight,
      rsvpCount: 210,
      interestedCount: 460,
      colorHex: '#5D00FF',
      isFree: false,
      isHot: true,
      isTrending: true,
      isWeekend: true,
      lat: 21.2266,
      lng: 81.6820,
      isSafeVenue: true,
      lineup: ['cr5'],
      attendees: [_attendees[0], _attendees[4], _attendees[6]],
    ),
    Event(
      id: 'e6',
      title: 'Photo Walk: Old Raipur',
      description: 'A morning photo walk through Purani Basti. All levels welcome.',
      coverUrl:
          'https://images.unsplash.com/photo-1516961642265-531546e84af2?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      organizer: 'Kabir Verma',
      organizerId: 'cr4',
      date: DateTime.now().add(const Duration(days: 5)),
      time: '6:30 AM',
      venue: 'Purani Basti, Raipur',
      category: EventCategory.workshop,
      rsvpCount: 42,
      interestedCount: 140,
      colorHex: '#FFD400',
      isNewlyAdded: true,
      lat: 21.2321,
      lng: 81.6296,
      attendees: [_attendees[3], _attendees[7]],
    ),
  ];

  // ---------------- Communities (meetup-first taxonomy) ----------------
  // Small helper: pick 4 sample attendees for the members preview.
  static List<Attendee> _sample(List<int> idxs) =>
      [for (final i in idxs) _attendees[i]];

  static final List<Community> mockCommunities = [
    // 🎨 INTEREST
    Community(
      id: 'c1',
      name: 'Raipur Photography Club',
      description: 'For anyone who loves capturing moments. Photo walks + workshops.',
      coverUrl: 'https://picsum.photos/seed/hatri-photoclub/800/500',
      memberCount: 1240,
      emoji: '📸',
      type: CommunityType.interest,
      hostId: 'cr4',
      nextEventId: 'e6',
      location: 'Raipur',
      memberAvatars: _sample([0, 3, 5, 7]),
    ),
    Community(
      id: 'c2',
      name: 'Coffee Lovers Raipur',
      description: 'Best cafes and brews in town. Serious coffee discussions only.',
      coverUrl: 'https://picsum.photos/seed/hatri-coffee/800/500',
      memberCount: 890,
      emoji: '☕',
      type: CommunityType.interest,
      location: 'Raipur',
      memberAvatars: _sample([1, 2, 4, 6]),
    ),
    Community(
      id: 'c3',
      name: 'CG Gamers',
      description: 'PC, Console, Mobile — all gamers welcome. Tournaments every month.',
      coverUrl: 'https://picsum.photos/seed/hatri-gamers/800/500',
      memberCount: 3200,
      emoji: '🎮',
      type: CommunityType.interest,
      location: 'Chhattisgarh',
      memberAvatars: _sample([2, 5, 7, 0]),
    ),
    Community(
      id: 'c4',
      name: 'Raipur Runners',
      description: 'Morning runs at Marine Drive and Naya Raipur.',
      coverUrl: 'https://picsum.photos/seed/hatri-runners/800/500',
      memberCount: 560,
      emoji: '🏃‍♂️',
      type: CommunityType.interest,
      location: 'Marine Drive',
      memberAvatars: _sample([3, 6, 1, 4]),
    ),

    // 📍 NEIGHBORHOOD
    Community(
      id: 'c5',
      name: 'Civil Lines Nightlife',
      description: 'The Civil Lines crew — cafes, open mics, weekend spots.',
      coverUrl: 'https://picsum.photos/seed/hatri-civillines/800/500',
      memberCount: 720,
      emoji: '🍸',
      type: CommunityType.neighborhood,
      nextEventId: 'e2',
      location: 'Civil Lines',
      memberAvatars: _sample([0, 4, 6, 2]),
    ),
    Community(
      id: 'c6',
      name: 'Telibandha Weekends',
      description: 'Marine Drive walks, farmers markets, sunset chai spots.',
      coverUrl: 'https://picsum.photos/seed/hatri-telibandha/800/500',
      memberCount: 480,
      emoji: '🌅',
      type: CommunityType.neighborhood,
      nextEventId: 'e3',
      location: 'Telibandha',
      memberAvatars: _sample([1, 3, 5, 7]),
    ),
    Community(
      id: 'c7',
      name: 'VIP Road Foodies',
      description: 'Best food finds along VIP Road. Weekly food crawls.',
      coverUrl: 'https://picsum.photos/seed/hatri-vip/800/500',
      memberCount: 340,
      emoji: '🍽️',
      type: CommunityType.neighborhood,
      location: 'VIP Road',
      memberAvatars: _sample([2, 5, 0, 6]),
    ),

    // 🎓 COLLEGE
    Community(
      id: 'c8',
      name: 'NIT Raipur Community',
      description: 'The unofficial home of every NITian. Fests, hacks, hangouts.',
      coverUrl: 'https://picsum.photos/seed/hatri-nit/800/500',
      memberCount: 4200,
      emoji: '🎓',
      type: CommunityType.college,
      hostId: 'cr1',
      nextEventId: 'e1',
      location: 'NIT Raipur',
      memberAvatars: _sample([1, 2, 4, 7]),
    ),
    Community(
      id: 'c9',
      name: 'IIT Bhilai Circle',
      description: 'IIT Bhilai students & alumni. Talks, projects, chai runs.',
      coverUrl: 'https://picsum.photos/seed/hatri-iitbhilai/800/500',
      memberCount: 1100,
      emoji: '⚙️',
      type: CommunityType.college,
      location: 'IIT Bhilai',
      memberAvatars: _sample([3, 0, 6, 5]),
    ),

    // 🎤 CREATOR HUBS
    Community(
      id: 'c10',
      name: 'Aditi Sings · Fans',
      description: 'Indie music lovers who show up to Aditi\'s cafe sets.',
      coverUrl: 'https://picsum.photos/seed/hatri-aditi/800/500',
      memberCount: 620,
      emoji: '🎤',
      type: CommunityType.creator,
      hostId: 'cr3',
      nextEventId: 'e2',
      location: 'Raipur',
      memberAvatars: _sample([4, 1, 7, 3]),
    ),
    Community(
      id: 'c11',
      name: 'DJ Mira · Crew',
      description: 'Late-night techno crowd. Circuit regulars welcome.',
      coverUrl: 'https://picsum.photos/seed/hatri-djmira/800/500',
      memberCount: 890,
      emoji: '🎧',
      type: CommunityType.creator,
      hostId: 'cr5',
      nextEventId: 'e5',
      location: 'Circuit Club',
      memberAvatars: _sample([2, 6, 0, 4]),
    ),
  ];
}

class MockEventRepository implements EventRepository {
  @override
  Future<List<Event>> getEvents() async => MockRepository.mockEvents;
}

class MockCommunityRepository implements CommunityRepository {
  @override
  Future<List<Community>> getCommunities() async => MockRepository.mockCommunities;
}

class MockCreatorRepository implements CreatorRepository {
  @override
  Future<List<CreatorProfile>> getCreators() async => MockRepository.mockCreators;

  @override
  Future<CreatorProfile?> getById(String id) async {
    try {
      return MockRepository.mockCreators.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
