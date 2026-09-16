import 'maker_models.dart';

/// Card shape returned by GET /events (discovery feed).
class ApiEventCard {
  final String id;
  final String slug;
  final String title;
  final String category;
  final String citySlug;
  final DateTime startAt;
  final String? venueName;
  final String? coverUrl;
  final int priceMin;
  final int priceMax;
  final int saves;
  final int popularityScore;

  const ApiEventCard({
    required this.id,
    required this.slug,
    required this.title,
    required this.category,
    required this.citySlug,
    required this.startAt,
    required this.venueName,
    required this.coverUrl,
    required this.priceMin,
    required this.priceMax,
    required this.saves,
    required this.popularityScore,
  });

  factory ApiEventCard.fromJson(Map<String, dynamic> json) => ApiEventCard(
        id: json['id'] as String,
        slug: json['slug'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        citySlug: json['citySlug'] as String,
        startAt: DateTime.parse(json['startAt'] as String),
        venueName: json['venueName'] as String?,
        coverUrl: json['coverUrl'] as String?,
        priceMin: json['priceMin'] as int? ?? 0,
        priceMax: json['priceMax'] as int? ?? 0,
        saves: json['saves'] as int? ?? 0,
        popularityScore: json['popularityScore'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'title': title,
        'category': category,
        'citySlug': citySlug,
        'startAt': startAt.toIso8601String(),
        'venueName': venueName,
        'coverUrl': coverUrl,
        'priceMin': priceMin,
        'priceMax': priceMax,
        'saves': saves,
        'popularityScore': popularityScore,
      };
}

class ApiEventFeed {
  final List<ApiEventCard> items;
  final String? nextCursor;

  const ApiEventFeed({required this.items, required this.nextCursor});

  factory ApiEventFeed.fromJson(Map<String, dynamic> json) => ApiEventFeed(
        items: (json['items'] as List<dynamic>? ?? const [])
            .map((e) => ApiEventCard.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextCursor: json['nextCursor'] as String?,
      );
}

/// Detail shape returned by GET /events/:id.
class ApiEventDetail {
  final String id;
  final String slug;
  final String title;
  final String? description;
  final String category;
  final String citySlug;
  final DateTime startAt;
  final DateTime? endAt;
  final String? venueName;
  final String? addressText;
  final double? latitude;
  final double? longitude;
  final String? coverUrl;
  final int priceMin;
  final int priceMax;
  final String currency;
  final String? externalRegisterUrl;
  final int? ageMin;
  final int? ageMax;
  final String status;
  final String moderationStatus;
  final int saves;
  final int shares;
  final int views;
  final int popularityScore;
  final int? capacity;
  final int ticketCount;
  final ApiMakerRef? maker;
  final DateTime createdAt;

  const ApiEventDetail({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.category,
    required this.citySlug,
    required this.startAt,
    required this.endAt,
    required this.venueName,
    required this.addressText,
    required this.latitude,
    required this.longitude,
    required this.coverUrl,
    required this.priceMin,
    required this.priceMax,
    required this.currency,
    required this.externalRegisterUrl,
    required this.ageMin,
    required this.ageMax,
    required this.status,
    required this.moderationStatus,
    required this.saves,
    required this.shares,
    required this.views,
    required this.popularityScore,
    required this.capacity,
    required this.ticketCount,
    required this.maker,
    required this.createdAt,
  });

  factory ApiEventDetail.fromJson(Map<String, dynamic> json) => ApiEventDetail(
        id: json['id'] as String,
        slug: json['slug'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        category: json['category'] as String,
        citySlug: json['citySlug'] as String,
        startAt: DateTime.parse(json['startAt'] as String),
        endAt: json['endAt'] == null
            ? null
            : DateTime.parse(json['endAt'] as String),
        venueName: json['venueName'] as String?,
        addressText: json['addressText'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        coverUrl: json['coverUrl'] as String?,
        priceMin: json['priceMin'] as int? ?? 0,
        priceMax: json['priceMax'] as int? ?? 0,
        currency: json['currency'] as String? ?? 'INR',
        externalRegisterUrl: json['externalRegisterUrl'] as String?,
        ageMin: json['ageMin'] as int?,
        ageMax: json['ageMax'] as int?,
        status: json['status'] as String,
        moderationStatus: json['moderationStatus'] as String,
        saves: json['saves'] as int? ?? 0,
        shares: json['shares'] as int? ?? 0,
        views: json['views'] as int? ?? 0,
        popularityScore: json['popularityScore'] as int? ?? 0,
        capacity: json['capacity'] as int?,
        ticketCount: json['ticketCount'] as int? ?? 0,
        maker: json['maker'] == null
            ? null
            : ApiMakerRef.fromJson(json['maker'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class SaveResult {
  final bool ok;
  final int saves;
  const SaveResult({required this.ok, required this.saves});
  factory SaveResult.fromJson(Map<String, dynamic> json) => SaveResult(
        ok: json['ok'] as bool? ?? false,
        saves: json['saves'] as int? ?? 0,
      );
}

class ReactResult {
  final bool ok;
  final bool reacted;
  const ReactResult({required this.ok, required this.reacted});
  factory ReactResult.fromJson(Map<String, dynamic> json) => ReactResult(
        ok: json['ok'] as bool? ?? false,
        reacted: json['reacted'] as bool? ?? false,
      );
}

class ShareResult {
  final bool ok;
  final int shares;
  const ShareResult({required this.ok, required this.shares});
  factory ShareResult.fromJson(Map<String, dynamic> json) => ShareResult(
        ok: json['ok'] as bool? ?? false,
        shares: json['shares'] as int? ?? 0,
      );
}
