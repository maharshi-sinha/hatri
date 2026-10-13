class ApiCity {
  final String slug;
  final String name;
  final String state;
  final bool active;
  final String timezone;
  final double? latitude;
  final double? longitude;

  const ApiCity({
    required this.slug,
    required this.name,
    required this.state,
    required this.active,
    required this.timezone,
    required this.latitude,
    required this.longitude,
  });

  factory ApiCity.fromJson(Map<String, dynamic> json) => ApiCity(
        slug: json['slug'] as String,
        name: json['name'] as String,
        state: json['state'] as String,
        active: json['active'] as bool? ?? false,
        timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}
