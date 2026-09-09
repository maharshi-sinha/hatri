import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// ─── Enums ────────────────────────────────────────────────────────────────

enum MakerStatus {
  takingBookings,   // lime — accepting inquiries
  slotsFull,        // fuchsia — booked out
  backOnDate,       // muted — on a break, returning
  droppingSoon,     // yellow — next drop teased
}

enum BookingChannel { whatsapp, instagram, inApp }

// ─── Review ────────────────────────────────────────────────────────────────

class Review {
  final String authorName;
  final String? authorAvatar;
  final double rating;       // 0..5, half-star granularity supported
  final String text;
  final DateTime date;

  const Review({
    required this.authorName,
    this.authorAvatar,
    required this.rating,
    required this.text,
    required this.date,
  });
}

// ─── Maker ─────────────────────────────────────────────────────────────────

class Maker {
  final String id;
  final String name;
  final String handle;              // "@sourdough_ash"
  final String tagline;             // one line, Gen Z voice
  final String bio;                 // longer, editorial length

  final String primaryTag;          // shown as the big chip on the card
  final List<String> tags;          // includes primaryTag; used for search + THE LIST

  final String portrait;            // hero image (URL or asset)
  final List<String> portfolio;     // 4-6 images

  final String priceBand;           // "₹1.5k-3k" · optional feeling
  final String neighborhood;        // Shankar Nagar, Purani Basti, etc.

  final MakerStatus status;
  final String? statusHint;         // "Weekend slots open" · "Back Monday" · "Drops Saturday"

  final BookingChannel bookingChannel;
  final String bookingHandle;       // phone (for WhatsApp) or IG handle

  final bool verified;
  final DateTime joinedAt;

  final double rating;       // 0..5
  final int reviewCount;
  final List<Review> reviews;

  const Maker({
    required this.id,
    required this.name,
    required this.handle,
    required this.tagline,
    required this.bio,
    required this.primaryTag,
    required this.tags,
    required this.portrait,
    required this.portfolio,
    required this.priceBand,
    required this.neighborhood,
    required this.status,
    this.statusHint,
    required this.bookingChannel,
    required this.bookingHandle,
    this.verified = false,
    required this.joinedAt,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.reviews = const [],
  });

  Color get statusColor {
    switch (status) {
      case MakerStatus.takingBookings:
        return AppColors.lime;
      case MakerStatus.slotsFull:
        return AppColors.fuchsia;
      case MakerStatus.backOnDate:
        return AppColors.muted;
      case MakerStatus.droppingSoon:
        return AppColors.accentYellow;
    }
  }

  String get statusLabel {
    switch (status) {
      case MakerStatus.takingBookings:
        return 'TAKING BOOKINGS';
      case MakerStatus.slotsFull:
        return 'SLOTS FULL';
      case MakerStatus.backOnDate:
        return statusHint?.toUpperCase() ?? 'ON A BREAK';
      case MakerStatus.droppingSoon:
        return statusHint?.toUpperCase() ?? 'DROPS SOON';
    }
  }
}

// ─── THE LIST · themed editorial cluster ──────────────────────────────────

class TheList {
  final String id;
  final String theme;               // "MONSOON MODE"
  final String blurb;               // editorial one-liner
  final Color accent;               // hero card accent color
  final List<String> makerIds;      // ordered

  const TheList({
    required this.id,
    required this.theme,
    required this.blurb,
    required this.accent,
    required this.makerIds,
  });
}

// ─── Hero carousel item ───────────────────────────────────────────────────

enum HeroType { weekDrop, theList, sceneOfTheWeek, cityMoment }

class HeroCard {
  final HeroType type;
  final Color accent;
  final String eyebrow;             // "NEW · THIS WEEK IN HATRI"
  final String title;               // "RAIPUR\nGATHERS"
  final String subtitle;            // shorter blurb
  final String cta;                 // "SEE THE DROP"
  final String? payloadId;          // list id / scene id / etc — resolved by tap handler

  const HeroCard({
    required this.type,
    required this.accent,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.cta,
    this.payloadId,
  });
}

// ─── Seed data ────────────────────────────────────────────────────────────

class AppMakers {
  AppMakers._();

