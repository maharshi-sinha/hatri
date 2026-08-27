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
      priceRupees: 499,
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
      priceRupees: 250,
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
      priceRupees: 700,
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

  // Wall-photo builder — deterministic picsum seeds keep the visual stable.
  static WallPhoto _wall({
    required String id,
    required String seed,
    required int daysAgo,
    required String eventTitle,
    required int byIdx,
    String? caption,
    int likes = 0,
    bool youAreIn = false,
  }) =>
      WallPhoto(
        id: id,
        photoUrl: 'https://picsum.photos/seed/hatri-wall-$seed/700/700',
        attendedAt: DateTime.now().subtract(Duration(days: daysAgo)),
        eventTitle: eventTitle,
        byUserName: _attendees[byIdx].name,
        byUserAvatarUrl: _attendees[byIdx].avatarUrl,
        caption: caption,
        likes: likes,
        youAreIn: youAreIn,
      );

  // Bulk-generator for wall photos — pads out a scene's memory wall with
  // deterministic seeds so the grid feels populated (~20 photos each).
  static List<WallPhoto> _wallBulk({
    required String prefix,
    required int count,
    required String eventTitle,
    required int daysAgoStart,
    required List<int> byIdxRotation,
    List<String>? captions,
  }) {
    return [
      for (int i = 0; i < count; i++)
        _wall(
          id: '$prefix-$i',
          seed: '$prefix-$i',
          daysAgo: daysAgoStart + i,
          eventTitle: eventTitle,
          byIdx: byIdxRotation[i % byIdxRotation.length],
          caption: captions != null && captions.isNotEmpty
              ? captions[i % captions.length]
              : null,
          likes: (i * 7 + 5) % 40 + 3,
          youAreIn: i % 5 == 0,
        ),
    ];
  }

  // Chatter-message builder — assumes ordering by hours ago.
  static ChatterMessage _chat({
    required String id,
    required int byIdx,
    required String text,
    required int hoursAgo,
    bool isMe = false,
  }) =>
      ChatterMessage(
        id: id,
        byUserName: isMe ? 'you' : _attendees[byIdx].name,
        byUserAvatarUrl: _attendees[byIdx].avatarUrl,
        text: text,
        at: DateTime.now().subtract(Duration(hours: hoursAgo)),
        isMe: isMe,
      );

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
      coHostIds: const ['cr1'],
      nextEventId: 'e6',
      location: 'Raipur',
      memberAvatars: _sample([0, 3, 5, 7]),
      hostedWeekly: const HostedWeekly(
        dayLabel: 'SATURDAYS',
        timeLabel: '5:00 PM',
        venueLabel: 'ROTATING · PURANI BASTI THIS WEEK',
        description: 'golden hour shoot + chai after',
        nextInstanceEventId: 'e6',
      ),
      vibeTags: const ['🎞️ film first', '🌆 golden hour heads', '☕ chai crew'],
      eventsThisMonth: 4,
      rating: 4.9,
      reviewCount: 128,
      newMembersThisWeek: 12,
      firstTimerGuide: const FirstTimerGuide(
        whatToExpect: [
          "we meet at the venue 15 mins before, chai + intros",
          "2 hour shoot walk, all levels welcome",
          "post-shoot review at mocha, host buys chai",
        ],
        dressVibe: 'casual · comfortable shoes a must',
        whatToBring: [
          'any camera (phone works)',
          'a lens if you have (35mm or 50mm sweet)',
          'water bottle',
        ],
        soloFriendly: true,
        soloLastTime: 6,
      ),
      memberVibes: [
        MemberVibe(
          quote: 'my sundays finally have a plan.',
          byName: 'Aditi',
          byAvatarUrl: 'https://i.pravatar.cc/100?img=32',
        ),
        MemberVibe(
          quote: 'met 3 of my best friends here.',
          byName: 'Rohan',
          byAvatarUrl: 'https://i.pravatar.cc/100?img=12',
        ),
        MemberVibe(
          quote: 'ravi actually critiques your shots. love that.',
          byName: 'Meera',
          byAvatarUrl: 'https://i.pravatar.cc/100?img=41',
        ),
      ],
      upcomingEventIds: const ['e6'],
      wallPhotos: [
        ..._wallBulk(
          prefix: 'photoclub-cityscape',
          count: 8,
          eventTitle: 'Sunday Cityscape',
          daysAgoStart: 3,
          byIdxRotation: const [3, 0, 5, 7],
          captions: const [
            'golden hour hit different',
            "ravi's shot > everyone else",
            'test roll came out clean',
            'this cafe never disappoints',
          ],
        ),
        ..._wallBulk(
          prefix: 'photoclub-naya',
          count: 6,
          eventTitle: 'Naya Raipur Morning',
          daysAgoStart: 10,
          byIdxRotation: const [5, 7, 1, 3],
          captions: const ['6am but worth it', 'foggy morning magic', 'best light this year'],
        ),
        ..._wallBulk(
          prefix: 'photoclub-marine',
          count: 5,
          eventTitle: 'Marine Drive Sunset',
          daysAgoStart: 17,
          byIdxRotation: const [3, 5, 0, 6],
          captions: const ['sun setting = crew arriving', 'chai + camera', 'best sunset in town'],
        ),
      ],
      weeklyDrop: CommunityDrop(
        id: 'd1',
        hostName: 'Ravi',
        hostAvatarUrl: 'https://i.pravatar.cc/100?img=12',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        headline: 'THIS WEEK: PURANI BASTI @ GOLDEN HOUR',
        body: "Meeting at the Ghadi Chowk at 4:45pm sharp. Bring a wide lens if you have one. Chai after at Mocha, my treat for whoever brings the best shot.",
        linkedEventIds: const ['e6'],
      ),
      chatterEnabled: true,
      chatter: [
        _chat(id: 'ch1', byIdx: 2, text: 'weather looking clear for saturday?', hoursAgo: 4),
        _chat(id: 'ch2', byIdx: 5, text: 'yeah, sunset around 6:15', hoursAgo: 3),
        _chat(id: 'ch3', byIdx: 0, text: "i'll bring my 35mm", hoursAgo: 2),
        _chat(id: 'ch4', byIdx: 7, text: 'anyone driving from civil lines? need a lift 🙋', hoursAgo: 1),
      ],
    ),
    Community(
      id: 'c2',
      name: 'Chai Pe Charcha',
      description: 'slow sundays. long convos. cafe hopping. classic chai + cool crowd.',
      coverUrl: 'https://images.unsplash.com/photo-1516600164266-f3b8166ae679?w=800&q=80',
      memberCount: 890,
      emoji: '☕',
      type: CommunityType.interest,
      location: 'Raipur',
      memberAvatars: _sample([1, 2, 4, 6]),
      vibeTags: const ['☕ chai first', '📓 slow talkers', '🌿 cafe hoppers'],
      eventsThisMonth: 3,
      rating: 4.6,
      reviewCount: 89,
      newMembersThisWeek: 5,
      firstTimerGuide: const FirstTimerGuide(
        whatToExpect: [
          "different cafe every sunday, host picks",
          "no agenda, just long chats",
          "usually 2-3 hours, leave when you want",
        ],
        dressVibe: 'literally whatever',
        whatToBring: ['your appetite for chai'],
        soloFriendly: true,
        soloLastTime: 4,
      ),
      memberVibes: [
        MemberVibe(
          quote: "the only sunday plan i actually keep.",
          byName: 'Priya',
          byAvatarUrl: 'https://i.pravatar.cc/100?img=47',
        ),
        MemberVibe(
          quote: 'found my favorite cafes through this crew.',
          byName: 'Kabir',
          byAvatarUrl: 'https://i.pravatar.cc/100?img=15',
        ),
      ],
    ),
    Community(
      id: 'c4',
      name: 'Raipur Runners',
      description: 'Morning runs at Marine Drive and Naya Raipur.',
      coverUrl: 'https://picsum.photos/seed/hatri-runners/800/500',
      memberCount: 560,
      emoji: '🏃‍♂️',
      type: CommunityType.interest,
      hostId: 'cr2',
      location: 'Marine Drive',
      memberAvatars: _sample([3, 6, 1, 4]),
      hostedWeekly: const HostedWeekly(
        dayLabel: 'SUNDAYS',
        timeLabel: '6:00 AM',
        venueLabel: 'MARINE DRIVE · TELIBANDHA',
        description: '5km loop, all paces welcome',
      ),
      vibeTags: const ['🌅 morning people', '🏃 all paces', '🎧 no phones'],
      eventsThisMonth: 4,
      rating: 4.8,
      reviewCount: 62,
      newMembersThisWeek: 3,
      firstTimerGuide: const FirstTimerGuide(
        whatToExpect: [
          "meet at parking gate 5:55am sharp",
          "5km loop, walk if you need to",
          "we regroup at the end, no one runs alone",
        ],
        dressVibe: 'anything you can run in',
        whatToBring: ['water bottle', 'a jacket for after'],
        soloFriendly: true,
        soloLastTime: 8,
      ),
      memberVibes: [
        MemberVibe(
          quote: "showed up once. now i can't miss it.",
          byName: 'Sana',
          byAvatarUrl: 'https://i.pravatar.cc/100?img=41',
        ),
        MemberVibe(
          quote: 'zero pressure, all pace. love this crew.',
          byName: 'Arjun',
          byAvatarUrl: 'https://i.pravatar.cc/100?img=8',
        ),
      ],
      wallPhotos: [
        ..._wallBulk(
          prefix: 'runners-marine',
          count: 7,
          eventTitle: 'Sunday Run · Marine Drive',
          daysAgoStart: 4,
          byIdxRotation: const [3, 6, 1, 4],
          captions: const ["5k done, chai earned", 'sunrise crew showed up', 'no phones, all vibes'],
        ),
        ..._wallBulk(
          prefix: 'runners-naya',
          count: 6,
          eventTitle: 'Naya Raipur Loop',
          daysAgoStart: 11,
          byIdxRotation: const [1, 4, 3, 6],
          captions: const ['fastest 5k so far', 'sneha brought new shoes', 'post-run chai squad'],
        ),
        ..._wallBulk(
          prefix: 'runners-hills',
          count: 5,
          eventTitle: 'Hill Trail Special',
          daysAgoStart: 20,
          byIdxRotation: const [6, 3, 4],
          captions: const ['toughest run this month', 'legs still crying', 'view >>>'],
        ),
      ],
      weeklyDrop: CommunityDrop(
        id: 'dr1',
        hostName: 'Sana',
        hostAvatarUrl: 'https://i.pravatar.cc/100?img=41',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        headline: "THIS SUNDAY: EASY 5K, POST-RUN CHAI",
        body: "Rain forecast dropped to 10%. We're on. Meet at the parking gate 5:55am. Sneha's bringing tape for anyone with sore knees.",
      ),
      chatterEnabled: true,
      chatter: [
        _chat(id: 'chr1', byIdx: 1, text: 'rain today?', hoursAgo: 5),
        _chat(id: 'chr2', byIdx: 4, text: 'no, we running', hoursAgo: 5),
        _chat(id: 'chr3', byIdx: 3, text: 'bring extra water', hoursAgo: 3),
      ],
    ),

    // 🎓 COLLEGE
    Community(
      id: 'c9',
      name: 'The Study Sesh',
      description: 'college kids, deadline warriors, chai + notes crew.',
      coverUrl: 'https://picsum.photos/seed/hatri-studysesh/800/500',
      memberCount: 1100,
      emoji: '📚',
      type: CommunityType.college,
      location: 'Raipur',
      memberAvatars: _sample([3, 0, 6, 5]),
      eventsThisMonth: 2,
      rating: 4.4,
      reviewCount: 34,
      newMembersThisWeek: 7,
      firstTimerGuide: const FirstTimerGuide(
        whatToExpect: [
          "study together, take chai breaks, actually get work done",
          "usually at cafes around civil lines",
          "vibe is silent-but-together, not chatty",
        ],
        dressVibe: 'chill · loungewear energy',
        whatToBring: ['laptop', 'notes', 'headphones'],
        soloFriendly: true,
        soloLastTime: 10,
      ),
      memberVibes: [
        MemberVibe(
          quote: 'the only way i finish assignments.',
          byName: 'Ishita',
          byAvatarUrl: 'https://i.pravatar.cc/100?img=45',
        ),
      ],
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
