/// DTO for a single marquee item returned by GET /api/v1/marquee.
class ApiMarqueeItem {
  final String id;
  final String text;
  final String? emoji;
  final int order;
  final String? citySlug;

  const ApiMarqueeItem({
    required this.id,
    required this.text,
    required this.emoji,
    required this.order,
    required this.citySlug,
  });

  factory ApiMarqueeItem.fromJson(Map<String, dynamic> json) => ApiMarqueeItem(
        id: json['id'] as String,
        text: json['text'] as String,
        emoji: json['emoji'] as String?,
        order: (json['order'] as num?)?.toInt() ?? 0,
        citySlug: json['citySlug'] as String?,
      );

  /// Rendered form the TickerWidget consumes. Prepends the emoji with a
  /// single space when present so `🔥 THIS WEEK IN HATRI:` is one token.
  String get display =>
      (emoji != null && emoji!.isNotEmpty) ? '$emoji $text' : text;
}