  static final List<Maker> all = [
    Maker(
      id: 'm-kavya',
      name: 'Kavya',
      handle: '@kavya.makeup',
      tagline: 'glossy party looks. main character energy.',
      bio: 'freelance mua working out of Shankar Nagar. specialise in editorial, weddings, and that one friend who wants "clean girl but louder".',
      primaryTag: 'MUA',
      tags: ['mua', 'makeup', 'weddings', 'editorial'],
      portrait: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1596704017254-9b121068fb31?w=800',
        'https://images.unsplash.com/photo-1522337660859-02fbefca4702?w=800',
        'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=800',
        'https://images.unsplash.com/photo-1552693673-1bf958298935?w=800',
      ],
      priceBand: '₹1.5k-3k',
      neighborhood: 'Shankar Nagar',
      status: MakerStatus.takingBookings,
      statusHint: 'weekend slots open',
      bookingChannel: BookingChannel.whatsapp,
      bookingHandle: '919876500001',
      verified: true,
      joinedAt: DateTime(2026, 8, 12),
      rating: 4.8,
      reviewCount: 47,
      reviews: [
        Review(
          authorName: 'ananya',
          rating: 5.0,
          text: 'showed up 20 min early and completely got my vision. glazed reception look for a friend\'s wedding. everyone asked who did it.',
          date: DateTime(2026, 9, 2),
        ),
        Review(
          authorName: 'priya',
          rating: 5.0,
          text: 'she reads a mood board like she wrote it. clean, fast, no crashing at the after party.',
          date: DateTime(2026, 8, 20),
        ),
        Review(
          authorName: 'nikita',
          rating: 4.0,
          text: 'gorgeous look but ran 30 min late. still worth it. would rebook.',
          date: DateTime(2026, 8, 5),
        ),
      ],
    ),
    Maker(
      id: 'm-sourdough-ash',
      name: 'Sourdough Ash',
      handle: '@sourdough_ash',
      tagline: 'saturday loaves. bake schedule runs the week.',
      bio: 'home baker. sourdough, focaccia, occasional cinnamon rolls. preorders open every wednesday.',
      primaryTag: 'BAKER',
      tags: ['baker', 'sourdough', 'home chef', 'weekend drops'],
      portrait: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=800',
        'https://images.unsplash.com/photo-1571167530149-c72f2b6ded31?w=800',
        'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=800',
        'https://images.unsplash.com/photo-1509365465985-25d11c17e812?w=800',
      ],
      priceBand: '₹300-800',
      neighborhood: 'Devendra Nagar',
      status: MakerStatus.droppingSoon,
      statusHint: 'drops Saturday · preorder by Friday',
      bookingChannel: BookingChannel.whatsapp,
      bookingHandle: '919876500002',
      joinedAt: DateTime(2026, 7, 3),
      rating: 4.9,
      reviewCount: 32,
      reviews: [
        Review(
          authorName: 'ishaan',
          rating: 5.0,
          text: 'best sourdough i\'ve had outside a bakery. crust is legit. preorder friday, thank me saturday.',
          date: DateTime(2026, 8, 30),
        ),
        Review(
          authorName: 'meera',
          rating: 5.0,
          text: 'ordered the focaccia rosemary loaf twice in one month. sending help.',
          date: DateTime(2026, 8, 15),
        ),
      ],
    ),
    Maker(
      id: 'm-ink-ridhi',
      name: 'Ink by Ridhi',
      handle: '@inkbyridhi',
      tagline: 'fine-line tattoos. tiny, meaningful, no filler.',
      bio: 'tattoo artist. minimalist fine-line only. studio hours by appointment, no walk-ins.',
      primaryTag: 'TATTOO',
      tags: ['tattoo', 'fine-line', 'minimal'],
      portrait: 'https://images.unsplash.com/photo-1568515387631-8b650bbcdb90?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1611501275019-9b5cda994e8d?w=800',
        'https://images.unsplash.com/photo-1568516387631-8b650bbcdb90?w=800',
        'https://images.unsplash.com/photo-1550537687-c91efd94ee75?w=800',
        'https://images.unsplash.com/photo-1560707303-4e980ce876ad?w=800',
      ],
      priceBand: '₹2k+',
      neighborhood: 'Telibandha',
      status: MakerStatus.slotsFull,
      statusHint: 'booked till November',
      bookingChannel: BookingChannel.instagram,
      bookingHandle: 'inkbyridhi',
      verified: true,
      joinedAt: DateTime(2026, 5, 20),
      rating: 4.7,
      reviewCount: 63,
      reviews: [
        Review(
          authorName: 'kabir',
          rating: 5.0,
          text: 'wanted something small and specific. she pushed back on the placement, was right. healed perfect.',
          date: DateTime(2026, 8, 28),
        ),
        Review(
          authorName: 'sana',
          rating: 4.0,
          text: 'clean studio, careful work, no small talk. exactly what i wanted.',
          date: DateTime(2026, 7, 12),
        ),
      ],
    ),
    Maker(
      id: 'm-tara-knits',
      name: 'Tara Knits',
      handle: '@tara.knits',
      tagline: 'handmade sweaters. one-of-one drops.',
      bio: 'chunky knits for people who care. drops of 5-6 pieces every fortnight. no restocks.',
      primaryTag: 'KNITTING',
      tags: ['knitting', 'fashion', 'handmade', 'weekend drops'],
      portrait: 'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1583744946564-b52ac1c389c8?w=800',
        'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=800',
        'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800',
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800',
      ],
      priceBand: '₹2.5k-6k',
      neighborhood: 'Shankar Nagar',
      status: MakerStatus.droppingSoon,
      statusHint: 'next drop · Sunday 8pm',
      bookingChannel: BookingChannel.instagram,
      bookingHandle: 'tara.knits',
      joinedAt: DateTime(2026, 6, 10),
      rating: 4.6,
      reviewCount: 21,
      reviews: [
        Review(
          authorName: 'aisha',
          rating: 5.0,
          text: 'the chunky sweater i got last drop is going into rotation this winter. one-of-one for real.',
          date: DateTime(2026, 8, 22),
        ),
      ],
    ),
    Maker(
      id: 'm-riya-tarot',
      name: 'Riya · Tarot',
      handle: '@riya.reads',
      tagline: "reads that hit. no love bombing, no doom.",
      bio: 'tarot + oracle. 30-min sessions on video or in-person. weekly slots posted every monday.',
      primaryTag: 'TAROT',
      tags: ['tarot', 'wellness', 'readings'],
      portrait: 'https://images.unsplash.com/photo-1519074002996-a69e7ac46a42?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1633158829999-0d1c3a4f6f9d?w=800',
        'https://images.unsplash.com/photo-1512446733611-9099a758e63c?w=800',
        'https://images.unsplash.com/photo-1512418490979-92798cec1380?w=800',
        'https://images.unsplash.com/photo-1517430816045-df4b7de11d1d?w=800',
      ],
      priceBand: '₹800/session',
      neighborhood: 'Purani Basti',
      status: MakerStatus.takingBookings,
      statusHint: 'slots open · monday post',
      bookingChannel: BookingChannel.whatsapp,
      bookingHandle: '919876500003',
      joinedAt: DateTime(2026, 4, 2),
      rating: 4.9,
      reviewCount: 89,
      reviews: [
        Review(
          authorName: 'diya',
          rating: 5.0,
          text: 'no fluff, no scare tactics. she just tells you what she sees. bookmarking her weekly.',
          date: DateTime(2026, 8, 30),
        ),
        Review(
          authorName: 'rhea',
          rating: 5.0,
          text: 'went in a mess, left with a game plan. the girl is real.',
          date: DateTime(2026, 8, 10),
        ),
      ],
    ),
    Maker(
      id: 'm-home-chef-neha',
      name: 'Neha ki Rasoi',
      handle: '@nehakirasoi',
      tagline: 'ghar ka khaana. lunch dabbas + weekend thalis.',
      bio: 'home chef. daily tiffin service in Pandri + Shankar Nagar. weekend thali menus posted friday.',
      primaryTag: 'HOME CHEF',
      tags: ['home chef', 'tiffin', 'thali'],
      portrait: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=800',
        'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=800',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800',
        'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=800',
      ],
      priceBand: '₹120/dabba',
      neighborhood: 'Pandri',
      status: MakerStatus.takingBookings,
      statusHint: 'monthly tiffin waitlist open',
      bookingChannel: BookingChannel.whatsapp,
      bookingHandle: '919876500004',
      joinedAt: DateTime(2026, 3, 15),
      rating: 4.8,
      reviewCount: 128,
      reviews: [
        Review(
          authorName: 'aarti',
          rating: 5.0,
          text: 'flavors like my nani\'s kitchen. the sambar alone is worth the monthly plan.',
          date: DateTime(2026, 9, 1),
        ),
        Review(
          authorName: 'vishal',
          rating: 5.0,
          text: 'ate every meal from her tiffin for a month. never once got bored.',
          date: DateTime(2026, 7, 24),
        ),
      ],
    ),
    Maker(
      id: 'm-mishika-tutor',
      name: 'Mishika · Maths',
      handle: '@mishika.tutors',
      tagline: 'class 8-12 maths. no rote, just clarity.',
      bio: 'home tutor. 4 years teaching. small batches or 1-on-1. board + jee foundation.',
      primaryTag: 'HOME TUTOR',
      tags: ['home tutor', 'maths', 'boards', 'jee'],
      portrait: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800',
        'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=800',
      ],
      priceBand: '₹1.5k/month',
      neighborhood: 'Devendra Nagar',
      status: MakerStatus.takingBookings,
      statusHint: 'summer batch enrolling',
      bookingChannel: BookingChannel.whatsapp,
      bookingHandle: '919876500005',
      joinedAt: DateTime(2026, 2, 8),
      rating: 4.7,
      reviewCount: 54,
      reviews: [
        Review(
          authorName: 'ananya',
          rating: 5.0,
          text: 'she doesn\'t make you feel dumb. rare in tutors. my grades went up in one term.',
          date: DateTime(2026, 8, 18),
        ),
      ],
    ),
    Maker(
      id: 'm-arya-portraits',
      name: 'Arya draws you',
      handle: '@arya.portraits',
      tagline: 'commissioned portraits. graphite + digital.',
      bio: 'portrait artist. couples, pets, that one photo you love but never framed. turnaround 5-7 days.',
      primaryTag: 'PORTRAIT ARTIST',
      tags: ['portrait artist', 'illustration', 'commission', 'gifts'],
      portrait: 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1544967082-d9d25d867d66?w=800',
        'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800',
        'https://images.unsplash.com/photo-1547891654-e66ed7ebb968?w=800',
        'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800',
      ],
      priceBand: '₹1.2k-4k',
      neighborhood: 'Marine Drive',
      status: MakerStatus.takingBookings,
      statusHint: 'delivering by month-end',
      bookingChannel: BookingChannel.instagram,
      bookingHandle: 'arya.portraits',
      joinedAt: DateTime(2026, 7, 22),
      rating: 4.9,
      reviewCount: 38,
      reviews: [
        Review(
          authorName: 'sameer',
          rating: 5.0,
          text: 'commissioned a couple\'s portrait for an anniversary. delivered early. framed and everything. cried a little.',
          date: DateTime(2026, 8, 25),
        ),
      ],
    ),
    Maker(
      id: 'm-nails-by-simran',
      name: 'Nails by Simran',
      handle: '@nailsbysimran',
      tagline: 'gel, extensions, glazed donut. picky welcome.',
      bio: 'home studio in Telibandha. 90-min sessions. designs from your reference or my mood board.',
      primaryTag: 'NAIL ARTIST',
      tags: ['nail artist', 'gel', 'extensions'],
      portrait: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1610992015732-2449b0dd2b8f?w=800',
        'https://images.unsplash.com/photo-1595475207225-428b62bda831?w=800',
        'https://images.unsplash.com/photo-1607779097040-26e80aa78e66?w=800',
        'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?w=800',
      ],
      priceBand: '₹900-1.8k',
      neighborhood: 'Telibandha',
      status: MakerStatus.takingBookings,
      statusHint: 'saturday only',
      bookingChannel: BookingChannel.whatsapp,
      bookingHandle: '919876500006',
      joinedAt: DateTime(2026, 6, 30),
      rating: 4.8,
      reviewCount: 71,
      reviews: [
        Review(
          authorName: 'kavya',
          rating: 5.0,
          text: 'glazed donut set lasted 3 weeks. she picked up the ref immediately, no back and forth.',
          date: DateTime(2026, 8, 29),
        ),
      ],
    ),
    Maker(
      id: 'm-thrift-basement',
      name: 'The Basement',
      handle: '@basement.thrift',
      tagline: 'curated y2k thrift. drops every other weekend.',
      bio: 'thrift + reworks. denim, tees, one-off pieces. drops go live sunday 8pm on story.',
      primaryTag: 'THRIFT',
      tags: ['thrift', 'y2k', 'fashion', 'weekend drops'],
      portrait: 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
        'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=800',
        'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800',
        'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=800',
      ],
      priceBand: '₹250-1.5k',
      neighborhood: 'Marine Drive',
      status: MakerStatus.droppingSoon,
      statusHint: 'next drop · sunday 8pm',
      bookingChannel: BookingChannel.instagram,
      bookingHandle: 'basement.thrift',
      joinedAt: DateTime(2026, 5, 5),
      rating: 4.6,
      reviewCount: 42,
      reviews: [
        Review(
          authorName: 'aditi',
          rating: 5.0,
          text: 'the drops move FAST. got a mesh top last month and it lives on my rotation. never restocks so save the story.',
          date: DateTime(2026, 8, 17),
        ),
      ],
    ),
    Maker(
      id: 'm-decor-vidhi',
      name: 'Vidhi · home decor',
      handle: '@vidhi.decorates',
      tagline: 'small space glow-ups. renter-friendly.',
      bio: 'home decor consultant. one-room refresh, weekend styling, or full house. i shop with you or for you.',
      primaryTag: 'HOME DECOR',
      tags: ['home decor', 'styling', 'renter friendly'],
      portrait: 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800',
        'https://images.unsplash.com/photo-1615873968403-89e068629265?w=800',
        'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=800',
        'https://images.unsplash.com/photo-1616486788371-62d930495c44?w=800',
      ],
      priceBand: '₹3k+',
      neighborhood: 'Shankar Nagar',
      status: MakerStatus.takingBookings,
      statusHint: 'weekday visits open',
      bookingChannel: BookingChannel.whatsapp,
      bookingHandle: '919876500007',
      joinedAt: DateTime(2026, 8, 1),
      rating: 4.7,
      reviewCount: 19,
      reviews: [
        Review(
          authorName: 'meher',
          rating: 5.0,
          text: 'refreshed one room in one saturday. worked with what i already had, didn\'t push me to buy things.',
          date: DateTime(2026, 8, 26),
        ),
      ],
    ),
    Maker(
      id: 'm-candle-luma',
      name: 'Luma Candles',
      handle: '@luma.candles',
      tagline: 'soy wax, weird scents. try the "wet grass".',
      bio: 'small-batch candles. natural soy, hand-poured, weekly limited scents. no reeds.',
      primaryTag: 'CANDLE MAKER',
      tags: ['candle maker', 'handmade', 'gifts'],
      portrait: 'https://images.unsplash.com/photo-1602874801007-aa5e7f8f9db1?w=800',
      portfolio: [
        'https://images.unsplash.com/photo-1608181831718-c9ffd8728105?w=800',
        'https://images.unsplash.com/photo-1602874801126-b39e6a7f9c8e?w=800',
        'https://images.unsplash.com/photo-1603006905003-9ea2c88f7c73?w=800',
        'https://images.unsplash.com/photo-1608571422999-96e2b3e0a80e?w=800',
      ],
      priceBand: '₹450-900',
      neighborhood: 'Devendra Nagar',
      status: MakerStatus.backOnDate,
      statusHint: 'back monday',
      bookingChannel: BookingChannel.instagram,
      bookingHandle: 'luma.candles',
      joinedAt: DateTime(2026, 4, 18),
      rating: 4.5,
      reviewCount: 27,
      reviews: [
        Review(
          authorName: 'shreya',
          rating: 5.0,
          text: 'wet grass is a real scent and i can\'t explain why it works. house smells like a good day.',
          date: DateTime(2026, 7, 30),
        ),
      ],
    ),
  ];

  static Maker byId(String id) => all.firstWhere((m) => m.id == id);

  static List<Maker> takingBookings() =>
      all.where((m) => m.status == MakerStatus.takingBookings).toList();

  static List<Maker> byTag(String tag) =>
      all.where((m) => m.tags.contains(tag)).toList();

  static List<Maker> byNeighborhood(String hood) =>
      all.where((m) => m.neighborhood == hood).toList();

  /// Editorial ranking. Interleaves NEW makers (joined ≤ 10.5 days ago) with
  /// HIGH-RATED makers (≥4.5★), then the rest. Prevents both the "old money
  /// hogs the top" problem and the "algorithm surfaces the same 3 people"
  /// problem. New-biz boost expires after 1.5 weeks; they merge into normal.
  static List<Maker> prioritized({List<Maker>? pool, int? limit, DateTime? now}) {
    final source = pool ?? all;
    final today = now ?? DateTime(2026, 9, 8);
    const boostWindowDays = 10; // ~1.5 weeks
    const highRating = 4.5;

    final boostable = <Maker>[];
    final rated = <Maker>[];
    final rest = <Maker>[];

    for (final m in source) {
      final ageDays = today.difference(m.joinedAt).inDays;
      if (ageDays <= boostWindowDays) {
        boostable.add(m);
      } else if (m.rating >= highRating) {
        rated.add(m);
      } else {
        rest.add(m);
      }
    }

    // Newest first inside the boost bucket; highest-rated first inside rated.
    boostable.sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
    rated.sort((a, b) => b.rating.compareTo(a.rating));

    // Interleave boostable + rated so a fresh maker never sits next to another
    // fresh maker in a row. Falls back cleanly when either bucket runs out.
    final interleaved = <Maker>[];
    int i = 0, j = 0;
    while (i < boostable.length || j < rated.length) {
      if (i < boostable.length) interleaved.add(boostable[i++]);
      if (j < rated.length) interleaved.add(rated[j++]);
    }
    interleaved.addAll(rest);

    if (limit != null && limit < interleaved.length) {
      return interleaved.sublist(0, limit);
    }
    return interleaved;
  }

  /// Returns every maker whose tag list intersects the category's tag set.
  static List<Maker> byCategory(MakerCategory cat) => all
      .where((m) => m.tags.any((t) => cat.tags.contains(t.toLowerCase())))
      .toList();
}

