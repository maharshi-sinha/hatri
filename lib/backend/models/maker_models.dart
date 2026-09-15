/// Shape embedded in event detail. Minimal maker preview.
class ApiMakerRef {
  final String id;
  final String slug;
  final String name;
  final String category;
  final String? logoUrl;
  final bool verified;

  const ApiMakerRef({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.logoUrl,
    required this.verified,
  });

  factory ApiMakerRef.fromJson(Map<String, dynamic> json) => ApiMakerRef(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        logoUrl: json['logoUrl'] as String?,
        verified: json['verified'] as bool? ?? false,
      );
}

/// Card returned by GET /makers.
class ApiMakerCard {
  final String id;
  final String slug;
  final String name;
  final String category;
  final String citySlug;
  final String? logoUrl;
  final int followerCount;
  final bool verified;
  final String tier;

  const ApiMakerCard({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.citySlug,
    required this.logoUrl,
    required this.followerCount,
    required this.verified,
    required this.tier,
  });

  factory ApiMakerCard.fromJson(Map<String, dynamic> json) => ApiMakerCard(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        citySlug: json['citySlug'] as String,
        logoUrl: json['logoUrl'] as String?,
        followerCount: json['followerCount'] as int? ?? 0,
        verified: json['verified'] as bool? ?? false,
        tier: json['tier'] as String? ?? 'FREE',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'category': category,
        'citySlug': citySlug,
        'logoUrl': logoUrl,
        'followerCount': followerCount,
        'verified': verified,
        'tier': tier,
      };
}

class ApiMakerFeed {
  final List<ApiMakerCard> items;
  final String? nextCursor;
  const ApiMakerFeed({required this.items, required this.nextCursor});
  factory ApiMakerFeed.fromJson(Map<String, dynamic> json) => ApiMakerFeed(
        items: (json['items'] as List<dynamic>? ?? const [])
            .map((e) => ApiMakerCard.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextCursor: json['nextCursor'] as String?,
      );
}

/// Detail returned by GET /makers/:id.
class ApiMakerDetail {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final String category;
  final String citySlug;
  final String? logoUrl;
  final String? whatsapp;
  final String? instagram;
  final double? latitude;
  final double? longitude;
  final String? addressText;
  final bool verified;
  final String tier;
  final int followerCount;
  final DateTime createdAt;

  const ApiMakerDetail({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.category,
    required this.citySlug,
    required this.logoUrl,
    required this.whatsapp,
    required this.instagram,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    required this.verified,
    required this.tier,
    required this.followerCount,
    required this.createdAt,
  });

  factory ApiMakerDetail.fromJson(Map<String, dynamic> json) => ApiMakerDetail(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        category: json['category'] as String,
        citySlug: json['citySlug'] as String,
        logoUrl: json['logoUrl'] as String?,
        whatsapp: json['whatsapp'] as String?,
        instagram: json['instagram'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        addressText: json['addressText'] as String?,
        verified: json['verified'] as bool? ?? false,
        tier: json['tier'] as String? ?? 'FREE',
        followerCount: json['followerCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class FollowResult {
  final bool ok;
  final int followerCount;
  const FollowResult({required this.ok, required this.followerCount});
  factory FollowResult.fromJson(Map<String, dynamic> json) => FollowResult(
        ok: json['ok'] as bool? ?? false,
        followerCount: json['followerCount'] as int? ?? 0,
      );
}