// ─── Umbrella categories ───────────────────────────────────────────────────

/// Umbrella grouping for filtering the maker grid. Individual tags (like
/// "sourdough", "gel", "maths") live on the Maker model; a category maps
/// many tags to one filter chip, so BAKER + HOME CHEF both sit under FOOD.
class MakerCategory {
  final String label;
  final Set<String> tags;
  const MakerCategory({required this.label, required this.tags});
}

// ─── Weekly issue (city page hook) ─────────────────────────────────────────

/// A weekly magazine-style cut of Raipur makers. Rotates every Friday. Prevents
/// the city page from feeling like an infinite grid — you see THIS week's cut,
/// not everyone at once.
class WeeklyIssue {
  final int weekNumber;
  final int year;
  final String title;         // 2 lines, Clash-friendly, no wasted words
  final String blurb;         // one-liner
  final Color accent;
  final Color shadowAccent;
  final List<String> makerIds; // 5-7 curated

  const WeeklyIssue({
    required this.weekNumber,
    required this.year,
    required this.title,
    required this.blurb,
    required this.accent,
    required this.shadowAccent,
    required this.makerIds,
  });
}

class AppWeeklyIssue {
  AppWeeklyIssue._();

  static const WeeklyIssue current = WeeklyIssue(
    weekNumber: 42,
    year: 2026,
    title: 'RAIPUR\nHANDPICKED.',
    blurb: 'six makers. one week. no algorithms, no ads.',
    accent: AppColors.lime,
    shadowAccent: AppColors.fuchsia,
    makerIds: [
      'm-kavya',
      'm-sourdough-ash',
      'm-riya-tarot',
      'm-tara-knits',
      'm-arya-portraits',
      'm-candle-luma',
    ],
  );
}

class AppMakerCategories {
  AppMakerCategories._();

  static const List<MakerCategory> all = [
    MakerCategory(label: 'FOOD', tags: {
      'baker', 'home chef', 'tiffin', 'sourdough', 'thali', 'cake', 'dabba',
    }),
    MakerCategory(label: 'BEAUTY', tags: {
      'mua', 'makeup', 'nail artist', 'gel', 'extensions',
      'hair', 'stylist', 'salon',
    }),
    MakerCategory(label: 'INK', tags: {
      'tattoo', 'fine-line', 'piercing', 'minimal',
    }),
    MakerCategory(label: 'TUTOR', tags: {
      'home tutor', 'coaching', 'maths', 'boards', 'jee',
      'guitar teacher', 'dance instructor', 'music teacher', 'classes',
    }),
    MakerCategory(label: 'ART', tags: {
      'portrait artist', 'illustration', 'photographer',
      'commission', 'gifts',
    }),
    MakerCategory(label: 'HOME', tags: {
      'home decor', 'styling', 'renter friendly', 'tailor', 'plants',
    }),
    MakerCategory(label: 'HANDMADE', tags: {
      'candle maker', 'knitting', 'thrift', 'y2k',
      'handmade', 'resin', 'pottery', 'fashion',
    }),
    MakerCategory(label: 'WELLNESS', tags: {
      'tarot', 'wellness', 'readings', 'yoga', 'therapy',
    }),
  ];
}

// ─── Seed neighborhoods ────────────────────────────────────────────────────

class AppRaipur {
  AppRaipur._();

  static const List<String> neighborhoods = [
    'Shankar Nagar',
    'Purani Basti',
    'Marine Drive',
    'Telibandha',
    'Devendra Nagar',
    'Pandri',
    'Byron Bazaar',
    'Amanaka',
  ];

  /// Curated tag chips shown on Home + City filter row. Rotates weekly in prod.
  static const List<String> featuredTags = [
    'MUA',
    'BAKER',
    'HOME CHEF',
    'HOME TUTOR',
    'TATTOO',
    'NAIL ARTIST',
    'TAROT',
    'PORTRAIT ARTIST',
    'HOME DECOR',
    'THRIFT',
  ];
}

// ─── Seed THE LIST ─────────────────────────────────────────────────────────

class AppLists {
  AppLists._();

  static final List<TheList> all = [
    TheList(
      id: 'list-monsoon',
      theme: 'MONSOON MODE',
      blurb: 'raipur makers doing their thing indoors. bake orders, tarot, tattoos, decor refresh.',
      accent: AppColors.indigo,
      makerIds: ['m-sourdough-ash', 'm-riya-tarot', 'm-ink-ridhi', 'm-decor-vidhi', 'm-candle-luma'],
    ),
    TheList(
      id: 'list-glow-up',
      theme: 'WEEKEND GLOW-UP',
      blurb: 'shortlist for looking like you tried without trying.',
      accent: AppColors.fuchsia,
      makerIds: ['m-kavya', 'm-nails-by-simran', 'm-thrift-basement'],
    ),
    TheList(
      id: 'list-saturday-drops',
      theme: 'SATURDAY DROPS',
      blurb: 'preorder friday. pick up saturday. no fomo.',
      accent: AppColors.lime,
      makerIds: ['m-sourdough-ash', 'm-tara-knits', 'm-thrift-basement'],
    ),
    TheList(
      id: 'list-shankar-nagar',
      theme: 'SHANKAR NAGAR THIS WEEK',
      blurb: 'everyone you can walk to.',
      accent: AppColors.accentYellow,
      makerIds: ['m-kavya', 'm-tara-knits', 'm-decor-vidhi'],
    ),
  ];

  static TheList byId(String id) => all.firstWhere((l) => l.id == id);
}

// ─── Seed HOME HERO carousel ──────────────────────────────────────────────

/// Default hero deck — all entity-neutral. Evergreen mood + cadence themes.
/// Location or business-specific cards should be pushed as ADMIN PROMO slots
/// (Phase 6 backend), not baked into the default rotation.
class AppHomeHero {
  AppHomeHero._();

  static const List<HeroCard> cards = [
    HeroCard(
      type: HeroType.weekDrop,
      accent: AppColors.lime,
      eyebrow: 'NEW · THIS WEEK IN HATRI',
      title: 'RAIPUR\nGATHERS',
      subtitle: 'Your weekly drop of the scene. Fests, open mics, club nights.',
      cta: 'SEE THE DROP',
    ),
    HeroCard(
      type: HeroType.theList,
      accent: AppColors.indigo,
      eyebrow: 'THE LIST · MONSOON MODE',
      title: 'STAY IN.\nBOOK OUT.',
      subtitle: "makers doing their thing indoors this week. thoughtful, not desperate.",
      cta: 'SEE THE LIST',
      payloadId: 'list-monsoon',
    ),
    HeroCard(
      type: HeroType.theList,
      accent: AppColors.fuchsia,
      eyebrow: 'THE LIST · NEW IN TOWN',
      title: 'FRESH\nDROPS.',
      subtitle: "just joined hatri. bakers, artists, tutors, one tarot reader.",
      cta: 'MEET THEM',
      payloadId: 'list-new-in-town',
    ),
    HeroCard(
      type: HeroType.theList,
      accent: AppColors.accentYellow,
      eyebrow: 'THE LIST · SATURDAY DROPS',
      title: 'PREORDER\nFRIDAY.',
      subtitle: "makers who drop on weekends. no fomo if you plan ahead.",
      cta: 'SEE THE LIST',
      payloadId: 'list-saturday-drops',
    ),
  ];
}
